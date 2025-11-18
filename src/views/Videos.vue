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

    <!-- 引入共享的视频弹窗组件 -->
    <VideosModal 
      v-if="showVideoModal && currentVideo"
      :video="currentVideo"
      :comments="comments"
      :isGeneratingExplanation="isGeneratingExplanation"
      :currentExplanation="currentExplanation"
      :showExplanation="showExplanation"
      :isLoadingComments="isLoadingComments"
      @close="closeVideo"
      @new-comment="handleNewComment"
      @generate-explanation="generateExplanation"
      @close-explanation="closeExplanationModal"
    />
  </div>
</template>

<script>
import { VideoService } from '../services/videoService.js'
import { AIService } from '../services/aiService.js'
import { CommentService } from '../services/commentService.js'
import VideosModal from '../components/VideosModal.vue'

export default {
  name: 'Videos',
  components: {
    VideosModal
  },
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
      totalVideos: 0,
      showVideoModal: false,
      comments: [],
      newComment: '',
      isSubmittingComment: false,
      isGeneratingExplanation: false,
      currentExplanation: '',
      showExplanation: false,
      isLoadingComments: false
    }
  },
  computed: {
    filteredVideos() {
      let list = this.videos || []

      // 分类过滤（双重保险，后端已经按分类查了一次）
      if (this.selectedCategory) {
        const catId = isNaN(Number(this.selectedCategory))
          ? this.selectedCategory
          : Number(this.selectedCategory)
        list = list.filter(v => v.category_id === catId)
      }

      // 关键字前端模糊搜索
      const keyword = this.searchQuery.trim().toLowerCase()
      if (keyword) {
        list = list.filter(v => {
          const title = (v.title || '').toLowerCase()
          const desc = (v.description || '').toLowerCase()
          const performer = (v.performer || '').toLowerCase()
          const tags = (v.tags || []).join(' ').toLowerCase()
          return (
            title.includes(keyword) ||
            desc.includes(keyword) ||
            performer.includes(keyword) ||
            tags.includes(keyword)
          )
        })
      }

      return list
    },
    hasMoreVideos() {
      return this.page < this.totalPages
    }
  },
  async mounted() {
    await this.loadVideos()
    // 初始化时清空评论状态
    this.comments = []
    this.isLoadingComments = false
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
    
    async filterVideos() {
      this.page = 1
      await this.loadVideos()
    },
    
    async playVideo(video) {
      this.currentVideo = video
      this.showVideoModal = true
      await this.loadComments(video.id)
    },
    
    closeVideo() {
      this.showVideoModal = false
      this.currentVideo = null
      this.comments = []
      this.isLoadingComments = false
      this.newComment = ''
      this.closeExplanationModal()
    },
    
    closeExplanationModal() {
      this.showExplanation = false
      this.currentExplanation = ''
      this.isGeneratingExplanation = false
    },
    
    async loadComments() {
      if (!this.currentVideo) return
      
      try {
        // 设置加载状态
        this.isLoadingComments = true
        
        // 调用真实的评论API
        this.comments = await CommentService.getComments(this.currentVideo.id)
      } catch (error) {
        console.error('加载评论失败:', error)
        this.comments = []
      } finally {
        this.isLoadingComments = false
      }
    },
    

    
    formatTime(isoString) {
      const date = new Date(isoString)
      const now = new Date()
      const diff = now - date
      const days = Math.floor(diff / (1000 * 60 * 60 * 24))
      
      if (days === 0) {
        const hours = Math.floor(diff / (1000 * 60 * 60))
        if (hours === 0) {
          const minutes = Math.floor(diff / (1000 * 60))
          return minutes === 0 ? '刚刚' : `${minutes}分钟前`
        }
        return `${hours}小时前`
      } else if (days === 1) {
        return '昨天'
      } else if (days < 7) {
        return `${days}天前`
      } else {
        return date.toLocaleDateString('zh-CN')
      }
    },
    
    async generateExplanation() {
      if (this.isGeneratingExplanation || !this.currentVideo) return
      
      this.isGeneratingExplanation = true
      this.showExplanation = false
      this.currentExplanation = ''
      
      const categoryName = this.currentVideo
        ? this.getCategoryName(this.currentVideo.category_id)
        : '未知分类'
      
      try {
        const prompt = `请作为专业的曲艺讲解员，为以下作品提供专业而生动的讲解：

作品标题：${this.currentVideo.title}
表演者：${this.currentVideo.performer || '未知表演者'}
曲种类别：${categoryName}
作品描述：${this.currentVideo.description}

请从以下几个方面进行讲解：
1. 作品背景和历史意义
2. 艺术特色和表演技巧
3. 文化价值和传承意义
4. 观赏要点和欣赏角度

要求：
- 语言生动有趣，通俗易懂
- 专业性与通俗性并重
- 字数控制在200-300字
- 使用分段结构，便于阅读
- 突出作品的艺术魅力`

        // 使用AIService调用DeepSeek API
        const explanation = await AIService.sendMessage(prompt)
        
        // 格式化讲解内容
        const sanitizedExplanation = (explanation || '').trim()
        this.currentExplanation = sanitizedExplanation
          ? sanitizedExplanation
              .replace(/\r?\n{2,}/g, '</p><p>')
              .replace(/\r?\n/g, '<br>')
              .replace(/^/, '<p>')
              .replace(/$/, '</p>')
          : '<p>讲解内容暂不可用。</p>'
        
        this.showExplanation = true
        
      } catch (error) {
        console.error('生成讲解失败:', error)
        
        // 降级到本地讲解内容
        this.currentExplanation = `<p><strong>作品简介：</strong></p>
          <p>《${this.currentVideo.title}》是一则精彩的${categoryName}作品，由${this.currentVideo.performer || '著名艺术家'}表演。</p>
          <p><strong>艺术特色：</strong></p>
          <p>这个作品充分展现了${categoryName}的艺术魅力，表演者运用精湛的技艺，将传统艺术的精髓完美呈现。无论是语言运用还是表演技巧，都体现了深厚的艺术功底。</p>
          <p><strong>文化价值：</strong></p>
          <p>作为传统曲艺的重要组成部分，这样的作品不仅具有很高的艺术价值，更是中华优秀传统文化的重要载体，值得我们去欣赏和传承。</p>`
        
        this.showExplanation = true
      } finally {
        this.isGeneratingExplanation = false
      }
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
    },

    handleNewComment(newComment) {
      // 将新评论添加到评论列表开头
      this.comments.unshift(newComment)
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

.search-box {
  position: relative;
  flex: 1;
  max-width: 400px;
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #999;
  font-size: 1rem;
  z-index: 2;
}

.search-loading {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #8B4513;
  font-size: 0.9rem;
  z-index: 2;
}

.search-input {
  width: 100%;
  padding: 0.75rem 3rem 0.75rem 2.5rem;
  border: 2px solid #e0e0e0;
  border-radius: 25px;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #8B4513;
  box-shadow: 0 0 0 3px rgba(139, 69, 19, 0.1);
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
  background: rgba(139, 69, 19);
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
  padding: 1rem;
}

.modal-content-split {
  background: white;
  border-radius: 15px;
  max-width: 1200px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  position: relative;
  overflow: hidden;
}

.close-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(139, 69, 19);
  color: white;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  cursor: pointer;
  z-index: 1001;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 左侧视频区域 */
.video-section {
  flex: 1.2;
  display: flex;
  flex-direction: column;
  border-right: 1px solid #e0e0e0;
  overflow-y: auto;
}

.video-player {
  height: 300px;
  background: #000;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.player-placeholder {
  width: 100%;
  height: 100%;
  position: relative;
}

.video-cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.play-overlay {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 4rem;
  opacity: 0.8;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-overlay:hover {
  opacity: 1;
  transform: translate(-50%, -50%) scale(1.1);
}

.video-details {
  padding: 1.5rem;
}

.video-details h2 {
  margin-bottom: 1rem;
  color: #2c3e50;
  font-size: 1.5rem;
}

.video-description {
  color: #666;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.video-meta-info {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  font-size: 0.9rem;
  color: #666;
  margin-bottom: 1rem;
}

.video-meta-info span {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

/* AI讲解区域 */
.ai-explanation-section {
  margin-top: 1rem;
  border-top: 1px solid #e0e0e0;
  padding-top: 1rem;
}

.ai-explanation-btn {
  background: rgba(139, 69, 19);
  color: white;
  border: 2px solid rgba(139, 69, 19);
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  margin-bottom: 1rem;
}

.ai-explanation-btn:hover:not(:disabled) {
  background: rgba(110, 55, 15);
  border-color: rgba(110, 55, 15);
  transform: translateY(-2px);
}

.ai-explanation-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
  background: rgba(150, 150, 150);
  border-color: rgba(150, 150, 150);
}

/* 加载状态显示 */
.loading-status {
  text-align: center;
  padding: 1.5rem;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  margin-bottom: 1rem;
  animation: slideIn 0.3s ease;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e9ecef;
  border-top: 4px solid rgba(139, 69, 19);
  border-radius: 50%;
  margin: 0 auto 1rem;
  animation: spin 1s linear infinite;
}

.loading-status p {
  margin: 0;
  color: #666;
  font-size: 0.9rem;
}

.loading-status.compact {
  margin-top: 0.75rem;
  padding: 0.75rem 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  text-align: left;
}

.loading-status.compact p {
  font-size: 0.85rem;
  margin: 0;
}

.loading-spinner.small {
  width: 24px;
  height: 24px;
  border-width: 3px;
  margin: 0;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.explanation-content {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 12px;
  padding: 1.5rem;
  position: relative;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.explanation-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  color: rgba(139, 69, 19);
}

.explanation-header i {
  font-size: 1.2rem;
}

.explanation-header h4 {
  margin: 0;
  font-size: 1.1rem;
  color: #2c3e50;
}

.explanation-text {
  line-height: 1.8;
  color: #333;
  font-size: 0.95rem;
}

.explanation-text p {
  margin-bottom: 1rem;
}

.explanation-text p:last-child {
  margin-bottom: 0;
}

.close-explanation-btn {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: transparent;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 1.2rem;
  padding: 0.5rem;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.close-explanation-btn:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #666;
}

/* 右侧评论区域 */
.comments-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.comments-header {
  padding: 1.5rem 1.5rem 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.comments-header h3 {
  margin: 0;
  color: #2c3e50;
  font-size: 1.2rem;
}

.comment-input-area {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.comment-input-wrapper {
  display: flex;
  gap: 0.5rem;
}

.comment-input {
  flex: 1;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 0.75rem;
  resize: none;
  font-family: inherit;
  font-size: 0.9rem;
}

.comment-input:focus {
  outline: none;
  border-color: rgba(139, 69, 19);
}

.submit-btn {
  padding: 0.75rem 1.5rem;
  background: rgba(139, 69, 19);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: rgba(110, 55, 15);
}

.submit-btn:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}

.comments-list {
  flex: 1;
  overflow-y: auto;
  padding: 0 1.5rem 1.5rem;
}

.no-comments {
  text-align: center;
  padding: 3rem 1rem;
  color: #999;
}

.no-comments i {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.comment-item {
  display: flex;
  gap: 1rem;
  padding: 1rem 0;
  border-bottom: 1px solid #f0f0f0;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.comment-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.comment-avatar i {
  color: #999;
  font-size: 1.2rem;
}

.comment-content {
  flex: 1;
  min-width: 0;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.username {
  font-weight: 600;
  color: #2c3e50;
}

.comment-time {
  font-size: 0.85rem;
  color: #999;
}

.comment-text {
  margin: 0 0 0.5rem 0;
  color: #333;
  line-height: 1.5;
  word-wrap: break-word;
}

.comment-actions {
  display: flex;
  gap: 1rem;
}

.like-btn {
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.85rem;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.like-btn:hover {
  background: #f0f0f0;
  color: rgba(139, 69, 19);
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
  
  .modal-content-split {
    flex-direction: column;
    max-height: 95vh;
  }
  
  .video-section {
    border-right: none;
    border-bottom: 1px solid #e0e0e0;
  }
  
  .video-player {
    height: 200px;
  }
  
  .video-details {
    padding: 1rem;
  }
  
  .video-details h2 {
    font-size: 1.2rem;
  }
  
  .video-meta-info {
    gap: 0.5rem;
    font-size: 0.8rem;
  }
  
  .ai-explanation-btn {
    width: 100%;
    justify-content: center;
  }
  
  .explanation-content {
    padding: 1rem;
  }
  
  .explanation-text {
    font-size: 0.9rem;
  }
  
  .loading-spinner {
    width: 30px;
    height: 30px;
    border-width: 3px;
  }
  
  .loading-status {
    padding: 1rem;
  }
  
  .loading-status p {
    font-size: 0.85rem;
  }
  
  .comments-section {
    max-height: 50vh;
  }
  
  .comment-input-wrapper {
    flex-direction: column;
  }
  
  .submit-btn {
    width: 100%;
  }
}
/* AI讲解弹窗 */
.ai-explanation-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
  padding: 1rem;
}

.ai-explanation-modal-content {
  background: white;
  border-radius: 12px;
  max-width: 600px;
  width: 100%;
  max-height: 80vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: modalSlideIn 0.3s ease;
}

.ai-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem 1.5rem 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.ai-modal-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.ai-modal-title i {
  font-size: 1.3rem;
  color: rgba(139, 69, 19);
}

.ai-modal-title h3 {
  margin: 0;
  font-size: 1.3rem;
  color: #2c3e50;
}

.ai-modal-close-btn {
  background: transparent;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 1.5rem;
  padding: 0.5rem;
  border-radius: 50%;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.ai-modal-close-btn:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #666;
}

.ai-modal-body {
  flex: 1;
  padding: 1.5rem;
  overflow-y: auto;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(-20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

@media (max-width: 768px) {
  .ai-explanation-modal-content {
    max-height: 90vh;
    margin: 0.5rem;
  }
  
  .ai-modal-header {
    padding: 1rem;
  }
  
  .ai-modal-body {
    padding: 1rem;
  }
}
</style>