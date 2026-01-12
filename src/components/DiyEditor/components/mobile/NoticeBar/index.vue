<template>
  <div
    class="flex items-center p-y-4px text-12px"
    :style="{ backgroundColor: property.backgroundColor, color: property.textColor }"
  >
    <el-image :src="displayIconUrl" class="h-18px" />
    <el-divider direction="vertical" />
    <el-carousel height="24px" direction="vertical" :autoplay="true" class="flex-1 p-r-8px">
      <el-carousel-item v-for="(item, index) in property.contents" :key="index">
        <div class="h-24px truncate leading-24px">{{ item.text }}</div>
      </el-carousel-item>
    </el-carousel>
    <Icon icon="ep:arrow-right" />
  </div>
</template>

<script setup lang="ts">
import { NoticeBarProperty } from './config'
import * as FileApi from '@/api/infra/file'

/** 公告栏 */
defineOptions({ name: 'NoticeBar' })

const props = defineProps<{ property: NoticeBarProperty }>()

// 用于显示的图标URL（响应式，确保Vue能检测到变化）
const displayIconUrl = ref<string>('')

// 监听iconUrl变化，获取签名URL
watch(
  () => props.property.iconUrl,
  async (iconUrl) => {
    if (!iconUrl) {
      displayIconUrl.value = ''
      return
    }
    
    // 如果URL已经是完整的http/https地址，直接使用
    if (iconUrl.startsWith('http://') || iconUrl.startsWith('https://')) {
      displayIconUrl.value = iconUrl
      return
    }
    
    // 先使用原始URL
    displayIconUrl.value = iconUrl
    
    // 异步获取签名URL
    try {
      console.log('[NoticeBar] 开始获取图标签名URL:', iconUrl)
      const signedUrl = await FileApi.getFileAccessUrl(iconUrl)
      console.log('[NoticeBar] 获取图标签名URL成功:', signedUrl)
      
      if (signedUrl && typeof signedUrl === 'string') {
        displayIconUrl.value = signedUrl
      } else {
        console.warn('[NoticeBar] 签名URL格式不正确，使用原始URL:', signedUrl)
        displayIconUrl.value = iconUrl
      }
    } catch (error) {
      console.error('[NoticeBar] 获取图标签名URL失败:', iconUrl, error)
      displayIconUrl.value = iconUrl
    }
  },
  { immediate: true }
)
</script>

<style scoped lang="scss"></style>
