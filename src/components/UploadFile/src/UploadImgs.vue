<!--
  多图片上传组件 (UploadImgs)
  
  功能说明：
  1. 支持多图片上传、预览、删除
  2. 支持拖拽上传
  3. 自动处理 COS 预签名 URL（存储原始 URL，显示签名 URL）
  4. 支持签名 URL 缓存，避免重复请求
  5. 支持禁用状态和自定义样式
  
  核心逻辑：
  - modelValue: 存储原始 URL 数组（用于表单提交）
  - fileList: 存储带签名的 URL（用于显示）
  - originalUrls: 维护原始 URL 列表，与 fileList 索引对应
  - signedUrlCache: 缓存原始 URL 到签名 URL 的映射
-->
<template>
  <!-- 上传容器 -->
  <div class="upload-box">
    <!-- Element Plus 上传组件 -->
    <el-upload
      v-model:file-list="fileList"
      :accept="fileType.join(',')"
      :action="uploadUrl"
      :before-upload="beforeUpload"
      :class="['upload', drag ? 'no-border' : '']"
      :disabled="disabled"
      :drag="drag"
      :http-request="httpRequest"
      :limit="limit"
      :multiple="true"
      :on-error="uploadError"
      :on-exceed="handleExceed"
      :on-success="uploadSuccess"
      list-type="picture-card"
    >
      <!-- 空状态插槽：上传按钮 -->
      <div class="upload-empty">
        <slot name="empty">
          <Icon icon="ep:plus" />
          <span>请上传图片</span>
        </slot>
      </div>
      <!-- 文件项插槽：图片预览和操作按钮 -->
      <template #file="{ file }">
        <img :src="file.url" class="upload-image" />
        <div class="upload-handle" @click.stop>
          <!-- 查看按钮 -->
          <div class="handle-icon" @click="imagePreview(file.url!)">
            <Icon icon="ep:zoom-in" />
            <span>查看</span>
          </div>
          <!-- 删除按钮（禁用状态下隐藏） -->
          <div v-if="!disabled" class="handle-icon" @click="handleRemove(file)">
            <Icon icon="ep:delete" />
            <span>删除</span>
          </div>
        </div>
      </template>
    </el-upload>
  </div>
</template>

<script lang="ts" setup>
// ==================== 导入依赖 ====================
import { ref, watch, nextTick } from 'vue'
import type { UploadFile, UploadProps, UploadUserFile } from 'element-plus'
import { ElNotification } from 'element-plus'
import { createImageViewer } from '@/components/ImageViewer'

import { propTypes } from '@/utils/propTypes'
import { useUpload } from '@/components/UploadFile/src/useUpload'
import * as FileApi from '@/api/infra/file'
import { useMessage } from '@/hooks/web/useMessage'

// ==================== 组件配置 ====================
defineOptions({ name: 'UploadImgs' })

// ==================== 签名 URL 缓存 ====================
// 缓存原始 URL 到签名 URL 的映射，避免重复请求
const signedUrlCache = new Map<string, string>()

// ==================== 工具函数 ====================
const message = useMessage() // 消息弹窗工具

/**
 * 图片预览功能
 * 功能：打开图片查看器，支持签名 URL 处理
 * @param imgUrl - 图片 URL（可能包含签名参数）
 */
const imagePreview = async (imgUrl: string) => {
  try {
    let previewUrl = imgUrl

    // 只有需要签名时才获取签名 URL
    if (props.needSignature) {
      // 判断URL是否已经包含签名参数（如：X-Amz-Signature, sign, signature等）
      const hasSignature = /[?&](X-Amz-Signature|sign|signature|x-cos-security-token)=/i.test(
        imgUrl
      )

      // 如果URL已经包含签名，直接使用，否则获取新签名
      if (!hasSignature) {
        // 直接传递完整的文件URL获取签名
        const signedUrl = await FileApi.getFileAccessUrl(imgUrl)
        previewUrl = signedUrl || imgUrl
      }
    }

    createImageViewer({
      zIndex: 9999999,
      urlList: [previewUrl]
    })
  } catch (error) {
    console.error('获取图片访问链接失败:', error)
    message.error('获取图片访问链接失败')
  }
}

// ==================== 类型定义 ====================
/**
 * 支持的图片 MIME 类型
 */
type FileTypes =
  | 'image/apng'
  | 'image/bmp'
  | 'image/gif'
  | 'image/jpeg'
  | 'image/pjpeg'
  | 'image/png'
  | 'image/svg+xml'
  | 'image/tiff'
  | 'image/webp'
  | 'image/x-icon'

// ==================== 组件 Props ====================
/**
 * 组件属性定义
 * 所有属性都有默认值，使用时可选择性传入
 */
const props = defineProps({
  modelValue: propTypes.oneOfType<string | string[]>([String, Array<String>]).isRequired, // 图片URL列表（组件内部自动处理：存储原始URL，显示签名URL）
  drag: propTypes.bool.def(true), // 是否支持拖拽上传 ==> 非必传（默认为 true）
  disabled: propTypes.bool.def(false), // 是否禁用上传组件 ==> 非必传（默认为 false）
  limit: propTypes.number.def(5), // 最大图片上传数 ==> 非必传（默认为 5张）
  fileSize: propTypes.number.def(5), // 图片大小限制 ==> 非必传（默认为 5M）
  fileType: propTypes.array.def(['image/jpeg', 'image/png', 'image/gif']), // 图片类型限制 ==> 非必传（默认为 ["image/jpeg", "image/png", "image/gif"]）
  height: propTypes.string.def('150px'), // 组件高度 ==> 非必传（默认为 150px）
  width: propTypes.string.def('150px'), // 组件宽度 ==> 非必传（默认为 150px）
  borderradius: propTypes.string.def('8px'), // 组件边框圆角 ==> 非必传（默认为 8px）
  directory: propTypes.string.def(undefined), // 上传目录 ==> 非必传（默认为 undefined）
  needSignature: propTypes.bool.def(true), // 是否需要获取签名 URL ==> 非必传（默认为 true）
  autoDelete: propTypes.bool.def(true) // 删除时是否自动调用后端删除文件 ==> 非必传（默认为 true）
})

// ==================== 上传配置 ====================
// 获取上传 URL 和自定义上传请求函数
const { uploadUrl, httpRequest } = useUpload(props.directory)

// ==================== 响应式数据 ====================
/**
 * 文件列表（用于 Element Plus 显示）
 * 存储的是带签名的 URL，用于图片显示
 */
const fileList = ref<UploadUserFile[]>([])

/**
 * 当前上传任务数量
 * 用于判断所有文件是否上传完成
 */
const uploadNumber = ref<number>(0)

/**
 * 临时上传列表
 * 用于批量上传时暂存上传成功的文件
 */
const uploadList = ref<UploadUserFile[]>([])

/**
 * 原始 URL 列表（用于表单提交）
 * 存储的是不带签名参数的原始 URL，与 fileList 索引一一对应
 */
const originalUrls = ref<string[]>([])

// ==================== 上传前验证 ====================
/**
 * 文件上传前的验证函数
 * 功能：检查文件类型和大小是否符合要求
 * @param rawFile - 待上传的原始文件对象
 * @returns {boolean} - 验证通过返回 true，否则返回 false
 */
const beforeUpload: UploadProps['beforeUpload'] = (rawFile) => {
  const imgSize = rawFile.size / 1024 / 1024 < props.fileSize
  const imgType = props.fileType
  if (!imgType.includes(rawFile.type as FileTypes))
    ElNotification({
      title: '温馨提示',
      message: '上传图片不符合所需的格式！',
      type: 'warning'
    })
  if (!imgSize)
    ElNotification({
      title: '温馨提示',
      message: `上传图片大小不能超过 ${props.fileSize}M！`,
      type: 'warning'
    })
  uploadNumber.value++
  return imgType.includes(rawFile.type as FileTypes) && imgSize
}

// ==================== 事件定义 ====================
/**
 * 组件事件类型定义
 */
interface UploadEmits {
  (e: 'update:modelValue', value: string[]): void
}

const emit = defineEmits<UploadEmits>()

// ==================== 上传成功处理 ====================
/**
 * 文件上传成功回调
 * 功能：
 * 1. 收集所有上传成功的文件 URL
 * 2. 当所有文件上传完成后，批量处理签名 URL
 * 3. 更新 fileList 和 originalUrls
 * 4. 触发 modelValue 更新事件
 *
 * @param res - 上传接口返回的响应数据，包含文件 URL
 */
const uploadSuccess: UploadProps['onSuccess'] = async (res: any): Promise<void> => {
  message.success('上传成功')
  console.log('[UploadImgs] 上传成功，返回URL:', res.data)

  // 删除自身
  const index = fileList.value.findIndex((item) => item.response?.data === res.data)
  fileList.value.splice(index, 1)

  // 新上传的文件URL
  const newUrl = res.data
  uploadList.value.push({ name: newUrl, url: newUrl })

  console.log('[UploadImgs] 当前上传进度:', uploadList.value.length, '/', uploadNumber.value)

  if (uploadList.value.length == uploadNumber.value) {
    console.log('[UploadImgs] 所有文件上传完成，开始批量处理')
    // 所有文件上传完成，批量处理
    const newUrls = uploadList.value.map((item) => item.url)

    // 为每个新URL获取签名（如果需要）
    for (const originalUrl of newUrls) {
      originalUrls.value.push(originalUrl) // 保存原始URL

      let displayUrl = originalUrl

      // 如果需要签名
      if (props.needSignature && originalUrl) {
        const hasSignature = /[?&](X-Amz-Signature|sign|signature|x-cos-security-token)=/i.test(
          originalUrl
        )

        if (!hasSignature) {
          try {
            const signedUrl = await FileApi.getFileAccessUrl(originalUrl)
            displayUrl = signedUrl || originalUrl
          } catch (error) {
            console.error('获取签名URL失败:', error)
            displayUrl = originalUrl
          }
        }
      }

      fileList.value.push({
        name: originalUrl.substring(originalUrl.lastIndexOf('/') + 1),
        url: displayUrl // 使用签名URL用于显示
      })
    }

    uploadList.value = []
    uploadNumber.value = 0

    console.log('[UploadImgs] 更新后的 originalUrls:', originalUrls.value)
    console.log('[UploadImgs] 更新后的 fileList 数量:', fileList.value.length)
    emitUpdateModelValue()
  }
}

// ==================== 数据监听 ====================
/**
 * 监听 modelValue 变化
 *
 * 核心功能：
 * 1. 将外部传入的 URL 数组转换为 fileList 格式
 * 2. 处理签名 URL：自动分离签名参数，存储原始 URL
 * 3. 智能判断是否为追加操作，避免不必要的重建
 * 4. 支持多种数据格式：字符串数组、对象数组、对象（带数字键）
 * 5. 签名 URL 缓存：避免重复请求后端接口
 *
 * 处理逻辑：
 * - 如果 URL 已包含签名且 needSignature=true：分离签名，存储原始 URL，显示签名 URL
 * - 如果 URL 不包含签名且 needSignature=true：获取新签名，缓存并显示
 * - 如果 needSignature=false：直接使用原始 URL，不做签名处理
 */
watch(
  () => props.modelValue,
  async (val: string | string[], oldVal: string | string[]) => {
    const newUrlsRaw = val as any
    console.log('[UploadImgs] watch raw modelValue:', newUrlsRaw)
    const newUrls = Array.isArray(newUrlsRaw) ? newUrlsRaw : []
    console.log('[UploadImgs] watch normalized array length:', newUrls.length)

    if (newUrls.length === 0) {
      fileList.value = []
      originalUrls.value = []
      console.log('[UploadImgs] newUrls 为空，清空 fileList')
      return
    }
    const oldUrls = Array.isArray(oldVal) ? oldVal : []
    const isAppending =
      oldUrls.length > 0 &&
      newUrls.length > oldUrls.length &&
      oldUrls.every((url, index) => newUrls[index] === url)

    if (isAppending) {
      console.log('[UploadImgs] 检测到追加操作，跳过重建')
      return
    }

    console.log('[UploadImgs] 重建文件列表，URL数量:', newUrls.length)
    fileList.value = []
    originalUrls.value = []

    let hasAnySignature = false

    for (const item of newUrls) {
      let url = ''
      if (typeof item === 'string') {
        url = item
      } else if (item && typeof item === 'object') {
        url = item.url || item.response?.data || ''
      }

      if (!url) {
        console.warn('[UploadImgs] 跳过无效的图片项:', item)
        continue
      }

      const hasSignature = /[?&](X-Amz-Signature|sign|signature|x-cos-security-token)=/i.test(url)

      let originalUrlValue = url
      let displayUrlValue = url

      if (hasSignature && props.needSignature) {
        console.log('[UploadImgs] 检测到签名URL，自动分离:', url)
        hasAnySignature = true
        const cleanUrl = url.split('?')[0]
        originalUrlValue = cleanUrl
        displayUrlValue = url
        signedUrlCache.set(cleanUrl, url)
      } else if (hasSignature && !props.needSignature) {
        originalUrlValue = url
        displayUrlValue = url
      } else {
        originalUrlValue = url

        if (props.needSignature) {
          const cachedSigned = signedUrlCache.get(url)
          if (cachedSigned) {
            console.log('[UploadImgs] 使用缓存签名 URL:', cachedSigned)
            displayUrlValue = cachedSigned
          } else {
            try {
              const signedUrl = await FileApi.getFileAccessUrl(url)
              console.log('[UploadImgs] 重新获取签名成功:', signedUrl)
              displayUrlValue = signedUrl || url
              if (signedUrl) {
                signedUrlCache.set(url, signedUrl)
              }
            } catch (error) {
              console.error('[UploadImgs] 获取签名URL失败:', error)
              displayUrlValue = url
            }
          }
        } else {
          displayUrlValue = url
        }
      }

      originalUrls.value.push(originalUrlValue)
      fileList.value.push({
        name: originalUrlValue.substring(originalUrlValue.lastIndexOf('/') + 1),
        url: displayUrlValue
      })
    }

    if (hasAnySignature && props.needSignature) {
      console.log('[UploadImgs] 自动更新为原始URL列表')
      nextTick(() => {
        emit('update:modelValue', originalUrls.value)
      })
    }

    console.log('[UploadImgs] 构建后的 fileList:', fileList.value)
  },
  { immediate: true, deep: true }
)

// ==================== 数据更新 ====================
/**
 * 发送 modelValue 更新事件
 * 功能：将原始 URL 列表同步到父组件
 * 说明：组件内部维护显示 URL（fileList），外部只需关心原始 URL（originalUrls）
 */
const emitUpdateModelValue = () => {
  emit('update:modelValue', originalUrls.value)
}

// ==================== 删除功能 ====================
/**
 * 删除图片
 * 功能：
 * 1. 从 fileList 和 originalUrls 中移除指定文件
 * 2. 如果开启 autoDelete，调用后端接口删除文件
 * 3. 清除签名 URL 缓存
 * 4. 触发 modelValue 更新事件
 *
 * @param uploadFile - 要删除的文件对象
 */
const handleRemove = async (uploadFile: UploadFile) => {
  // 找到要删除的文件在列表中的索引
  const fileIndex = fileList.value.findIndex(
    (item) => item.url === uploadFile.url && item.name === uploadFile.name
  )

  if (fileIndex === -1) return

  // 如果开启了自动删除，并且有文件URL
  if (props.autoDelete && uploadFile.url) {
    try {
      // 去除签名参数，传递原始文件URL
      const fileUrl = uploadFile.url.split('?')[0]

      // 调用后端删除文件
      await FileApi.deleteFileByPath(fileUrl)
      message.success('文件删除成功')
    } catch (error) {
      console.error('删除文件失败:', error)
      message.error('删除文件失败')
      // 即使删除失败，也继续从列表中移除（因为可能是文件已经不存在）
    }
  }

  // 从显示列表中移除
  fileList.value.splice(fileIndex, 1)

  // 从原始URL列表中移除（保持索引一致）
  const removedOriginal = originalUrls.value.splice(fileIndex, 1)[0]
  if (removedOriginal) {
    signedUrlCache.delete(removedOriginal)
  }

  // 发送原始URL列表更新
  emitUpdateModelValue()
}

// ==================== 错误处理 ====================
/**
 * 上传错误提示
 * 当文件上传失败时触发
 */
const uploadError = () => {
  ElNotification({
    title: '温馨提示',
    message: '图片上传失败，请您重新上传！',
    type: 'error'
  })
}

/**
 * 文件数量超出限制提示
 * 当上传文件数超过 limit 限制时触发
 */
const handleExceed = () => {
  ElNotification({
    title: '温馨提示',
    message: `当前最多只能上传 ${props.limit} 张图片，请移除后上传！`,
    type: 'warning'
  })
}
</script>

<!-- ==================== 样式定义 ==================== -->
<style lang="scss" scoped>
/* 错误状态样式：上传组件边框显示红色 */
.is-error {
  .upload {
    :deep(.el-upload--picture-card),
    :deep(.el-upload-dragger) {
      border: 1px dashed var(--el-color-danger) !important;

      &:hover {
        border-color: var(--el-color-primary) !important;
      }
    }
  }
}

/* 禁用状态样式：禁用上传功能时的视觉反馈 */
:deep(.disabled) {
  .el-upload--picture-card,
  .el-upload-dragger {
    cursor: not-allowed;
    background: var(--el-disabled-bg-color) !important;
    border: 1px dashed var(--el-border-color-darker);

    &:hover {
      border-color: var(--el-border-color-darker) !important;
    }
  }
}

/* 上传容器主样式 */
.upload-box {
  /* 无边框模式：隐藏上传卡片边框 */
  .no-border {
    :deep(.el-upload--picture-card) {
      border: none !important;
    }
  }

  /* 上传组件内部样式 */
  :deep(.upload) {
    /* 拖拽上传区域样式 */
    .el-upload-dragger {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      padding: 0;
      overflow: hidden;
      border: 1px dashed var(--el-border-color-darker);
      border-radius: v-bind(borderradius);

      &:hover {
        border: 1px dashed var(--el-color-primary);
      }
    }

    .el-upload-dragger.is-dragover {
      background-color: var(--el-color-primary-light-9);
      border: 2px dashed var(--el-color-primary) !important;
    }

    /* 上传列表项和上传卡片尺寸（使用动态绑定） */
    .el-upload-list__item,
    .el-upload--picture-card {
      width: v-bind(width);
      height: v-bind(height);
      background-color: transparent;
      border-radius: v-bind(borderradius);
    }

    /* 上传的图片显示样式 */
    .upload-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    /* 图片操作遮罩层（查看/删除按钮） */
    .upload-handle {
      position: absolute;
      top: 0;
      right: 0;
      display: flex;
      width: 100%;
      height: 100%;
      cursor: pointer;
      background: rgb(0 0 0 / 60%);
      opacity: 0;
      box-sizing: border-box;
      transition: var(--el-transition-duration-fast);
      align-items: center;
      justify-content: center;

      /* 操作按钮图标样式 */
      .handle-icon {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 0 6%;
        color: aliceblue;

        .el-icon {
          margin-bottom: 15%;
          font-size: 140%;
        }

        span {
          font-size: 100%;
        }
      }
    }

    /* 鼠标悬停时显示操作遮罩 */
    .el-upload-list__item {
      &:hover {
        .upload-handle {
          opacity: 1;
        }
      }
    }

    /* 空状态上传按钮样式 */
    .upload-empty {
      display: flex;
      flex-direction: column;
      align-items: center;
      font-size: 12px;
      line-height: 30px;
      color: var(--el-color-info);

      .el-icon {
        font-size: 28px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .el-upload__tip {
    line-height: 15px;
    text-align: center;
  }
}
</style>
