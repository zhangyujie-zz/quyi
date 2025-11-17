<template>
  <div class="category-container">
    <!-- 加载状态 -->
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>正在加载分类详情...</p>
    </div>
    
    <!-- 错误提示 -->
    <div v-else-if="errorMessage" class="error-state">
      <i class="fas fa-exclamation-triangle"></i>
      <p>{{ errorMessage }}</p>
      <button @click="loadCategoryDetail" class="retry-btn">
        重新加载
      </button>
    </div>
    
    <!-- 分类详情内容 -->
    <div v-else-if="category" class="category-main">
      <!-- 返回按钮 -->
      <div class="back-section">
        <button @click="goBack" class="back-btn">
          <i class="fas fa-arrow-left"></i>
          返回分类
        </button>
      </div>

      <!-- 单一内容卡片 -->
      <div class="content-card">
        <!-- 分类头部信息 -->
        <div class="category-header">
          <div class="category-icon">
            <i :class="getCategoryIcon(category.name)"></i>
          </div>
          <div class="category-info">
            <h1>{{ category.name }}</h1>
            <p class="category-desc">{{ category.description }}</p>
            <div class="category-meta">
              <span><i class="fas fa-map-marker-alt"></i> {{ category.origin }}</span>
              <span><i class="fas fa-star"></i> {{ category.popularity }}</span>
            </div>
          </div>
        </div>

        <!-- 详细内容 -->
        <div class="detail-content">
          <div class="content-section">
            <h3>详细描述</h3>
            <p>{{ category.detailed_description }}</p>
          </div>

          <div class="content-section">
            <h3>艺术特点</h3>
            <p>{{ category.characteristics }}</p>
          </div>

          <div class="content-section">
            <h3>表演形式</h3>
            <p>{{ category.performance_form }}</p>
          </div>

          <!-- 代表人物 -->
          <div class="content-section">
            <h3>代表人物</h3>
            <div class="people-grid">
              <div 
                v-for="person in detailedRepresentatives" 
                :key="person.id"
                class="person-card"
              >
                <div class="person-avatar">
                  <img 
                    v-if="person.avatarUrl" 
                    :src="person.avatarUrl" 
                    :alt="person.name"
                    @error="handleImageError"
                  >
                  <i v-else class="fas fa-user"></i>
                </div>
                <div class="person-info">
                  <h4>{{ person.name }}</h4>
                  <p class="person-bio">{{ person.achievement }}</p>
                  <p class="person-details">
                    <span><i class="fas fa-clock"></i> {{ person.birthPeriod }}</span>
                    <span><i class="fas fa-star"></i> {{ person.masterpiece }}</span>
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 显示一个相关视频 -->
        <div class="video-section">
          <h3>推荐视频</h3>
          <div v-if="displayVideo" class="video-card">
            <div class="video-thumbnail">
              <img 
                v-if="displayVideo.thumbnail_url" 
                :src="displayVideo.thumbnail_url" 
                :alt="displayVideo.title"
                @error="handleImageError"
              >
              <div v-else class="thumbnail-placeholder"></div>
              <i class="fas fa-play-circle"></i>
            </div>
            <div class="video-info">
              <h4>{{ displayVideo.title }}</h4>
              <p class="video-desc">{{ displayVideo.description }}</p>
              <div class="video-meta">
                <span><i class="fas fa-clock"></i> {{ formatDuration(displayVideo.duration) }}</span>
                <span><i class="fas fa-eye"></i> {{ displayVideo.views_count }} 次观看</span>
              </div>
              <button @click="playVideo(displayVideo.id)" class="play-btn">
                <i class="fas fa-play"></i>
                立即观看
              </button>
            </div>
          </div>
          <div v-else class="video-placeholder">
            <div class="placeholder-content">
              <i class="fas fa-video"></i>
              <p>正在加载视频信息...</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 无数据状态 -->
    <div v-else class="no-data">
      <i class="fas fa-masks-theater"></i>
      <p>分类数据不存在</p>
      <button @click="goToCategories" class="btn">
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
      representativesData: [], // 从数据库获取的代表人物数据
      displayVideo: null // 显示的单个视频
    }
  },
  computed: {
    detailedRepresentatives() {
      // 直接从数据库获取数据，如果数据不存在则返回静态数据
      if (this.representativesData && this.representativesData.length > 0) {
        return this.representativesData
      }
      
      // 简化的人物数据，移除status和statusText字段
      const fallbackData = {
        1: [ // 相声
          { id: 1, name: '侯宝林', birthPeriod: '1917-1993', masterpiece: '《戏剧与方言》', achievement: '相声艺术大师，创立"侯派"风格' },
          { id: 2, name: '马三立', birthPeriod: '1914-2003', masterpiece: '《买猴》', achievement: '相声泰斗，马派相声创始人' },
          { id: 3, name: '郭德纲', birthPeriod: '1973-', masterpiece: '《我要幸福》', achievement: '德云社创始人，现代相声代表人物' }
        ],
        2: [ // 评书
          { id: 1, name: '单田芳', birthPeriod: '1934-2018', masterpiece: '《隋唐演义》', achievement: '评书表演艺术家，"单氏评书"创始人' },
          { id: 2, name: '刘兰芳', birthPeriod: '1944-', masterpiece: '《岳飞传》', achievement: '评书表演艺术家，中国曲艺家协会名誉主席' }
        ],
        3: [ // 京剧
          { id: 1, name: '梅兰芳', birthPeriod: '1894-1961', masterpiece: '《贵妃醉酒》', achievement: '京剧表演艺术家，"梅派"创始人' },
          { id: 2, name: '程砚秋', birthPeriod: '1904-1958', masterpiece: '《锁麟囊》', achievement: '京剧表演艺术家，"程派"创始人' }
        ]
      }
      
      // 默认返回对应分类的数据，如果没有则返回空数组
      return fallbackData[this.id] || []
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
        // 使用VideoService获取完整分类详情数据
        const categoryData = await VideoService.getCategoryDetailWithRepresentatives(parseInt(this.id))
        
        if (!categoryData) {
          this.errorMessage = '分类不存在'
          return
        }
        
        this.category = categoryData.category
        
        // 设置代表人物数据
        if (categoryData.representatives && categoryData.representatives.length > 0) {
          this.representativesData = categoryData.representatives.map(rep => ({
            id: rep.id,
            name: rep.name,
            birthPeriod: rep.birth_period,
            masterpiece: rep.masterpiece,
            achievement: rep.artistic_achievement,
            status: rep.status,
            statusText: rep.status_text,
            avatarUrl: this.getAvatarUrl(rep.name, rep.avatar_url),
            biography: rep.biography
          }))
        } else {
          // 如果没有数据，使用模拟数据
          this.useMockRepresentatives()
        }
        
        // 设置相关视频
        this.relatedVideos = categoryData.videos || []
        
        // 设置显示的视频（如果存在视频，则取第一个）
        if (this.relatedVideos.length > 0) {
          this.displayVideo = this.relatedVideos[0]
        } else {
          // 如果没有视频数据，使用模拟视频
          this.useMockVideo()
        }
        
      } catch (error) {
        console.error('加载分类详情失败:', error)
        this.errorMessage = '加载分类详情失败，请检查网络连接'
        // 使用模拟数据作为备选方案
        this.useMockData()
        // 使用模拟视频
        this.useMockVideo()
      } finally {
        this.isLoading = false
      }
    },
    

    
    useMockData() {
      // 模拟数据用于数据库不可用时
      const categories = {
        1: { 
          id: 1, 
          name: '相声', 
          description: '相声是中国传统喜剧表演艺术，以对话为主要形式。', 
          representatives: '郭德纲、于谦、马三立、侯宝林',
          origin: '北京、天津',
          characteristics: '语言幽默、包袱迭出、互动性强',
          performance_form: '对口相声、单口相声、群口相声',
          popularity: '国家级'
        },
        2: { 
          id: 2, 
          name: '评书', 
          description: '评书是口头讲述故事的表演艺术形式。', 
          representatives: '单田芳、刘兰芳、袁阔成、田连元',
          origin: '北京、河北',
          characteristics: '故事性强、语言生动、节奏鲜明',
          performance_form: '单人口述、坐姿表演',
          popularity: '国家级'
        },
        3: { 
          id: 3, 
          name: '京剧', 
          description: '京剧是中国最具代表性的戏曲艺术形式。', 
          representatives: '梅兰芳、程砚秋、尚小云、荀慧生',
          origin: '北京',
          characteristics: '唱念做打、程式化表演、华丽服饰',
          performance_form: '舞台表演、戏曲演唱',
          popularity: '国家级'
        }
      }
      
      this.category = categories[this.id] || categories[1]
      this.useMockRepresentatives()
    },
    
    useMockRepresentatives() {
      // 静态代表人物数据
      const mockRepresentatives = {
        1: [
          { id: 1, name: '郭德纲', birthPeriod: '1973-', masterpiece: '《我要幸福》', achievement: '德云社创始人，现代相声代表人物', status: 'living', statusText: '当代大师', avatarUrl: this.getAvatarUrl('郭德纲') },
          { id: 2, name: '于谦', birthPeriod: '1969-', masterpiece: '《我是黑社会》', achievement: '德云社搭档，相声表演艺术家', status: 'living', statusText: '艺术家', avatarUrl: this.getAvatarUrl('于谦') },
          { id: 3, name: '马三立', birthPeriod: '1914-2003', masterpiece: '《买猴》', achievement: '相声泰斗，马派相声创始人', status: 'master', statusText: '泰斗', avatarUrl: this.getAvatarUrl('马三立') },
          { id: 4, name: '侯宝林', birthPeriod: '1917-1993', masterpiece: '《戏剧与方言》', achievement: '相声艺术大师，创立"侯派"风格', status: 'master', statusText: '大师', avatarUrl: this.getAvatarUrl('侯宝林') }
        ],
        2: [
          { id: 1, name: '单田芳', birthPeriod: '1934-2018', masterpiece: '《隋唐演义》', achievement: '评书表演艺术家，"单氏评书"创始人', status: 'master', statusText: '艺术大师', avatarUrl: this.getAvatarUrl('单田芳') },
          { id: 2, name: '刘兰芳', birthPeriod: '1944-', masterpiece: '《岳飞传》', achievement: '评书表演艺术家，中国曲艺家协会名誉主席', status: 'living', statusText: '艺术家', avatarUrl: this.getAvatarUrl('刘兰芳') },
          { id: 3, name: '袁阔成', birthPeriod: '1929-2015', masterpiece: '《三国演义》', achievement: '评书表演艺术家，"袁派评书"创始人', status: 'master', statusText: '大师', avatarUrl: null },
          { id: 4, name: '田连元', birthPeriod: '1941-', masterpiece: '《杨家将》', achievement: '评书表演艺术家，现代评书改革者', status: 'living', statusText: '改革家', avatarUrl: null }
        ],
        3: [
          { id: 1, name: '梅兰芳', birthPeriod: '1894-1961', masterpiece: '《贵妃醉酒》', achievement: '京剧表演艺术家，"梅派"创始人', status: 'master', statusText: '艺术大师', avatarUrl: this.getAvatarUrl('梅兰芳') },
          { id: 2, name: '程砚秋', birthPeriod: '1904-1958', masterpiece: '《锁麟囊》', achievement: '京剧表演艺术家，"程派"创始人', status: 'master', statusText: '大师', avatarUrl: this.getAvatarUrl('程砚秋') },
          { id: 3, name: '尚小云', birthPeriod: '1900-1976', masterpiece: '《昭君出塞》', achievement: '京剧表演艺术家，"尚派"创始人', status: 'master', statusText: '大师', avatarUrl: null },
          { id: 4, name: '荀慧生', birthPeriod: '1900-1968', masterpiece: '《红娘》', achievement: '京剧表演艺术家，"荀派"创始人', status: 'master', statusText: '大师', avatarUrl: null }
        ]
      }
      
      this.representativesData = mockRepresentatives[this.id] || []
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
    },
    
    showRepresentativeDetail(representative) {
      // 这里可以弹出一个模态框显示详细资料
      alert(`查看 ${representative.name} 的详细资料

` +
            `出生年代：${representative.birthPeriod}
` +
            `代表作品：${representative.masterpiece}
` +
            `艺术成就：${representative.achievement}`)
    },
    
    showRepresentativeDetail(representative) {
      // 这里可以弹出一个模态框显示详细资料
      alert(`查看 ${representative.name} 的详细资料

` +
            `出生年代：${representative.birthPeriod}
` +
            `代表作品：${representative.masterpiece}
` +
            `艺术成就：${representative.achievement}`)
    },
    
    useMockVideo() {
      // 模拟视频数据用于数据库不可用时
      const mockVideos = {
        1: {
          id: 1,
          title: '相声名段欣赏 - 郭德纲经典相声',
          description: '郭德纲经典相声表演，包含多个经典段子，展现相声艺术的魅力。',
          duration: 1800, // 30分钟
          views_count: 25000,
          thumbnail_url: '/resource/image/首页相声.png'
        },
        2: {
          id: 2,
          title: '评书精选 - 单田芳《隋唐演义》',
          description: '单田芳大师经典评书《隋唐演义》，讲述隋唐历史英雄故事。',
          duration: 2400, // 40分钟
          views_count: 18000,
          thumbnail_url: '/resource/image/首页评书.jpg'
        },
        3: {
          id: 3,
          title: '京剧经典 - 梅兰芳《贵妃醉酒》',
          description: '梅兰芳大师经典京剧表演《贵妃醉酒》，展现京剧艺术的精髓。',
          duration: 1500, // 25分钟
          views_count: 12000,
          thumbnail_url: '/resource/image/首页京剧.jpg'
        }
      }
      
      this.displayVideo = mockVideos[this.id] || mockVideos[1]
    },
    
    getAvatarUrl(name, avatarUrl) {
      // 如果有数据库中的头像URL，直接使用
      if (avatarUrl) {
        return avatarUrl
      }
      
      // 否则使用本地图片
      const nameMap = {
        '侯宝林': '/resource/image/representative%20figure/侯宝林.jpg',
        '马三立': '/resource/image/representative%20figure/马三立.jpg', 
        '郭德纲': '/resource/image/representative%20figure/郭德纲.jpg',
        '于谦': '/resource/image/representative%20figure/于谦.jpg',
        '单田芳': '/resource/image/representative%20figure/单田芳.jpg',
        '刘兰芳': '/resource/image/representative%20figure/刘兰芳.jpg',
        '梅兰芳': '/resource/image/representative%20figure/梅兰芳.jpg',
        '程砚秋': '/resource/image/representative%20figure/程砚秋.jpg'
      }
      
      return nameMap[name] || null
    },
    
    handleImageError(event) {
      // 图片加载失败时显示默认图标
      event.target.style.display = 'none'
      const parent = event.target.parentElement
      if (parent) {
        const icon = parent.querySelector('.fa-user')
        if (icon) {
          icon.style.display = 'block'
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
    
    playVideo(videoId) {
      // 跳转到视频播放页面
      this.$router.push(`/video/${videoId}`)
    }
  }
}
</script>

<style scoped>
/* 容器样式 */
.category-container {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 20px;
}

/* 加载和错误状态 */
.loading-state, .error-state, .no-data {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.loading-state {
  color: #666;
}

.error-state {
  color: #d32f2f;
}

.no-data {
  color: #666;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #8B4513;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

.retry-btn, .btn {
  padding: 10px 20px;
  background: #8B4513;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 15px;
}

/* 主要内容区域 */
.category-main {
  max-width: 1000px;
  margin: 0 auto;
}

.back-section {
  margin-bottom: 20px;
}

.back-btn {
  background: #8B4513;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

/* 内容卡片 */
.content-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
  overflow: hidden;
}

/* 分类头部 */
.category-header {
  background: linear-gradient(135deg, #8B4513, #A0522D);
  color: white;
  padding: 30px;
  display: flex;
  align-items: center;
  gap: 20px;
}

.category-icon {
  font-size: 48px;
  opacity: 0.9;
}

.category-info h1 {
  font-size: 32px;
  margin: 0 0 10px 0;
}

.category-desc {
  font-size: 16px;
  opacity: 0.9;
  margin: 0 0 15px 0;
}

.category-meta {
  display: flex;
  gap: 20px;
  font-size: 14px;
}

.category-meta span {
  display: flex;
  align-items: center;
  gap: 5px;
}

/* 详情内容 */
.detail-content {
  padding: 30px;
}

.content-section {
  margin-bottom: 30px;
}

.content-section h3 {
  color: #8B4513;
  font-size: 20px;
  margin: 0 0 15px 0;
  border-left: 4px solid #8B4513;
  padding-left: 12px;
}

.content-section p {
  line-height: 1.6;
  color: #333;
  margin: 0;
}

/* 人物网格 */
.people-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.person-card {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  transition: transform 0.2s;
}

.person-card:hover {
  transform: translateY(-2px);
}

.person-avatar {
  width: 60px;
  height: 60px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
  margin: 0 auto 15px;
  overflow: hidden;
  position: relative;
}

.person-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.person-avatar .fa-user {
  display: none;
}

.person-info {
  text-align: center;
}

.person-info h4 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 18px;
}

.person-bio {
  color: #666;
  font-size: 14px;
  line-height: 1.4;
  margin: 0 0 10px 0;
}

.person-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
  font-size: 12px;
  color: #888;
}

.person-details span {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
}

/* 操作按钮 */
.action-section {
  padding: 20px 30px;
  background: #f8f9fa;
  border-top: 1px solid #e0e0e0;
  display: flex;
  gap: 15px;
  justify-content: center;
}

.action-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.action-btn.primary {
  background: #8B4513;
  color: white;
}

.action-btn.secondary {
  background: white;
  color: #8B4513;
  border: 1px solid #8B4513;
}

.action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

/* 视频区域样式 */
.video-section {
  padding: 30px;
  border-top: 1px solid #e0e0e0;
}

.video-section h3 {
  color: #8B4513;
  font-size: 20px;
  margin: 0 0 20px 0;
  border-left: 4px solid #8B4513;
  padding-left: 12px;
}

.video-card {
  display: flex;
  background: #f8f9fa;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.3s;
}

.video-card:hover {
  transform: translateY(-2px);
}

.video-thumbnail {
  width: 180px;
  min-width: 180px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 48px;
  position: relative;
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

.video-info {
  flex: 1;
  padding: 20px;
}

.video-info h4 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 18px;
  line-height: 1.4;
}

.video-desc {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
  margin: 0 0 15px 0;
}

.video-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.video-meta span {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #888;
  font-size: 14px;
}

.play-btn {
  background: #8B4513;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.play-btn:hover {
  background: #A0522D;
  transform: translateY(-1px);
}

/* 视频占位符样式 */
.video-placeholder {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 40px 20px;
  text-align: center;
  border: 2px dashed #ddd;
}

.placeholder-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.placeholder-content i {
  font-size: 48px;
  color: #8B4513;
  opacity: 0.6;
}

.placeholder-content p {
  color: #666;
  font-size: 16px;
  margin: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .category-container {
    padding: 10px;
  }
  
  .category-header {
    flex-direction: column;
    text-align: center;
    padding: 20px;
  }
  
  .category-info h1 {
    font-size: 24px;
  }
  
  .category-meta {
    flex-direction: column;
    gap: 10px;
  }
  
  .detail-content {
    padding: 20px;
  }
  
  .people-grid {
    grid-template-columns: 1fr;
  }
  
  .action-section {
    flex-direction: column;
    padding: 15px;
  }
  
  .action-btn {
    justify-content: center;
  }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>