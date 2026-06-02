<template>
  <div class="booking-page">
    <section class="hero-section">
      <div class="section-container hero-content">
        <el-breadcrumb separator="/" class="breadcrumb">
          <el-breadcrumb-item @click="router.push('/')">首页</el-breadcrumb-item>
          <el-breadcrumb-item @click="router.push('/accommodation')">周边住宿</el-breadcrumb-item>
          <el-breadcrumb-item @click="goToAccommodationDetail">{{ accommodation?.name || '住宿详情' }}</el-breadcrumb-item>
          <el-breadcrumb-item>预约酒店</el-breadcrumb-item>
        </el-breadcrumb>

        <h1 class="hero-title">酒店预约</h1>
        <p class="hero-subtitle">填写入住信息并确认支付方式后提交酒店订单。</p>
      </div>
    </section>

    <section class="section-container content-section">
      <div class="content-grid">
        <div class="main-content">
          <el-card shadow="never" class="summary-card" v-if="roomType">
            <div class="summary-grid">
              <img class="room-image" :src="getImageUrl(roomType.imageUrl)" :alt="roomType.roomName" />
              <div>
                <h2 class="room-name">{{ roomType.roomName }}</h2>
                <p class="room-subtitle">{{ accommodation?.name || '-' }}</p>
                <div class="fact-list">
                  <span>{{ roomType.bedType || '床型待补充' }}</span>
                  <span>{{ roomType.roomArea ? `${roomType.roomArea}㎡` : '面积待补充' }}</span>
                  <span>{{ roomType.maxOccupancy ? `可住${roomType.maxOccupancy}人` : '人数待补充' }}</span>
                  <span>{{ roomType.breakfast === 1 ? '含早餐' : '不含早餐' }}</span>
                </div>
                <div class="price-line">每晚均价：<strong>{{ formatCurrency(unitPrice) }}</strong></div>
              </div>
            </div>
          </el-card>

          <el-card shadow="never" class="form-card">
            <el-form ref="formRef" :model="bookingForm" :rules="rules" label-position="top">
              <div class="form-grid">
                <el-form-item label="入住日期" prop="checkInDate">
                  <el-date-picker
                    v-model="bookingForm.checkInDate"
                    type="date"
                    value-format="YYYY-MM-DD"
                    placeholder="请选择入住日期"
                    :disabled-date="disableCheckInDate"
                    class="full-width"
                  />
                </el-form-item>

                <el-form-item label="离店日期" prop="checkOutDate">
                  <el-date-picker
                    v-model="bookingForm.checkOutDate"
                    type="date"
                    value-format="YYYY-MM-DD"
                    placeholder="请选择离店日期"
                    :disabled-date="disableCheckOutDate"
                    class="full-width"
                  />
                </el-form-item>
              </div>

              <div class="form-grid">
                <el-form-item label="预订房间数" prop="rooms">
                  <el-input-number
                    v-model="bookingForm.rooms"
                    :min="1"
                    :max="maxBookableRooms"
                    controls-position="right"
                    class="full-width"
                  />
                </el-form-item>

                <el-form-item label="入住人姓名" prop="guestName">
                  <el-input v-model="bookingForm.guestName" placeholder="请输入入住人姓名" />
                </el-form-item>
              </div>

              <div class="form-grid">
                <el-form-item label="手机号" prop="guestPhone">
                  <el-input v-model="bookingForm.guestPhone" placeholder="请输入手机号" />
                </el-form-item>

                <el-form-item label="身份证号" prop="idCard">
                  <el-input v-model="bookingForm.idCard" placeholder="可不填" />
                </el-form-item>
              </div>

              <el-form-item label="备注">
                <el-input v-model="bookingForm.remark" type="textarea" :rows="4" maxlength="200" show-word-limit />
              </el-form-item>
            </el-form>
          </el-card>
        </div>

        <aside class="side-content">
          <el-card shadow="never" class="side-card">
            <h3>订单概览</h3>

            <div v-if="availability" class="availability-box" :class="availability.bookable ? 'success' : 'danger'">
              <div>{{ availability.bookable ? '当前日期可预订' : '当前日期不可预订' }}</div>
              <small>可订余量：{{ availability.availableRooms ?? 0 }}</small>
            </div>

            <div v-else class="availability-placeholder">选择日期后会自动校验房量</div>

            <div class="summary-row"><span>房型单价</span><strong>{{ formatCurrency(unitPrice) }}</strong></div>
            <div class="summary-row"><span>入住晚数</span><strong>{{ nights }}晚</strong></div>
            <div class="summary-row"><span>房间数</span><strong>{{ bookingForm.rooms }}间</strong></div>
            <div class="summary-row total"><span>订单总额</span><strong>{{ formatCurrency(totalAmount) }}</strong></div>

            <div class="actions">
              <el-button @click="goToRoomTypes">返回房型列表</el-button>
              <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="submitBooking">提交预约</el-button>
            </div>
          </el-card>
        </aside>
      </div>
    </section>

    <el-dialog v-model="payDialogVisible" title="订单支付" width="520px" :close-on-click-modal="false">
      <div v-if="createdOrder" class="pay-dialog">
        <div class="pay-row"><span>订单号</span><strong>{{ createdOrder.orderNo }}</strong></div>
        <div class="pay-row"><span>住宿名称</span><strong>{{ createdOrder.accommodationName || accommodation?.name || '-' }}</strong></div>
        <div class="pay-row"><span>房型</span><strong>{{ createdOrder.roomName || roomType?.roomName || '-' }}</strong></div>
        <div class="pay-row"><span>金额</span><strong class="amount">{{ formatCurrency(createdOrder.totalAmount) }}</strong></div>

        <el-radio-group v-model="paymentMethod" class="payment-methods">
          <el-radio value="WECHAT">微信支付</el-radio>
          <el-radio value="ALIPAY">支付宝</el-radio>
          <el-radio value="BANK_CARD">银行卡</el-radio>
        </el-radio-group>
      </div>

      <template #footer>
        <el-button @click="goToAccommodationOrders">稍后支付</el-button>
        <el-button type="primary" :loading="paying" @click="confirmPayment">确认支付</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const baseAPI = process.env.VUE_APP_BASE_API || '/api'

const roomType = ref(null)
const accommodation = ref(null)
const availability = ref(null)
const createdOrder = ref(null)
const loading = ref(false)
const submitting = ref(false)
const paying = ref(false)
const payDialogVisible = ref(false)
const checkingAvailability = ref(false)
const paymentMethod = ref('WECHAT')
const formRef = ref(null)

const bookingForm = reactive({
  accommodationId: undefined,
  roomTypeId: undefined,
  checkInDate: '',
  checkOutDate: '',
  rooms: 1,
  guestName: '',
  guestPhone: '',
  idCard: '',
  remark: ''
})

const rules = {
  checkInDate: [{ required: true, message: '请选择入住日期', trigger: 'change' }],
  checkOutDate: [{ required: true, message: '请选择离店日期', trigger: 'change' }],
  rooms: [{ required: true, message: '请选择房间数', trigger: 'change' }],
  guestName: [{ required: true, message: '请输入入住人姓名', trigger: 'blur' }],
  guestPhone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  idCard: [{ pattern: /(^$)|(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/, message: '请输入正确的身份证号', trigger: 'blur' }]
}

const unitPrice = computed(() => Number(roomType.value?.discountPrice ?? roomType.value?.price ?? 0))
const nights = computed(() => {
  if (!bookingForm.checkInDate || !bookingForm.checkOutDate) return 0
  const start = new Date(bookingForm.checkInDate)
  const end = new Date(bookingForm.checkOutDate)
  const diff = Math.ceil((end.getTime() - start.getTime()) / 86400000)
  return diff > 0 ? diff : 0
})
const totalAmount = computed(() => Number((unitPrice.value * nights.value * bookingForm.rooms).toFixed(2)))
const maxBookableRooms = computed(() => Math.max(1, Number(availability.value?.availableRooms ?? roomType.value?.totalRooms ?? 1)))
const canSubmit = computed(() => Boolean(availability.value?.bookable) && nights.value > 0)

const getImageUrl = (url) => {
  if (!url) return require('@/assets/images/no-image.png')
  if (url.startsWith('http')) return url
  return `${baseAPI}${url}`
}

const formatCurrency = (amount) => `￥${Number(amount || 0).toFixed(2)}`

const fetchRoomTypeDetail = async () => {
  loading.value = true
  try {
    const data = await request.get(`/accommodation/type/${route.params.roomTypeId}`, {}, { showDefaultMsg: false })
    roomType.value = data
    bookingForm.roomTypeId = data?.id
    bookingForm.accommodationId = data?.accommodationId
  } catch (error) {
    console.error('获取房型详情失败:', error)
  } finally {
    loading.value = false
  }
}

const fetchAccommodationDetail = async () => {
  if (!bookingForm.accommodationId) return
  try {
    const data = await request.get(`/accommodation/${bookingForm.accommodationId}`, {}, { showDefaultMsg: false })
    accommodation.value = data
  } catch (error) {
    console.error('获取住宿详情失败:', error)
  }
}

const checkAvailability = async () => {
  if (!bookingForm.roomTypeId || !bookingForm.checkInDate || !bookingForm.checkOutDate || nights.value <= 0) {
    availability.value = null
    return
  }

  checkingAvailability.value = true
  try {
    const data = await request.get('/accommodation/booking/check-availability', {
      roomTypeId: bookingForm.roomTypeId,
      checkInDate: bookingForm.checkInDate,
      checkOutDate: bookingForm.checkOutDate
    }, {
      showDefaultMsg: false
    })
    availability.value = data
  } catch (error) {
    console.error('校验房量失败:', error)
    availability.value = null
  } finally {
    checkingAvailability.value = false
  }
}

const disableCheckInDate = (date) => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return date.getTime() < today.getTime()
}

const disableCheckOutDate = (date) => {
  if (!bookingForm.checkInDate) return disableCheckInDate(date)
  const checkIn = new Date(bookingForm.checkInDate)
  checkIn.setHours(0, 0, 0, 0)
  return date.getTime() <= checkIn.getTime()
}

const submitBooking = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录后再预约酒店')
    router.push(`/login?redirect=${encodeURIComponent(route.fullPath)}`)
    return
  }

  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid || !canSubmit.value) {
    ElMessage.warning('请先完善预约信息并确认房量')
    return
  }

  submitting.value = true
  try {
    const data = await request.post('/accommodation/booking', {
      ...bookingForm,
      rooms: Number(bookingForm.rooms)
    }, {
      successMsg: '酒店预约订单创建成功'
    })
    createdOrder.value = data
    paymentMethod.value = 'WECHAT'
    payDialogVisible.value = true
  } catch (error) {
    console.error('创建酒店预约订单失败:', error)
  } finally {
    submitting.value = false
  }
}

const confirmPayment = async () => {
  if (!createdOrder.value?.id) {
    ElMessage.warning('订单信息不存在，请稍后重试')
    return
  }

  if (!paymentMethod.value) {
    ElMessage.warning('请选择支付方式')
    return
  }

  if (paymentMethod.value === 'ALIPAY') {
    router.push(`/payment/alipay/${createdOrder.value.id}`)
    return
  }

  paying.value = true
  try {
    await request.post(`/accommodation/booking/${createdOrder.value.id}/pay`, null, {
      params: {
        paymentMethod: paymentMethod.value
      },
      successMsg: '支付成功'
    })
    payDialogVisible.value = false
    router.push('/accommodation/orders')
  } catch (error) {
    console.error('支付酒店订单失败:', error)
  } finally {
    paying.value = false
  }
}

const goToAccommodationDetail = () => {
  if (bookingForm.accommodationId) router.push(`/accommodation/${bookingForm.accommodationId}`)
}

const goToRoomTypes = () => {
  if (bookingForm.accommodationId) router.push(`/accommodation/${bookingForm.accommodationId}/room-types`)
}

const goToAccommodationOrders = () => {
  payDialogVisible.value = false
  router.push('/accommodation/orders')
}

watch(() => [bookingForm.checkInDate, bookingForm.checkOutDate], () => {
  checkAvailability()
})

onMounted(async () => {
  if (userStore.isLoggedIn && userStore.userInfo) {
    bookingForm.guestName = userStore.userInfo.name || userStore.userInfo.nickname || ''
    bookingForm.guestPhone = userStore.userInfo.phone || ''
  }

  await fetchRoomTypeDetail()
  await fetchAccommodationDetail()
})
</script>

<style scoped>
.booking-page { min-height: 100vh; background: #f4f7fb; }
.section-container { max-width: 1280px; margin: 0 auto; padding: 0 20px; }
.hero-section { background: linear-gradient(120deg, rgba(7, 89, 133, 0.94), rgba(15, 118, 110, 0.84)); color: #fff; }
.hero-content { padding: 28px 20px 48px; }
.breadcrumb { margin-bottom: 24px; }
.breadcrumb :deep(.el-breadcrumb__inner), .breadcrumb :deep(.el-breadcrumb__separator) { color: rgba(255,255,255,.84); cursor: pointer; }
.hero-title { margin: 0 0 12px; font-size: 38px; }
.hero-subtitle { margin: 0; max-width: 620px; color: rgba(255,255,255,.88); }
.content-section { padding: 32px 20px 56px; }
.content-grid { display: grid; grid-template-columns: minmax(0, 1fr) 340px; gap: 24px; align-items: start; }
.summary-card, .form-card, .side-card { border: none; border-radius: 24px; box-shadow: 0 16px 40px rgba(31,52,85,.08); }
.summary-card { margin-bottom: 20px; }
.summary-grid { display: grid; grid-template-columns: 280px 1fr; gap: 20px; }
.room-image { width: 100%; height: 220px; object-fit: cover; border-radius: 20px; }
.room-name { margin: 0 0 8px; font-size: 28px; }
.room-subtitle { margin: 0 0 16px; color: #6d7b8d; }
.fact-list { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 16px; }
.fact-list span { padding: 8px 12px; border-radius: 999px; background: #f3f6fa; color: #506071; font-size: 13px; }
.price-line strong, .amount { color: #d43c2f; }
.form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
.full-width { width: 100%; }
.availability-box, .availability-placeholder { margin-bottom: 16px; padding: 16px; border-radius: 16px; }
.availability-box.success { background: #ecfdf5; color: #065f46; }
.availability-box.danger { background: #fef2f2; color: #991b1b; }
.availability-placeholder { background: #f8fafc; color: #64748b; }
.summary-row { display: flex; justify-content: space-between; gap: 12px; padding: 10px 0; border-bottom: 1px solid #e6edf5; }
.summary-row.total strong { color: #d43c2f; }
.actions { display: flex; flex-direction: column; gap: 12px; margin-top: 18px; }
.pay-dialog { display: flex; flex-direction: column; gap: 14px; }
.pay-row { display: flex; justify-content: space-between; gap: 12px; }
.payment-methods { display: flex; flex-direction: column; gap: 10px; margin-top: 12px; }
@media (max-width: 1100px) {
  .content-grid,
  .summary-grid {
    grid-template-columns: 1fr;
  }

  .side-content {
    order: -1;
  }
}

@media (max-width: 768px) {
  .booking-page {
    min-height: auto;
    padding-bottom: calc(96px + env(safe-area-inset-bottom));
  }

  .section-container {
    padding: 0 14px;
  }

  .hero-content {
    padding: 20px 14px 28px;
  }

  .breadcrumb {
    margin-bottom: 14px;
    font-size: 12px;
  }

  .hero-title {
    font-size: 28px;
  }

  .hero-subtitle {
    font-size: 14px;
    line-height: 1.6;
  }

  .content-section {
    padding: 18px 0 28px;
  }

  .summary-card,
  .form-card,
  .side-card {
    border-radius: 20px;
  }

  .summary-grid,
  .form-grid {
    grid-template-columns: 1fr;
  }

  .room-image {
    height: 180px;
  }

  .room-name {
    font-size: 22px;
  }

  .side-content {
    order: -1;
  }

  .side-card {
    position: sticky;
    bottom: calc(10px + env(safe-area-inset-bottom));
    z-index: 10;
    box-shadow: 0 14px 32px rgba(31, 52, 85, 0.14);
  }

  .summary-row {
    font-size: 14px;
  }

  .actions {
    margin-top: 14px;
  }

  .actions .el-button {
    min-height: 46px;
  }

  .pay-row {
    flex-direction: column;
    align-items: flex-start;
  }
}

@media (max-width: 480px) {
  .section-container {
    padding: 0 12px;
  }

  .hero-title {
    font-size: 24px;
  }

  .room-image {
    height: 160px;
    border-radius: 16px;
  }

  .fact-list span {
    width: 100%;
    text-align: center;
  }
}
</style>
