<!-- 商品发布 - 物流设置 -->
<template>
  <el-form ref="formRef" :model="formData" :rules="rules" label-width="120px" :disabled="isDetail">
    <el-form-item label="配送方式" prop="deliveryTypes">
      <el-checkbox-group v-model="formData.deliveryTypes" class="w-full">
        <div class="flex flex-wrap gap-4">
          <el-checkbox
            v-for="dict in getIntDictOptions(DICT_TYPE.TRADE_DELIVERY_TYPE)"
            :key="dict.value"
            :value="dict.value"
            class="!mr-0"
          >
            <span class="font-medium">{{ dict.label }}</span>
          </el-checkbox>
        </div>
      </el-checkbox-group>
      <div class="mt-2 text-gray-500 text-sm">
        💡 提示：可选择多种配送方式，至少选择一种。选择"快递发货"时，需要配置运费模板。
      </div>
    </el-form-item>
    <el-form-item
      label="运费模板"
      prop="deliveryTemplateId"
      v-if="formData.deliveryTypes?.includes(DeliveryTypeEnum.EXPRESS.type)"
    >
      <el-select placeholder="请选择运费模板" v-model="formData.deliveryTemplateId" class="w-80">
        <el-option
          v-for="item in deliveryTemplateList"
          :key="item.id"
          :label="item.name"
          :value="item.id"
        />
      </el-select>
      <div class="mt-2 text-gray-500 text-sm">
        提示：选择快递发货时，必须配置运费模板
      </div>
    </el-form-item>
  </el-form>
</template>
<script lang="ts" setup>
import { PropType, computed, watch } from 'vue'
import { copyValueToTarget } from '@/utils'
import { propTypes } from '@/utils/propTypes'
import type { Spu } from '@/api/mall/product/spu'
import * as ExpressTemplateApi from '@/api/mall/trade/delivery/expressTemplate'
import type { DeliveryExpressTemplateVO } from '@/api/mall/trade/delivery/expressTemplate'
import { DICT_TYPE, getIntDictOptions } from '@/utils/dict'
import { DeliveryTypeEnum } from '@/utils/constants'
import { required } from '@/utils/formRules'

defineOptions({ name: 'ProductDeliveryForm' })

const message = useMessage() // 消息弹窗

const props = defineProps({
  propFormData: {
    type: Object as PropType<Spu>,
    default: () => {}
  },
  isDetail: propTypes.bool.def(false) // 是否作为详情组件
})
const formRef = ref() // 表单 Ref
const formData = reactive<Spu>({
  deliveryTypes: [], // 配送方式
  deliveryTemplateId: undefined // 运费模版
})

// 动态验证规则：运费模板只在选择快递发货时必填
const rules = computed(() => {
  const baseRules: any = {
    deliveryTypes: [required]
  }
  
  // 如果选择了快递发货，运费模板才是必填的
  if (formData.deliveryTypes?.includes(DeliveryTypeEnum.EXPRESS.type)) {
    baseRules.deliveryTemplateId = [required]
  } else {
    // 未选择快递发货时，移除必填验证（清空操作在 watch 中处理）
    baseRules.deliveryTemplateId = []
  }
  
  return baseRules
})

/** 将传进来的值赋值给 formData */
watch(
  () => props.propFormData,
  (data) => {
    if (!data) {
      return
    }
    copyValueToTarget(formData, data)
  },
  {
    immediate: true
  }
)

/** 监听配送方式变化，自动处理运费模板 */
watch(
  () => formData.deliveryTypes,
  (newTypes) => {
    // 如果取消选择快递发货，清空运费模板
    if (!newTypes?.includes(DeliveryTypeEnum.EXPRESS.type)) {
      formData.deliveryTemplateId = undefined
    }
    // 触发表单验证更新
    if (formRef.value) {
      formRef.value.clearValidate('deliveryTemplateId')
    }
  },
  { deep: true }
)

/** 表单校验 */
const emit = defineEmits(['update:activeName'])
const validate = async () => {
  if (!formRef) return
  try {
    await unref(formRef)?.validate()
    // 校验通过更新数据
    Object.assign(props.propFormData, formData)
  } catch (e) {
    message.error('【物流设置】不完善，请填写相关信息')
    emit('update:activeName', 'delivery')
    throw e // 目的截断之后的校验
  }
}
defineExpose({ validate })

/** 初始化 */
const deliveryTemplateList = ref<DeliveryExpressTemplateVO[]>([]) // 运费模版
onMounted(async () => {
  deliveryTemplateList.value = await ExpressTemplateApi.getSimpleTemplateList()
})
</script>
