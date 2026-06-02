<template>
  <div class="guide-edit-container">
    <div class="page-header">
      <h1>{{ form.id ? '编辑攻略' : '发布新攻略' }}</h1>
      <p>分享你的旅行体验，也可以把刚规划好的路线一键整理成攻略。</p>
    </div>

    <div class="edit-form-container">
      <el-form
        ref="formRef"
        :model="form"
        label-width="80px"
        class="edit-form"
      >
        <el-form-item label="标题" prop="title" required>
          <el-input
            v-model="form.title"
            placeholder="请输入攻略标题，建议 30 字以内"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="封面" prop="coverImage" required>
          <div class="cover-uploader-container">
            <el-upload
              class="cover-uploader"
              action="#"
              :show-file-list="false"
              :http-request="customUploadCover"
              :before-upload="beforeCoverUpload"
            >
              <div v-if="form.coverImage" class="cover-preview-container">
                <img :src="getImageUrl(form.coverImage)" class="cover-preview" />
                <div class="cover-hover-mask">
                  <el-icon class="upload-icon"><EditPen /></el-icon>
                  <span>更换封面</span>
                </div>
              </div>
              <div v-else class="upload-placeholder">
                <el-icon class="upload-icon"><Plus /></el-icon>
                <span>上传封面图片</span>
                <div class="upload-tip">推荐尺寸: 900x600px，JPG/PNG 格式</div>
              </div>
            </el-upload>
            <div v-if="!form.coverImage" class="form-tips">
              一张清晰的封面图会更容易吸引用户点击。
            </div>
          </div>
        </el-form-item>

        <el-form-item label="内容" prop="content" required>
          <div class="editor-container">
            <WangEditor v-model="form.content" />
            <div class="form-tips">
              支持图文混排；路线信息会单独保存在攻略里，不会直接显示在正文中。
            </div>
          </div>
        </el-form-item>

        <el-form-item label="路线">
          <div class="route-section">
            <div v-if="form.routePlaces.length" class="route-card">
              <div class="route-card-header">
                <span>已关联 {{ form.routePlaces.length }} 个路线地点</span>
                <el-button text type="primary" @click="previewRoute">预览路线</el-button>
              </div>
              <div class="route-places">
                <span
                  v-for="(place, index) in form.routePlaces"
                  :key="`${place.name}_${index}`"
                  class="route-place-tag"
                >
                  {{ index + 1 }}. {{ place.name }}
                </span>
              </div>
              <div class="form-tips">
                发布后，其他用户可以从攻略详情直接带入这条路线，并重新选择自己的起始地点。
              </div>
            </div>
            <div v-else class="route-empty">
              当前没有关联路线。你可以先去路线规划页完成规划，再一键跳转回来发布。
            </div>
          </div>
        </el-form-item>

        <el-form-item>
          <div class="form-actions">
            <el-button @click="goBack">取消</el-button>
            <el-button type="primary" :loading="submitting" @click="submit">
              {{ form.id ? '保存修改' : '发布攻略' }}
            </el-button>
          </div>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { EditPen, Plus } from '@element-plus/icons-vue'
import WangEditor from '@/components/WangEditor.vue'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'
import {
  decodeRouteFromQuery,
  embedGuideRoute,
  encodeRouteForQuery,
  extractGuideRoute,
  stripGuideRouteMarker
} from '@/utils/guideRoute'

const baseAPI = process.env.VUE_APP_BASE_API || '/api'
const route = useRoute()
const router = useRouter()
const formRef = ref(null)
const submitting = ref(false)
const userStore = useUserStore()

const form = reactive({
  id: '',
  title: '',
  coverImage: '',
  content: '',
  routePlaces: []
})

const getImageUrl = (url) => {
  if (!url) return ''
  return url.startsWith('http') ? url : baseAPI + url
}

const loadGuide = async () => {
  if (!route.query.id) return

  try {
    await request.get(`/guide/${route.query.id}`, {}, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        form.id = res.id
        form.title = res.title
        form.coverImage = res.coverImage
        form.content = stripGuideRouteMarker(res.content || '')

        if (!form.routePlaces.length) {
          form.routePlaces = extractGuideRoute(res.content || '')
        }
      }
    })
  } catch (error) {
    ElMessage.error('获取攻略信息失败')
    console.error('获取攻略信息失败', error)
  }
}

onMounted(async () => {
  const routePlacesFromQuery = decodeRouteFromQuery(route.query.routeData)
  if (routePlacesFromQuery.length) {
    form.routePlaces = routePlacesFromQuery
  }

  await loadGuide()
})

const beforeCoverUpload = (file) => {
  const isJPG = file.type === 'image/jpeg'
  const isPNG = file.type === 'image/png'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isJPG && !isPNG) {
    ElMessage.error('封面只能是 JPG 或 PNG 格式')
    return false
  }

  if (!isLt2M) {
    ElMessage.error('封面大小不能超过 2MB')
    return false
  }

  return true
}

const customUploadCover = async (options) => {
  try {
    const { file } = options
    const formData = new FormData()
    formData.append('file', file)

    await request.post('/file/upload/img', formData, {
      headers: { token: localStorage.getItem('token') || '' },
      transformRequest: [(data) => data],
      successMsg: '封面上传成功',
      errorMsg: '封面上传失败',
      onSuccess: (data) => {
        form.coverImage = data
        options.onSuccess({ data })
      },
      onError: (error) => {
        options.onError(new Error(error.message || '上传失败'))
      }
    })
  } catch (error) {
    options.onError(error)
  }
}

const submit = async () => {
  if (!form.title.trim()) {
    return ElMessage.warning('请输入攻略标题')
  }

  if (!form.coverImage) {
    return ElMessage.warning('请上传攻略封面')
  }

  if (!form.content || form.content === '<p><br></p>') {
    return ElMessage.warning('请填写攻略内容')
  }

  submitting.value = true

  const payload = {
    id: form.id,
    title: form.title,
    coverImage: form.coverImage,
    userId: userStore.userInfo.id,
    content: embedGuideRoute(form.content, form.routePlaces)
  }

  try {
    if (form.id) {
      await request.put('/guide/update', payload, {
        successMsg: '修改成功',
        onSuccess: () => {
          router.push({ name: 'MyGuideList' })
        }
      })
    } else {
      await request.post('/guide/add', payload, {
        successMsg: '发布成功',
        onSuccess: () => {
          form.id = ''
          form.title = ''
          form.coverImage = ''
          form.content = ''
          form.routePlaces = []
          router.push({ name: 'MyGuideList' })
        }
      })
    }
  } catch (error) {
    console.error('提交攻略失败', error)
  } finally {
    submitting.value = false
  }
}

const previewRoute = () => {
  if (!form.routePlaces.length) return

  router.push({
    name: 'RoutePlanning',
    query: {
      source: 'guide',
      routeData: encodeRouteForQuery(form.routePlaces)
    }
  })
}

const goBack = () => {
  router.back()
}
</script>

<style lang="scss" scoped>
.guide-edit-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;

  h1 {
    font-size: 28px;
    font-weight: 600;
    color: #333;
    margin: 0 0 10px;
  }

  p {
    font-size: 16px;
    color: #666;
    max-width: 600px;
    margin: 0 auto;
  }
}

.edit-form-container {
  background: #fff;
  border-radius: 8px;
  padding: 30px;
}

.edit-form {
  .el-form-item {
    margin-bottom: 25px;
  }
}

.cover-uploader-container,
.route-section {
  width: 100%;
}

.cover-uploader {
  :deep(.el-upload) {
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: all 0.3s;
    width: 100%;
    max-width: 360px;
  }

  .cover-preview-container {
    position: relative;
    width: 360px;
    height: 200px;
    border-radius: 8px;
    overflow: hidden;
    transition: all 0.3s;

    &:hover {
      .cover-hover-mask {
        opacity: 1;
      }
    }
  }

  .cover-preview {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .cover-hover-mask {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    opacity: 0;
    transition: opacity 0.3s;
    color: #fff;

    .upload-icon {
      font-size: 24px;
      margin-bottom: 8px;
    }
  }

  .upload-placeholder {
    width: 360px;
    height: 200px;
    border: 1px dashed #d9d9d9;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    color: #8c939d;
    transition: all 0.3s;

    &:hover {
      border-color: #409eff;
      color: #409eff;
    }

    .upload-icon {
      font-size: 28px;
      margin-bottom: 8px;
    }

    .upload-tip {
      font-size: 12px;
      margin-top: 8px;
      color: #999;
    }
  }
}

.editor-container {
  width: 100%;

  :deep(.w-e-text-container) {
    min-height: 400px;
    max-height: 600px;
  }
}

.route-card {
  width: 100%;
  background: #f8fbff;
  border: 1px solid #dbeafe;
  border-radius: 10px;
  padding: 14px 16px;
}

.route-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
  font-weight: 600;
  color: #1f2937;
}

.route-places {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.route-place-tag {
  display: inline-flex;
  align-items: center;
  padding: 6px 10px;
  border-radius: 999px;
  background: #e0f2fe;
  color: #075985;
  font-size: 13px;
}

.route-empty {
  width: 100%;
  padding: 14px 16px;
  border-radius: 10px;
  background: #fafafa;
  color: #666;
  border: 1px dashed #d9d9d9;
}

.form-actions {
  display: flex;
  gap: 12px;
}

.form-tips {
  font-size: 13px;
  color: #909399;
  margin-top: 8px;
  line-height: 1.5;
}
</style>
