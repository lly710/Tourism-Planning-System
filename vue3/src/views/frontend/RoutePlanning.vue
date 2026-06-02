<template>
  <div class="route-planning-page">
    <div class="page-header">
      <h1 class="page-title">
        <el-icon><Compass /></el-icon>
        智能路线规划
      </h1>
      <p class="page-desc">点击地图或搜索地点，系统会自动计算最优游览路线。</p>
    </div>

    <div v-if="guideImportedPlaces.length" class="guide-import-banner">
      <div class="banner-text">
        已从攻略带入 {{ guideImportedPlaces.length }} 个地点，请先选择你的起点，其余地点会按攻略地点自动加入。
      </div>
      <div class="banner-tags">
        <span
          v-for="(place, index) in guideImportedPlaces"
          :key="`${place.name}_${index}`"
          class="banner-tag"
        >
          {{ index + 1 }}. {{ place.name }}
        </span>
      </div>
    </div>

    <div class="main-content">
      <div class="control-panel">
        <div class="panel-card">
          <div class="card-header">
            <el-icon><Search /></el-icon>
            <span>{{ waitingGuideStart ? '选择新的起点' : '搜索添加地点' }}</span>
          </div>

          <div class="search-box">
            <el-input
              v-model="searchKeyword"
              :placeholder="waitingGuideStart ? '搜索你的出发地点，例如：杭州东站' : '输入地点名称，例如：西湖、故宫'"
              clearable
              @input="handleSearchInput"
              @clear="suggestions = []"
            >
              <template #prefix><el-icon><Search /></el-icon></template>
              <template #suffix>
                <span v-if="searching" class="searching-text">搜索中...</span>
              </template>
            </el-input>

            <div v-if="suggestions.length" class="suggestions-list">
              <div
                v-for="(item, idx) in suggestions"
                :key="idx"
                class="suggestion-item"
                @mousedown.prevent="selectSuggestion(item)"
              >
                <el-icon class="sug-icon"><MapLocation /></el-icon>
                <div class="sug-info">
                  <span class="sug-name">{{ item.name }}</span>
                  <span class="sug-addr">{{ [item.cityname, item.adname, item.address].filter(Boolean).join(' ') }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="panel-card">
          <div class="card-header">
            <el-icon><List /></el-icon>
            <span>当前地点</span>
            <span class="count-badge">{{ places.length }}/10</span>
          </div>

          <div v-if="!places.length" class="empty-tip">
            <el-icon><Aim /></el-icon>
            <span>{{ waitingGuideStart ? '先添加起点，攻略地点会自动跟上' : '点击地图或搜索添加地点' }}</span>
          </div>

          <transition-group name="list" tag="div">
            <div
              v-for="(element, index) in places"
              :key="element.id"
              class="place-item"
              :class="{ 'place-start': index === 0 }"
            >
              <div class="place-order" :class="{ 'order-start': index === 0 }">{{ index + 1 }}</div>
              <div class="place-info">
                <div class="place-name">
                  {{ element.name }}
                  <span v-if="element.isGuideStop" class="guide-stop-tag">攻略地点</span>
                </div>
                <div class="place-coord">{{ element.lng.toFixed(5) }}, {{ element.lat.toFixed(5) }}</div>
                <div v-if="getBookingTargets(element).length" class="booking-links">
                  <el-button
                    v-for="target in getBookingTargets(element)"
                    :key="`${target.type}_${target.id}`"
                    type="primary"
                    text
                    size="small"
                    @click.stop="goToBookingTarget(target)"
                  >
                    {{ target.type === 'scenic' ? '景点预订' : '酒店预订' }}
                  </el-button>
                </div>
              </div>
              <el-button
                type="danger"
                size="small"
                circle
                @click="removePlace(index)"
                :disabled="guideImportedPlaces.length && element.isGuideStop"
              >
                <el-icon><Delete /></el-icon>
              </el-button>
            </div>
          </transition-group>

          <div v-if="places.length >= 2" class="planning-mode-card">
            <div class="planning-mode-label">规划方式</div>
            <el-radio-group v-model="navigationMode" size="small" class="planning-mode-group">
              <el-radio-button label="car">驾车</el-radio-button>
              <el-radio-button label="walk">步行</el-radio-button>
            </el-radio-group>
            <div class="planning-mode-label planning-target-label">规划目标</div>
            <el-radio-group v-model="planningMetric" size="small" class="planning-mode-group">
              <el-radio-button label="distance">最短路径</el-radio-button>
              <el-radio-button label="time">最短时间</el-radio-button>
              <el-radio-button label="time_distance">时间优先（同时间取更短路程）</el-radio-button>
              <el-radio-button label="distance_time">路径优先（同路径取更短时间）</el-radio-button>
            </el-radio-group>
          </div>

          <div v-if="places.length >= 2" class="place-actions">
            <el-button type="primary" size="large" class="plan-btn" :loading="planning" @click="planRoute">
              <el-icon><Position /></el-icon>
              开始规划
            </el-button>
            <el-button size="large" plain @click="clearAll">
              <el-icon><RefreshLeft /></el-icon>
              清空
            </el-button>
          </div>
        </div>

        <div v-if="routeResult" class="panel-card result-card">
          <div class="result-header">
            <el-icon class="result-icon"><CircleCheck /></el-icon>
            <span class="result-title">最优路线</span>
            <el-button size="small" text @click="clearAll">重新规划</el-button>
          </div>

          <div class="stat-row">
            <div class="stat-card">
              <div class="stat-val">{{ formatDistance(routeResult.totalDistance) }}</div>
              <div class="stat-label">总路程</div>
            </div>
            <div class="stat-card">
              <div class="stat-val">{{ routePlacesForPublish.length }}</div>
              <div class="stat-label">地点数</div>
            </div>
          </div>

          <div class="route-timeline">
            <div
              v-for="(place, idx) in routeResult.orderedPlaces"
              :key="`${place.name}_${idx}`"
              class="timeline-item"
            >
              <div class="tl-left">
                <div
                  class="tl-dot"
                  :class="{
                    'dot-start': idx === 0,
                    'dot-end': idx === routeResult.orderedPlaces.length - 1
                  }"
                >
                  <span v-if="idx === 0">出发</span>
                  <span v-else-if="idx === routeResult.orderedPlaces.length - 1">返回</span>
                  <span v-else>{{ idx }}</span>
                </div>
                <div v-if="idx < routeResult.orderedPlaces.length - 1" class="tl-line"></div>
              </div>

              <div class="tl-right">
                <div class="tl-name">{{ place.name }}</div>
                <div v-if="idx < routeResult.orderedPlaces.length - 1" class="tl-dist">
                  <el-icon><Bottom /></el-icon>
                  {{ formatDistanceSeg(routeResult, idx) }}
                </div>
                <div v-if="getBookingTargets(place).length" class="booking-links">
                  <el-button
                    v-for="target in getBookingTargets(place)"
                    :key="`timeline_${target.type}_${target.id}_${idx}`"
                    type="primary"
                    text
                    size="small"
                    @click.stop="goToBookingTarget(target)"
                  >
                    {{ target.type === 'scenic' ? '景点预订' : '酒店预订' }}
                  </el-button>
                </div>
              </div>
            </div>
          </div>

          <div class="segment-nav-panel">
            <div class="segment-nav-header">
              <span>分段导航</span>
              <el-radio-group v-model="navigationMode" size="small">
                <el-radio-button label="car">驾车</el-radio-button>
                <el-radio-button label="walk">步行</el-radio-button>
              </el-radio-group>
            </div>
            <div v-if="adjacentSegments.length" class="segment-nav-toolbar">
              <el-button size="small" :disabled="currentSegmentIndex <= 0" @click="focusPrevSegment">
                上一段
              </el-button>
              <div class="segment-nav-current">
                当前第 {{ currentSegmentIndex + 1 }} 段，共 {{ adjacentSegments.length }} 段
              </div>
              <el-button size="small" :disabled="currentSegmentIndex >= adjacentSegments.length - 1" @click="focusNextSegment">
                下一段
              </el-button>
            </div>
            <div class="segment-nav-list">
              <div
                v-for="(segment, index) in adjacentSegments"
                :key="`${segment.from.name}_${segment.to.name}_${index}`"
                class="segment-nav-item"
                :class="{ active: currentSegmentIndex === index }"
                @click="focusSegment(index)"
              >
                <div class="segment-nav-info">
                  <div class="segment-nav-title">{{ segment.from.name }} -> {{ segment.to.name }}</div>
                  <div class="segment-nav-distance">{{ formatDistance(segment.distance) }}</div>
                </div>
                <el-button type="primary" plain size="small" @click="navigateSegment(segment)">
                  导航这一段
                </el-button>
              </div>
            </div>
          </div>

          <div class="publish-actions">
            <el-button type="success" @click="publishGuide">
              <el-icon><DocumentAdd /></el-icon>
              {{ publishButtonText }}
            </el-button>
          </div>
        </div>
      </div>

      <div class="map-wrapper">
        <div class="map-container" :class="{ 'map-clicking': !routeResult }">
          <div id="amap-container"></div>

          <div class="map-top-bar">
            <template v-if="!routeResult">
              <el-icon><Aim /></el-icon>
              <span>{{ waitingGuideStart ? '点击地图选择新的起点' : '点击地图添加地点' }}</span>
              <span v-if="geocoding" class="geocoding-badge">
                <el-icon class="is-loading"><Loading /></el-icon>
                识别位置中...
              </span>
            </template>
            <template v-else>
              <el-icon class="success-icon"><CircleCheck /></el-icon>
              <span>路线规划完成，共 {{ routePlacesForPublish.length }} 个地点，总距离 {{ formatDistance(routeResult.totalDistance) }}</span>
            </template>
          </div>

          <div v-if="!places.length" class="map-empty">
            <el-icon><MapLocation /></el-icon>
            <p>{{ waitingGuideStart ? '先选一个新的起点' : '点击地图任意位置添加地点' }}</p>
            <p>{{ waitingGuideStart ? '系统会自动拼接攻略中的其他地点' : '也可以在左侧搜索框中输入地点名称' }}</p>
          </div>
        </div>

        <div v-if="routeResult" class="side-nav-panel panel-card">
          <div class="segment-nav-header">
            <span>分段导航</span>
            <el-radio-group v-model="navigationMode" size="small">
              <el-radio-button label="car">驾车</el-radio-button>
              <el-radio-button label="walk">步行</el-radio-button>
            </el-radio-group>
          </div>
          <div v-if="adjacentSegments.length" class="segment-nav-toolbar">
            <el-button size="small" :disabled="currentSegmentIndex <= 0" @click="focusPrevSegment">
              上一段
            </el-button>
            <div class="segment-nav-current">
              当前第 {{ currentSegmentIndex + 1 }} 段，共 {{ adjacentSegments.length }} 段
            </div>
            <el-button size="small" :disabled="currentSegmentIndex >= adjacentSegments.length - 1" @click="focusNextSegment">
              下一段
            </el-button>
          </div>
          <div class="segment-nav-list side-nav-list">
            <div
              v-for="(segment, index) in adjacentSegments"
              :key="`side_${segment.from.name}_${segment.to.name}_${index}`"
              class="segment-nav-item"
              :class="{ active: currentSegmentIndex === index }"
              @click="focusSegment(index)"
            >
              <div class="segment-nav-info">
                <div class="segment-nav-title">{{ segment.from.name }} -> {{ segment.to.name }}</div>
                <div class="segment-nav-distance">{{ formatDistance(segment.distance) }}</div>
                <div class="booking-links">
                  <el-button
                    v-for="target in getBookingTargets(segment.to)"
                    :key="`side_${target.type}_${target.id}_${index}`"
                    type="primary"
                    text
                    size="small"
                    @click.stop="goToBookingTarget(target)"
                  >
                    {{ target.type === 'scenic' ? '景点预订' : '酒店预订' }}
                  </el-button>
                </div>
              </div>
              <el-button type="primary" plain size="small" @click.stop="navigateSegment(segment)">
                导航
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios'
import { computed, nextTick, onActivated, onDeactivated, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Aim,
  Bottom,
  CircleCheck,
  Compass,
  Delete,
  DocumentAdd,
  List,
  Loading,
  MapLocation,
  Position,
  RefreshLeft,
  Search
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { decodeRouteFromQuery, encodeRouteForQuery, normalizeRoutePlaces } from '@/utils/guideRoute'

const AMAP_KEY = '65451f379de90729c07afb7453fa76f8'
const API_BASE = '/api'
const MAX_PLACE_COUNT = 10
const ROUTE_STATE_KEY = 'route-planning-state-v1'
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const searchKeyword = ref('')
const suggestions = ref([])
const searching = ref(false)
const places = ref([])
const planning = ref(false)
const routeResult = ref(null)
const geocoding = ref(false)
const guideImportedPlaces = ref([])
const scenicCatalog = ref([])
const accommodationCatalog = ref([])
const navigationMode = ref('car')
const planningMetric = ref('distance')
const currentSegmentIndex = ref(0)
const latestImportedRouteData = ref('')

let mapInstance = null
let markers = []
let polylines = []
let activeSegmentLine = null
let routeSegmentPaths = []
let placeSearch = null
let walkingService = null
let drivingService = null
let searchDebounce = null
let animTimer = null
let bookingCatalogLoaded = false
let mapResizeTimer = null

const waitingGuideStart = computed(() => guideImportedPlaces.value.length > 0 && places.value.length === 0)
const routePlacesForPublish = computed(() => {
  if (routeResult.value?.orderedPlaces?.length) {
    return normalizeRoutePlaces(routeResult.value.orderedPlaces.slice(0, -1))
  }
  return normalizeRoutePlaces(places.value)
})
const publishButtonText = computed(() => route.query.guideId ? '修改并重新发布攻略' : '一键发布为攻略')
const adjacentSegments = computed(() => {
  if (!routeResult.value?.orderedPlaces?.length) return []

  return routeResult.value.orderedPlaces.slice(0, -1).map((from, index) => {
    const to = routeResult.value.orderedPlaces[index + 1]
    return {
      from,
      to,
      distance: getSegmentDistance(routeResult.value, index)
    }
  })
})

const normalizedScenicMap = computed(() => {
  const map = new Map()
  scenicCatalog.value.forEach((item) => {
    const key = normalizeMatchName(item.name)
    if (key && !map.has(key)) map.set(key, item)
  })
  return map
})

const normalizedAccommodationMap = computed(() => {
  const map = new Map()
  accommodationCatalog.value.forEach((item) => {
    const key = normalizeMatchName(item.name)
    if (key && !map.has(key)) map.set(key, item)
  })
  return map
})

function loadAmapScript() {
  return new Promise((resolve, reject) => {
    if (window.AMap) {
      resolve()
      return
    }

    window._AMapSecurityConfig = { securityJsCode: '802c48bd7f3c0c5bdf29f064a15724f5' }
    const script = document.createElement('script')
    script.src = `https://webapi.amap.com/maps?v=2.0&key=${AMAP_KEY}&plugin=AMap.PlaceSearch,AMap.Polyline,AMap.Driving,AMap.Walking`
    script.onload = resolve
    script.onerror = reject
    document.head.appendChild(script)
  })
}

function normalizeMatchName(name) {
  return String(name || '')
    .toLowerCase()
    .replace(/\s+/g, '')
    .replace(/[()（）\-—·,.，。]/g, '')
}

function buildNameCandidates(name) {
  const base = normalizeMatchName(name)
  if (!base) return []

  const candidates = new Set([base])
  const removableSuffixes = [
    '景区', '景點', '景点', '风景区', '风景名胜区', '旅游区', '公园', '酒店', '大酒店', '宾馆', '旅馆', '民宿', '客栈', '度假酒店'
  ]

  removableSuffixes.forEach((suffix) => {
    if (base.endsWith(suffix)) {
      const shorter = base.slice(0, -suffix.length)
      if (shorter) candidates.add(shorter)
    }
  })

  return Array.from(candidates).filter(Boolean)
}

function findBestCatalogMatch(placeName, catalog = []) {
  const candidates = buildNameCandidates(placeName)
  if (!candidates.length || !catalog.length) return null

  let bestMatch = null
  let bestScore = -1

  for (const item of catalog) {
    const itemCandidates = buildNameCandidates(item.name)
    for (const candidate of candidates) {
      for (const itemCandidate of itemCandidates) {
        let score = -1
        if (candidate === itemCandidate) {
          score = 100
        } else if (candidate.includes(itemCandidate) || itemCandidate.includes(candidate)) {
          score = Math.min(candidate.length, itemCandidate.length)
        }

        if (score > bestScore) {
          bestScore = score
          bestMatch = item
        }
      }
    }
  }

  return bestScore >= 2 ? bestMatch : null
}

async function loadBookingCatalogs() {
  if (bookingCatalogLoaded) return

  try {
    const [scenicResponse, accommodationResponse] = await Promise.all([
      axios.get(`${API_BASE}/scenic/all`),
      axios.get(`${API_BASE}/accommodation/page`, {
        params: { currentPage: 1, size: 500 }
      })
    ])

    scenicCatalog.value = scenicResponse.data?.code === '200' ? (scenicResponse.data.data || []) : []
    accommodationCatalog.value = accommodationResponse.data?.code === '200'
      ? (accommodationResponse.data.data?.records || [])
      : []
    bookingCatalogLoaded = true
  } catch (error) {
    console.error('加载景点和酒店目录失败', error)
  }
}

function hasPlannerState() {
  return !!(places.value.length || guideImportedPlaces.value.length || routeResult.value)
}

function normalizeSavedPlace(place, index = 0) {
  return {
    id: place?.id || `saved_${Date.now()}_${index}_${Math.random()}`,
    name: place?.name || `place_${index + 1}`,
    lng: Number(place?.lng),
    lat: Number(place?.lat),
    isGuideStop: !!place?.isGuideStop
  }
}

function saveRouteState() {
  if (typeof window === 'undefined') return

  const payload = {
    places: places.value,
    routeResult: routeResult.value,
    guideImportedPlaces: guideImportedPlaces.value,
    navigationMode: navigationMode.value,
    planningMetric: planningMetric.value,
    currentSegmentIndex: currentSegmentIndex.value,
    latestImportedRouteData: latestImportedRouteData.value
  }

  window.sessionStorage.setItem(ROUTE_STATE_KEY, JSON.stringify(payload))
}

function restoreRouteState() {
  if (typeof window === 'undefined') return false

  const raw = window.sessionStorage.getItem(ROUTE_STATE_KEY)
  if (!raw) return false

  try {
    const payload = JSON.parse(raw)
    places.value = Array.isArray(payload?.places)
      ? payload.places.map((place, index) => normalizeSavedPlace(place, index))
      : []
    routeResult.value = payload?.routeResult || null
    guideImportedPlaces.value = Array.isArray(payload?.guideImportedPlaces)
      ? payload.guideImportedPlaces.map((place, index) => normalizeSavedPlace(place, index))
      : []
    navigationMode.value = payload?.navigationMode === 'walk' ? 'walk' : 'car'
    planningMetric.value = ['time', 'time_distance', 'distance', 'distance_time'].includes(payload?.planningMetric)
      ? payload.planningMetric
      : 'distance'
    currentSegmentIndex.value = Number.isInteger(payload?.currentSegmentIndex) ? payload.currentSegmentIndex : 0
    latestImportedRouteData.value = payload?.latestImportedRouteData || ''
    return hasPlannerState()
  } catch {
    return false
  }
}

function resetPlannerState() {
  places.value = []
  routeResult.value = null
  guideImportedPlaces.value = []
  currentSegmentIndex.value = 0
  suggestions.value = []
  searchKeyword.value = ''
  markers.forEach(({ marker }) => marker.setMap(null))
  markers = []
  clearPolylines()
}

function applyImportedRoute(routeData) {
  const imported = decodeRouteFromQuery(routeData)
  if (!imported.length) return false

  const normalized = normalizeRoutePlaces(imported)
  resetPlannerState()
  guideImportedPlaces.value = normalized.slice(1).map((place, index) => normalizeSavedPlace(place, index))
  latestImportedRouteData.value = routeData
  saveRouteState()
  return true
}

async function syncMapWithState() {
  if (!mapInstance) return

  await nextTick()
  triggerMapResize()

  if (routeResult.value?.orderedPlaces?.length) {
    await drawRoute(routeResult.value.orderedPlaces)
    if (adjacentSegments.value.length) {
      currentSegmentIndex.value = Math.min(currentSegmentIndex.value, adjacentSegments.value.length - 1)
      await highlightCurrentSegment()
    }
    return
  }

  clearPolylines()
  refreshMarkers()
}

function triggerMapResize(delay = 0) {
  if (!mapInstance) return

  window.clearTimeout(mapResizeTimer)
  mapResizeTimer = window.setTimeout(() => {
    if (!mapInstance || typeof mapInstance.resize !== 'function') return
    mapInstance.resize()
  }, delay)
}

function handleViewportChange() {
  triggerMapResize(60)
  triggerMapResize(220)
}

function resolveDrivingPolicy(metric = planningMetric.value) {
  return metric === 'distance' ? 2 : 0
}

function initializePlannerState() {
  const queryRouteData = typeof route.query.routeData === 'string' ? route.query.routeData : ''
  if (queryRouteData) {
    if (queryRouteData !== latestImportedRouteData.value || !hasPlannerState()) {
      return applyImportedRoute(queryRouteData)
    }
    return true
  }

  if (!hasPlannerState()) {
    return restoreRouteState()
  }

  return true
}

async function initMap() {
  await loadAmapScript()
  await nextTick()

  mapInstance = new window.AMap.Map('amap-container', {
    zoom: 12,
    center: [116.397428, 39.90923],
    mapStyle: 'amap://styles/fresh'
  })

  placeSearch = new window.AMap.PlaceSearch({
    pageSize: 8,
    pageIndex: 1,
    city: '全国',
    citylimit: false
  })

  walkingService = new window.AMap.Walking({
    hideMarkers: true,
    autoFitView: false
  })

  drivingService = new window.AMap.Driving({
    hideMarkers: true,
    showTraffic: false,
    autoFitView: false,
    policy: resolveDrivingPolicy()
  })

  mapInstance.on('click', onMapClick)
}

function handleSearchInput() {
  clearTimeout(searchDebounce)
  if (!searchKeyword.value.trim()) {
    suggestions.value = []
    return
  }
  searchDebounce = setTimeout(doSearch, 500)
}

function doSearch() {
  const keyword = searchKeyword.value.trim()
  if (!keyword || !placeSearch) return

  searching.value = true
  suggestions.value = []
  placeSearch.search(keyword, (status, result) => {
    searching.value = false
    if (status === 'complete' && result?.poiList?.pois?.length) {
      suggestions.value = result.poiList.pois
        .filter((poi) => poi.location)
        .slice(0, 8)
        .map((poi) => ({
          name: poi.name,
          address: typeof poi.address === 'string' ? poi.address : '',
          cityname: poi.cityname || '',
          adname: poi.adname || '',
          lng: poi.location.lng,
          lat: poi.location.lat
        }))
      return
    }
    suggestions.value = []
  })
}

function appendGuidePlacesIfNeeded() {
  if (!guideImportedPlaces.value.length || places.value.length !== 1) return

  const remain = guideImportedPlaces.value.map((place, index) => ({
    ...place,
    id: `guide_${Date.now()}_${index}`,
    isGuideStop: true
  }))
  places.value = [places.value[0], ...remain].slice(0, MAX_PLACE_COUNT)
  refreshMarkers()
}

function getBookingTargets(place) {
  const keyCandidates = buildNameCandidates(place?.name)
  if (!keyCandidates.length) return []

  let scenic = null
  let accommodation = null

  for (const key of keyCandidates) {
    scenic = scenic || normalizedScenicMap.value.get(key)
    accommodation = accommodation || normalizedAccommodationMap.value.get(key)
  }

  scenic = scenic || findBestCatalogMatch(place?.name, scenicCatalog.value)
  accommodation = accommodation || findBestCatalogMatch(place?.name, accommodationCatalog.value)
  const result = []

  if (scenic) {
    result.push({ type: 'scenic', id: scenic.id, name: scenic.name })
  }
  if (accommodation) {
    result.push({ type: 'accommodation', id: accommodation.id, name: accommodation.name })
  }

  return result
}

function goToBookingTarget(target) {
  if (target.type === 'scenic') {
    router.push(`/scenic/${target.id}`)
    return
  }

  if (target.type === 'accommodation') {
    router.push(`/accommodation/${target.id}/room-types`)
  }
}

function selectSuggestion(item) {
  if (guideImportedPlaces.value.length && places.value.length > 0) {
    ElMessage.warning('该路线已从攻略导入，当前只支持重新选择起点')
    return
  }

  if (places.value.length >= MAX_PLACE_COUNT && !waitingGuideStart.value) {
    ElMessage.warning(`最多添加 ${MAX_PLACE_COUNT} 个地点`)
    return
  }

  suggestions.value = []
  searchKeyword.value = ''
  doAddPlace(item.lng, item.lat, item.name)
  if (mapInstance) {
    mapInstance.setCenter([item.lng, item.lat])
  }
}

async function onMapClick(event) {
  if (routeResult.value) return
  if (guideImportedPlaces.value.length && places.value.length > 0) {
    ElMessage.warning('该路线已从攻略导入，当前只支持重新选择起点')
    return
  }
  if (places.value.length >= MAX_PLACE_COUNT && !waitingGuideStart.value) {
    ElMessage.warning(`最多添加 ${MAX_PLACE_COUNT} 个地点`)
    return
  }

  const { lng, lat } = event.lnglat
  geocoding.value = true
  try {
    const { data } = await axios.get(`${API_BASE}/route/regeo`, { params: { lng, lat } })
    const name = data.code === '200' && data.data?.name
      ? data.data.name
      : `位置(${lng.toFixed(4)}, ${lat.toFixed(4)})`
    doAddPlace(lng, lat, name)
  } catch (error) {
    doAddPlace(lng, lat, `位置(${lng.toFixed(4)}, ${lat.toFixed(4)})`)
  } finally {
    geocoding.value = false
  }
}

function doAddPlace(lng, lat, name) {
  if (waitingGuideStart.value) {
    places.value = [{
      id: Date.now() + Math.random(),
      name,
      lng,
      lat,
      isGuideStop: false
    }]
    appendGuidePlacesIfNeeded()
    ElMessage.success('起点已加入，攻略地点已自动带入')
    return
  }

  if (places.value.length >= MAX_PLACE_COUNT) {
    ElMessage.warning(`最多添加 ${MAX_PLACE_COUNT} 个地点`)
    return
  }

  const place = { id: Date.now() + Math.random(), name, lng, lat, isGuideStop: false }
  places.value.push(place)
  addMarker(place, places.value.length - 1)
  ElMessage.success(`已添加：${name}`)
}

function addMarker(place, index) {
  if (!mapInstance) return

  const isFirst = index === 0
  const bgColor = isFirst ? '#ff6b35' : (place.isGuideStop ? '#14b8a6' : '#1890ff')
  const marker = new window.AMap.Marker({
    position: [place.lng, place.lat],
    title: place.name,
    label: {
      content: `<div style="background:${bgColor};color:#fff;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:600;white-space:nowrap;box-shadow:0 2px 6px rgba(0,0,0,.2)">${index + 1}. ${place.name}</div>`,
      direction: 'top',
      offset: new window.AMap.Pixel(0, -4)
    }
  })

  marker.setMap(mapInstance)
  markers.push({ marker, placeId: place.id })
  fitMapView()
}

function refreshMarkers() {
  markers.forEach(({ marker }) => marker.setMap(null))
  markers = []
  places.value.forEach((place, index) => addMarker(place, index))
}

function fitMapView() {
  if (!mapInstance || !places.value.length) return

  if (places.value.length === 1) {
    mapInstance.setCenter([places.value[0].lng, places.value[0].lat])
    mapInstance.setZoom(15)
    return
  }

  const lngs = places.value.map((place) => place.lng)
  const lats = places.value.map((place) => place.lat)
  mapInstance.setBounds(
    new window.AMap.Bounds(
      [Math.min(...lngs), Math.min(...lats)],
      [Math.max(...lngs), Math.max(...lats)]
    ),
    false,
    [80, 80, 80, 80]
  )
}

function removePlace(index) {
  const target = places.value[index]
  if (guideImportedPlaces.value.length && target?.isGuideStop) return

  if (guideImportedPlaces.value.length && index === 0) {
    clearAll()
    return
  }

  const removed = places.value.splice(index, 1)[0]
  const markerIndex = markers.findIndex((item) => item.placeId === removed.id)
  if (markerIndex !== -1) {
    markers[markerIndex].marker.setMap(null)
    markers.splice(markerIndex, 1)
  }
  clearPolylines()
  routeResult.value = null
  refreshMarkers()
}

function clearPolylines() {
  stopAntLineAnim()
  polylines.forEach((polyline) => polyline.setMap(null))
  polylines = []
  routeSegmentPaths = []
  if (activeSegmentLine) {
    activeSegmentLine.setMap(null)
    activeSegmentLine = null
  }
}

function clearAll() {
  places.value = []
  markers.forEach(({ marker }) => marker.setMap(null))
  markers = []
  clearPolylines()
  routeSegmentPaths = []
  routeResult.value = null
}

async function planRoute(options = {}) {
  const { silent = false } = options
  if (places.value.length < 2) {
    ElMessage.warning('至少需要 2 个地点')
    return
  }

  planning.value = true
  try {
    const { data } = await axios.post(`${API_BASE}/route/plan`, {
      travelMode: navigationMode.value,
      planningStrategy: planningMetric.value,
      places: places.value.map((place) => ({
        name: place.name,
        lng: place.lng,
        lat: place.lat
      }))
    })

    if (data.code === '200') {
      routeResult.value = data.data
      await drawRoute(data.data.orderedPlaces)
      currentSegmentIndex.value = 0
      await highlightCurrentSegment()
      if (!silent) {
        ElMessage.success('路线规划成功')
      }
      return
    }

    ElMessage.error(data.msg || '路线规划失败')
  } catch (error) {
    ElMessage.error(`请求失败：${error.message || '未知错误'}`)
  } finally {
    planning.value = false
  }
}

function searchWalkingPath(from, to) {
  return new Promise((resolve, reject) => {
    if (!walkingService) {
      reject(new Error('walking service unavailable'))
      return
    }

    walkingService.search(
      new window.AMap.LngLat(from.lng, from.lat),
      new window.AMap.LngLat(to.lng, to.lat),
      (status, result) => {
        if (status !== 'complete' || !result?.routes?.length) {
          reject(new Error('no walking route'))
          return
        }

        const path = result.routes[0].steps.flatMap((step) => (step.path || []).map((point) => [point.lng, point.lat]))
        path.length ? resolve(path) : reject(new Error('empty walking path'))
      }
    )
  })
}

function searchDrivingPath(from, to) {
  return new Promise((resolve, reject) => {
    const policy = resolveDrivingPolicy()
    if (!window.AMap) {
      reject(new Error('driving service unavailable'))
      return
    }

    if (!drivingService || drivingService.__policy !== policy) {
      drivingService = new window.AMap.Driving({
        hideMarkers: true,
        showTraffic: false,
        autoFitView: false,
        policy
      })
      drivingService.__policy = policy
    }

    drivingService.search(
      new window.AMap.LngLat(from.lng, from.lat),
      new window.AMap.LngLat(to.lng, to.lat),
      (status, result) => {
        if (status !== 'complete' || !result?.routes?.length) {
          reject(new Error('no driving route'))
          return
        }

        const path = result.routes[0].steps.flatMap((step) => (step.path || []).map((point) => [point.lng, point.lat]))
        path.length ? resolve(path) : reject(new Error('empty driving path'))
      }
    )
  })
}

async function buildSegmentPath(from, to, mode = navigationMode.value) {
  const preferredMode = mode === 'walk' ? 'walk' : 'car'

  if (preferredMode === 'walk') {
    try {
      return await searchWalkingPath(from, to)
    } catch {
      try {
        return await searchDrivingPath(from, to)
      } catch {
        return [
          [from.lng, from.lat],
          [to.lng, to.lat]
        ]
      }
    }
  }

  try {
    return await searchDrivingPath(from, to)
  } catch {
    try {
      return await searchWalkingPath(from, to)
    } catch {
      return [
        [from.lng, from.lat],
        [to.lng, to.lat]
      ]
    }
  }
}

async function buildRoutePath(orderedPlaces, mode = navigationMode.value) {
  const segments = []
  for (let index = 0; index < orderedPlaces.length - 1; index++) {
    const from = orderedPlaces[index]
    const to = orderedPlaces[index + 1]
    const segmentPath = await buildSegmentPath(from, to, mode)
    segments.push(segmentPath)
  }

  const fullPath = segments.reduce((accumulator, segment, index) => {
    if (index === 0) return segment
    return accumulator.concat(segment.slice(1))
  }, [])

  return {
    segments,
    fullPath
  }
}

async function drawRoute(orderedPlaces, mode = navigationMode.value) {
  clearPolylines()
  markers.forEach(({ marker }) => marker.setMap(null))
  markers = []

  const displayPlaces = orderedPlaces.slice(0, orderedPlaces.length - 1)
  displayPlaces.forEach((place, index) => {
    const bgColor = index === 0 ? '#ff6b35' : '#1890ff'
    const marker = new window.AMap.Marker({
      position: [place.lng, place.lat],
      title: place.name,
      label: {
        content: `<div style="background:${bgColor};color:#fff;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:600;white-space:nowrap;box-shadow:0 2px 6px rgba(0,0,0,.25)">${index + 1}. ${place.name}</div>`,
        direction: 'top',
        offset: new window.AMap.Pixel(0, -4)
      }
    })
    marker.setMap(mapInstance)
    markers.push({ marker, placeId: `route_${index}` })
  })

  const { segments, fullPath } = await buildRoutePath(orderedPlaces, mode)
  routeSegmentPaths = segments

  const baseLine = new window.AMap.Polyline({
    path: fullPath,
    strokeColor: '#1890ff',
    strokeWeight: 7,
    strokeOpacity: 0.95,
    strokeStyle: 'solid',
    lineJoin: 'round',
    lineCap: 'round',
    zIndex: 100
  })
  baseLine.setMap(mapInstance)
  polylines.push(baseLine)

  fitMapToPath(fullPath)
}

function fitMapToPath(path) {
  if (!mapInstance || !path.length) return

  const lngs = path.map((point) => point[0])
  const lats = path.map((point) => point[1])
  mapInstance.setBounds(
    new window.AMap.Bounds(
      [Math.min(...lngs), Math.min(...lats)],
      [Math.max(...lngs), Math.max(...lats)]
    ),
    false,
    [80, 80, 80, 80]
  )
}

function stopAntLineAnim() {
  if (animTimer) {
    clearInterval(animTimer)
    animTimer = null
  }
}

async function highlightCurrentSegment() {
  if (!mapInstance || !adjacentSegments.value.length) return

  const segment = adjacentSegments.value[currentSegmentIndex.value]
  if (!segment) return

  const path = routeSegmentPaths[currentSegmentIndex.value]
    || await buildSegmentPath(segment.from, segment.to, navigationMode.value)
  if (activeSegmentLine) {
    activeSegmentLine.setMap(null)
    activeSegmentLine = null
  }

  activeSegmentLine = new window.AMap.Polyline({
    path,
    strokeColor: '#ff7a00',
    strokeWeight: 8,
    strokeOpacity: 0.98,
    strokeStyle: 'solid',
    lineJoin: 'round',
    lineCap: 'round',
    zIndex: 130
  })
  activeSegmentLine.setMap(mapInstance)
  fitMapToPath(path)
}

function formatDistance(meters) {
  if (!meters) return '--'
  return meters >= 1000 ? `${(meters / 1000).toFixed(1)} km` : `${Math.round(meters)} m`
}

function formatDistanceSeg(result, idx) {
  return formatDistance(getSegmentDistance(result, idx))
}

function getSegmentDistance(result, idx) {
  const order = result.order
  const distMatrix = result.distMatrix
  const isLastSegment = idx === result.orderedPlaces.length - 2
  const from = order[idx]
  const to = isLastSegment ? order[0] : order[idx + 1]
  return (distMatrix[from] && distMatrix[from][to]) || 0
}

function buildNavigationUrl(segment) {
  const mode = navigationMode.value === 'walk' ? 'walk' : 'car'
  const from = `${segment.from.lng},${segment.from.lat},${encodeURIComponent(segment.from.name)}`
  const to = `${segment.to.lng},${segment.to.lat},${encodeURIComponent(segment.to.name)}`
  const policy = resolveDrivingPolicy()
  return `https://uri.amap.com/navigation?from=${from}&to=${to}&mode=${mode}&policy=${policy}&src=route-planning&coordinate=gaode&callnative=0`
}

function navigateSegment(segment) {
  if (!segment?.from || !segment?.to) {
    ElMessage.warning('当前分段导航信息不完整')
    return
  }

  window.open(buildNavigationUrl(segment), '_blank', 'noopener')
}

function focusSegment(index) {
  if (index < 0 || index >= adjacentSegments.value.length) return
  currentSegmentIndex.value = index
  highlightCurrentSegment()
}

function focusPrevSegment() {
  if (currentSegmentIndex.value <= 0) return
  currentSegmentIndex.value -= 1
  highlightCurrentSegment()
}

function focusNextSegment() {
  if (currentSegmentIndex.value >= adjacentSegments.value.length - 1) return
  currentSegmentIndex.value += 1
  highlightCurrentSegment()
}

function publishGuide() {
  if (!routePlacesForPublish.value.length) {
    ElMessage.warning('请先完成路线规划')
    return
  }

  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录后再发布攻略')
    router.push('/login?redirect=' + route.fullPath)
    return
  }

  router.push({
    name: 'GuideEdit',
    query: {
      ...(route.query.guideId ? { id: route.query.guideId } : {}),
      routeData: encodeRouteForQuery(routePlacesForPublish.value)
    }
  })
}

onMounted(async () => {
  initializePlannerState()
  await loadBookingCatalogs()

  try {
    await initMap()
    triggerMapResize(0)
    triggerMapResize(180)
    await syncMapWithState()
  } catch (error) {
    ElMessage.error('高德地图加载失败，请检查网络连接')
  }

  window.addEventListener('resize', handleViewportChange)
  window.addEventListener('orientationchange', handleViewportChange)
  window.addEventListener('pageshow', handleViewportChange)
})

onActivated(async () => {
  initializePlannerState()
  await loadBookingCatalogs()
  triggerMapResize(0)
  triggerMapResize(180)
  await syncMapWithState()
})

onDeactivated(() => {
  saveRouteState()
  stopAntLineAnim()
})

watch(
  [places, routeResult, guideImportedPlaces, navigationMode, planningMetric, currentSegmentIndex],
  () => {
    saveRouteState()
  },
  { deep: true }
)

watch(
  () => route.query.routeData,
  async (newValue) => {
    if (typeof newValue !== 'string' || !newValue) return
    if (newValue === latestImportedRouteData.value && hasPlannerState()) return

    applyImportedRoute(newValue)
    await syncMapWithState()
  }
)

watch(
  [navigationMode, planningMetric],
  async ([newMode, newMetric], [oldMode, oldMetric]) => {
    if ((newMode === oldMode && newMetric === oldMetric) || !routeResult.value?.orderedPlaces?.length) return
    await planRoute({ silent: true })
  }
)

onUnmounted(() => {
  saveRouteState()
  stopAntLineAnim()
  window.removeEventListener('resize', handleViewportChange)
  window.removeEventListener('orientationchange', handleViewportChange)
  window.removeEventListener('pageshow', handleViewportChange)
  window.clearTimeout(mapResizeTimer)
  if (searchDebounce) {
    clearTimeout(searchDebounce)
  }
  if (mapInstance) {
    mapInstance.destroy()
    mapInstance = null
  }
})
</script>

<style scoped>
.route-planning-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f4ff 0%, #f5f7fa 100%);
  padding: 24px 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 20px;
}

.page-title {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-size: 30px;
  font-weight: 800;
  color: #1a1a2e;
  margin: 0 0 8px;
}

.page-desc {
  color: #777;
  font-size: 14px;
  margin: 0;
}

.guide-import-banner {
  max-width: 1440px;
  margin: 0 auto 16px;
  background: linear-gradient(135deg, #ecfeff, #eff6ff);
  border: 1px solid #bae6fd;
  border-radius: 16px;
  padding: 16px 18px;
}

.banner-text {
  color: #0f172a;
  font-weight: 600;
  margin-bottom: 10px;
}

.banner-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.banner-tag,
.guide-stop-tag {
  display: inline-flex;
  align-items: center;
  border-radius: 999px;
}

.banner-tag {
  padding: 6px 10px;
  background: #dbeafe;
  color: #1d4ed8;
  font-size: 12px;
}

.guide-stop-tag {
  margin-left: 8px;
  padding: 2px 8px;
  background: #ccfbf1;
  color: #0f766e;
  font-size: 12px;
}

.main-content {
  display: flex;
  gap: 20px;
  max-width: 1440px;
  margin: 0 auto;
  align-items: flex-start;
}

.control-panel {
  width: 370px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.panel-card {
  background: #fff;
  border-radius: 14px;
  padding: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
  border: 1px solid #f0f0f0;
}

.card-header,
.result-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 14px;
}

.count-badge {
  margin-left: auto;
  background: #eff6ff;
  color: #1d4ed8;
  border-radius: 999px;
  padding: 2px 10px;
  font-size: 12px;
}

.search-box {
  position: relative;
}

.searching-text {
  color: #1890ff;
  font-size: 12px;
}

.suggestions-list {
  margin-top: 10px;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  overflow: hidden;
}

.suggestion-item {
  display: flex;
  gap: 10px;
  padding: 12px;
  cursor: pointer;
  background: #fff;
}

.suggestion-item + .suggestion-item {
  border-top: 1px solid #f3f4f6;
}

.suggestion-item:hover {
  background: #f8fafc;
}

.sug-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.sug-name {
  font-weight: 600;
  color: #111827;
}

.sug-addr {
  font-size: 12px;
  color: #6b7280;
}

.empty-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #6b7280;
  min-height: 70px;
}

.place-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f3f4f6;
}

.place-item:last-child {
  border-bottom: none;
}

.place-order {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #dbeafe;
  color: #1d4ed8;
  font-size: 13px;
  font-weight: 700;
}

.order-start {
  background: #fed7aa;
  color: #c2410c;
}

.place-info {
  flex: 1;
  min-width: 0;
}

.place-name {
  font-weight: 600;
  color: #111827;
}

.booking-links {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 6px;
}

.place-coord {
  font-size: 12px;
  color: #6b7280;
  margin-top: 4px;
}

.place-actions,
.publish-actions {
  display: flex;
  gap: 10px;
  margin-top: 14px;
}

.planning-mode-card {
  margin-top: 16px;
  padding: 18px;
  border-radius: 18px;
  background: linear-gradient(180deg, #f8fbff 0%, #f3f7fb 100%);
  border: 1px solid #dbe7f3;
}

.planning-mode-label {
  margin-bottom: 12px;
  font-size: 14px;
  font-weight: 700;
  text-align: center;
  color: #0f172a;
}

.planning-target-label {
  margin-top: 18px;
}

.planning-mode-group {
  display: grid;
  width: 100%;
  gap: 10px;
}

.planning-mode-card .planning-mode-group:first-of-type {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.planning-mode-card .planning-mode-group:last-of-type {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.planning-mode-group :deep(.el-radio-button) {
  width: 100%;
}

.planning-mode-group :deep(.el-radio-button__inner) {
  width: 100%;
  min-height: 60px;
  padding: 14px 12px;
  border: 1px solid #cfd8e3;
  border-radius: 18px !important;
  background: #ffffff;
  color: #1e293b;
  font-size: 15px;
  font-weight: 700;
  line-height: 1.45;
  white-space: normal;
  word-break: break-word;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
  transition: all 0.2s ease;
}

.planning-mode-group :deep(.el-radio-button:first-child .el-radio-button__inner),
.planning-mode-group :deep(.el-radio-button:last-child .el-radio-button__inner) {
  border-radius: 18px !important;
}

.planning-mode-group :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
  border-color: #2f80ed;
  background: linear-gradient(135deg, #2ea7e0 0%, #2f6fed 100%);
  color: #fff;
  box-shadow: 0 12px 24px rgba(47, 111, 237, 0.18);
}

.planning-mode-group :deep(.el-radio-button__inner:hover) {
  border-color: #93c5fd;
  color: #0f172a;
}

.plan-btn {
  flex: 1;
}

.stat-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
  margin-bottom: 16px;
}

.stat-card {
  background: #f8fafc;
  border-radius: 12px;
  padding: 14px;
}

.stat-val {
  font-size: 22px;
  font-weight: 700;
  color: #0f172a;
}

.stat-label {
  margin-top: 6px;
  color: #64748b;
  font-size: 13px;
}

.route-timeline {
  position: relative;
}

.segment-nav-panel {
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px solid #e5e7eb;
  display: none;
}

.segment-nav-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
  color: #111827;
  font-weight: 600;
}

.segment-nav-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 12px;
}

.segment-nav-current {
  flex: 1;
  text-align: center;
  font-size: 13px;
  color: #475569;
}

.segment-nav-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.segment-nav-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  background: #f8fafc;
  cursor: pointer;
  transition: all 0.2s ease;
}

.segment-nav-item.active {
  background: #fff7ed;
  box-shadow: inset 0 0 0 1px #fdba74;
}

.segment-nav-info {
  min-width: 0;
}

.segment-nav-title {
  color: #111827;
  font-weight: 600;
  line-height: 1.4;
}

.segment-nav-distance {
  margin-top: 4px;
  font-size: 12px;
  color: #6b7280;
}

.timeline-item {
  display: flex;
  gap: 12px;
}

.tl-left {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.tl-dot {
  min-width: 50px;
  height: 28px;
  padding: 0 10px;
  border-radius: 999px;
  background: #dbeafe;
  color: #1d4ed8;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
}

.dot-start {
  background: #fed7aa;
  color: #c2410c;
}

.dot-end {
  background: #dcfce7;
  color: #15803d;
}

.tl-line {
  width: 2px;
  flex: 1;
  background: #cbd5e1;
  margin: 6px 0;
}

.tl-right {
  padding-bottom: 16px;
}

.tl-name {
  font-weight: 600;
  color: #111827;
}

.tl-dist {
  margin-top: 6px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #64748b;
  font-size: 12px;
}

.map-wrapper {
  flex: 1;
  min-width: 0;
  display: grid;
  grid-template-columns: minmax(0, 1fr) 340px;
  gap: 16px;
  align-items: start;
}

.side-nav-panel {
  position: sticky;
  top: 0;
}

.side-nav-list {
  max-height: calc(100vh - 250px);
  overflow: auto;
  padding-right: 4px;
}

.map-container {
  position: relative;
  height: calc(100vh - 170px);
  min-height: 620px;
  overflow: hidden;
  border-radius: 18px;
  background: #fff;
  box-shadow: 0 6px 28px rgba(0, 0, 0, 0.08);
}

#amap-container {
  width: 100%;
  height: 100%;
}

.map-top-bar {
  position: absolute;
  top: 18px;
  left: 18px;
  right: 18px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(6px);
  color: #111827;
  z-index: 10;
}

.success-icon {
  color: #22c55e;
}

.geocoding-badge {
  margin-left: auto;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #2563eb;
}

.map-empty {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
  color: #64748b;
  gap: 8px;
}

@media (max-width: 1100px) {
  .main-content {
    flex-direction: column;
  }

  .control-panel {
    width: 100%;
  }

  .map-wrapper {
    grid-template-columns: 1fr;
  }

  .side-nav-panel {
    position: static;
  }

  .map-container {
    height: 620px;
  }
}

@media (max-width: 768px) {
  .route-planning-page {
    padding: 12px 0 calc(92px + env(safe-area-inset-bottom));
  }

  .page-header {
    text-align: left;
    margin-bottom: 14px;
    padding: 0 2px;
  }

  .page-title {
    font-size: 24px;
  }

  .page-desc {
    font-size: 13px;
    line-height: 1.5;
  }

  .guide-import-banner {
    padding: 14px;
    border-radius: 14px;
  }

  .main-content {
    gap: 14px;
  }

  .map-wrapper {
    order: -1;
    gap: 12px;
  }

  .map-container {
    height: 52vh;
    min-height: 420px;
    border-radius: 16px;
  }

  .map-top-bar {
    top: 12px;
    left: 12px;
    right: 12px;
    padding: 8px 10px;
    font-size: 12px;
    line-height: 1.4;
  }

  .side-nav-panel,
  .panel-card {
    border-radius: 16px;
    padding: 14px;
  }

  .segment-nav-header,
  .segment-nav-toolbar,
  .segment-nav-item {
    flex-direction: column;
    align-items: stretch;
  }

  .segment-nav-toolbar {
    gap: 8px;
  }

  .segment-nav-current {
    order: -1;
  }

  .side-nav-list {
    max-height: 320px;
    padding-right: 0;
  }

  .planning-mode-card {
    padding: 14px;
    border-radius: 16px;
  }

  .planning-mode-group {
    gap: 8px;
  }

  .planning-mode-group :deep(.el-radio-button) {
    width: 100%;
  }

  .planning-mode-group :deep(.el-radio-button__inner) {
    width: 100%;
    min-height: 52px;
    padding: 10px 12px;
    font-size: 14px;
  }

  .place-actions,
  .publish-actions {
    position: sticky;
    bottom: calc(10px + env(safe-area-inset-bottom));
    z-index: 30;
    margin-top: 16px;
    padding: 10px;
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.94);
    backdrop-filter: blur(10px);
    box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
  }

  .place-actions .el-button,
  .publish-actions .el-button {
    flex: 1;
    min-height: 44px;
  }

  .result-header {
    align-items: flex-start;
  }

  .stat-row {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 480px) {
  .route-planning-page {
    padding-bottom: calc(104px + env(safe-area-inset-bottom));
  }

  .page-title {
    font-size: 21px;
  }

  .page-desc {
    font-size: 12px;
  }

  .guide-import-banner {
    margin-bottom: 12px;
  }

  .card-header,
  .result-header {
    margin-bottom: 12px;
  }

  .map-container {
    height: 48vh;
    min-height: 360px;
  }

  .map-top-bar {
    align-items: flex-start;
    flex-wrap: wrap;
  }

  .planning-mode-group {
    grid-template-columns: 1fr !important;
    gap: 8px;
  }

  .planning-target-label {
    margin-top: 12px;
  }

  .place-actions,
  .publish-actions {
    flex-direction: column;
  }

  .stat-row {
    grid-template-columns: 1fr;
  }
}
</style>
