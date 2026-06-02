<template>
  <div class="guide-detail-page" v-loading="loading">
    <div v-if="guide" class="guide-detail-container">
      <div class="hero-card">
        <div class="hero-media">
          <img v-if="guide.coverImage" :src="getImageUrl(guide.coverImage)" :alt="guide.title" class="hero-image" />
          <div v-else class="hero-image placeholder">旅游攻略</div>
        </div>

        <div class="hero-content">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item @click="$router.push('/')">首页</el-breadcrumb-item>
            <el-breadcrumb-item @click="$router.push('/guide')">旅游攻略</el-breadcrumb-item>
            <el-breadcrumb-item>{{ guide.title }}</el-breadcrumb-item>
          </el-breadcrumb>

          <h1 class="guide-title">{{ guide.title }}</h1>

          <div class="guide-meta">
            <div class="meta-item">
              <el-avatar :src="getImageUrl(guide.userAvatar)" :size="36">
                <el-icon><User /></el-icon>
              </el-avatar>
              <span>{{ guide.userNickname || `用户${guide.userId}` }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Calendar /></el-icon>
              <span>{{ formatDate(guide.createTime) }}</span>
            </div>
            <div class="meta-item">
              <el-icon><View /></el-icon>
              <span>{{ formatNumber(guide.views) }} 阅读</span>
            </div>
          </div>

          <div class="action-buttons">
            <el-button
              :type="isCollected ? 'danger' : 'primary'"
              size="large"
              :disabled="!userStore.isLoggedIn"
              @click="handleCollectionToggle"
            >
              <el-icon>
                <StarFilled v-if="isCollected" />
                <Star v-else />
              </el-icon>
              {{ isCollected ? '已收藏' : '收藏攻略' }}
            </el-button>
            <el-button size="large" @click="handleShare">
              <el-icon><Share /></el-icon>
              分享
            </el-button>
            <el-button
              v-if="guideRoutePlaces.length"
              type="success"
              size="large"
              @click="goPlanByGuideRoute"
            >
              <el-icon><Promotion /></el-icon>
              按攻略路线规划
            </el-button>
          </div>
        </div>
      </div>

      <div class="content-layout">
        <div class="main-panel">
          <div v-if="guideRoutePlaces.length" class="route-panel">
            <div class="panel-header">
              <div>
                <h3>攻略路线</h3>
                <p>跳转后只需要重新选择起点，其余地点会自动沿用这篇攻略。</p>
              </div>
              <el-button type="primary" plain @click="goPlanByGuideRoute">去规划</el-button>
            </div>

            <div class="route-tags">
              <span
                v-for="(place, index) in guideRoutePlaces"
                :key="`${place.name}_${index}`"
                class="route-tag"
              >
                {{ index + 1 }}. {{ place.name }}
              </span>
            </div>
          </div>

          <div class="article-panel">
            <div v-html="displayContent" class="rich-content"></div>
          </div>
        </div>

        <div v-if="relatedGuides.length" class="side-panel">
          <div class="side-card">
            <h3>相关攻略</h3>
            <div
              v-for="item in relatedGuides"
              :key="item.id"
              class="related-item"
              @click="goToGuide(item.id)"
            >
              <div class="related-title">{{ item.title }}</div>
              <div class="related-meta">
                <el-icon><View /></el-icon>
                <span>{{ formatNumber(item.views) }} 阅读</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="!loading" class="guide-not-found">
      <el-empty description="未找到该攻略" />
      <el-button type="primary" @click="goBack">返回</el-button>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Calendar,
  Promotion,
  Share,
  Star,
  StarFilled,
  User,
  View
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import { formatDate } from '@/utils/dateUtils'
import { useUserStore } from '@/store/user'
import { encodeRouteForQuery, extractGuideRoute, stripGuideRouteMarker } from '@/utils/guideRoute'

const baseAPI = process.env.VUE_APP_BASE_API || '/api'
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const guide = ref(null)
const isCollected = ref(false)
const loading = ref(true)
const relatedGuides = ref([])

const displayContent = computed(() => stripGuideRouteMarker(guide.value?.content || ''))
const guideRoutePlaces = computed(() => extractGuideRoute(guide.value?.content || ''))
const isOwner = computed(() => !!guide.value && !!userStore.userInfo?.id && Number(userStore.userInfo.id) === Number(guide.value.userId))

const getImageUrl = (url) => {
  if (!url) return ''
  return url.startsWith('http') ? url : baseAPI + url
}

const formatNumber = (num) => {
  if (!num) return '0'
  if (num >= 10000) return `${(num / 10000).toFixed(1)}w`
  if (num >= 1000) return `${(num / 1000).toFixed(1)}k`
  return String(num)
}

const fetchRelatedGuides = async () => {
  if (!guide.value) return

  try {
    await request.get('/guide/page', { currentPage: 1, size: 4 }, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        relatedGuides.value = (res.records || []).filter((item) => item.id !== guide.value.id).slice(0, 3)
      }
    })
  } catch (error) {
    console.error('获取相关攻略失败:', error)
  }
}

const checkIsCollected = async (guideId) => {
  if (!userStore.isLoggedIn) return

  try {
    await request.get('/collection/isCollected', { guideId }, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        isCollected.value = data
      }
    })
  } catch (error) {
    console.error('查询收藏状态失败:', error)
  }
}

const fetchGuide = async () => {
  loading.value = true

  try {
    await request.get(`/guide/${route.params.id}`, {}, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        guide.value = res
        document.title = `${res.title} - 旅游攻略`

        if (userStore.isLoggedIn) {
          checkIsCollected(res.id)
        }

        fetchRelatedGuides()
      }
    })
  } catch (error) {
    console.error('获取攻略详情失败:', error)
  } finally {
    loading.value = false
  }
}

const handleCollectionToggle = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login?redirect=' + route.fullPath)
    return
  }

  try {
    if (isCollected.value) {
      await request.delete(`/collection/cancel?guideId=${guide.value.id}`, {
        successMsg: '已取消收藏',
        onSuccess: () => {
          isCollected.value = false
        }
      })
    } else {
      await request.post('/collection/add', { guideId: guide.value.id }, {
        successMsg: '收藏成功',
        onSuccess: () => {
          isCollected.value = true
        }
      })
    }
  } catch (error) {
    console.error('收藏操作失败:', error)
  }
}

const handleShare = () => {
  const url = window.location.href
  navigator.clipboard.writeText(url).then(() => {
    ElMessage.success('链接已复制')
  }).catch(() => {
    ElMessage.error('复制失败，请手动复制地址栏链接')
  })
}

const goPlanByGuideRoute = () => {
  if (!guideRoutePlaces.value.length) {
    ElMessage.warning('这篇攻略还没有关联路线')
    return
  }

  router.push({
    name: 'RoutePlanning',
    query: {
      source: 'guide',
      ...(isOwner.value ? { guideId: guide.value.id } : {}),
      routeData: encodeRouteForQuery(guideRoutePlaces.value)
    }
  })
}

const goToGuide = (id) => {
  router.push(`/guide/detail/${id}`)
}

const goBack = () => {
  router.back()
}

onMounted(fetchGuide)
</script>

<style lang="scss" scoped>
.guide-detail-page {
  min-height: 100vh;
  padding: 24px;
  background: linear-gradient(180deg, #f7fafc 0%, #eef4f8 100%);
}

.guide-detail-container {
  max-width: 1280px;
  margin: 0 auto;
}

.hero-card {
  display: grid;
  grid-template-columns: minmax(320px, 480px) 1fr;
  gap: 24px;
  background: #fff;
  border-radius: 24px;
  padding: 24px;
  box-shadow: 0 20px 45px rgba(15, 23, 42, 0.08);
  margin-bottom: 24px;
}

.hero-media {
  min-height: 320px;
}

.hero-image {
  width: 100%;
  height: 100%;
  min-height: 320px;
  object-fit: cover;
  border-radius: 18px;
}

.placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0ea5e9, #22c55e);
  color: #fff;
  font-size: 28px;
  font-weight: 700;
}

.hero-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.guide-title {
  margin: 18px 0 16px;
  font-size: 34px;
  line-height: 1.25;
  color: #0f172a;
}

.guide-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  color: #475569;
  margin-bottom: 22px;
}

.meta-item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.action-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.content-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 300px;
  gap: 24px;
}

.main-panel {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.route-panel,
.article-panel,
.side-card {
  background: #fff;
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 16px 32px rgba(15, 23, 42, 0.06);
}

.panel-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;

  h3 {
    margin: 0 0 6px;
    color: #0f172a;
  }

  p {
    margin: 0;
    color: #64748b;
    line-height: 1.6;
  }
}

.route-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.route-tag {
  display: inline-flex;
  align-items: center;
  padding: 8px 12px;
  border-radius: 999px;
  background: #ecfeff;
  color: #0f766e;
  font-size: 14px;
}

.related-item {
  padding: 14px 0;
  border-bottom: 1px solid #e2e8f0;
  cursor: pointer;

  &:last-child {
    border-bottom: none;
    padding-bottom: 0;
  }
}

.related-title {
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 8px;
}

.related-meta {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #64748b;
  font-size: 13px;
}

.rich-content {
  color: #334155;
  line-height: 1.9;
  word-break: break-word;

  :deep(img) {
    max-width: 100%;
    border-radius: 12px;
  }
}

.guide-not-found {
  min-height: 60vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

@media (max-width: 1024px) {
  .hero-card,
  .content-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .guide-detail-page {
    padding: 16px;
  }

  .hero-card,
  .route-panel,
  .article-panel,
  .side-card {
    padding: 18px;
    border-radius: 16px;
  }

  .guide-title {
    font-size: 28px;
  }

  .panel-header {
    flex-direction: column;
  }
}
</style>
