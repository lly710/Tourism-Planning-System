<template>
  <div class="room-type-management">
    <div class="page-header">
      <div>
        <h1 class="page-title">房型管理</h1>
        <p class="page-subtitle">Accommodation Room Type Management</p>
      </div>
      <el-button type="primary" class="add-btn" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增房型
      </el-button>
    </div>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="所属住宿">
          <el-select
            v-model="searchForm.accommodationId"
            placeholder="请选择住宿"
            clearable
            filterable
            style="width: 220px"
          >
            <el-option
              v-for="item in accommodationOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="房型名称">
          <el-input
            v-model="searchForm.roomName"
            placeholder="请输入房型名称"
            clearable
            style="width: 220px"
          />
        </el-form-item>

        <el-form-item label="价格区间">
          <div class="inline-range">
            <el-input v-model="searchForm.minPrice" placeholder="最低价" clearable />
            <span class="separator">-</span>
            <el-input v-model="searchForm.maxPrice" placeholder="最高价" clearable />
          </div>
        </el-form-item>

        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 140px">
            <el-option label="可预订" :value="1" />
            <el-option label="不可预订" :value="0" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <div v-if="activeAccommodationName" class="filter-tip">
        当前已按住宿筛选：{{ activeAccommodationName }}
      </div>
    </el-card>

    <el-card shadow="never" class="table-card">
      <el-table v-loading="loading" :data="tableData" border>
        <el-table-column type="index" label="#" width="60" />
        <el-table-column prop="roomName" label="房型名称" min-width="160" />
        <el-table-column label="所属住宿" min-width="180">
          <template #default="{ row }">
            {{ row.accommodationName || getAccommodationName(row.accommodationId) || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="图片" width="110">
          <template #default="{ row }">
            <el-image
              v-if="row.imageUrl"
              :src="getImageUrl(row.imageUrl)"
              :preview-src-list="[getImageUrl(row.imageUrl)]"
              preview-teleported
              fit="cover"
              class="room-image"
            />
            <span v-else class="no-image">暂无图片</span>
          </template>
        </el-table-column>
        <el-table-column prop="bedType" label="床型" width="150" />
        <el-table-column label="面积" width="100">
          <template #default="{ row }">
            {{ row.roomArea ? `${row.roomArea} ㎡` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="maxOccupancy" label="可住人数" width="100" />
        <el-table-column label="原价" width="110">
          <template #default="{ row }">
            {{ formatPrice(row.price) }}
          </template>
        </el-table-column>
        <el-table-column label="优惠价" width="110">
          <template #default="{ row }">
            {{ row.discountPrice ? formatPrice(row.discountPrice) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="totalRooms" label="房量" width="90" />
        <el-table-column label="早餐/窗户" width="140">
          <template #default="{ row }">
            <div class="tag-stack">
              <el-tag size="small" :type="row.breakfast === 1 ? 'success' : 'info'">
                {{ row.breakfast === 1 ? '含早' : '无早' }}
              </el-tag>
              <el-tag size="small" :type="row.hasWindow === 1 ? 'warning' : 'info'">
                {{ row.hasWindow === 1 ? '有窗' : '无窗' }}
              </el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '可预订' : '不可预订' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" plain @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" plain @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="fetchRoomTypes"
          @current-change="fetchRoomTypes"
        />
      </div>
    </el-card>

    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑房型' : '新增房型'"
      width="760px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        :disabled="formLoading"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属住宿" prop="accommodationId">
              <el-select
                v-model="form.accommodationId"
                placeholder="请选择住宿"
                filterable
                style="width: 100%"
              >
                <el-option
                  v-for="item in accommodationOptions"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="房型名称" prop="roomName">
              <el-input v-model="form.roomName" placeholder="如：豪华大床房" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="床型" prop="bedType">
              <el-select v-model="form.bedType" placeholder="请选择床型" clearable style="width: 100%">
                <el-option v-for="item in bedTypeOptions" :key="item" :label="item" :value="item" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="房间面积" prop="roomArea">
              <el-input-number
                v-model="form.roomArea"
                :min="1"
                :max="1000"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="可住人数" prop="maxOccupancy">
              <el-input-number
                v-model="form.maxOccupancy"
                :min="1"
                :max="20"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总房量" prop="totalRooms">
              <el-input-number
                v-model="form.totalRooms"
                :min="0"
                :max="9999"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="原价" prop="price">
              <el-input-number
                v-model="form.price"
                :min="0"
                :precision="2"
                :step="10"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="优惠价" prop="discountPrice">
              <el-input-number
                v-model="form.discountPrice"
                :min="0"
                :precision="2"
                :step="10"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="是否有窗" prop="hasWindow">
              <el-select v-model="form.hasWindow" style="width: 100%">
                <el-option label="有窗" :value="1" />
                <el-option label="无窗" :value="0" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="是否含早" prop="breakfast">
              <el-select v-model="form.breakfast" style="width: 100%">
                <el-option label="含早" :value="1" />
                <el-option label="不含早" :value="0" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="预订状态" prop="status">
              <el-select v-model="form.status" style="width: 100%">
                <el-option label="可预订" :value="1" />
                <el-option label="不可预订" :value="0" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="设施" prop="facilities">
          <el-input v-model="form.facilities" placeholder="如：WiFi,空调,电视，多个请用逗号分隔" />
        </el-form-item>

        <el-form-item label="房型图片">
          <el-upload
            class="image-uploader"
            action="#"
            :auto-upload="true"
            :show-file-list="false"
            :http-request="customUploadImage"
            :before-upload="beforeImageUpload"
          >
            <img v-if="form.imageUrl" :src="getImageUrl(form.imageUrl)" class="upload-image" />
            <el-icon v-else class="upload-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>

        <el-form-item label="房型描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="4"
            placeholder="请输入房型描述"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
const baseAPI = process.env.VUE_APP_BASE_API || '/api'

const loading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const accommodationOptions = ref([])

const dialogVisible = ref(false)
const isEdit = ref(false)
const formLoading = ref(false)
const formRef = ref(null)

const bedTypeOptions = [
  '大床房',
  '双床房',
  '豪华大床房',
  '豪华双床房',
  '家庭房',
  '榻榻米房',
  '多人间'
]

const searchForm = reactive({
  accommodationId: undefined,
  roomName: '',
  minPrice: '',
  maxPrice: '',
  status: undefined
})

const createDefaultForm = () => ({
  id: null,
  accommodationId: undefined,
  roomName: '',
  roomArea: 20,
  bedType: '',
  maxOccupancy: 2,
  hasWindow: 1,
  breakfast: 0,
  price: 0,
  discountPrice: null,
  totalRooms: 0,
  description: '',
  facilities: '',
  imageUrl: '',
  status: 1
})

const form = reactive(createDefaultForm())

const rules = {
  accommodationId: [{ required: true, message: '请选择所属住宿', trigger: 'change' }],
  roomName: [{ required: true, message: '请输入房型名称', trigger: 'blur' }],
  bedType: [{ required: true, message: '请选择床型', trigger: 'change' }],
  maxOccupancy: [{ required: true, message: '请输入可住人数', trigger: 'change' }],
  totalRooms: [{ required: true, message: '请输入总房量', trigger: 'change' }],
  price: [{ required: true, message: '请输入原价', trigger: 'change' }]
}

const activeAccommodationName = computed(() => {
  const name = route.query.accommodationName
  return typeof name === 'string' ? name : ''
})

const applyRouteFilter = () => {
  const accommodationId = Number(route.query.accommodationId)
  searchForm.accommodationId = Number.isNaN(accommodationId) || accommodationId <= 0
    ? undefined
    : accommodationId
}

const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${baseAPI}${url}`
}

const formatPrice = (price) => {
  if (price === null || price === undefined || price === '') return '-'
  return `￥${Number(price).toFixed(2)}`
}

const getAccommodationName = (accommodationId) => {
  const target = accommodationOptions.value.find(item => item.id === accommodationId)
  return target?.name || ''
}

const fetchAccommodationOptions = async () => {
  try {
    const data = await request.get('/accommodation/page', {
      currentPage: 1,
      size: 1000
    }, {
      showDefaultMsg: false
    })

    accommodationOptions.value = data?.records || []
  } catch (error) {
    console.error('获取住宿列表失败:', error)
  }
}

const fetchRoomTypes = async () => {
  loading.value = true
  try {
    const params = {
      currentPage: currentPage.value,
      size: pageSize.value
    }

    if (searchForm.accommodationId) params.accommodationId = searchForm.accommodationId
    if (searchForm.roomName) params.roomName = searchForm.roomName
    if (searchForm.minPrice !== '') params.minPrice = searchForm.minPrice
    if (searchForm.maxPrice !== '') params.maxPrice = searchForm.maxPrice
    if (searchForm.status !== undefined) params.status = searchForm.status

    const data = await request.get('/accommodation/type/page', params, {
      showDefaultMsg: false
    })

    tableData.value = data?.records || []
    total.value = data?.total || 0
  } catch (error) {
    console.error('获取房型列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchRoomTypes()
}

const resetSearch = () => {
  searchForm.roomName = ''
  searchForm.minPrice = ''
  searchForm.maxPrice = ''
  searchForm.status = undefined
  applyRouteFilter()
  currentPage.value = 1
  fetchRoomTypes()
}

const resetForm = () => {
  formRef.value?.resetFields()
  Object.assign(form, createDefaultForm())

  if (searchForm.accommodationId) {
    form.accommodationId = searchForm.accommodationId
  }
}

const handleAdd = () => {
  resetForm()
  isEdit.value = false
  dialogVisible.value = true
}

const handleEdit = (row) => {
  resetForm()
  isEdit.value = true
  Object.assign(form, {
    ...createDefaultForm(),
    ...row,
    discountPrice: row.discountPrice ?? null
  })
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm(`确定删除房型“${row.roomName}”吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    try {
      await request.delete(`/accommodation/type/${row.id}`, {
        successMsg: '删除成功'
      })
      fetchRoomTypes()
    } catch (error) {
      console.error('删除房型失败:', error)
    }
  }).catch(() => {})
}

const beforeImageUpload = (file) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp']
  const isImage = allowedTypes.includes(file.type)
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('仅支持 JPG、PNG、WEBP 图片')
    return false
  }

  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB')
    return false
  }

  return true
}

const customUploadImage = async (options) => {
  try {
    const formData = new FormData()
    formData.append('file', options.file)

    const data = await request.post('/file/upload/img', formData, {
      headers: {
        token: localStorage.getItem('token') || ''
      },
      transformRequest: [(payload) => payload],
      successMsg: '图片上传成功',
      errorMsg: '图片上传失败'
    })

    form.imageUrl = data
    options.onSuccess({ data })
  } catch (error) {
    console.error('上传房型图片失败:', error)
    options.onError(error)
  }
}

const submitForm = async () => {
  if (!formRef.value) return

  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  formLoading.value = true
  try {
    const payload = {
      ...form,
      discountPrice: form.discountPrice || null
    }

    if (isEdit.value) {
      await request.put(`/accommodation/type/${form.id}`, payload, {
        successMsg: '更新成功'
      })
    } else {
      await request.post('/accommodation/type', payload, {
        successMsg: '新增成功'
      })
    }

    dialogVisible.value = false
    fetchRoomTypes()
  } catch (error) {
    console.error('提交房型失败:', error)
  } finally {
    formLoading.value = false
  }
}

watch(
  () => route.query.accommodationId,
  () => {
    applyRouteFilter()
    currentPage.value = 1
    fetchRoomTypes()
  }
)

onMounted(async () => {
  applyRouteFilter()
  await fetchAccommodationOptions()
  fetchRoomTypes()
})
</script>

<style lang="scss" scoped>
.room-type-management {
  min-height: calc(100vh - 120px);
  padding: 20px;
  background: #f8fafc;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.page-title {
  margin: 0 0 6px;
  font-size: 24px;
  color: #1f2937;
}

.page-subtitle {
  margin: 0;
  font-size: 14px;
  color: #64748b;
}

.add-btn {
  min-width: 112px;
}

.search-card,
.table-card {
  margin-bottom: 20px;
  border-radius: 12px;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 0;
}

.inline-range {
  display: flex;
  align-items: center;
  width: 250px;
}

.separator {
  margin: 0 8px;
  color: #94a3b8;
}

.filter-tip {
  margin-top: 8px;
  color: #2563eb;
  font-size: 13px;
}

.room-image {
  width: 64px;
  height: 42px;
  border-radius: 6px;
}

.tag-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.no-image {
  color: #94a3b8;
  font-size: 12px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.image-uploader :deep(.el-upload) {
  width: 180px;
  height: 120px;
  border: 1px dashed #d1d5db;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  cursor: pointer;
  transition: border-color 0.2s ease;
}

.image-uploader :deep(.el-upload:hover) {
  border-color: #2563eb;
}

.upload-image {
  width: 180px;
  height: 120px;
  object-fit: cover;
}

.upload-icon {
  font-size: 28px;
  color: #94a3b8;
}
</style>
