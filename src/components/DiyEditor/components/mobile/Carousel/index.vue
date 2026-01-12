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
          :src="displayImgUrls[index] || item.imgUrl"
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

// 用于显示在轮播图中的图片URL列表（响应式数组，确保Vue能检测到变化）
const displayImgUrls = ref<string[]>([])

// 正在加载中的URL集合（避免重复请求）
const loadingUrls = new Set<string>()

// 异步加载签名URL并更新对应索引的URL
const loadSignedUrl = async (imgUrl: string, index: number) => {
  // 如果URL已经是完整的http/https地址，直接使用
  if (imgUrl.startsWith('http://') || imgUrl.startsWith('https://')) {
    displayImgUrls.value[index] = imgUrl
    return
  }
  
  // 如果已经在加载中，跳过
  if (loadingUrls.has(imgUrl)) {
    return
  }
  
  loadingUrls.add(imgUrl)
  
  try {
    console.log('[Carousel] 开始获取签名URL:', imgUrl, 'index:', index)
    const signedUrl = await FileApi.getFileAccessUrl(imgUrl)
    console.log('[Carousel] 获取签名URL成功:', signedUrl)
    
    if (signedUrl && typeof signedUrl === 'string') {
      // 更新响应式数组，Vue会自动检测到变化并重新渲染
      displayImgUrls.value[index] = signedUrl
    } else {
      // 如果返回的不是字符串，使用原始URL
      console.warn('[Carousel] 签名URL格式不正确，使用原始URL:', signedUrl)
      displayImgUrls.value[index] = imgUrl
    }
  } catch (error) {
    console.error('[Carousel] 获取签名URL失败:', imgUrl, error)
    // 即使失败，也使用原始URL
    displayImgUrls.value[index] = imgUrl
  } finally {
    loadingUrls.delete(imgUrl)
  }
}

// 监听items变化，为所有图片获取签名URL
watch(
  () => props.property.items,
  async (items) => {
    if (!items || items.length === 0) {
      displayImgUrls.value = []
      return
    }
    
    // 初始化数组，先使用原始URL
    displayImgUrls.value = items.map((item) => {
      const imgUrl = item.type === 'img' ? item.imgUrl : item.videoUrl
      // 如果已经是完整URL，直接使用
      if (imgUrl && (imgUrl.startsWith('http://') || imgUrl.startsWith('https://'))) {
        return imgUrl
      }
      // 否则先返回原始URL，后续异步更新
      return imgUrl || ''
    })
    
    // 并行获取所有图片的签名URL
    const promises = items.map(async (item, index) => {
      const imgUrl = item.type === 'img' ? item.imgUrl : item.videoUrl
      if (imgUrl && !imgUrl.startsWith('http')) {
        await loadSignedUrl(imgUrl, index)
      }
    })
    
    await Promise.all(promises)
  },
  { immediate: true, deep: true }
)
</script>

<style scoped lang="scss"></style>
