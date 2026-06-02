<template>
  <div class="booking-management">
    <div class="page-header">
      <div>
        <h1 class="page-title">酒店预订订单管理</h1>
        <p class="page-subtitle">Accommodation Booking Order Management</p>
      </div>
    </div>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNo" placeholder="请输入订单号" clearable style="width: 220px" />
        </el-form-item>

        <el-form-item label="入住人">
          <el-input v-model="searchForm.guestName" placeholder="请输入入住人姓名" clearable style="width: 180px" />
        </el-form-item>

        <el-form-item label="手机号">
          <el-input v-model="searchForm.guestPhone" placeholder="请输入手机号" clearable style="width: 180px" />
        </el-form-item>

        <el-form-item label="订单状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="待支付" :value="0" />
            <el-option label="已支付" :value="1" />
            <el-option label="已取消" :value="2" />
            <el-option label="已退款" :value="3" />
            <el-option label="已完成" :value="4" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="table-card">
      <el-table v-loading="loading" :data="tableData" border>
        <el-table-column prop="orderNo" label="订单号" min-width="220" />
        <el-table-column prop="accommodationName" label="住宿名称" min-width="180" />
        <el-table-column prop="roomName" label="房型名称" min-width="160" />
        <el-table-column prop="guestName" label="入住人" width="110" />
        <el-table-column prop="guestPhone" label="手机号" width="140" />
        <el-table-column label="入住日期" width="120">
          <template #default="{ row }">{{ row.checkInDate || '-' }}</template>
        </el-table-column>
        <el-table-column label="离店日期" width="120">
          <template #default="{ row }">{{ row.checkOutDate || '-' }}</template>
        </el-table-column>
        <el-table-column label="晚数/房间" width="110">
          <template #default="{ row }">{{ row.nights || 0 }}晚 / {{ row.rooms || 0 }}间</template>
        </el-table-column>
        <el-table-column label="订单金额" width="120">
          <template #default="{ row }">
            <span class="amount">￥{{ formatPrice(row.totalAmount) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="订单状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" plain @click="handleViewDetail(row)">详情</el-button>
            <el-button v-if="row.status === 0" type="danger" size="small" plain @click="handleCancel(row)">取消</el-button>
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
          @size-change="fetchOrders"
          @current-change="fetchOrders"
        />
      </div>
    </el-card>

    <el-dialog v-model="detailVisible" title="酒店订单详情" width="760px">
      <el-descriptions v-if="currentOrder" :column="2" border>
        <el-descriptions-item label="订单号">{{ currentOrder.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">{{ getStatusText(currentOrder.status) }}</el-descriptions-item>
        <el-descriptions-item label="住宿名称">{{ currentOrder.accommodationName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="房型名称">{{ currentOrder.roomName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="入住人">{{ currentOrder.guestName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentOrder.guestPhone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="身份证号">{{ currentOrder.idCard || '未填写' }}</el-descriptions-item>
        <el-descriptions-item label="下单用户">{{ currentOrder.username || currentOrder.userId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="入住日期">{{ currentOrder.checkInDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="离店日期">{{ currentOrder.checkOutDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="入住晚数">{{ currentOrder.nights || 0 }} 晚</el-descriptions-item>
        <el-descriptions-item label="房间数">{{ currentOrder.rooms || 0 }} 间</el-descriptions-item>
        <el-descriptions-item label="订单金额">￥{{ formatPrice(currentOrder.totalAmount) }}</el-descriptions-item>
        <el-descriptions-item label="支付方式">{{ currentOrder.paymentMethod || '未支付' }}</el-descriptions-item>
        <el-descriptions-item label="支付时间">{{ currentOrder.paymentTime || '未支付' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ currentOrder.remark || '无' }}</el-descriptions-item>
      </el-descriptions>

      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="currentOrder?.status === 0" type="danger" @click="handleCancel(currentOrder)">取消订单</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const loading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const detailVisible = ref(false)
const currentOrder = ref(null)

const searchForm = reactive({
  orderNo: '',
  guestName: '',
  guestPhone: '',
  status: undefined
})

const getStatusText = (status) => {
  const map = {
    0: '待支付',
    1: '已支付',
    2: '已取消',
    3: '已退款',
    4: '已完成'
  }
  return map[status] || '未知状态'
}

const getStatusTagType = (status) => {
  const map = {
    0: 'warning',
    1: 'success',
    2: 'info',
    3: 'danger',
    4: 'success'
  }
  return map[status] || 'info'
}

const formatPrice = (price) => Number(price || 0).toFixed(2)

const fetchOrders = async () => {
  loading.value = true
  try {
    const params = {
      currentPage: currentPage.value,
      size: pageSize.value
    }

    if (searchForm.orderNo) params.orderNo = searchForm.orderNo
    if (searchForm.guestName) params.guestName = searchForm.guestName
    if (searchForm.guestPhone) params.guestPhone = searchForm.guestPhone
    if (searchForm.status !== undefined) params.status = searchForm.status

    const data = await request.get('/accommodation/booking/admin/page', params, {
      showDefaultMsg: false
    })

    tableData.value = data?.records || []
    total.value = data?.total || 0
  } catch (error) {
    console.error('获取酒店订单列表失败:', error)
    tableData.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchOrders()
}

const resetSearch = () => {
  searchForm.orderNo = ''
  searchForm.guestName = ''
  searchForm.guestPhone = ''
  searchForm.status = undefined
  currentPage.value = 1
  fetchOrders()
}

const handleViewDetail = async (row) => {
  try {
    const data = await request.get(`/accommodation/booking/${row.id}`, {}, {
      showDefaultMsg: false
    })
    currentOrder.value = data
    detailVisible.value = true
  } catch (error) {
    console.error('获取酒店订单详情失败:', error)
  }
}

const handleCancel = (row) => {
  ElMessageBox.confirm(`确定取消订单“${row.orderNo}”吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    try {
      await request.post(`/accommodation/booking/${row.id}/cancel`, {}, {
        successMsg: '订单已取消'
      })
      detailVisible.value = false
      fetchOrders()
    } catch (error) {
      console.error('取消酒店订单失败:', error)
    }
  }).catch(() => {})
}

onMounted(() => {
  fetchOrders()
})
</script>

<style lang="scss" scoped>
.booking-management {
  min-height: calc(100vh - 120px);
  padding: 20px;
  background: #f8fafc;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  margin: 0 0 8px;
  font-size: 24px;
  color: #1f2937;
}

.page-subtitle {
  margin: 0;
  font-size: 14px;
  color: #64748b;
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

.amount {
  color: #dc2626;
  font-weight: 700;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
