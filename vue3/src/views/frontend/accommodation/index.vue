<template>
  <div class="accommodation-frontend-container">
    <div class="search-filter-section">
      <div class="section-container">
        <div class="page-header">
          <div class="header-content">
            <h1 class="page-title">
              <span class="title-icon">🏨</span>
              精选住宿推荐
            </h1>
            <p class="page-subtitle">
              发现舒适便捷的住宿选择，让您的旅程更加轻松惬意
            </p>
          </div>
        </div>

        <div class="search-card">
          <div class="search-header">
            <h3 class="search-title">
              <el-icon><Search /></el-icon>
              智能筛选
            </h3>
          </div>

          <div class="search-form">
            <div class="search-inputs">
              <div class="search-input-group">
                <el-input
                  v-model="searchForm.name"
                  placeholder="搜索住宿名称或地址..."
                  clearable
                  size="large"
                  class="main-search-input"
                  @keyup.enter="handleSearch"
                >
                  <template #prefix>
                    <el-icon><Search /></el-icon>
                  </template>
                </el-input>
              </div>

              <div class="search-input-group">
                <el-select
                  v-model="filters.scenicId"
                  placeholder="选择景点"
                  clearable
                  size="large"
                  style="width: 100%"
                >
                  <el-option
                    v-for="item in scenicOptions"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
              </div>

              <div class="search-actions">
                <el-button type="primary" @click="handleSearch" class="search-btn" size="large">
                  <el-icon><Search /></el-icon>
                  搜索
                </el-button>
                <el-button @click="resetSearch" class="reset-btn" size="large">
                  <el-icon><Refresh /></el-icon>
                  重置
                </el-button>
              </div>
            </div>

            <div class="advanced-filters">
              <div class="filter-row">
                <div class="filter-group">
                  <label class="filter-label">住宿类型</label>
                  <el-select v-model="filters.type" placeholder="选择类型" clearable>
                    <el-option
                      v-for="item in typeOptions"
                      :key="item"
                      :label="item"
                      :value="item"
                    />
                  </el-select>
                </div>

                <div class="filter-group">
                  <label class="filter-label">价格区间</label>
                  <div class="price-range">
                    <el-input v-model="filters.minPrice" placeholder="最低价" />
                    <span class="price-separator">-</span>
                    <el-input v-model="filters.maxPrice" placeholder="最高价" />
                  </div>
                </div>

                <div class="filter-group">
                  <label class="filter-label">最低评分</label>
                  <el-rate v-model="filters.minRating" :max="5" :colors="colors" show-score />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="accommodation-list-section">
      <div class="section-container">
        <div v-if="loading" class="loading-state">
          <el-skeleton :rows="8" animated />
        </div>

        <div v-else-if="accommodationList && accommodationList.length > 0" class="accommodation-grid">
          <div
            v-for="item in accommodationList"
            :key="item.id"
            class="accommodation-card hover-lift"
            @click="goToDetail(item.id)"
          >
            <div class="card-image">
              <img :src="getImageUrl(item.imageUrl)" :alt="item.name" />
              <div class="image-overlay">
                <div class="overlay-content">
                  <div class="accommodation-rating">
                    <el-icon><Star /></el-icon>
                    {{ item.starLevel || '4.5' }}
                  </div>
                </div>
              </div>
              <div class="card-badges">
                <span v-if="item.type" class="badge type">{{ item.type }}</span>
                <span v-if="item.priceRange" class="badge price">{{ item.priceRange }}</span>
              </div>
            </div>

            <div class="card-content">
              <h3 class="accommodation-name">{{ item.name }}</h3>
              <div class="accommodation-location">
                <el-icon><Location /></el-icon>
                {{ item.address || '地址待更新' }}
              </div>
              <div v-if="item.scenicName" class="accommodation-scenic">
                <el-icon><MapLocation /></el-icon>
                靠近 {{ item.scenicName }}
                <span v-if="item.distance" class="distance">{{ item.distance }}</span>
              </div>
              <p class="accommodation-features">
                {{ truncateText(item.features || '舒适便捷的住宿环境，为您提供优质的服务体验', 60) }}
              </p>
              <div class="card-footer">
                <div class="card-meta">
                  <div class="meta-stats">
                    <span class="rating-info">
                      <el-icon><Star /></el-icon>
                      {{ getDisplayRating(item.starLevel) }}
                    </span>
                    <span class="price-info">{{ item.priceRange || '价格面议' }}</span>
                  </div>
                </div>
                <el-button type="primary" size="small" class="detail-btn" @click.stop="goToDetail(item.id)">
                  查看详情
                </el-button>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="empty-state">
          <div class="empty-icon">🏨</div>
          <h3 class="empty-title">暂无住宿信息</h3>
          <p class="empty-desc">试试调整搜索条件或浏览其他选项</p>
          <el-button type="primary" @click="resetSearch" class="empty-action">
            重新搜索
          </el-button>
        </div>

        <div class="pagination-wrapper" v-if="total > 0">
          <el-pagination
            background
            layout="total, prev, pager, next, jumper"
            :current-page="currentPage"
            :page-size="pageSize"
            :total="total"
            @current-change="handleCurrentChange"
            @size-change="handleSizeChange"
            class="modern-pagination"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { Location, Star, Search, Refresh, MapLocation } from '@element-plus/icons-vue'

const router = useRouter()
const baseAPI = process.env.VUE_APP_BASE_API || '/api'

const loading = ref(false)
const accommodationList = ref([])
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)
const scenicOptions = ref([])
const typeOptions = ref([])

const searchForm = reactive({
  name: ''
})

const filters = reactive({
  scenicId: '',
  type: '',
  minPrice: '',
  maxPrice: '',
  minRating: 0
})

const colors = ['#99A9BF', '#F7BA2A', '#FF9900']

const fetchAccommodations = async () => {
  loading.value = true
  try {
    const params = {
      currentPage: currentPage.value,
      size: pageSize.value
    }

    if (searchForm.name) params.name = searchForm.name
    if (filters.scenicId) params.scenicId = filters.scenicId
    if (filters.type) params.type = filters.type
    if (filters.minPrice) params.minPrice = filters.minPrice
    if (filters.maxPrice) params.maxPrice = filters.maxPrice
    if (filters.minRating > 0) params.minRating = filters.minRating

    await request.get('/accommodation/page', params, {
      onSuccess: (res) => {
        accommodationList.value = res.records || []
        total.value = res.total || 0
      }
    })
  } catch (error) {
    console.error('获取住宿列表失败:', error)
  } finally {
    loading.value = false
  }
}

const fetchScenicOptions = async () => {
  try {
    await request.get('/scenic/all', {}, {
      onSuccess: (res) => {
        scenicOptions.value = res || []
      }
    })
  } catch (error) {
    console.error('获取景点列表失败:', error)
  }
}

const fetchAccommodationTypes = async () => {
  try {
    await request.get('/accommodation/types', {}, {
      onSuccess: (res) => {
        typeOptions.value = res || []
      }
    })
  } catch (error) {
    console.error('获取住宿类型列表失败:', error)
  }
}

const getImageUrl = (url) => {
  if (!url) return require('@/assets/images/no-image.png')
  if (url.startsWith('http')) return url
  return baseAPI + url
}

const handleSearch = () => {
  currentPage.value = 1
  fetchAccommodations()
}

const resetSearch = () => {
  searchForm.name = ''
  filters.scenicId = ''
  filters.type = ''
  filters.minPrice = ''
  filters.maxPrice = ''
  filters.minRating = 0
  currentPage.value = 1
  fetchAccommodations()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  fetchAccommodations()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchAccommodations()
}

const goToDetail = (id) => {
  router.push(`/accommodation/${id}`)
}

const truncateText = (text, length) => {
  if (!text) return ''
  return text.length > length ? `${text.substring(0, length)}...` : text
}

const getDisplayRating = (rating) => {
  if (!rating) return '4.5'
  return parseFloat(rating).toFixed(1)
}

onMounted(() => {
  fetchScenicOptions()
  fetchAccommodationTypes()
  fetchAccommodations()
})
</script>

<style lang="scss" scoped>
.accommodation-frontend-container {
  min-height: 100vh;
  background: #f8fafc;
  font-family: "思源黑体", "Source Han Sans", "Noto Sans CJK SC", sans-serif;
  color: #333;

  .section-container {
    max-width: 1300px;
    margin: 0 auto;
    padding: 40px 20px;
  }

  .search-filter-section {
    background: white;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 40px;
    padding: 40px 0 20px;
    border-bottom: 1px solid #e2e8f0;
  }

  .header-content {
    flex: 1;
  }

  .page-title {
    font-size: 36px;
    font-weight: 700;
    margin: 0 0 8px;
    color: #2d3748;
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .title-icon {
    font-size: 32px;
  }

  .page-subtitle {
    font-size: 16px;
    color: #64748b;
    margin: 0;
    line-height: 1.6;
  }

  .search-card {
    background: white;
    border-radius: 16px;
    padding: 32px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    border: 1px solid #e2e8f0;
    margin-bottom: 40px;
  }

  .search-header {
    margin-bottom: 24px;
  }

  .search-title {
    font-size: 20px;
    font-weight: 700;
    color: #2d3748;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .search-form .search-inputs {
    display: grid;
    grid-template-columns: 1fr 200px auto;
    gap: 16px;
    align-items: end;
    margin-bottom: 24px;
  }

  .search-actions {
    display: flex;
    gap: 12px;
  }

  .search-btn {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-weight: 600;
  }

  .reset-btn {
    border-radius: 12px;
    padding: 12px 24px;
    font-weight: 600;
  }

  .advanced-filters {
    border-top: 1px solid #f1f5f9;
    padding-top: 24px;
  }

  .filter-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
  }

  .filter-label {
    display: block;
    font-size: 14px;
    font-weight: 600;
    color: #374151;
    margin-bottom: 8px;
  }

  .price-range {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .price-separator {
    color: #9ca3af;
    font-weight: 500;
  }

  .accommodation-list-section {
    background: #f8fafc;
    min-height: 60vh;
  }

  .loading-state,
  .empty-state {
    background: white;
    border-radius: 16px;
    padding: 40px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  }

  .accommodation-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
    margin-bottom: 40px;
  }

  .accommodation-card {
    background: white;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    border: 1px solid #e2e8f0;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .accommodation-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
    border-color: #667eea;
  }

  .card-image {
    position: relative;
    height: 200px;
    overflow: hidden;
  }

  .card-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .image-overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(to bottom, rgba(0, 0, 0, 0.1) 0%, rgba(0, 0, 0, 0.3) 100%);
    display: flex;
    align-items: flex-end;
    padding: 16px;
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  .accommodation-card:hover .image-overlay {
    opacity: 1;
  }

  .overlay-content {
    width: 100%;
  }

  .accommodation-rating {
    background: rgba(255, 255, 255, 0.9);
    padding: 6px 12px;
    border-radius: 20px;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-size: 14px;
    font-weight: 600;
  }

  .card-badges {
    position: absolute;
    top: 12px;
    left: 12px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    color: white;
  }

  .badge.type {
    background: rgba(102, 126, 234, 0.9);
  }

  .badge.price {
    background: rgba(239, 68, 68, 0.9);
  }

  .card-content {
    padding: 20px;
  }

  .accommodation-name {
    font-size: 18px;
    font-weight: 700;
    color: #2d3748;
    margin: 0 0 12px;
  }

  .accommodation-location,
  .accommodation-scenic {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: #64748b;
    margin-bottom: 8px;
  }

  .distance {
    color: #10b981;
    font-weight: 600;
  }

  .accommodation-features {
    font-size: 14px;
    color: #64748b;
    line-height: 1.5;
    margin: 12px 0;
  }

  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 16px;
    padding-top: 16px;
    border-top: 1px solid #f1f5f9;
  }

  .meta-stats {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .rating-info {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 14px;
    font-weight: 600;
  }

  .price-info {
    font-size: 14px;
    font-weight: 600;
    color: #ef4444;
  }

  .detail-btn {
    border-radius: 20px;
    padding: 8px 16px;
    font-size: 14px;
    font-weight: 600;
  }

  .empty-state {
    text-align: center;
  }

  .empty-icon {
    font-size: 64px;
    margin-bottom: 16px;
  }

  .empty-title {
    font-size: 24px;
    font-weight: 700;
    margin: 0 0 8px;
  }

  .empty-desc {
    font-size: 16px;
    color: #64748b;
    margin: 0 0 24px;
  }

  .empty-action {
    border-radius: 12px;
    padding: 12px 24px;
    font-weight: 600;
  }

  .pagination-wrapper {
    display: flex;
    justify-content: center;
    margin-top: 40px;
  }

  @media (max-width: 768px) {
    .page-title {
      font-size: 28px;
    }

    .search-form .search-inputs {
      grid-template-columns: 1fr;
    }

    .search-actions {
      justify-content: stretch;
    }

    .search-btn,
    .reset-btn {
      flex: 1;
    }

    .accommodation-grid {
      grid-template-columns: 1fr;
    }
  }
}
</style>
