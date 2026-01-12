<template>
  <div class="relative h-full min-h-30px w-full">
    <el-image :src="displayImgUrl" class="pointer-events-none h-full w-full select-none" />
    <div
      v-for="(item, index) in property.list"
      :key="index"
      class="hot-zone"
      :style="{
        width: `${item.width}px`,
        height: `${item.height}px`,
        top: `${item.top}px`,
        left: `${item.left}px`
      }"
    >
      {{ item.name }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { HotZoneProperty } from './config'
import * as FileApi from '@/api/infra/file'

/** 热区 */
defineOptions({ name: 'HotZone' })
const props = defineProps<{ property: HotZoneProperty }>()

// 用于显示的图片URL（响应式，确保Vue能检测到变化）
const displayImgUrl = ref<string>('')

// 监听imgUrl变化，获取签名URL
watch(
  () => props.property.imgUrl,
  async (imgUrl) => {
    if (!imgUrl) {
      displayImgUrl.value = ''
      return
    }
    
    // 如果URL已经是完整的http/https地址，直接使用
    if (imgUrl.startsWith('http://') || imgUrl.startsWith('https://')) {
      displayImgUrl.value = imgUrl
      return
    }
    
    // 先使用原始URL
    displayImgUrl.value = imgUrl
    
    // 异步获取签名URL
    try {
      console.log('[HotZone] 开始获取签名URL:', imgUrl)
      const signedUrl = await FileApi.getFileAccessUrl(imgUrl)
      console.log('[HotZone] 获取签名URL成功:', signedUrl)
      
      if (signedUrl && typeof signedUrl === 'string') {
        displayImgUrl.value = signedUrl
      } else {
        console.warn('[HotZone] 签名URL格式不正确，使用原始URL:', signedUrl)
        displayImgUrl.value = imgUrl
      }
    } catch (error) {
      console.error('[HotZone] 获取签名URL失败:', imgUrl, error)
      displayImgUrl.value = imgUrl
    }
  },
  { immediate: true }
)
</script>

<style scoped lang="scss">
.hot-zone {
  position: absolute;
  background: var(--el-color-primary-light-7);
  opacity: 0.8;
  border: 1px solid var(--el-color-primary);
  color: var(--el-color-primary);
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: move;
  z-index: 10;
}
</style>
