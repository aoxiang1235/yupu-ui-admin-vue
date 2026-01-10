<template>
  <ComponentContainerProperty v-model="formData.style">
    <el-form label-width="80px" :model="formData">
      <el-form-item label="店铺" prop="storeId">
        <el-select
          v-model="formData.storeId"
          placeholder="请选择店铺（留空显示第一个启用的店铺）"
          class="w-full"
          filterable
          remote
          :remote-method="queryStoreList"
          :loading="loading"
          clearable
        >
          <el-option
            v-for="store in stores"
            :key="store.id"
            :label="store.name"
            :value="store.id"
          >
            <div style="display: flex; justify-content: space-between; align-items: center">
              <span>{{ store.name }}</span>
              <span style="color: #999; font-size: 12px">{{ store.phone }}</span>
            </div>
          </el-option>
        </el-select>
      </el-form-item>
    </el-form>
  </ComponentContainerProperty>
</template>

<script setup lang="ts">
import { StoreCardProperty } from './config'
import { useVModel } from '@vueuse/core'
import * as DeliveryPickUpStoreApi from '@/api/mall/trade/delivery/pickUpStore'

// 店铺卡片属性面板
defineOptions({ name: 'StoreCardProperty' })

const props = defineProps<{ modelValue: StoreCardProperty }>()
const emit = defineEmits(['update:modelValue'])
const formData = useVModel(props, 'modelValue', emit)

// 店铺列表
const stores = ref<DeliveryPickUpStoreApi.DeliveryPickUpStoreVO[]>([])
// 加载中
const loading = ref(false)

// 查询店铺列表
const queryStoreList = async (name?: string) => {
  loading.value = true
  try {
    const { list } = await DeliveryPickUpStoreApi.getDeliveryPickUpStorePage({
      name,
      status: 0, // 只查询启用的店铺
      pageSize: 20
    })
    stores.value = list || []
  } catch (e) {
    console.error('查询店铺列表失败', e)
    stores.value = []
  } finally {
    loading.value = false
  }
}

// 初始化
onMounted(() => {
  queryStoreList()
})
</script>

<style scoped lang="scss"></style>

