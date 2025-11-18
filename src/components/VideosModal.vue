<template>
  <div class="video-modal" @click="$emit('close')">
    <div class="modal-content-split" @click.stop>
      <button class="close-btn" @click="$emit('close')">
        <i class="fas fa-times"></i>
      </button>
      
      <!-- 左侧：视频播放器 -->
      <div class="video-section">
        <div class="video-player">
          <div class="player-placeholder">
            <img 
              v-if="video.thumbnail_url" 
              :src="video.thumbnail_url" 
              :alt="video.title"
              class="video-cover"
              @error="handleImageError"
            >
            <div class="play-overlay">
              <i class="fas fa-play-circle"></i>
            </div>
          </div>
        </div>
        <div class="video-details">
          <h2>{{ video.title }}</h2>
          <p class="video-description">{{ video.description }}</p>
          <div class="video-meta-info">
            <span><i class="fas fa-user"></i> {{ video.performer || '未知表演者' }}</span>
            <span><i class="fas fa-clock"></i> {{ formatDuration(video.duration) }}</span>
            <span><i class="fas fa-eye"></i> {{ video.views_count || 0 }} 次观看</span>
          </div>
          
          <!-- AI讲解员按钮 -->
          <div class="ai-explanation-section">
            <button 
              @click="$emit('generate-explanation')"
              :disabled="isGeneratingExplanation"
              class="ai-explanation-btn"
            >
              <i class="fas fa-graduation-cap"></i>
              {{ isGeneratingExplanation ? '正在生成讲解...' : 'AI讲解员' }}
            </button>
            <div v-if="isGeneratingExplanation" class="loading-status compact">
              <div class="loading-spinner small"></div>
              <p>正在为您生成专业讲解...</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 右侧：评论区域 -->
      <div class="comments-section">
        <div class="comments-header">
          <h3>评论 ({{ comments.length }})</h3>
        </div>
        
        <!-- 评论输入框 -->
        <div class="comment-input-area">
          <div class="comment-input-wrapper">
            <textarea 
              v-model="newComment"
              placeholder="发表你的看法..."
              class="comment-input"
              rows="3"
              @keydown.enter.prevent="submitNewComment"
            ></textarea>
            <button 
              @click="submitNewComment"
              :disabled="!newComment.trim() || isSubmittingComment"
              class="submit-btn"
            >
              {{ isSubmittingComment ? '发送中...' : '发送' }}
            </button>
          </div>
        </div>
        
        <!-- 评论列表 -->
        <div class="comments-list">
          <!-- 评论加载状态 -->
          <div v-if="isLoadingComments" class="comments-loading">
            <div class="loading-spinner small"></div>
            <p>正在加载评论...</p>
          </div>
          
          <!-- 评论内容 -->
          <template v-else>
            <div v-if="comments.length === 0" class="no-comments">
              <i class="fas fa-comments"></i>
              <p>暂无评论，快来抢沙发吧！</p>
            </div>
            
            <div 
              v-for="comment in comments" 
              :key="comment.id"
              class="comment-item"
            >
              <div class="comment-avatar">
                <img 
                  v-if="comment.avatar_url" 
                  :src="comment.avatar_url" 
                  :alt="comment.user_name"
                  @error="handleImageError"
                >
                <i v-else class="fas fa-user"></i>
              </div>
              <div class="comment-content">
                <div class="comment-header">
                  <span class="username">{{ comment.user_name }}</span>
                  <span class="comment-time">{{ formatTime(comment.created_at) }}</span>
                </div>
              <p class="comment-text">{{ comment.content }}</p>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>
    
    <!-- AI讲解弹窗 -->
    <div v-if="showExplanation" class="ai-explanation-modal" @click="$emit('close-explanation')">
      <div class="ai-explanation-modal-content" @click.stop>
        <div class="ai-modal-header">
          <div class="ai-modal-title">
            <i class="fas fa-robot"></i>
            <h3>AI专业讲解</h3>
          </div>
          <button @click="$emit('close-explanation')" class="ai-modal-close-btn">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="ai-modal-body">
          <div class="explanation-text" v-html="currentExplanation"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { CommentService } from '../services/commentService.js'

export default {
  name: 'VideosModal',
  props: {
    video: {
      type: Object,
      required: true
    },
    comments: {
      type: Array,
      default: () => []
    },
    isGeneratingExplanation: {
      type: Boolean,
      default: false
    },
    currentExplanation: {
      type: String,
      default: ''
    },
    showExplanation: {
      type: Boolean,
      default: false
    },
    isLoadingComments: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      newComment: '',
      isSubmittingComment: false,
      isLoadingComments: false
    }
  },
  methods: {
    formatDuration(seconds) {
      if (!seconds) return '00:00'
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
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
    
    handleImageError(event) {
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
    
    async submitNewComment() {
      if (!this.newComment.trim() || this.isSubmittingComment) return
      
      this.isSubmittingComment = true
      
      try {
        // 调用评论服务API
        const newComment = await CommentService.submitComment(
          this.video.id, 
          this.newComment.trim(),
          null // 用户ID为null，表示匿名评论
        )
        
        // 通知父组件有新评论
        this.$emit('new-comment', newComment)
        
        // 只有成功时才清空输入框
        this.newComment = ''
      } catch (error) {
        console.error('提交评论失败:', error)
        
        // 显示具体的错误信息
        if (error.message.includes('暂时不可用')) {
          alert('评论功能暂时不可用，请稍后重试')
        } else if (error.message.includes('不能为空')) {
          alert('评论内容不能为空')
        } else if (error.message.includes('无效的视频ID')) {
          alert('无效的视频ID')
        } else {
          alert('评论提交失败，请稍后重试')
        }
      } finally {
        this.isSubmittingComment = false
      }
    },


  }
}
</script>

<style scoped>
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

/* 评论加载状态 */
.comments-loading {
  text-align: center;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  color: #666;
}

.comments-loading .loading-spinner.small {
  margin: 0;
}

.comments-loading p {
  margin: 0;
  font-size: 0.9rem;
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

/* 弹窗响应式设计 */
@media (max-width: 768px) {
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
  
  .comments-section {
    max-height: 50vh;
  }
  
  .comment-input-wrapper {
    flex-direction: column;
  }
  
  .submit-btn {
    width: 100%;
  }
  
  .ai-explanation-modal-content {
    max-height: 90vh;
    margin: 0.5rem;
  }
}
</style>