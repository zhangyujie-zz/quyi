<template>
  <div class="category-detail">
    <!-- 加载状态 -->
    <div v-if="isLoading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>正在加载分类详情...</p>
    </div>
    
    <!-- 错误提示 -->
    <div v-else-if="errorMessage" class="error-container">
      <i class="fas fa-exclamation-triangle"></i>
      <p>{{ errorMessage }}</p>
      <button @click="loadCategoryDetail" class="btn btn-secondary">
        重新加载
      </button>
    </div>
    
    <!-- 分类详情内容 -->
    <div v-else-if="category" class="category-content">
      <!-- 头部信息 -->
      <header class="category-header">
        <div class="header-background">
          <div class="header-overlay"></div>
          <div class="container">
            <div class="header-content">
              <button @click="goBack" class="back-btn">
                <i class="fas fa-arrow-left"></i>
                返回分类
              </button>
              
              <div class="category-info">
                <div class="category-icon">
                  <i :class="getCategoryIcon(category.name)"></i>
                </div>
                <div class="category-text">
                  <h1 class="category-title">{{ category.name }}</h1>
                  <p class="category-subtitle">{{ category.description }}</p>
                  <div class="category-meta">
                    <span class="meta-item">
                      <i class="fas fa-map-marker-alt"></i>
                      {{ category.origin }}
                    </span>
                    <span class="meta-item">
                      <i class="fas fa-star"></i>
                      {{ category.popularity }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- 主要内容区域 -->
      <main class="main-content">
        <div class="container">
          <!-- 详细描述 -->
          <section class="detail-section">
            <h2 class="section-title">详细描述</h2>
            <div class="description-content">
              <p>{{ category.detailed_description }}</p>
            </div>
          </section>

          <!-- 特点 -->
          <section class="detail-section">
            <h2 class="section-title">艺术特点</h2>
            <div class="characteristics-content">
              <p>{{ category.characteristics }}</p>
            </div>
          </section>

          <!-- 代表人物 -->
          <section class="detail-section">
            <h2 class="section-title">代表人物</h2>
            <div class="representatives-content">
              <div class="representatives-list">
                <div 
                  v-for="representative in representativesList" 
                  :key="representative"
                  class="representative-item"
                >
                  <i class="fas fa-user"></i>
                  <span>{{ representative }}</span>
                </div>
              </div>
            </div>
          </section>

          <!-- 表演形式 -->
          <section class="detail-section">
            <h2 class="section-title">表演形式</h2>
            <div class="performance-content">
              <p>{{ category.performance_form }}</p>
            </div>
          </section>

          <!-- 相关视频 -->
          <section class="detail-section">
            <h2 class="section-title">相关视频</h2>
            <div class="videos-content">
              <div v-if="relatedVideos.length > 0" class="videos-grid">
                <div 
                  v-for="video in relatedVideos" 
                  :key="video.id"
                  class="video-card"
                  @click="goToVideo(video.id)"
                >
                  <div class="video-thumbnail">
                    <img :src="video.thumbnail_url || '/default-thumbnail.jpg'" :alt="video.title">
                    <div class="video-overlay">
                      <i class="fas fa-play"></i>
                    </div>
                    <div class="video-duration">
                      {{ formatDuration(video.duration) }}
                    </div>
                  </div>
                  <div class="video-info">
                    <h4 class="video-title">{{ video.title }}</h4>
                    <p class="video-description">{{ video.description }}</p>
                    <div class="video-stats">
                      <span><i class="fas fa-eye"></i> {{ video.views_count }}</span>
                      <span><i class="fas fa-heart"></i> {{ video.likes_count }}</span>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="no-videos">
                <i class="fas fa-video-slash"></i>
                <p>暂无相关视频</p>
              </div>
            </div>
          </section>

          <!-- 快速导航 -->
          <section class="quick-nav-section">
            <div class="quick-nav">
              <button @click="goToVideos" class="nav-btn primary">
                <i class="fas fa-play"></i>
                观看视频
              </button>
              <button @click="goToCategories" class="nav-btn secondary">
                <i class="fas fa-list"></i>
                浏览其他分类
              </button>
            </div>
          </section>
        </div>
      </main>
    </div>

    <!-- 无数据状态 -->
    <div v-else class="no-data">
      <i class="fas fa-masks-theater"></i>
      <p>分类数据不存在</p>
      <button @click="goToCategories" class="btn btn-primary">
        返回分类列表
      </button>
    </div>
  </div>
</template>

<script>
import { VideoService } from '../services/videoService.js'

export default {
  name: 'CategoryDetail',
  props: {
    id: {
      type: [String, Number],
      required: true
    }
  },
  data() {
    return {
      isLoading: false,
      errorMessage: '',
      category: null,
      relatedVideos: []
    }
  },
  computed: {
    representativesList() {
      if (!this.category || !this.category.representatives) return []
      return this.category.representatives.split('、').map(item => item.trim())
    }
  },
  
  async mounted() {
    await this.loadCategoryDetail()
  },
  
  methods: {
    async loadCategoryDetail() {
      this.isLoading = true
      this.errorMessage = ''
      
      try {
        // 获取分类详情
        this.category = await VideoService.getCategoryDetail(parseInt(this.id))
        
        if (!this.category) {
          this.errorMessage = '分类不存在'
          return
        }
        
        // 获取相关视频
        const videosResult = await VideoService.getVideos({
          categoryId: parseInt(this.id),
          pageSize: 4
        })
        this.relatedVideos = videosResult.videos
        
      } catch (error) {
        console.error('加载分类详情失败:', error)
        this.errorMessage = '加载分类详情失败，请检查网络连接'
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
    
    formatDuration(seconds) {
      if (!seconds) return '00:00'
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
    },
    
    goBack() {
      this.$router.back()
    },
    
    goToVideos() {
      this.$router.push(`/videos?category=${this.id}`)
    },
    
    goToCategories() {
      this.$router.push('/categories')
    },
    
    goToVideo(videoId) {
      this.$router.push(`/video/${videoId}`)
    }
  }
}
</script>

<style scoped>
.category-detail {
  min-height: 100vh;
  background: #f8f9fa;
}

/* 头部样式 */
.category-header {
  position: relative;
  background: linear-gradient(135deg, #8B4513 0%, #A0522D 100%);
  color: white;
}

.header-background {
  position: relative;
  padding: 2rem 0;
}

.header-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
}

.header-content {
  position: relative;
  z-index: 2;
}

.back-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 25px;
  cursor: pointer;
  margin-bottom: 2rem;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateX(-5px);
}

.category-info {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.category-icon {
  font-size: 4rem;
  opacity: 0.9;
}

.category-text {
  flex: 1;
}

.category-title {
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.category-subtitle {
  font-size: 1.3rem;
  opacity: 0.9;
  margin-bottom: 1rem;
}

.category-meta {
  display: flex;
  gap: 2rem;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  opacity: 0.8;
}

/* 主内容区域 */
.main-content {
  padding: 3rem 0;
}

.detail-section {
  margin-bottom: 3rem;
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 1.5rem;
  border-left: 4px solid #8B4513;
  padding-left: 1rem;
}

.description-content p,
.characteristics-content p,
.performance-content p {
  line-height: 1.8;
  color: #555;
  font-size: 1.1rem;
}

/* 代表人物样式 */
.representatives-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.representative-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.representative-item:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.representative-item i {
  color: #8B4513;
  font-size: 1.2rem;
}

/* 视频网格样式 */
.videos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.video-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #e0e0e0;
}

.video-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  border-color: #8B4513;
}

.video-thumbnail {
  position: relative;
  height: 160px;
  overflow: hidden;
}

.video-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.video-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.video-card:hover .video-overlay {
  opacity: 1;
}

.video-overlay i {
  color: white;
  font-size: 2rem;
}

.video-duration {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.8rem;
}

.video-info {
  padding: 1rem;
}

.video-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.video-description {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 1rem;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.video-stats {
  display: flex;
  gap: 1rem;
  color: #888;
  font-size: 0.8rem;
}

.video-stats i {
  margin-right: 0.25rem;
}

/* 快速导航 */
.quick-nav-section {
  text-align: center;
  padding: 2rem 0;
}

.quick-nav {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.nav-btn {
  padding: 1rem 2rem;
  border: none;
  border-radius: 25px;
  font-weight: 600;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
}

.nav-btn.primary {
  background: linear-gradient(45deg, #8B4513, #A0522D);
  color: white;
}

.nav-btn.primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
}

.nav-btn.secondary {
  background: white;
  color: #8B4513;
  border: 2px solid #8B4513;
}

.nav-btn.secondary:hover {
  background: #8B4513;
  color: white;
  transform: translateY(-2px);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .category-title {
    font-size: 2rem;
  }
  
  .category-info {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }
  
  .category-icon {
    font-size: 3rem;
  }
  
  .category-meta {
    flex-direction: column;
    gap: 1rem;
  }
  
  .detail-section {
    padding: 1.5rem;
    margin-bottom: 2rem;
  }
  
  .videos-grid {
    grid-template-columns: 1fr;
  }
  
  .quick-nav {
    flex-direction: column;
    align-items: center;
  }
  
  .nav-btn {
    width: 100%;
    max-width: 300px;
    justify-content: center;
  }
}

/* 加载和错误状态样式 */
.loading-container,
.error-container,
.no-data {
  text-align: center;
  padding: 4rem 2rem;
}

.loading-container {
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

.error-container {
  color: #d9534f;
}

.error-container i {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.no-data {
  color: #888;
}

.no-data i {
  font-size: 4rem;
  margin-bottom: 1rem;
  color: #e0e0e0;
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

.btn-primary {
  background: linear-gradient(45deg, #8B4513, #A0522D);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>