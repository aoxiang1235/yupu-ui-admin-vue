<template>
  <div class="store-card-preview">
    <div class="store-header">
      <div class="store-logo" v-if="storeInfo?.logo">
        <img :src="storeInfo.logo" alt="店铺Logo" />
      </div>
      <div class="store-info">
        <div class="store-name">{{ storeInfo?.name || '店铺名称' }}</div>
        <div class="store-address" v-if="storeInfo">
          {{ (storeInfo.areaName || '') + (storeInfo.detailAddress ? (storeInfo.areaName ? ', ' : '') + storeInfo.detailAddress : '') }}
        </div>
      </div>
    </div>
    <div class="store-actions">
      <div class="action-btn phone-btn">
        <span class="icon">📞</span>
        <span>拨打电话</span>
      </div>
      <div class="action-btn address-btn">
        <span class="icon">📍</span>
        <span>查看地址</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { StoreCardProperty } from './config'
import * as DeliveryPickUpStoreApi from '@/api/mall/trade/delivery/pickUpStore'

/** 店铺卡片预览 */
defineOptions({ name: 'StoreCard' })
// 定义属性
const props = defineProps<{ property: StoreCardProperty }>()
// 店铺信息
const storeInfo = ref<DeliveryPickUpStoreApi.DeliveryPickUpStoreVO>()

// 加载店铺信息
const loadStoreInfo = async () => {
  if (!props.property.storeId) {
    // 如果没有指定 storeId，获取第一个启用的店铺
    try {
      const { list } = await DeliveryPickUpStoreApi.getDeliveryPickUpStorePage({ pageNo: 1, pageSize: 1, status: 0 })
      if (list && list.length > 0) {
        storeInfo.value = list[0]
      }
    } catch (e) {
      console.error('获取店铺信息失败', e)
    }
    return
  }

  try {
    storeInfo.value = await DeliveryPickUpStoreApi.getDeliveryPickUpStore(props.property.storeId)
  } catch (e) {
    console.error('获取店铺信息失败', e)
  }
}

watch(
  () => props.property.storeId,
  () => {
    loadStoreInfo()
  },
  { immediate: true }
)
</script>

<style scoped lang="scss">
.store-card-preview {
  padding: 16px;
  background: #fff;
  border-radius: 8px;
}

.store-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}

.store-logo {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  overflow: hidden;
  margin-right: 12px;
  background: #f5f5f5;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.store-info {
  flex: 1;
  min-width: 0;
}

.store-name {
  font-size: 16px;
  font-weight: 500;
  color: #333;
  margin-bottom: 8px;
}

.store-address {
  font-size: 14px;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.store-actions {
  display: flex;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
  gap: 8px;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 12px;
  border-radius: 8px;
  background: #f8f8f8;
  font-size: 12px;
  color: #666;

  .icon {
    font-size: 20px;
    margin-bottom: 4px;
  }
}

.phone-btn {
  .icon {
    color: #ff690d;
  }
}

.address-btn {
  .icon {
    color: #4a90e2;
  }
}
</style>

