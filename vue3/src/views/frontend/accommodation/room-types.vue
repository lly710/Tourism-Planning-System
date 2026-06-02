<template>
  <div class="room-type-page">
    <section class="hero-section">
      <div class="hero-overlay"></div>
      <div class="section-container hero-content">
        <el-breadcrumb separator="/" class="breadcrumb">
          <el-breadcrumb-item @click="router.push('/')">首页</el-breadcrumb-item>
          <el-breadcrumb-item @click="router.push('/accommodation')">周边住宿</el-breadcrumb-item>
          <el-breadcrumb-item @click="goToAccommodationDetail">{{ accommodation?.name || '详情' }}</el-breadcrumb-item>
          <el-breadcrumb-item>房型列表</el-breadcrumb-item>
        </el-breadcrumb>

        <div class="hero-main">
          <div>
            <div class="hero-tag">房型信息</div>
            <h1 class="hero-title">{{ accommodation?.name || '房型列表' }}</h1>
            <p class="hero-subtitle">
              可按价格、床型、面积、早餐和窗型条件对比不同房型，方便快速选择适合的住宿方案。
            </p>
          </div>

          <div v-if="accommodation" class="hero-summary">
            <div class="summary-item">
              <span class="summary-label">住宿类型</span>
              <span class="summary-value">{{ accommodation.type || '-' }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">价格区间</span>
              <span class="summary-value price">{{ accommodation.priceRange || '价格面议' }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">联系电话</span>
              <span class="summary-value">{{ accommodation.contactPhone || '暂无' }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="content-section">
      <div class="section-container content-grid">
        <div class="main-content">
          <el-card shadow="never" class="filter-card">
            <div class="filter-header">
              <div>
                <h3>筛选房型</h3>
                <p>支持按房型名称、预订状态和价格区间快速筛选。</p>
              </div>
              <div class="filter-actions">
                <el-button @click="resetFilters">重置</el-button>
                <el-button type="primary" @click="handleSearch">搜索</el-button>
              </div>
            </div>

            <div class="filter-grid">
              <el-input
                v-model="filters.roomName"
                placeholder="请输入房型名称"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>

              <el-select v-model="filters.status" placeholder="房型状态" clearable>
                <el-option label="可预订" :value="1" />
                <el-option label="不可预订" :value="0" />
              </el-select>

              <el-input v-model="filters.minPrice" placeholder="最低价格" clearable />
              <el-input v-model="filters.maxPrice" placeholder="最高价格" clearable />

              <el-select v-model="sortType" placeholder="排序方式">
                <el-option label="默认排序" value="default" />
                <el-option label="价格从低到高" value="priceAsc" />
                <el-option label="价格从高到低" value="priceDesc" />
              </el-select>
            </div>
          </el-card>

          <div v-if="loading" class="loading-state">
            <el-skeleton :rows="8" animated />
          </div>

          <div v-else-if="displayRoomTypes.length" class="room-type-grid">
            <article v-for="item in displayRoomTypes" :key="item.id" class="room-card">
              <div class="room-image">
                <img :src="getImageUrl(item.imageUrl)" :alt="item.roomName" />
                <div class="room-badge-group">
                  <span class="room-badge" :class="item.status === 1 ? 'success' : 'danger'">
                    {{ item.status === 1 ? '可预订' : '不可预订' }}
                  </span>
                  <span v-if="item.breakfast === 1" class="room-badge neutral">含早餐</span>
                </div>
              </div>

              <div class="room-body">
                <div class="room-head">
                  <div>
                    <h3 class="room-name">{{ item.roomName }}</h3>
                    <p class="room-meta">{{ item.bedType || '床型待补充' }}</p>
                  </div>
                  <div class="price-block">
                    <div class="current-price">¥{{ formatPrice(getSalePrice(item)) }}</div>
                    <div v-if="item.discountPrice" class="origin-price">¥{{ formatPrice(item.price) }}</div>
                  </div>
                </div>

                <div class="room-facts">
                  <span>{{ item.roomArea ? `${item.roomArea}㎡` : '面积待补充' }}</span>
                  <span>{{ item.maxOccupancy ? `可住${item.maxOccupancy}人` : '入住人数待补充' }}</span>
                  <span>{{ item.hasWindow === 1 ? '有窗' : '无窗/待确认' }}</span>
                  <span>{{ item.totalRooms !== undefined && item.totalRooms !== null ? `剩余房量${item.totalRooms}` : '房量待补充' }}</span>
                </div>

                <div v-if="parseFacilities(item.facilities).length" class="facility-list">
                  <span
                    v-for="facility in parseFacilities(item.facilities).slice(0, 6)"
                    :key="facility"
                    class="facility-tag"
                  >
                    {{ facility }}
                  </span>
                </div>

                <p class="room-description">{{ truncateText(item.description || '暂无房型介绍。', 90) }}</p>

                <div class="room-actions">
                  <el-button @click="viewRoomType(item)">查看详情</el-button>
                  <el-button type="primary" :disabled="item.status !== 1" @click="bookAccommodation(item)">
                    {{ item.status === 1 ? '立即预订' : '不可预订' }}
                  </el-button>
                </div>
              </div>
            </article>
          </div>

          <div v-else class="empty-state">
            <div class="empty-icon">房</div>
            <h3>暂无符合条件的房型</h3>
            <p>请调整筛选条件后重新搜索。</p>
            <el-button type="primary" @click="resetFilters">重置筛选</el-button>
          </div>

          <div v-if="total > 0" class="pagination-wrapper">
            <el-pagination
              background
              layout="total, prev, pager, next"
              :total="total"
              :page-size="pageSize"
              :current-page="currentPage"
              @current-change="handleCurrentChange"
            />
          </div>
        </div>

        <aside class="sidebar-content">
          <el-card shadow="never" class="side-card">
            <h3 class="side-title">住宿信息</h3>
            <div v-if="accommodation" class="side-info">
              <div class="side-row">
                <span>名称</span>
                <strong>{{ accommodation.name }}</strong>
              </div>
              <div class="side-row">
                <span>地址</span>
                <strong>{{ accommodation.address || '暂无' }}</strong>
              </div>
              <div class="side-row">
                <span>评分</span>
                <strong>{{ getDisplayRating(accommodation.starLevel) }}</strong>
              </div>
              <div class="side-row">
                <span>所属景点</span>
                <strong>{{ accommodation.scenicName || '暂无' }}</strong>
              </div>
            </div>
            <div v-else class="side-placeholder">正在加载住宿信息...</div>

            <div class="side-buttons">
              <el-button type="primary" plain @click="goToAccommodationDetail">返回住宿详情</el-button>
              <el-button type="primary" @click="goToAccommodationOrders">我的酒店订单</el-button>
              <el-button v-if="accommodation?.contactPhone" @click="copyContactPhone">复制电话</el-button>
            </div>
          </el-card>
        </aside>
      </div>
    </section>

    <el-drawer v-model="detailVisible" size="520px" :title="selectedRoomType?.roomName || '房型详情'">
      <div v-if="selectedRoomType" class="drawer-content">
        <img class="drawer-image" :src="getImageUrl(selectedRoomType.imageUrl)" :alt="selectedRoomType.roomName" />

        <div class="drawer-price">
          <span class="drawer-current">¥{{ formatPrice(getSalePrice(selectedRoomType)) }}</span>
          <span v-if="selectedRoomType.discountPrice" class="drawer-origin">¥{{ formatPrice(selectedRoomType.price) }}</span>
        </div>

        <div class="drawer-grid">
          <div class="drawer-item">
            <span>床型</span>
            <strong>{{ selectedRoomType.bedType || '-' }}</strong>
          </div>
          <div class="drawer-item">
            <span>面积</span>
            <strong>{{ selectedRoomType.roomArea ? `${selectedRoomType.roomArea}㎡` : '-' }}</strong>
          </div>
          <div class="drawer-item">
            <span>可住人数</span>
            <strong>{{ selectedRoomType.maxOccupancy ? `${selectedRoomType.maxOccupancy}人` : '-' }}</strong>
          </div>
          <div class="drawer-item">
            <span>房量</span>
            <strong>{{ selectedRoomType.totalRooms ?? '-' }}</strong>
          </div>
          <div class="drawer-item">
            <span>早餐</span>
            <strong>{{ selectedRoomType.breakfast === 1 ? '包含早餐' : '不含早餐' }}</strong>
          </div>
          <div class="drawer-item">
            <span>窗型</span>
            <strong>{{ selectedRoomType.hasWindow === 1 ? '有窗' : '无窗/待确认' }}</strong>
          </div>
        </div>

        <div v-if="parseFacilities(selectedRoomType.facilities).length" class="drawer-section">
          <h4>房间设施</h4>
          <div class="facility-list">
            <span v-for="facility in parseFacilities(selectedRoomType.facilities)" :key="facility" class="facility-tag">
              {{ facility }}
            </span>
          </div>
        </div>

        <div class="drawer-section">
          <h4>房型介绍</h4>
          <p>{{ selectedRoomType.description || '暂无房型介绍。' }}</p>
        </div>

        <div class="drawer-actions">
          <el-button @click="detailVisible = false">关闭</el-button>
          <el-button type="primary" :disabled="selectedRoomType.status !== 1" @click="bookAccommodation(selectedRoomType)">
            {{ selectedRoomType.status === 1 ? '立即预订' : '不可预订' }}
          </el-button>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import { Search } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const baseAPI = process.env.VUE_APP_BASE_API || '/api'

const accommodationId = computed(() => Number(route.params.id))
const accommodation = ref(null)
const roomTypeList = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(9)
const total = ref(0)
const sortType = ref('default')
const detailVisible = ref(false)
const selectedRoomType = ref(null)

const filters = reactive({
  roomName: '',
  status: undefined,
  minPrice: '',
  maxPrice: ''
})

const displayRoomTypes = computed(() => {
  const list = [...roomTypeList.value]

  if (sortType.value === 'priceAsc') {
    return list.sort((a, b) => getSalePrice(a) - getSalePrice(b))
  }

  if (sortType.value === 'priceDesc') {
    return list.sort((a, b) => getSalePrice(b) - getSalePrice(a))
  }

  return list
})

const fetchAccommodationDetail = async () => {
  try {
    await request.get(`/accommodation/${accommodationId.value}`, {}, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        accommodation.value = res
      }
    })
  } catch (error) {
    console.error('获取住宿详情失败:', error)
  }
}

const fetchRoomTypes = async () => {
  loading.value = true
  try {
    const params = {
      accommodationId: accommodationId.value,
      currentPage: currentPage.value,
      size: pageSize.value
    }

    if (filters.roomName) params.roomName = filters.roomName
    if (filters.status !== undefined) params.status = filters.status
    if (filters.minPrice !== '') params.minPrice = filters.minPrice
    if (filters.maxPrice !== '') params.maxPrice = filters.maxPrice

    await request.get('/accommodation/type/page', params, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        roomTypeList.value = res.records || []
        total.value = res.total || 0
      }
    })
  } catch (error) {
    console.error('获取房型列表失败:', error)
    roomTypeList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const getImageUrl = (url) => {
  if (!url) return require('@/assets/images/no-image.png')
  if (url.startsWith('http')) return url
  return `${baseAPI}${url}`
}

const getSalePrice = (item) => Number(item.discountPrice ?? item.price ?? 0)

const formatPrice = (price) => {
  const number = Number(price)
  return Number.isInteger(number) ? String(number) : number.toFixed(2)
}

const getDisplayRating = (rating) => {
  if (!rating) return '4.5'
  return Number(rating).toFixed(1)
}

const parseFacilities = (facilities) => {
  if (!facilities) return []
  return facilities
    .split(/[,，、]/)
    .map(item => item.trim())
    .filter(Boolean)
}

const truncateText = (text, length) => {
  if (!text) return ''
  return text.length > length ? `${text.slice(0, length)}...` : text
}

const handleSearch = () => {
  currentPage.value = 1
  fetchRoomTypes()
}

const resetFilters = () => {
  filters.roomName = ''
  filters.status = undefined
  filters.minPrice = ''
  filters.maxPrice = ''
  sortType.value = 'default'
  currentPage.value = 1
  fetchRoomTypes()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchRoomTypes()
}

const viewRoomType = (item) => {
  selectedRoomType.value = item
  detailVisible.value = true
}

const goToAccommodationDetail = () => {
  router.push(`/accommodation/${accommodationId.value}`)
}

const goToAccommodationOrders = () => {
  router.push('/accommodation/orders')
}

const copyContactPhone = async () => {
  if (!accommodation.value?.contactPhone) {
    ElMessage.warning('暂无联系电话')
    return
  }

  try {
    await navigator.clipboard.writeText(accommodation.value.contactPhone)
    ElMessage.success('联系电话已复制')
  } catch (error) {
    ElMessage.error('复制失败')
  }
}

const bookAccommodation = (item) => {
  if (!item?.id) return
  router.push(`/accommodation/booking/${item.id}`)
}

onMounted(() => {
  fetchAccommodationDetail()
  fetchRoomTypes()
})
</script>

<style lang="scss" scoped>
.room-type-page {
  min-height: 100vh;
  background: #f4f7fb;
  color: #243245;
}

.section-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 20px;
}

.hero-section {
  position: relative;
  overflow: hidden;
  background:
    linear-gradient(120deg, rgba(11, 76, 140, 0.92), rgba(12, 130, 112, 0.78)),
    url('@/assets/bg.jpg') center/cover;
  color: #fff;
}

.hero-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at top right, rgba(255, 255, 255, 0.18), transparent 30%),
    linear-gradient(to bottom, rgba(0, 0, 0, 0.08), rgba(0, 0, 0, 0.2));
}

.hero-content {
  position: relative;
  z-index: 1;
  padding-top: 28px;
  padding-bottom: 56px;
}

.breadcrumb {
  margin-bottom: 28px;

  :deep(.el-breadcrumb__inner),
  :deep(.el-breadcrumb__separator) {
    color: rgba(255, 255, 255, 0.82);
    cursor: pointer;
  }
}

.hero-main {
  display: flex;
  justify-content: space-between;
  gap: 32px;
  align-items: flex-end;
}

.hero-tag {
  display: inline-flex;
  padding: 6px 12px;
  margin-bottom: 16px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  font-size: 13px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.hero-title {
  margin: 0 0 12px;
  font-size: 42px;
  line-height: 1.15;
}

.hero-subtitle {
  max-width: 640px;
  margin: 0;
  font-size: 16px;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.88);
}

.hero-summary {
  min-width: 280px;
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(12px);
}

.summary-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 10px 0;
}

.summary-item + .summary-item {
  border-top: 1px solid rgba(255, 255, 255, 0.14);
}

.summary-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.72);
}

.summary-value {
  font-size: 15px;
  font-weight: 600;
}

.summary-value.price {
  color: #ffd66b;
}

.content-section {
  padding: 32px 0 56px;
}

.content-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 24px;
  align-items: start;
}

.filter-card,
.side-card {
  border: none;
  border-radius: 24px;
  box-shadow: 0 16px 40px rgba(31, 52, 85, 0.08);
}

.filter-header {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;

  h3 {
    margin: 0 0 6px;
    font-size: 20px;
  }

  p {
    margin: 0;
    color: #6d7b8d;
  }
}

.filter-actions {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.filter-grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 14px;
}

.loading-state,
.empty-state {
  margin-top: 24px;
  padding: 32px;
  border-radius: 24px;
  background: #fff;
  box-shadow: 0 16px 40px rgba(31, 52, 85, 0.08);
}

.empty-state {
  text-align: center;
}

.empty-icon {
  margin-bottom: 12px;
  font-size: 48px;
}

.room-type-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
  margin-top: 24px;
}

.room-card {
  overflow: hidden;
  border-radius: 24px;
  background: #fff;
  box-shadow: 0 18px 40px rgba(31, 52, 85, 0.08);
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.room-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 24px 50px rgba(31, 52, 85, 0.12);
}

.room-image {
  position: relative;
  height: 220px;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.room-badge-group {
  position: absolute;
  top: 14px;
  left: 14px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.room-badge {
  padding: 6px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  color: #fff;
}

.room-badge.success {
  background: rgba(16, 185, 129, 0.92);
}

.room-badge.danger {
  background: rgba(239, 68, 68, 0.92);
}

.room-badge.neutral {
  background: rgba(36, 50, 69, 0.75);
}

.room-body {
  padding: 20px;
}

.room-head {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-start;
}

.room-name {
  margin: 0 0 8px;
  font-size: 22px;
}

.room-meta {
  margin: 0;
  color: #6d7b8d;
}

.price-block {
  text-align: right;
}

.current-price {
  color: #d43c2f;
  font-size: 28px;
  font-weight: 700;
}

.origin-price {
  margin-top: 6px;
  color: #98a2b3;
  text-decoration: line-through;
}

.room-facts {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin: 18px 0 14px;

  span {
    padding: 8px 12px;
    border-radius: 999px;
    background: #f3f6fa;
    color: #506071;
    font-size: 13px;
  }
}

.facility-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.facility-tag {
  padding: 6px 10px;
  border-radius: 10px;
  background: #edf6f3;
  color: #14715f;
  font-size: 12px;
}

.room-description {
  min-height: 48px;
  margin: 16px 0 18px;
  color: #5f6f82;
  line-height: 1.7;
}

.room-actions {
  display: flex;
  gap: 12px;
}

.side-title {
  margin: 0 0 18px;
  font-size: 20px;
}

.side-info {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.side-row {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding-bottom: 14px;
  border-bottom: 1px solid #eef2f6;

  span {
    color: #6d7b8d;
    font-size: 13px;
  }

  strong {
    line-height: 1.6;
    word-break: break-word;
  }
}

.side-placeholder {
  color: #6d7b8d;
}

.side-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 20px;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 28px;
}

.drawer-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.drawer-image {
  width: 100%;
  height: 240px;
  object-fit: cover;
  border-radius: 20px;
}

.drawer-price {
  display: flex;
  align-items: baseline;
  gap: 12px;
}

.drawer-current {
  font-size: 32px;
  font-weight: 700;
  color: #d43c2f;
}

.drawer-origin {
  color: #98a2b3;
  text-decoration: line-through;
}

.drawer-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.drawer-item {
  padding: 14px;
  border-radius: 16px;
  background: #f6f8fb;

  span {
    display: block;
    margin-bottom: 6px;
    color: #6d7b8d;
    font-size: 12px;
  }
}

.drawer-section h4 {
  margin: 0 0 12px;
  font-size: 16px;
}

.drawer-section p {
  margin: 0;
  color: #5f6f82;
  line-height: 1.8;
}

.drawer-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 8px;
}

@media (max-width: 1100px) {
  .content-grid {
    grid-template-columns: 1fr;
  }

  .hero-main {
    flex-direction: column;
    align-items: flex-start;
  }

  .hero-summary {
    width: 100%;
    min-width: 0;
  }

  .filter-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .section-container {
    padding: 0 16px;
  }

  .hero-title {
    font-size: 30px;
  }

  .filter-header {
    flex-direction: column;
  }

  .filter-actions,
  .room-actions,
  .drawer-actions {
    flex-direction: column;
  }

  .filter-grid,
  .room-type-grid,
  .drawer-grid {
    grid-template-columns: 1fr;
  }

  .room-image {
    height: 200px;
  }
}
</style>
