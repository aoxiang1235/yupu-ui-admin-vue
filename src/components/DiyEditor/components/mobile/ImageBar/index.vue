<template>
  <!-- 无图片 -->
  <div class="h-50px flex items-center justify-center bg-gray-3" v-if="!property.imgUrl">
    <Icon icon="ep:picture" class="text-gray-8 text-30px!" />
  </div>
  <el-image class="min-h-30px" v-else :src="displayImgUrl" />
</template>
<script setup lang="ts">
import { ImageBarProperty } from './config'
import * as FileApi from '@/api/infra/file'

/** 图片展示 */
defineOptions({ name: 'ImageBar' })

const props = defineProps<{ property: ImageBarProperty }>()

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
      console.log('[ImageBar] 开始获取签名URL:', imgUrl)
      const signedUrl = await FileApi.getFileAccessUrl(imgUrl)
      console.log('[ImageBar] 获取签名URL成功:', signedUrl)
      
      if (signedUrl && typeof signedUrl === 'string') {
        displayImgUrl.value = signedUrl
      } else {
        console.warn('[ImageBar] 签名URL格式不正确，使用原始URL:', signedUrl)
        displayImgUrl.value = imgUrl
      }
    } catch (error) {
      console.error('[ImageBar] 获取签名URL失败:', imgUrl, error)
      displayImgUrl.value = imgUrl
    }
  },
  { immediate: true }
)
</script>

<style scoped lang="scss">
/* 图片 */
img {
  display: block;
  width: 100%;
  height: 100%;
}
</style>
