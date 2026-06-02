<template>
  <div class="frontend-layout">
    <header class="header">
      <div class="nav-container">
        <div class="logo-container">
          <el-icon class="logo-icon"><Place /></el-icon>
          <h1 class="logo-text">旅游信息系统</h1>
        </div>

        <el-menu mode="horizontal" :ellipsis="false" class="main-menu" :router="true">
          <el-menu-item index="/">
            <el-icon><HomeFilled /></el-icon>
            <span>首页</span>
          </el-menu-item>

          <el-menu-item index="/scenic">
            <el-icon><Bicycle /></el-icon>
            <span>景点</span>
          </el-menu-item>

          <el-menu-item index="/guide">
            <el-icon><Reading /></el-icon>
            <span>攻略</span>
          </el-menu-item>

          <el-menu-item index="/accommodation">
            <el-icon><House /></el-icon>
            <span>周边住宿</span>
          </el-menu-item>

          <el-menu-item index="/tickets">
            <el-icon><Ticket /></el-icon>
            <span>门票预订</span>
          </el-menu-item>

          <el-menu-item index="/route-planning">
            <el-icon><Compass /></el-icon>
            <span>路线规划</span>
          </el-menu-item>
        </el-menu>

        <el-button
          class="mobile-menu-btn"
          circle
          @click="mobileMenuVisible = true"
        >
          <el-icon><Menu /></el-icon>
        </el-button>

        <div class="user-actions">
          <template v-if="isLoggedIn">
            <el-dropdown trigger="click" @command="handleCommand">
              <div class="user-info">
                <el-avatar :size="32" :src="userAvatar">{{ userInitial }}</el-avatar>
                <span class="user-name">{{ userName || '用户' }}</span>
                <el-icon><ArrowDown /></el-icon>
              </div>

              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile" icon="User">个人中心</el-dropdown-item>
                  <el-dropdown-item command="guide" icon="Notebook">我的攻略</el-dropdown-item>
                  <el-dropdown-item command="collection" icon="Star">我的收藏</el-dropdown-item>
                  <el-dropdown-item command="orders" icon="Ticket">门票订单</el-dropdown-item>
                  <el-dropdown-item command="accommodationOrders" icon="House">酒店订单</el-dropdown-item>
                  <el-dropdown-item divided command="logout" icon="SwitchButton">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>

          <template v-else>
            <el-button type="primary" @click="goToLogin" class="login-btn">
              <el-icon><Key /></el-icon>
              <span>登录 / 注册</span>
            </el-button>
          </template>
        </div>
      </div>
    </header>

    <el-drawer
      v-model="mobileMenuVisible"
      direction="ltr"
      size="82%"
      class="mobile-nav-drawer"
    >
      <template #header>
        <div class="mobile-drawer-header">
          <div class="mobile-brand">
            <el-icon class="logo-icon"><Place /></el-icon>
            <span>旅游信息系统</span>
          </div>
        </div>
      </template>

      <div class="mobile-drawer-body">
        <div class="mobile-nav-list">
          <button
            v-for="item in navItems"
            :key="item.path"
            type="button"
            class="mobile-nav-item"
            :class="{ active: activePath === item.path }"
            @click="goToPath(item.path)"
          >
            <el-icon><component :is="item.icon" /></el-icon>
            <span>{{ item.label }}</span>
          </button>
        </div>

        <div class="mobile-user-panel">
          <template v-if="isLoggedIn">
            <div class="mobile-user-card">
              <el-avatar :size="42" :src="userAvatar">{{ userInitial }}</el-avatar>
              <div class="mobile-user-meta">
                <div class="mobile-user-name">{{ userName || '用户' }}</div>
                <div class="mobile-user-subtitle">欢迎回来</div>
              </div>
            </div>

            <div class="mobile-action-list">
              <button type="button" class="mobile-action-item" @click="handleMobileCommand('profile')">个人中心</button>
              <button type="button" class="mobile-action-item" @click="handleMobileCommand('guide')">我的攻略</button>
              <button type="button" class="mobile-action-item" @click="handleMobileCommand('collection')">我的收藏</button>
              <button type="button" class="mobile-action-item" @click="handleMobileCommand('orders')">门票订单</button>
              <button type="button" class="mobile-action-item" @click="handleMobileCommand('accommodationOrders')">酒店订单</button>
              <button type="button" class="mobile-action-item danger" @click="handleMobileCommand('logout')">退出登录</button>
            </div>
          </template>

          <template v-else>
            <el-button type="primary" class="mobile-login-btn" @click="goToLogin">
              登录 / 注册
            </el-button>
          </template>
        </div>
      </div>
    </el-drawer>

    <el-main class="main-content">
      <router-view v-slot="{ Component, route }">
        <keep-alive :include="['RoutePlanning']">
          <component
            :is="Component"
            v-if="route.meta?.keepAlive"
            :key="route.name"
          />
        </keep-alive>
        <component
          :is="Component"
          v-if="!route.meta?.keepAlive"
          :key="route.fullPath"
        />
      </router-view>
    </el-main>

    <footer class="footer">
      <div class="footer-content">
        <p class="copyright">&copy; 2026 旅游信息系统 | 版权所有</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useUserStore } from '@/store/user'
import { useRoute, useRouter } from 'vue-router'
import {
  ArrowDown,
  Bicycle,
  Menu,
  Compass,
  HomeFilled,
  House,
  Key,
  Place,
  Reading,
  Ticket
} from '@element-plus/icons-vue'

const userStore = useUserStore()
const router = useRouter()
const route = useRoute()
const mobileMenuVisible = ref(false)

const isLoggedIn = computed(() => !!userStore.token)
const userName = computed(() => userStore.userInfo?.name || userStore.userInfo?.username || '')
const navItems = [
  { path: '/', label: '首页', icon: HomeFilled },
  { path: '/scenic', label: '景点', icon: Bicycle },
  { path: '/guide', label: '攻略', icon: Reading },
  { path: '/accommodation', label: '住宿', icon: House },
  { path: '/tickets', label: '门票', icon: Ticket },
  { path: '/route-planning', label: '路线规划', icon: Compass }
]
const activePath = computed(() => {
  const currentPath = route.path || '/'
  const matched = navItems.find((item) => currentPath === item.path || currentPath.startsWith(`${item.path}/`))
  return matched?.path || '/'
})
const userInitial = computed(() => {
  const name = userName.value
  return name ? name.charAt(0).toUpperCase() : '游'
})

const userAvatar = computed(() => {
  const baseAPI = process.env.VUE_APP_BASE_API || '/api'
  return userStore.userInfo?.avatar ? baseAPI + userStore.userInfo.avatar : ''
})

const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'guide':
      router.push('/my-guide')
      break
    case 'collection':
      router.push('/collection')
      break
    case 'orders':
      router.push('/orders')
      break
    case 'accommodationOrders':
      router.push('/accommodation/orders')
      break
    case 'logout':
      userStore.clearUserInfo()
      router.push('/login')
      break
  }
}

const handleMobileCommand = (command) => {
  mobileMenuVisible.value = false
  handleCommand(command)
}

const goToPath = (path) => {
  mobileMenuVisible.value = false
  router.push(path)
}

const goToLogin = () => {
  mobileMenuVisible.value = false
  router.push('/login')
}
</script>

<style lang="scss" scoped>
.frontend-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f5f7fa;
}

.header {
  position: sticky;
  top: 0;
  z-index: 1000;
  background: #ffffff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.nav-container {
  display: flex;
  align-items: center;
  height: 64px;
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
}

.logo-container {
  display: flex;
  align-items: center;
  margin-right: 30px;
}

.logo-icon {
  margin-right: 10px;
  font-size: 24px;
  color: #3490dc;
}

.logo-text {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #3490dc;
}

.main-menu {
  flex: 1;
  border-bottom: none;
  background-color: transparent;
}

.mobile-menu-btn {
  display: none;
  margin-left: auto;
  border: none;
  background: #eff6ff;
  color: #2563eb;
}

.main-menu :deep(.el-menu-item) {
  color: #606266;
  font-size: 16px;
}

.main-menu :deep(.el-menu-item:hover),
.main-menu :deep(.el-menu-item.is-active) {
  color: #3490dc;
  background-color: transparent;
}

.main-menu :deep(.el-menu-item .el-icon) {
  margin-right: 5px;
}

.user-actions {
  margin-left: auto;
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  padding: 5px 10px;
  border-radius: 20px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: #f5f7fa;
}

.user-name {
  margin: 0 8px;
  color: #606266;
  font-size: 14px;
}

.login-btn {
  border: none;
  border-radius: 4px;
  background-color: #3490dc;
  color: #fff;
  padding: 8px 16px;
}

.login-btn .el-icon {
  margin-right: 5px;
}

.main-content {
  flex: 1;
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px max(16px, env(safe-area-inset-right)) calc(24px + env(safe-area-inset-bottom)) max(16px, env(safe-area-inset-left));
}

.footer {
  background: #f8fafc;
  color: #606266;
  border-top: 1px solid #eaecef;
  padding: 20px 0;
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  text-align: center;
}

.copyright {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

:deep(.mobile-nav-drawer .el-drawer__header) {
  margin-bottom: 0;
  padding-bottom: 12px;
}

:deep(.mobile-nav-drawer .el-drawer__body) {
  padding-top: 0;
}

.mobile-drawer-header {
  width: 100%;
}

.mobile-brand {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: 700;
  color: #0f172a;
}

.mobile-drawer-body {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.mobile-nav-list,
.mobile-action-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.mobile-nav-item,
.mobile-action-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 14px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  background: #fff;
  color: #0f172a;
  font-size: 15px;
  cursor: pointer;
}

.mobile-nav-item.active {
  border-color: #93c5fd;
  background: #eff6ff;
  color: #1d4ed8;
}

.mobile-user-panel {
  border-top: 1px solid #e5e7eb;
  padding-top: 20px;
}

.mobile-user-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 0 18px;
}

.mobile-user-meta {
  min-width: 0;
}

.mobile-user-name {
  color: #0f172a;
  font-size: 16px;
  font-weight: 700;
}

.mobile-user-subtitle {
  margin-top: 4px;
  color: #64748b;
  font-size: 13px;
}

.mobile-action-item.danger {
  color: #dc2626;
}

.mobile-login-btn {
  width: 100%;
  height: 44px;
  border-radius: 12px;
}

@media (max-width: 768px) {
  .nav-container {
    height: 60px;
    padding: 0 12px;
  }

  .logo-container {
    margin-right: 12px;
  }

  .main-menu {
    display: none;
  }

  .mobile-menu-btn {
    display: inline-flex;
  }

  .user-actions {
    margin-left: 10px;
  }

  .user-name {
    display: none;
  }

  .login-btn {
    padding: 8px 10px;
  }

  .login-btn span {
    display: none;
  }

  .login-btn .el-icon {
    margin-right: 0;
  }

  .main-content {
    padding-top: 14px;
    padding-left: max(12px, env(safe-area-inset-left));
    padding-right: max(12px, env(safe-area-inset-right));
  }

  .footer {
    padding: 14px 0 calc(14px + env(safe-area-inset-bottom));
  }

  .footer-content {
    padding: 0 16px;
  }

  .copyright {
    font-size: 12px;
  }
}
</style>
