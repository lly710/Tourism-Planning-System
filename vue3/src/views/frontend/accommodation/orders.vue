<template>
  <div class="orders-page">
    <div class="section-container">
      <div class="page-header">
        <h1 class="page-title">我的酒店订单</h1>
        <p class="page-subtitle">查看、支付和取消酒店预约订单。</p>
      </div>

      <el-card shadow="never" class="tabs-card">
        <el-tabs v-model="activeTab" @tab-click="handleTabChange">
          <el-tab-pane name="all"><template #label>全部 {{ orderStats.total || 0 }}</template></el-tab-pane>
          <el-tab-pane name="0"><template #label>待支付 {{ orderStats.pending || 0 }}</template></el-tab-pane>
          <el-tab-pane name="1"><template #label>已支付 {{ orderStats.paid || 0 }}</template></el-tab-pane>
          <el-tab-pane name="2"><template #label>已取消 {{ orderStats.cancelled || 0 }}</template></el-tab-pane>
          <el-tab-pane name="3"><template #label>已退款 {{ orderStats.refunded || 0 }}</template></el-tab-pane>
          <el-tab-pane name="4"><template #label>已完成 {{ orderStats.completed || 0 }}</template></el-tab-pane>
        </el-tabs>

        <div v-if="loading" class="loading-state">
          <el-skeleton :rows="8" animated />
        </div>

        <div v-else-if="orderList.length === 0" class="empty-state">
          <div class="empty-icon">🏨</div>
          <h3>暂无酒店订单</h3>
          <p>去看看可预订的房型吧。</p>
          <el-button type="primary" @click="router.push('/accommodation')">浏览住宿</el-button>
        </div>

        <div v-else class="order-list">
          <article v-for="order in orderList" :key="order.id" class="order-card">
            <div class="order-card-head">
              <div>
                <div class="order-no">{{ order.orderNo }}</div>
                <div class="order-time">下单时间：{{ formatDateTime(order.createTime) }}</div>
              </div>
              <el-tag :type="getStatusTagType(order.status)">{{ getStatusText(order.status) }}</el-tag>
            </div>

            <div class="order-card-body">
              <h3>{{ order.accommodationName }}</h3>
              <p>{{ order.roomName }}</p>
              <div class="order-grid">
                <div class="detail-item"><span>入住日期</span><strong>{{ order.checkInDate }}</strong></div>
                <div class="detail-item"><span>离店日期</span><strong>{{ order.checkOutDate }}</strong></div>
                <div class="detail-item"><span>入住晚数</span><strong>{{ order.nights }}晚</strong></div>
                <div class="detail-item"><span>房间数</span><strong>{{ order.rooms }}间</strong></div>
                <div class="detail-item"><span>入住人</span><strong>{{ order.guestName }}</strong></div>
                <div class="detail-item"><span>手机号</span><strong>{{ order.guestPhone }}</strong></div>
              </div>
            </div>

            <div class="order-card-foot">
              <div class="amount-box">
                <span>订单金额</span>
                <strong>{{ formatCurrency(order.totalAmount) }}</strong>
              </div>

              <div class="action-group">
                <el-button @click="viewOrderDetail(order.id)">查看详情</el-button>
                <el-button v-if="order.status === 0" type="primary" @click="openPayDialog(order)">去支付</el-button>
                <el-button v-if="order.status === 0" type="danger" plain @click="cancelOrder(order.id)">取消订单</el-button>
              </div>
            </div>
          </article>

          <div class="pagination-wrapper">
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
      </el-card>
    </div>

    <el-dialog v-model="detailDialogVisible" title="酒店订单详情" width="640px">
      <el-descriptions v-if="currentOrder" :column="1" border>
        <el-descriptions-item label="订单号">{{ currentOrder.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="住宿名称">{{ currentOrder.accommodationName }}</el-descriptions-item>
        <el-descriptions-item label="房型名称">{{ currentOrder.roomName }}</el-descriptions-item>
        <el-descriptions-item label="入住日期">{{ currentOrder.checkInDate }}</el-descriptions-item>
        <el-descriptions-item label="离店日期">{{ currentOrder.checkOutDate }}</el-descriptions-item>
        <el-descriptions-item label="入住晚数">{{ currentOrder.nights }}晚</el-descriptions-item>
        <el-descriptions-item label="房间数">{{ currentOrder.rooms }}间</el-descriptions-item>
        <el-descriptions-item label="入住人">{{ currentOrder.guestName }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentOrder.guestPhone }}</el-descriptions-item>
        <el-descriptions-item label="身份证号">{{ currentOrder.idCard || '未填写' }}</el-descriptions-item>
        <el-descriptions-item label="订单金额">{{ formatCurrency(currentOrder.totalAmount) }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">{{ getStatusText(currentOrder.status) }}</el-descriptions-item>
        <el-descriptions-item label="支付方式">{{ currentOrder.paymentMethod || '未支付' }}</el-descriptions-item>
        <el-descriptions-item label="支付时间">{{ currentOrder.paymentTime || '未支付' }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentOrder.remark || '无' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <el-dialog v-model="payDialogVisible" title="支付酒店订单" width="480px">
      <div v-if="currentOrder" class="pay-dialog">
        <div class="pay-row"><span>订单号</span><strong>{{ currentOrder.orderNo }}</strong></div>
        <div class="pay-row"><span>房型</span><strong>{{ currentOrder.roomName }}</strong></div>
        <div class="pay-row"><span>金额</span><strong class="amount">{{ formatCurrency(currentOrder.totalAmount) }}</strong></div>
        <el-radio-group v-model="paymentMethod" class="pay-methods">
          <el-radio value="WECHAT">微信支付</el-radio>
          <el-radio value="ALIPAY">支付宝</el-radio>
          <el-radio value="BANK_CARD">银行卡</el-radio>
        </el-radio-group>
      </div>

      <template #footer>
        <el-button @click="payDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="paying" @click="confirmPayment">确认支付</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()
const loading = ref(false)
const paying = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const activeTab = ref('all')
const orderList = ref([])
const currentOrder = ref(null)
const detailDialogVisible = ref(false)
const payDialogVisible = ref(false)
const paymentMethod = ref('WECHAT')
const orderStats = ref({ total: 0, pending: 0, paid: 0, cancelled: 0, refunded: 0, completed: 0 })

const getStatusText = (status) => ({ 0: '待支付', 1: '已支付', 2: '已取消', 3: '已退款', 4: '已完成' }[status] || '未知状态')
const getStatusTagType = (status) => ({ 0: 'warning', 1: 'success', 2: 'info', 3: 'danger', 4: 'success' }[status] || 'info')
const formatCurrency = (amount) => `￥${Number(amount || 0).toFixed(2)}`
const formatDateTime = (value) => {
  if (!value) return '-'
  const date = new Date(value)
  const year = date.getFullYear()
  const month = `${date.getMonth() + 1}`.padStart(2, '0')
  const day = `${date.getDate()}`.padStart(2, '0')
  const hour = `${date.getHours()}`.padStart(2, '0')
  const minute = `${date.getMinutes()}`.padStart(2, '0')
  return `${year}-${month}-${day} ${hour}:${minute}`
}

const fetchOrderStats = async () => {
  try {
    const data = await request.get('/accommodation/booking/my/stats', {}, { showDefaultMsg: false })
    orderStats.value = data || orderStats.value
  } catch (error) {
    console.error('获取酒店订单统计失败:', error)
  }
}

const fetchOrders = async () => {
  loading.value = true
  try {
    const params = { currentPage: currentPage.value, size: pageSize.value }
    if (activeTab.value !== 'all') params.status = activeTab.value
    const data = await request.get('/accommodation/booking/my', params, { showDefaultMsg: false })
    orderList.value = data?.records || []
    total.value = data?.total || 0
  } catch (error) {
    console.error('获取酒店订单列表失败:', error)
    orderList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleTabChange = () => {
  currentPage.value = 1
  fetchOrders()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchOrders()
}

const viewOrderDetail = async (id) => {
  try {
    const data = await request.get(`/accommodation/booking/${id}`, {}, { showDefaultMsg: false })
    currentOrder.value = data
    detailDialogVisible.value = true
  } catch (error) {
    console.error('获取酒店订单详情失败:', error)
  }
}

const openPayDialog = (order) => {
  currentOrder.value = order
  paymentMethod.value = 'WECHAT'
  payDialogVisible.value = true
}

const confirmPayment = async () => {
  if (!currentOrder.value?.id) return

  if (paymentMethod.value === 'ALIPAY') {
    payDialogVisible.value = false
    router.push(`/payment/alipay/${currentOrder.value.id}`)
    return
  }

  paying.value = true
  try {
    await request.post(`/accommodation/booking/${currentOrder.value.id}/pay`, null, {
      params: {
        paymentMethod: paymentMethod.value
      },
      successMsg: '支付成功'
    })
    payDialogVisible.value = false
    await fetchOrderStats()
    await fetchOrders()
  } catch (error) {
    console.error('支付酒店订单失败:', error)
  } finally {
    paying.value = false
  }
}

const cancelOrder = async (id) => {
  ElMessageBox.confirm('确定取消这笔酒店订单吗？', '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    try {
      await request.post(`/accommodation/booking/${id}/cancel`, {}, {
        successMsg: '订单已取消'
      })
      await fetchOrderStats()
      await fetchOrders()
    } catch (error) {
      console.error('取消酒店订单失败:', error)
    }
  }).catch(() => {})
}

onMounted(async () => {
  await fetchOrderStats()
  await fetchOrders()
})
</script>

<style scoped>
.orders-page { min-height: 100vh; background: #f4f7fb; }
.section-container { max-width: 1280px; margin: 0 auto; padding: 24px 20px 56px; }
.page-title { margin: 0 0 10px; font-size: 36px; color: #223046; }
.page-subtitle { margin: 0 0 20px; color: #6d7b8d; }
.tabs-card { border: none; border-radius: 24px; box-shadow: 0 16px 40px rgba(31,52,85,.08); }
.loading-state, .empty-state { padding: 28px 0 16px; }
.empty-state { text-align: center; }
.empty-icon { margin-bottom: 12px; font-size: 48px; }
.order-list { display: flex; flex-direction: column; gap: 18px; }
.order-card { border: 1px solid #edf2f7; border-radius: 22px; padding: 20px; background: #fff; }
.order-card-head, .order-card-foot { display: flex; justify-content: space-between; gap: 16px; }
.order-card-head { align-items: flex-start; margin-bottom: 18px; }
.order-no { font-size: 18px; font-weight: 700; color: #223046; }
.order-time, .order-card-body p { color: #6d7b8d; }
.order-card-body h3 { margin: 0 0 6px; font-size: 24px; }
.order-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin-top: 16px; }
.detail-item { padding: 14px; border-radius: 16px; background: #f8fafc; }
.detail-item span { display: block; margin-bottom: 6px; font-size: 12px; color: #6d7b8d; }
.amount-box { display: flex; flex-direction: column; gap: 6px; }
.amount-box span { color: #6d7b8d; }
.amount-box strong, .amount { color: #d43c2f; font-size: 28px; }
.action-group { display: flex; gap: 12px; align-items: flex-end; }
.pagination-wrapper { display: flex; justify-content: center; margin-top: 20px; }
.pay-dialog { display: flex; flex-direction: column; gap: 14px; }
.pay-row { display: flex; justify-content: space-between; gap: 12px; }
.pay-methods { display: flex; flex-direction: column; gap: 10px; margin-top: 10px; }
@media (max-width: 900px) { .order-grid { grid-template-columns: 1fr; } .order-card-head, .order-card-foot, .action-group { flex-direction: column; align-items: flex-start; } }
</style>
