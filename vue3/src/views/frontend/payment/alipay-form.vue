<template>
  <div class="alipay-form-container">
    <div v-if="loading" class="status-card">
      <h2>正在跳转支付宝</h2>
      <p>请稍候，系统正在为你发起支付。</p>
    </div>

    <div v-else-if="errorMessage" class="status-card error">
      <h2>支付发起失败</h2>
      <p>{{ errorMessage }}</p>
      <div class="actions">
        <button class="btn btn-secondary" @click="goBack">返回</button>
        <button class="btn btn-primary" @click="loadAlipayForm">重新发起</button>
      </div>
    </div>

    <div v-else class="status-card">
      <h2>已发起支付宝支付</h2>
      <p>如果页面没有自动跳转，请点击下方按钮重新发起。</p>
      <div class="actions">
        <button class="btn btn-secondary" @click="goBack">返回</button>
        <button class="btn btn-primary" @click="loadAlipayForm">重新发起支付</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()

const loading = ref(true)
const errorMessage = ref('')

const loadAlipayForm = async () => {
  loading.value = true
  errorMessage.value = ''

  try {
    await request.post(`/alipay/mock-pay/${route.params.id}`, null, {
      showDefaultMsg: false,
      successMsg: false,
      onSuccess: () => {
        router.push('/payment/result?status=success')
      }
    })
  } catch (error) {
    console.error('发起支付宝支付失败:', error)
    errorMessage.value = error?.message || '支付发起失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  router.back()
}

onMounted(() => {
  loadAlipayForm()
})
</script>

<style scoped>
.alipay-form-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: #f3f6fb;
  padding: 24px;
}

.status-card {
  width: 100%;
  max-width: 520px;
  padding: 36px 32px;
  border-radius: 20px;
  background: #ffffff;
  box-shadow: 0 18px 40px rgba(31, 52, 85, 0.08);
  text-align: center;
}

.status-card h2 {
  margin: 0 0 12px;
  color: #1f2937;
}

.status-card p {
  margin: 0;
  color: #64748b;
  line-height: 1.7;
}

.status-card.error h2 {
  color: #dc2626;
}

.actions {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 24px;
}

.btn {
  min-width: 132px;
  padding: 12px 18px;
  border: none;
  border-radius: 10px;
  font-size: 15px;
  cursor: pointer;
}

.btn-primary {
  background: #1677ff;
  color: #ffffff;
}

.btn-secondary {
  background: #e5e7eb;
  color: #374151;
}
</style>
