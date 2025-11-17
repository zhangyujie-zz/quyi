<template>
  <div class="guestbook">
    <div class="container">
      <!-- 页面标题 -->
      <div class="guestbook-header">
        <h1 class="page-title">访客留言</h1>
        <p class="page-subtitle">欢迎留下您的宝贵意见和建议</p>
      </div>

      <!-- 留言表单 -->
      <div class="guestbook-form-section">
        <div class="form-card">
          <h3>发表留言</h3>
          <form @submit.prevent="submitGuestbook" class="guestbook-form">
            <div class="form-row">
              <div class="form-group">
                <label for="contactName">您的姓名</label>
                <input
                  type="text"
                  id="contactName"
                  v-model="formData.contactName"
                  placeholder="请输入您的姓名（选填）"
                  class="form-input"
                  maxlength="100"
                >
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="contactInfo">联系方式 *</label>
                <input
                  type="text"
                  id="contactInfo"
                  v-model="formData.contactInfo"
                  placeholder="请输入电话或邮箱"
                  class="form-input"
                  required
                  maxlength="255"
                >
                <small class="form-hint">请填写电话或邮箱，至少填写一个</small>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group full-width">
                <label for="content">留言内容 *</label>
                <textarea
                  id="content"
                  v-model="formData.content"
                  placeholder="请输入您的留言内容..."
                  class="form-textarea"
                  rows="5"
                  required
                  maxlength="1000"
                ></textarea>
                <div class="character-count">
                  {{ formData.content.length }}/1000
                </div>
              </div>
            </div>

            <div class="form-actions">
              <button
                type="submit"
                :disabled="isSubmitting"
                class="submit-btn"
              >
                <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
                <i v-else class="fas fa-paper-plane"></i>
                {{ isSubmitting ? '提交中...' : '提交留言' }}
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- 加载状态 -->
      <div v-if="isLoading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>正在加载留言...</p>
      </div>

      <!-- 错误提示 -->
      <div v-else-if="errorMessage" class="error-container">
        <i class="fas fa-exclamation-triangle"></i>
        <p>{{ errorMessage }}</p>
        <button @click="loadGuestbooks" class="btn btn-secondary">
          重新加载
        </button>
      </div>

      <!-- 留言列表 -->
      <div v-else-if="guestbooks.length > 0" class="guestbook-list">
        <h3 class="list-title">最新留言 ({{ totalCount }})</h3>
        
        <div 
          v-for="guestbook in guestbooks" 
          :key="guestbook.id"
          class="guestbook-item card"
        >
          <div class="guestbook-content">
            <div class="guestbook-header">
              <span class="guest-name">{{ guestbook.contact_name }}</span>
              <span class="guestbook-time">{{ formatTime(guestbook.created_at) }}</span>
            </div>
            <p class="guestbook-text">{{ guestbook.content }}</p>
            <div class="guestbook-footer">
              <button 
                class="like-btn"
                @click="likeGuestbook(guestbook)"
                :disabled="isLiking === guestbook.id"
              >
                <i class="fas fa-thumbs-up"></i>
                {{ guestbook.likes_count || 0 }}
              </button>
            </div>
          </div>
        </div>

        <!-- 加载更多 -->
        <div v-if="hasMore" class="load-more">
          <button 
            @click="loadMore" 
            :disabled="isLoadingMore"
            class="btn"
          >
            <i v-if="isLoadingMore" class="fas fa-spinner fa-spin"></i>
            <i v-else class="fas fa-arrow-down"></i>
            {{ isLoadingMore ? '加载中...' : '加载更多' }}
          </button>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-else class="empty-state">
        <i class="fas fa-comments"></i>
        <h3>暂无留言</h3>
        <p>成为第一个发表留言的人吧！</p>
      </div>
    </div>
  </div>
</template>

<script>
import { GuestbookService } from '../services/guestbookService.js'

export default {
  name: 'Guestbook',
  data() {
    return {
      guestbooks: [],
      isLoading: false,
      isLoadingMore: false,
      errorMessage: '',
      isSubmitting: false,
      isLiking: null,
      formData: {
        contactName: '',
        contactInfo: '',
        content: ''
      },
      page: 1,
      pageSize: 10,
      totalCount: 0,
      hasMore: true
    }
  },
  async mounted() {
    await this.loadGuestbooks()
  },
  methods: {
    async loadGuestbooks() {
      this.isLoading = true
      this.errorMessage = ''
      
      try {
        // 同时加载留言列表和总数
        const [guestbooksData, totalCount] = await Promise.all([
          GuestbookService.getGuestbooks(this.pageSize, 0),
          GuestbookService.getGuestbookCount()
        ])
        
        this.guestbooks = guestbooksData
        this.totalCount = totalCount
        this.hasMore = guestbooksData.length === this.pageSize
        this.page = 1
      } catch (error) {
        console.error('加载留言失败:', error)
        this.errorMessage = '获取留言失败，请检查网络连接'
      } finally {
        this.isLoading = false
      }
    },

    async loadMore() {
      if (this.isLoadingMore || !this.hasMore) return
      
      this.isLoadingMore = true
      
      try {
        const offset = (this.page - 1) * this.pageSize
        const newGuestbooks = await GuestbookService.getGuestbooks(this.pageSize, offset)
        
        this.guestbooks = [...this.guestbooks, ...newGuestbooks]
        this.page++
        this.hasMore = newGuestbooks.length === this.pageSize
      } catch (error) {
        console.error('加载更多留言失败:', error)
      } finally {
        this.isLoadingMore = false
      }
    },

    async submitGuestbook() {
      // 表单验证
      if (!this.formData.content.trim()) {
        alert('请输入留言内容')
        return
      }

      if (!this.formData.contactInfo.trim()) {
        alert('请输入联系方式（电话或邮箱）')
        return
      }

      this.isSubmitting = true
      
      try {
        // 提交留言
        const newGuestbook = await GuestbookService.submitGuestbook(
          this.formData.contactName,
          this.formData.contactInfo,
          this.formData.content
        )

        // 添加到留言列表开头
        this.guestbooks.unshift(newGuestbook)
        this.totalCount++

        // 重置表单
        this.formData = {
          contactName: '',
          contactInfo: '',
          content: ''
        }

        alert('留言提交成功！感谢您的反馈。')
      } catch (error) {
        console.error('提交留言失败:', error)
        alert(error.message || '留言提交失败，请稍后重试')
      } finally {
        this.isSubmitting = false
      }
    },

    async likeGuestbook(guestbook) {
      if (this.isLiking === guestbook.id) return
      
      this.isLiking = guestbook.id
      
      try {
        const newLikesCount = await GuestbookService.likeGuestbook(guestbook.id)
        
        // 更新留言的点赞数
        const index = this.guestbooks.findIndex(g => g.id === guestbook.id)
        if (index !== -1) {
          this.guestbooks[index].likes_count = newLikesCount
        }
      } catch (error) {
        console.error('点赞失败:', error)
      } finally {
        this.isLiking = null
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
    }
  }
}
</script>

<style scoped>
.guestbook {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 20px;
}

.guestbook-header {
  text-align: center;
  margin-bottom: 2rem;
}

.page-title {
  color: #8B4513;
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.page-subtitle {
  color: #666;
  font-size: 1.1rem;
  margin: 0;
}

/* 表单样式 */
.guestbook-form-section {
  margin-bottom: 3rem;
}

.form-card {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  max-width: 800px;
  margin: 0 auto;
}

.form-card h3 {
  color: #8B4513;
  font-size: 1.5rem;
  margin: 0 0 1.5rem 0;
  text-align: center;
}

.guestbook-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-row {
  display: flex;
  gap: 1rem;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.form-group.full-width {
  width: 100%;
}

.form-group label {
  font-weight: 600;
  color: #333;
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.form-input {
  padding: 0.75rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.form-input:focus {
  outline: none;
  border-color: #8B4513;
}

.form-textarea {
  padding: 0.75rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  resize: vertical;
  min-height: 120px;
  transition: border-color 0.3s ease;
}

.form-textarea:focus {
  outline: none;
  border-color: #8B4513;
}

.form-hint {
  color: #666;
  font-size: 0.85rem;
  margin-top: 0.25rem;
}

.character-count {
  text-align: right;
  color: #999;
  font-size: 0.85rem;
  margin-top: 0.25rem;
}

.form-actions {
  display: flex;
  justify-content: center;
}

.submit-btn {
  background: #8B4513;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 1rem 2rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.submit-btn:hover:not(:disabled) {
  background: #6F3713;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(139, 69, 19, 0.3);
}

.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

/* 加载状态 */
.loading-container {
  text-align: center;
  padding: 3rem;
  background: white;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #8B4513;
  border-radius: 50%;
  margin: 0 auto 1rem;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 错误状态 */
.error-container {
  text-align: center;
  padding: 3rem;
  background: white;
  border-radius: 8px;
  margin-bottom: 2rem;
  color: #d32f2f;
}

/* 留言列表 */
.guestbook-list {
  max-width: 800px;
  margin: 0 auto;
}

.list-title {
  color: #8B4513;
  font-size: 1.8rem;
  margin-bottom: 1.5rem;
  text-align: center;
}

.guestbook-item {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  transition: transform 0.3s ease;
}

.guestbook-item:hover {
  transform: translateY(-2px);
}

.guestbook-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.guest-name {
  font-weight: 600;
  color: #333;
  font-size: 1.1rem;
}

.guestbook-time {
  color: #999;
  font-size: 0.9rem;
}

.guestbook-text {
  color: #333;
  line-height: 1.6;
  margin-bottom: 1rem;
  font-size: 1rem;
  word-wrap: break-word;
}

.guestbook-footer {
  display: flex;
  justify-content: flex-end;
}

.like-btn {
  background: none;
  border: 1px solid #e0e0e0;
  color: #666;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.like-btn:hover:not(:disabled) {
  background: #8B4513;
  color: white;
  border-color: #8B4513;
}

.like-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 加载更多 */
.load-more {
  text-align: center;
  margin-top: 2rem;
}

.btn {
  background: #8B4513;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn:hover:not(:disabled) {
  background: #6F3713;
}

.btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.btn-secondary {
  background: #6c757d;
}

.btn-secondary:hover {
  background: #545b62;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 8px;
  color: #999;
}

.empty-state i {
  font-size: 4rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-state h3 {
  margin-bottom: 0.5rem;
  color: #666;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .guestbook {
    padding: 10px;
  }
  
  .form-card {
    padding: 1.5rem;
  }
  
  .form-row {
    flex-direction: column;
  }
  
  .submit-btn {
    width: 100%;
    justify-content: center;
  }
  
  .guestbook-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .guestbook-item {
    padding: 1rem;
  }
}
</style>