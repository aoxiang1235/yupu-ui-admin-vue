<template>
  <div class="upload-box">
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
      <div class="upload-empty">
        <slot name="empty">
          <Icon icon="ep:plus" />
          <!-- <span>请上传图片</span> -->
        </slot>
      </div>
      <template #file="{ file }">
        <img :src="file.url" class="upload-image" />
        <div class="upload-handle" @click.stop>
          <div class="handle-icon" @click="imagePreview(file.url!)">
            <Icon icon="ep:zoom-in" />
            <span>查看</span>
          </div>
          <div v-if="!disabled" class="handle-icon" @click="handleRemove(file)">
            <Icon icon="ep:delete" />
            <span>删除</span>
          </div>
        </div>
      </template>
    </el-upload>
    <div class="el-upload__tip">
      <slot name="tip"></slot>
    </div>
  </div>
</template>
<script lang="ts" setup>
import type { UploadFile, UploadProps, UploadUserFile } from 'element-plus'
import { ElNotification } from 'element-plus'
import { createImageViewer } from '@/components/ImageViewer'

import { propTypes } from '@/utils/propTypes'
import { useUpload } from '@/components/UploadFile/src/useUpload'
import * as FileApi from '@/api/infra/file'

defineOptions({ name: 'UploadImgs' })

const message = useMessage() // 消息弹窗
// 查看图片
const imagePreview = async (imgUrl: string) => {
  try {
    let previewUrl = imgUrl
    
    // 只有需要签名时才获取签名 URL
    if (props.needSignature) {
      // 判断URL是否已经包含签名参数（如：X-Amz-Signature, sign, signature等）
      const hasSignature = /[?&](X-Amz-Signature|sign|signature|x-cos-security-token)=/i.test(imgUrl)
      
      // 如果URL已经包含签名，直接使用，否则获取新签名
      if (!hasSignature) {
        // 直接传递完整的文件URL获取签名
        const res = await FileApi.getFileAccessUrl(imgUrl)
        previewUrl = res.data || imgUrl
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

const props = defineProps({
  modelValue: propTypes.oneOfType<string | string[]>([String, Array<String>]).isRequired,
  drag: propTypes.bool.def(true), // 是否支持拖拽上传 ==> 非必传（默认为 true）
  disabled: propTypes.bool.def(false), // 是否禁用上传组件 ==> 非必传（默认为 false）
  limit: propTypes.number.def(5), // 最大图片上传数 ==> 非必传（默认为 5张）
  fileSize: propTypes.number.def(5), // 图片大小限制 ==> 非必传（默认为 5M）
  fileType: propTypes.array.def(['image/jpeg', 'image/png', 'image/gif']), // 图片类型限制 ==> 非必传（默认为 ["image/jpeg", "image/png", "image/gif"]）
  height: propTypes.string.def('150px'), // 组件高度 ==> 非必传（默认为 150px）
  width: propTypes.string.def('150px'), // 组件宽度 ==> 非必传（默认为 150px）
  borderradius: propTypes.string.def('8px'), // 组件边框圆角 ==> 非必传（默认为 8px）
  directory: propTypes.string.def(undefined), // 上传目录 ==> 非必传（默认为 undefined）
  needSignature: propTypes.bool.def(true), // 预览时是否需要获取签名 URL ==> 非必传（默认为 true）
  autoDelete: propTypes.bool.def(true) // 删除时是否自动调用后端删除文件 ==> 非必传（默认为 true）
})

const { uploadUrl, httpRequest } = useUpload(props.directory)

const fileList = ref<UploadUserFile[]>([])
const uploadNumber = ref<number>(0)
const uploadList = ref<UploadUserFile[]>([])
// 保存原始URL列表（用于表单提交）
const originalUrls = ref<string[]>([])
/**
 * @description 文件上传之前判断
 * @param rawFile 上传的文件
 * */
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

// 图片上传成功
interface UploadEmits {
  (e: 'update:modelValue', value: string[]): void
}

const emit = defineEmits<UploadEmits>()
const uploadSuccess: UploadProps['onSuccess'] = (res: any): void => {
  message.success('上传成功')
  // 删除自身
  const index = fileList.value.findIndex((item) => item.response?.data === res.data)
  fileList.value.splice(index, 1)
  uploadList.value.push({ name: res.data, url: res.data })
  if (uploadList.value.length == uploadNumber.value) {
    fileList.value.push(...uploadList.value)
    uploadList.value = []
    uploadNumber.value = 0
    emitUpdateModelValue()
  }
}

// 监听模型绑定值变动
watch(
  () => props.modelValue,
  async (val: string | string[]) => {
    if (!val) {
      fileList.value = [] // fix：处理掉缓存，表单重置后上传组件的内容并没有重置
      originalUrls.value = []
      return
    }

    fileList.value = [] // 保障数据为空
    originalUrls.value = [] // 清空原始URL列表
    
    // 遍历每个URL，如果需要签名则获取签名URL
    const urls = val as string[]
    for (const originalUrl of urls) {
      originalUrls.value.push(originalUrl) // 保存原始URL
      
      let displayUrl = originalUrl
      
      // 如果需要签名
      if (props.needSignature && originalUrl) {
        // 检查是否已经有签名
        const hasSignature = /[?&](X-Amz-Signature|sign|signature|x-cos-security-token)=/i.test(originalUrl)
        
        if (!hasSignature) {
          // 没有签名，获取签名URL
          try {
            // 直接传递完整的文件URL
            const res = await FileApi.getFileAccessUrl(originalUrl)
            displayUrl = res.data || originalUrl
          } catch (error) {
            console.error('获取签名URL失败:', error)
            // 获取失败也使用原始URL
            displayUrl = originalUrl
          }
        }
      }
      
      fileList.value.push({
        name: originalUrl.substring(originalUrl.lastIndexOf('/') + 1),
        url: displayUrl  // 使用签名URL用于显示
      })
    }
  },
  { immediate: true, deep: true }
)
// 发送图片链接列表更新
const emitUpdateModelValue = () => {
  // 使用原始URL列表进行更新（用于表单提交）
  emit('update:modelValue', originalUrls.value)
}
// 删除图片
const handleRemove = async (uploadFile: UploadFile) => {
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
  
  // 从文件列表中移除
  fileList.value = fileList.value.filter(
    (item) => item.url !== uploadFile.url || item.name !== uploadFile.name
  )
  emit(
    'update:modelValue',
    fileList.value.map((file) => file.url!)
  )
}

// 图片上传错误提示
const uploadError = () => {
  ElNotification({
    title: '温馨提示',
    message: '图片上传失败，请您重新上传！',
    type: 'error'
  })
}

// 文件数超出提示
const handleExceed = () => {
  ElNotification({
    title: '温馨提示',
    message: `当前最多只能上传 ${props.limit} 张图片，请移除后上传！`,
    type: 'warning'
  })
}
</script>

<style lang="scss" scoped>
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

.upload-box {
  .no-border {
    :deep(.el-upload--picture-card) {
      border: none !important;
    }
  }

  :deep(.upload) {
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

    .el-upload-list__item,
    .el-upload--picture-card {
      width: v-bind(width);
      height: v-bind(height);
      background-color: transparent;
      border-radius: v-bind(borderradius);
    }

    .upload-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

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

    .el-upload-list__item {
      &:hover {
        .upload-handle {
          opacity: 1;
        }
      }
    }

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
