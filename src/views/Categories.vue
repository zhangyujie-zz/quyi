<template>
  <div class="categories">
    <!-- 侧边栏导航 -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <div class="sidebar-toggle" @click="toggleSidebar">
          <i class="fas" :class="sidebarOpen ? 'fa-times' : 'fa-bars'"></i>
        </div>
      </div>
      
      <div class="sidebar-content" :class="{ open: sidebarOpen }">
        <nav class="category-nav">
          <div 
            v-for="nav in categoryNavs" 
            :key="nav.id"
            class="nav-item"
            :class="{ active: activeNav === nav.id }"
            @click="setActiveNav(nav.id)"
          >
            <span>{{ nav.name }}</span>
            <span class="category-count">{{ getCategoryCount(nav.id) }}</span>
          </div>
        </nav>
      </div>
    </aside>

    <!-- 主内容区域 -->
    <main class="main-content" :class="{ 'sidebar-expanded': sidebarOpen }">
      <div class="container">
        <h1 class="page-title">
          {{ activeNavName ? `${activeNavName}` : '' }}
        </h1>
        
        <!-- 加载状态 -->
        <div v-if="isLoading" class="loading-container">
          <div class="loading-spinner"></div>
          <p>正在加载分类数据...</p>
        </div>
        
        <!-- 错误提示 -->
        <div v-else-if="errorMessage" class="error-container">
          <i class="fas fa-exclamation-triangle"></i>
          <p>{{ errorMessage }}</p>
          <button @click="loadCategories" class="btn btn-secondary">
            重新加载
          </button>
        </div>
        
        <!-- 分类内容 -->
        <div v-else class="category-content">
          <div 
            v-for="category in filteredCategories" 
            :key="category.id"
            class="category-item card"
            @click="goToCategory(category.id)"
          >
            <div class="category-header">
              <i :class="category.icon"></i>
              <h3>{{ category.name }}</h3>
            </div>
            <p class="category-description">{{ category.description }}</p>
            <div class="category-stats">
              <span><i class="fas fa-video"></i> {{ category.videoCount }} 个视频</span>
              <span><i class="fas fa-users"></i> {{ category.studentCount }} 人学习</span>
            </div>
            <button class="btn btn-secondary">
              开始学习 <i class="fas fa-arrow-right"></i>
            </button>
          </div>
        </div>
        
        <div v-if="!isLoading && !errorMessage && filteredCategories.length === 0" class="no-categories">
          <i class="fas fa-masks-theater"></i>
          <p>暂无分类数据</p>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { VideoService } from '../services/videoService.js'

export default {
  name: 'Categories',
  data() {
    return {
      sidebarOpen: false,
      activeNav: 1,
      isLoading: false,
      errorMessage: '',
      categoryNavs: [
        { id: 1, name: '全部' },
        { id: 2, name: '语言类' },
        { id: 3, name: '戏曲类' },
        { id: 4, name: '音乐类' }
      ],
      categories: []
    }
  },
  computed: {
    filteredCategories() {
      if (this.activeNav === 1) {
        return this.categories
      }
      return this.categories.filter(cat => cat.type === this.activeNav)
    },
    
    activeNavName() {
      if (this.activeNav === 1) return ''
      const nav = this.categoryNavs.find(n => n.id === this.activeNav)
      return nav ? nav.name : ''
    }
  },
  
  async mounted() {
    await this.loadCategories()
  },
  
  methods: {
    async loadCategories() {
      this.isLoading = true
      this.errorMessage = ''
      
      try {
        const categoriesData = await VideoService.getCategories()
        
        if (categoriesData && categoriesData.length > 0) {
          // 将数据库数据转换为前端需要的格式
          this.categories = categoriesData.map(category => ({
            id: category.id,
            name: category.name,
            icon: this.getCategoryIcon(category.name),
            description: category.description || '暂无描述',
            videoCount: Math.floor(Math.random() * 200) + 50, // 暂时使用随机数据，后续可以从数据库获取实际数据
            studentCount: Math.floor(Math.random() * 10000) + 1000,
            type: this.getCategoryType(category.name)
          }))
        } else {
          // 如果数据库为空，使用默认数据
          this.useDefaultCategories()
        }
      } catch (error) {
        console.error('获取分类数据失败:', error)
        this.errorMessage = '获取分类数据失败，请检查网络连接或数据库配置'
        // 降级使用默认数据
        this.useDefaultCategories()
      } finally {
        this.isLoading = false
      }
    },
    
    getCategoryIcon(categoryName) {
      const iconMap = {
        '相声': 'fas fa-microphone-alt',
        '评书': 'fas fa-book-open',
        '京剧': 'fas fa-mask',
        '豫剧': 'fas fa-landmark',
        '快板': 'fas fa-drum',
        '山东快书': 'fas fa-guitar',
        '昆曲': 'fas fa-masks-theater',
        '二人转': 'fas fa-users'
      }
      return iconMap[categoryName] || 'fas fa-folder'
    },
    
    getCategoryType(categoryName) {
      const typeMap = {
        '相声': 2,
        '评书': 2,
        '京剧': 3,
        '豫剧': 3,
        '快板': 4,
        '山东快书': 4,
        '昆曲': 3,
        '二人转': 4
      }
      return typeMap[categoryName] || 1
    },
    
    useDefaultCategories() {
      this.categories = [
        {
          id: 1,
          name: '相声',
          icon: 'fas fa-microphone-alt',
          description: '中国传统喜剧表演形式，通过对话、笑话和幽默来娱乐观众',
          videoCount: 128,
          studentCount: 5234,
          type: 2
        },
        {
          id: 2,
          name: '评书',
          icon: 'fas fa-book-open',
          description: '以口头讲述为主，辅以表情和动作来演绎历史故事',
          videoCount: 96,
          studentCount: 3856,
          type: 2
        },
        {
          id: 3,
          name: '京剧',
          icon: 'fas fa-mask',
          description: '中国戏曲的代表，融合唱、念、做、打等多种表演形式',
          videoCount: 156,
          studentCount: 6897,
          type: 3
        }
      ]
    },
    
    toggleSidebar() {
      this.sidebarOpen = !this.sidebarOpen
    },
    
    setActiveNav(navId) {
      this.activeNav = navId
    },
    
    getNavIcon(navId) {
      const iconMap = {
        1: 'fa-th-large',
        2: 'fa-comments',
        3: 'fa-mask',
        4: 'fa-music'
      }
      return iconMap[navId] || 'fa-folder'
    },
    
    getCategoryCount(navId) {
      if (navId === 1) return this.categories.length
      return this.categories.filter(cat => cat.type === navId).length
    },
    
    goToCategory(categoryId) {
      this.$router.push(`/category/${categoryId}`)
    }
  }
}
</script>

<style scoped>
.categories {
  display: flex;
  min-height: 100vh;
}

/* 侧边栏样式 */
.sidebar {
  width: 280px;
  min-width: 280px;
  background: #f8f9fa;
  border-right: 1px solid #e0e0e0;
  transition: all 0.3s ease;
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
}

.sidebar-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
}



.sidebar-toggle {
  display: none;
  background: none;
  border: none;
  color: #8B4513;
  cursor: pointer;
  font-size: 1.2rem;
}

.category-nav {
  padding: 1rem 0;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  border-left: 3px solid transparent;
}

.nav-item:hover {
  background: rgba(139, 69, 19, 0.05);
}

.nav-item.active {
  background: rgba(139, 69, 19, 0.1);
  border-left-color: #8B4513;
  color: #8B4513;
}

.nav-item i {
  width: 20px;
  margin-right: 1rem;
  font-size: 1rem;
}

.nav-item span:first-of-type {
  flex: 1;
  font-weight: 500;
}

.category-count {
  background: #e0e0e0;
  color: #666;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  min-width: 30px;
  text-align: center;
}

.nav-item.active .category-count {
  background: #8B4513;
  color: white;
}

/* 主内容区域 */
.main-content {
  flex: 1;
  transition: all 0.3s ease;
  padding: 2rem;
}

.main-content.sidebar-expanded {
  margin-left: -280px;
}

.page-title {
  text-align: center;
  font-size: 2.5rem;
  margin-bottom: 2rem;
  color: #2c3e50;
}

.category-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 2rem;
}

.category-item {
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
}

.category-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  border-color: #8B4513;
}

.category-header {
  margin-bottom: 1.5rem;
}

.category-header i {
  font-size: 3rem;
  color: #8B4513;
  margin-bottom: 1rem;
}

.category-header h3 {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.category-description {
  color: #666;
  line-height: 1.6;
  margin-bottom: 1.5rem;
}

.category-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 1.5rem;
  color: #888;
}

.category-stats i {
  margin-right: 0.5rem;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.btn-secondary {
  background: linear-gradient(45deg, #8B4513, #A0522D);
  color: white;
}

.btn-secondary:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
}

.no-categories {
  text-align: center;
  padding: 4rem 2rem;
  color: #888;
}

.no-categories i {
  font-size: 4rem;
  margin-bottom: 1rem;
  color: #e0e0e0;
}

.no-categories p {
  font-size: 1.2rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .sidebar {
    width: 250px;
    min-width: 250px;
  }
  
  .main-content.sidebar-expanded {
    margin-left: -250px;
  }
  
  .sidebar-toggle {
    display: block;
  }
  
  .sidebar-content:not(.open) {
    display: none;
  }
  
  .main-content {
    padding: 1rem;
  }
  
  .page-title {
    font-size: 2rem;
  }
  
  .category-content {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .category-item {
    padding: 1.5rem;
  }
  
  .category-stats {
    flex-direction: column;
    gap: 0.5rem;
  }
}

@media (max-width: 480px) {
  .sidebar {
    position: fixed;
    left: -280px;
    z-index: 1000;
    background: white;
    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
  }
  
  .sidebar.open {
    left: 0;
  }
  
  .main-content {
    width: 100%;
    margin-left: 0;
  }
  
  .page-title {
    font-size: 1.8rem;
  }
}

/* 加载和错误状态样式 */
.loading-container {
  text-align: center;
  padding: 4rem 2rem;
  color: #666;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #8B4513;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-container p {
  font-size: 1.1rem;
}

.error-container {
  text-align: center;
  padding: 4rem 2rem;
  color: #d9534f;
}

.error-container i {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.error-container p {
  font-size: 1.2rem;
  margin-bottom: 2rem;
}

.error-container .btn {
  margin-top: 1rem;
}
</style>