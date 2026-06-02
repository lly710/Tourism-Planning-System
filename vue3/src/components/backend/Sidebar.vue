<template>
  <div class="sidebar-container" :class="{ 'is-collapsed': isCollapsed }">
    <div class="logo">
      <span class="logo-icon">旅</span>
      <span v-show="!isCollapsed" class="logo-text">旅游信息系统</span>
    </div>

    <div class="menu-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapsed"
        :collapse-transition="false"
        class="sidebar-menu"
        text-color="#a6b0cf"
        active-text-color="#ffffff"
        router
      >
        <el-menu-item index="/back/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <template #title>后台首页</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/user">
          <el-icon><User /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>

        <el-menu-item index="/back/profile">
          <el-icon><UserFilled /></el-icon>
          <template #title>个人信息</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/scenic">
          <el-icon><Location /></el-icon>
          <template #title>景点管理</template>
        </el-menu-item>

        <el-menu-item index="/back/category">
          <el-icon><Menu /></el-icon>
          <template #title>分类管理</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/comment">
          <el-icon><ChatDotRound /></el-icon>
          <template #title>评论管理</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/guide">
          <el-icon><Document /></el-icon>
          <template #title>攻略管理</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/collection">
          <el-icon><Star /></el-icon>
          <template #title>收藏管理</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/ticket">
          <el-icon><Ticket /></el-icon>
          <template #title>门票管理</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/order">
          <el-icon><List /></el-icon>
          <template #title>门票订单</template>
        </el-menu-item>

        <el-menu-item index="/back/accommodation">
          <el-icon><House /></el-icon>
          <template #title>住宿管理</template>
        </el-menu-item>

        <el-menu-item index="/back/accommodation-room-type">
          <el-icon><OfficeBuilding /></el-icon>
          <template #title>房型管理</template>
        </el-menu-item>

        <el-menu-item index="/back/accommodation-booking">
          <el-icon><List /></el-icon>
          <template #title>酒店预订订单</template>
        </el-menu-item>

        <el-menu-item v-if="userStore.isAdmin" index="/back/carousel">
          <el-icon><Picture /></el-icon>
          <template #title>轮播图管理</template>
        </el-menu-item>
      </el-menu>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '@/store/app'
import { useUserStore } from '@/store/user'
import {
  ChatDotRound,
  Document,
  HomeFilled,
  House,
  List,
  Location,
  Menu,
  OfficeBuilding,
  Picture,
  Star,
  Ticket,
  User,
  UserFilled
} from '@element-plus/icons-vue'

const route = useRoute()
const appStore = useAppStore()
const userStore = useUserStore()

const isCollapsed = computed(() => appStore.sidebarCollapsed)

const activeMenu = computed(() => {
  if (route.meta.activeMenu) {
    return route.meta.activeMenu
  }
  return route.path
})
</script>

<style lang="scss" scoped>
.sidebar-container {
  display: flex;
  flex-direction: column;
  width: 220px;
  min-height: 100vh;
  background: #ffffff;
  box-shadow: 2px 0 10px rgba(15, 23, 42, 0.08);
  transition: width 0.3s ease;
}

.sidebar-container.is-collapsed {
  width: 64px;
}

.sidebar-container.is-collapsed .logo {
  justify-content: center;
  padding: 0;
}

.sidebar-container.is-collapsed .logo-icon {
  margin-right: 0;
}

.logo {
  display: flex;
  align-items: center;
  height: 60px;
  padding: 0 16px;
  background: linear-gradient(90deg, #1d4ed8 0%, #06b6d4 100%);
  overflow: hidden;
}

.logo-icon {
  margin-right: 10px;
  font-size: 24px;
  font-weight: 700;
  color: #ffffff;
}

.logo-text {
  white-space: nowrap;
  font-size: 18px;
  font-weight: 600;
  color: #ffffff;
}

.menu-wrapper {
  flex: 1;
  overflow-y: auto;
}

:deep(.sidebar-menu) {
  border-right: none;
}

:deep(.sidebar-menu .el-menu-item),
:deep(.sidebar-menu .el-sub-menu__title) {
  height: 50px;
  line-height: 50px;
  transition: all 0.2s ease;
}

:deep(.sidebar-menu .el-menu-item:hover),
:deep(.sidebar-menu .el-sub-menu__title:hover) {
  background: rgba(37, 99, 235, 0.1) !important;
  color: #1d4ed8 !important;
}

:deep(.sidebar-menu .el-menu-item.is-active) {
  background: linear-gradient(90deg, #2563eb 0%, #0ea5e9 100%) !important;
  color: #ffffff !important;
}

.el-icon {
  width: 20px;
  margin-right: 8px;
}
</style>
