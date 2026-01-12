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
          :src="getImageUrl(item.imgUrl)"
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

// 存储签名后的图片URL（使用Map以imgUrl为key，避免重复请求）
const signedUrlCache = new Map<string, string>()

// 获取图片URL（同步方法，返回缓存或原始URL）
const getImageUrl = (imgUrl: string | undefined): string => {
  if (!imgUrl) {
    return ''
  }
  
  // 如果URL已经是完整的http/https地址（可能是外部URL或已签名的URL），直接返回
  if (imgUrl.indexOf('http') === 0) {
    return imgUrl
  }
  
  // 检查缓存
  if (signedUrlCache.has(imgUrl)) {
    return signedUrlCache.get(imgUrl)!
  }
  
  // 如果缓存中没有，异步获取签名URL（但先返回原始URL，获取到后再更新）
  // 这样可以避免阻塞渲染
  loadSignedUrl(imgUrl)
  
  // 先返回原始URL，等签名URL获取到后会自动更新
  return imgUrl
}

// 异步加载签名URL
const loadSignedUrl = async (imgUrl: string) => {
  // 如果已经在加载中，跳过
  if (signedUrlCache.has(imgUrl)) {
    return
  }
  
  try {
    const signedUrl = await FileApi.getFileAccessUrl(imgUrl)
    if (signedUrl) {
      signedUrlCache.set(imgUrl, signedUrl)
      // 触发响应式更新
      // 注意：这里需要强制更新，因为Vue可能不会检测到Map的变化
      // 我们可以使用一个ref来触发更新
      updateTrigger.value++
    }
  } catch (error) {
    console.error('[Carousel] 获取签名URL失败:', imgUrl, error)
    // 即使失败，也缓存原始URL，避免重复请求
    signedUrlCache.set(imgUrl, imgUrl)
  }
}

// 用于触发响应式更新的触发器
const updateTrigger = ref(0)

// 监听items变化，预加载所有图片的签名URL
watch(
  () => props.property.items,
  (items) => {
    if (!items || items.length === 0) {
      return
    }
    
    // 并行获取所有图片的签名URL
    items.forEach((item) => {
      if (item.type === 'img' && item.imgUrl && item.imgUrl.indexOf('http') !== 0) {
        loadSignedUrl(item.imgUrl)
      }
    })
  },
  { immediate: true, deep: true }
)
</script>

<style scoped lang="scss"></style>
