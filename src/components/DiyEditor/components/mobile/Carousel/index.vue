<template>
  <!-- 无图片 -->
  <div
    class="h-250px flex items-center justify-center bg-gray-3"
    v-if="property.items.length === 0"
  >
    <Icon icon="tdesign:image" class="text-gray-8 text-120px!" />
  </div>
  <div v-else class="relative">
    <el-carousel
      :height="property.height + 'px'"
      :type="property.type === 'card' ? 'card' : ''"
      :autoplay="property.autoplay"
      :interval="property.interval * 1000"
      :indicator-position="property.indicator === 'number' ? 'none' : undefined"
      @change="handleIndexChange"
    >
      <el-carousel-item v-for="(item, index) in property.items" :key="index">
        <el-image 
          class="h-full w-full" 
          :src="getImageSrc(item.imgUrl)"
        />
      </el-carousel-item>
    </el-carousel>
    <div
      v-if="property.indicator === 'number'"
      class="absolute bottom-10px right-10px rounded-xl bg-black p-x-8px p-y-2px text-10px text-white opacity-40"
      >{{ currentIndex }} / {{ property.items.length }}</div
    >
  </div>
</template>
<script setup lang="ts">
import { CarouselProperty } from './config'
import * as FileApi from '@/api/infra/file'

/** 轮播图 */
defineOptions({ name: 'Carousel' })

const props = defineProps<{ property: CarouselProperty }>()

const currentIndex = ref(0)
const handleIndexChange = (index: number) => {
  currentIndex.value = index + 1
}

// 使用响应式对象存储签名后的图片URL（key: 原始URL, value: 签名URL）
const signedUrlMap = reactive<Record<string, string>>({})

// 正在加载中的URL集合（避免重复请求）
const loadingUrls = new Set<string>()

// 获取图片URL（computed方式，确保响应式更新）
const getImageSrc = (imgUrl: string | undefined): string => {
  if (!imgUrl) {
    return ''
  }
  
  // 如果URL已经是完整的http/https地址（可能是外部URL或已签名的URL），直接返回
  if (imgUrl.startsWith('http://') || imgUrl.startsWith('https://')) {
    return imgUrl
  }
  
  // 如果已经有签名URL，直接返回
  if (signedUrlMap[imgUrl]) {
    return signedUrlMap[imgUrl]
  }
  
  // 如果正在加载中，先返回原始URL
  if (!loadingUrls.has(imgUrl)) {
    loadSignedUrl(imgUrl)
  }
  
  // 先返回原始URL，等签名URL获取到后会自动更新（因为signedUrlMap是响应式的）
  return imgUrl
}

// 异步加载签名URL
const loadSignedUrl = async (imgUrl: string) => {
  // 如果已经在加载中或已有缓存，跳过
  if (loadingUrls.has(imgUrl) || signedUrlMap[imgUrl]) {
    return
  }
  
  loadingUrls.add(imgUrl)
  
  try {
    console.log('[Carousel] 开始获取签名URL:', imgUrl)
    const signedUrl = await FileApi.getFileAccessUrl(imgUrl)
    console.log('[Carousel] 获取签名URL成功:', signedUrl)
    
    if (signedUrl && typeof signedUrl === 'string') {
      // 使用响应式对象存储，Vue会自动检测到变化并重新渲染
      signedUrlMap[imgUrl] = signedUrl
    } else {
      // 如果返回的不是字符串，使用原始URL
      console.warn('[Carousel] 签名URL格式不正确，使用原始URL:', signedUrl)
      signedUrlMap[imgUrl] = imgUrl
    }
  } catch (error) {
    console.error('[Carousel] 获取签名URL失败:', imgUrl, error)
    // 即使失败，也使用原始URL，避免重复请求
    signedUrlMap[imgUrl] = imgUrl
  } finally {
    loadingUrls.delete(imgUrl)
  }
}

// 监听items变化，预加载所有图片的签名URL
watch(
  () => props.property.items,
  (items) => {
    if (!items || items.length === 0) {
      return
    }
    
    // 并行获取所有图片的签名URL
    items.forEach((item) => {
      if (item.type === 'img' && item.imgUrl && !item.imgUrl.startsWith('http')) {
        loadSignedUrl(item.imgUrl)
      }
    })
  },
  { immediate: true, deep: true }
)
</script>

<style scoped lang="scss"></style>
