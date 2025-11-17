<template>
  <div class="videos">
    <div class="container">
      <!-- 页面标题和搜索 -->
      <div class="videos-header">
        <h1 class="page-title">曲艺视频展示</h1>
        <p class="page-subtitle">欣赏各类曲艺艺术的精彩表演视频</p>
        <div class="search-controls">
          <div class="search-box">
            <i class="fas fa-search search-icon"></i>
            <input 
              type="text" 
              class="search-input" 
              placeholder="搜索曲艺视频..."
              v-model="searchQuery"
              @input="handleSearch"
            >
          </div>
          <select v-model="selectedCategory" class="category-filter" @change="filterVideos">
            <option value="">所有曲种</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.name }}
            </option>
          </select>
        </div>
      </div>

      <!-- 加载状态 -->
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>正在加载视频...</p>
      </div>

      <!-- 错误提示 -->
      <div v-else-if="errorMessage" class="error-container">
        <i class="fas fa-exclamation-triangle"></i>
        <p>{{ errorMessage }}</p>
        <button @click="loadVideos" class="btn btn-secondary">
          重新加载
        </button>
      </div>

      <!-- 视频列表 -->
      <div v-else-if="filteredVideos.length > 0" class="videos-grid">
        <div 
          v-for="video in filteredVideos" 
          :key="video.id"
          class="video-card card"
          @click="playVideo(video)"
        >
          <div class="video-thumbnail">
            <img 
              v-if="video.thumbnail_url" 
              :src="video.thumbnail_url" 
              :alt="video.title"
              @error="handleImageError"
            >
            <div v-else class="thumbnail-placeholder"></div>
            <i class="fas fa-play-circle play-icon"></i>
            <div class="video-duration">{{ formatDuration(video.duration) }}</div>
            <div class="video-category">{{ getCategoryName(video.category_id) }}</div>
          </div>
          <div class="video-info">
            <div class="video-all-horizontal">
              <h3 class="video-title">{{ video.title }}</h3>
              <span class="video-performer">
                <i class="fas fa-user"></i> {{ video.performer || '未知表演者' }}
              </span>
              <span class="video-category horizontal">
                <i class="fas fa-tag"></i> {{ getCategoryName(video.category_id) }}
              </span>
              <p class="video-description">{{ video.description }}</p>
              <span class="video-views">
                <i class="fas fa-eye"></i> {{ video.views_count || 0 }} 次观看
              </span>
              <div class="video-tags">
                <span v-for="tag in (video.tags || [])" :key="tag" class="tag">{{ tag }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-else class="empty-state">
        <i class="fas fa-video-slash"></i>
        <h3>暂无视频</h3>
        <p>当前没有找到符合条件的视频内容</p>
      </div>

      <!-- 加载更多 -->
      <div class="load-more" v-if="hasMoreVideos">
        <button class="btn" @click="loadMoreVideos">
          加载更多视频 <i class="fas fa-arrow-down"></i>
        </button>
      </div>
    </div>

    <!-- 视频播放器模态框 -->
    <div v-if="currentVideo" class="video-modal" @click="closeVideo">
      <div class="modal-content" @click.stop>
        <button class="close-btn" @click="closeVideo">
          <i class="fas fa-times"></i>
        </button>
        <div class="video-player">
          <div class="player-placeholder">
            <i class="fas fa-play-circle"></i>
            <p>视频播放器</p>
          </div>
        </div>
        <div class="video-details">
          <h3>{{ currentVideo.title }}</h3>
          <p>{{ currentVideo.description }}</p>
          <div class="video-info">
            <span>讲师：{{ currentVideo.teacher }}</span>
            <span>时长：{{ currentVideo.duration }}</span>
            <span>分类：{{ getCategoryName(currentVideo.categoryId) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { VideoService } from '../services/videoService.js'

export default {
  name: 'Videos',
  data() {
    return {
      searchQuery: '',
      selectedCategory: '',
      currentVideo: null,
      categories: [],
      videos: [],
      loading: false,
      errorMessage: '',
      page: 1,
      pageSize: 12,
      totalPages: 0,
      totalVideos: 0
    }
  },
  computed: {
    filteredVideos() {
      return this.videos
    },
    hasMoreVideos() {
      return this.page < this.totalPages
    }
  },
  async mounted() {
    await this.loadVideos()
  },
  methods: {
    async loadCategories() {
      try {
        this.categories = await VideoService.getCategories()
      } catch (error) {
        console.error('加载分类失败:', error)
      }
    },
    
    async loadVideos() {
      this.loading = true
      this.errorMessage = ''
      
      try {
        // 同时加载分类和视频数据
        const [categoriesData, videosData] = await Promise.all([
          VideoService.getCategories(),
          VideoService.getVideos({
            categoryId: this.selectedCategory || null,
            page: this.page,
            pageSize: this.pageSize
          })
        ])
        
        // 处理分类数据
        this.categories = categoriesData || []
        
        // 处理视频数据
        if (videosData && videosData.videos) {
          this.videos = videosData.videos
          this.totalVideos = videosData.total
          this.totalPages = videosData.totalPages
        } else {
          // 如果数据库为空，使用默认数据
          this.useDefaultVideos()
        }
      } catch (error) {
        console.error('加载视频失败:', error)
        this.errorMessage = '获取视频数据失败，请检查网络连接'
        // 降级使用默认数据
        this.useDefaultVideos()
      } finally {
        this.loading = false
      }
    },
    
    useDefaultVideos() {
      // 默认视频数据
      this.videos = [
        {
          id: 1,
          title: '相声名段欣赏 - 郭德纲经典相声',
          description: '郭德纲经典相声表演，包含多个经典段子，展现相声艺术的魅力。',
          duration: 1800,
          views_count: 25000,
          category_id: 1,
          performer: '郭德纲',
          thumbnail_url: '/resource/image/首页相声.png',
          tags: ['相声', '经典', '幽默']
        },
        {
          id: 2,
          title: '评书精选 - 单田芳《隋唐演义》',
          description: '单田芳大师经典评书《隋唐演义》，讲述隋唐历史英雄故事。',
          duration: 2400,
          views_count: 18000,
          category_id: 2,
          performer: '单田芳',
          thumbnail_url: '/resource/image/首页评书.jpg',
          tags: ['评书', '历史', '经典']
        },
        {
          id: 3,
          title: '京剧经典 - 梅兰芳《贵妃醉酒》',
          description: '梅兰芳大师经典京剧表演《贵妃醉酒》，展现京剧艺术的精髓。',
          duration: 1500,
          views_count: 12000,
          category_id: 3,
          performer: '梅兰芳',
          thumbnail_url: '/resource/image/首页京剧.jpg',
          tags: ['京剧', '经典', '艺术']
        }
      ]
      this.totalVideos = this.videos.length
      this.totalPages = 1
    },
    
    useDefaultVideos() {
      // 默认视频数据
      this.videos = [
        {
          id: 1,
          title: '相声名段欣赏 - 郭德纲经典相声',
          description: '郭德纲经典相声表演，包含多个经典段子，展现相声艺术的魅力。',
          duration: 1800,
          views_count: 25000,
          category_id: 1,
          performer: '郭德纲',
          thumbnail_url: '/resource/image/首页相声.png',
          tags: ['相声', '经典', '幽默']
        },
        {
          id: 2,
          title: '评书精选 - 单田芳《隋唐演义》',
          description: '单田芳大师经典评书《隋唐演义》，讲述隋唐历史英雄故事。',
          duration: 2400,
          views_count: 18000,
          category_id: 2,
          performer: '单田芳',
          thumbnail_url: '/resource/image/首页评书.jpg',
          tags: ['评书', '历史', '经典']
        },
        {
          id: 3,
          title: '京剧经典 - 梅兰芳《贵妃醉酒》',
          description: '梅兰芳大师经典京剧表演《贵妃醉酒》，展现京剧艺术的精髓。',
          duration: 1500,
          views_count: 12000,
          category_id: 3,
          performer: '梅兰芳',
          thumbnail_url: '/resource/image/首页京剧.jpg',
          tags: ['京剧', '经典', '艺术']
        }
      ]
      this.totalVideos = this.videos.length
      this.totalPages = 1
    },
    
    async handleSearch() {
      if (this.searchQuery.trim()) {
        try {
          await VideoService.recordSearchKeyword(this.searchQuery)
          const result = await VideoService.searchVideos(this.searchQuery)
          this.videos = result.videos
          this.totalVideos = result.total
          this.totalPages = result.totalPages
          this.page = 1
        } catch (error) {
          console.error('搜索失败:', error)
        }
      } else {
        await this.loadVideos()
      }
    },
    
    async filterVideos() {
      this.page = 1
      await this.loadVideos()
    },
    
    playVideo(video) {
      // 跳转到视频播放页面
      this.$router.push(`/video/${video.id}`)
    },
    
    closeVideo() {
      this.currentVideo = null
    },
    
    getCategoryName(categoryId) {
      const category = this.categories.find(cat => cat.id === categoryId)
      return category ? category.name : '未知分类'
    },
    
    formatDuration(seconds) {
      if (!seconds) return '00:00'
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
    },
    
    async loadMoreVideos() {
      if (this.hasMoreVideos) {
        this.page++
        try {
          const options = {
            categoryId: this.selectedCategory || null,
            page: this.page,
            pageSize: this.pageSize
          }
          
          const result = await VideoService.getVideos(options)
          this.videos = [...this.videos, ...result.videos]
        } catch (error) {
          console.error('加载更多视频失败:', error)
          this.page--
        }
      }
    },
    
    handleImageError(event) {
      // 图片加载失败时显示占位符
      const img = event.target
      const parent = img.parentElement
      if (parent) {
        const placeholder = parent.querySelector('.thumbnail-placeholder')
        if (placeholder) {
          placeholder.style.display = 'block'
        }
        img.style.display = 'none'
      }
    }
  }
}
</script>

<style scoped>
.videos-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.search-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.category-filter {
  padding: 0.75rem 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 25px;
  background: white;
  cursor: pointer;
}

.videos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.video-card {
  cursor: pointer;
  transition: all 0.3s ease;
  overflow: hidden;
}

.video-card:hover {
  transform: translateY(-5px);
}

.video-thumbnail {
  position: relative;
  height: 200px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  overflow: hidden;
}

.video-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: absolute;
  top: 0;
  left: 0;
}

.thumbnail-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  position: absolute;
  top: 0;
  left: 0;
  display: none;
}

.play-icon {
  font-size: 4rem;
  opacity: 0.8;
  transition: all 0.3s ease;
}

.video-card:hover .play-icon {
  transform: scale(1.1);
  opacity: 1;
}

.video-duration {
  position: absolute;
  bottom: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.7);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
}

.video-category {
  position: absolute;
  top: 10px;
  left: 10px;
  background: #8B4513;
  color: white;
  padding: 0.3rem 0.6rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.video-info {
  padding: 1.5rem;
}

.video-all-horizontal {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.video-title {
  font-size: 1.1rem;
  color: #2c3e50;
  line-height: 1.3;
  margin: 0;
  flex-shrink: 0;
}

.video-description {
  color: #666;
  line-height: 1.4;
  font-size: 0.9rem;
  margin: 0;
  flex: 1;
  min-width: 200px;
}

.video-performer,
.video-views {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.85rem;
  color: #666;
  white-space: nowrap;
}

.video-category.horizontal {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.85rem;
  color: #666;
  white-space: nowrap;
}

.video-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
  margin: 0;
}

.tag {
  background: #e74c3c;
  padding: 0.2rem 0.4rem;
  border-radius: 10px;
  font-size: 0.75rem;
  color: white;
  white-space: nowrap;
  font-weight: 500;
}

.tag {
  background: #f0f0f0;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  color: #666;
}

.load-more {
  text-align: center;
}

/* 视频模态框样式 */
.video-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 15px;
  max-width: 800px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
}

.close-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  cursor: pointer;
  z-index: 1001;
}

.video-player {
  height: 400px;
  background: #000;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.player-placeholder {
  text-align: center;
}

.player-placeholder i {
  font-size: 5rem;
  margin-bottom: 1rem;
}

.video-details {
  padding: 2rem;
}

.video-details h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.video-info {
  display: flex;
  gap: 2rem;
  margin-top: 1rem;
  color: #666;
}

@media (max-width: 768px) {
  .videos-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-controls {
    flex-direction: column;
  }
  
  .videos-grid {
    grid-template-columns: 1fr;
  }
  
  .video-all-horizontal {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .modal-content {
    width: 95%;
    margin: 1rem;
  }
  
  .video-player {
    height: 250px;
  }
}
</style>