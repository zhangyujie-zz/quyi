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
              <!-- 表格视图 -->
              <div class="representatives-table-section">
                <div class="table-header">
                  <h3>代表人物一览表</h3>
                  <div class="view-toggle">
                    <button 
                      :class="{ active: viewMode === 'table' }"
                      @click="viewMode = 'table'"
                    >
                      <i class="fas fa-table"></i> 表格视图
                    </button>
                    <button 
                      :class="{ active: viewMode === 'grid' }"
                      @click="viewMode = 'grid'"
                    >
                      <i class="fas fa-th-large"></i> 网格视图
                    </button>
                  </div>
                </div>
                
                <!-- 表格模式 -->
                <div v-if="viewMode === 'table'" class="representatives-table">
                  <table class="table">
                    <thead>
                      <tr>
                        <th>姓名</th>
                        <th>出生年代</th>
                        <th>代表作品</th>
                        <th>艺术成就</th>
                        <th>地位</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr 
                        v-for="representative in detailedRepresentatives" 
                        :key="representative.id"
                        class="table-row"
                        @click="showRepresentativeDetail(representative)"
                      >
                        <td class="name-cell">
                          <i class="fas fa-user"></i>
                          <strong>{{ representative.name }}</strong>
                        </td>
                        <td>{{ representative.birthPeriod }}</td>
                        <td>{{ representative.masterpiece }}</td>
                        <td>{{ representative.achievement }}</td>
                        <td>
                          <span class="status-badge" :class="representative.status">
                            {{ representative.statusText }}
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                
                <!-- 网格模式 -->
                <div v-else class="representatives-grid">
                  <div 
                    v-for="representative in detailedRepresentatives" 
                    :key="representative.id"
                    class="representative-card"
                    @click="showRepresentativeDetail(representative)"
                  >
                    <div class="card-header">
                      <div class="avatar">
                        <i class="fas fa-user-tie"></i>
                      </div>
                      <div class="card-info">
                        <h4>{{ representative.name }}</h4>
                        <span class="period">{{ representative.birthPeriod }}</span>
                      </div>
                    </div>
                    <div class="card-content">
                      <p class="masterpiece">
                        <i class="fas fa-star"></i>
                        {{ representative.masterpiece }}
                      </p>
                      <p class="achievement">{{ representative.achievement }}</p>
                    </div>
                    <div class="card-footer">
                      <span class="status-badge" :class="representative.status">
                        {{ representative.statusText }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- 统计数据 -->
              <div class="representatives-stats">
                <div class="stat-item">
                  <i class="fas fa-users"></i>
                  <span class="stat-value">{{ detailedRepresentatives.length }}</span>
                  <span class="stat-label">代表人物</span>
                </div>
                <div class="stat-item">
                  <i class="fas fa-star"></i>
                  <span class="stat-value">{{ masterCount }}</span>
                  <span class="stat-label">大师级</span>
                </div>
                <div class="stat-item">
                  <i class="fas fa-award"></i>
                  <span class="stat-value">{{ livingCount }}</span>
                  <span class="stat-label">在世艺术家</span>
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
      relatedVideos: [],
      representativesData: [], // 从数据库获取的代表人物数据
      viewMode: 'table' // 视图模式: table/grid
    }
  },
  computed: {
    representativesList() {
      if (!this.category || !this.category.representatives) return []
      return this.category.representatives.split('、').map(item => item.trim())
    },
    
    detailedRepresentatives() {
      // 直接从数据库获取数据，如果数据不存在则返回静态数据
      if (this.representativesData && this.representativesData.length > 0) {
        return this.representativesData
      }
      
      // 备用数据，确保页面有内容显示
      const fallbackData = {
        1: [ // 相声
          { id: 1, name: '侯宝林', birthPeriod: '1917-1993', masterpiece: '《戏剧与方言》', achievement: '相声艺术大师，创立"侯派"风格', status: 'master', statusText: '大师' },
          { id: 2, name: '马三立', birthPeriod: '1914-2003', masterpiece: '《买猴》', achievement: '相声泰斗，马派相声创始人', status: 'master', statusText: '泰斗' },
          { id: 3, name: '郭德纲', birthPeriod: '1973-', masterpiece: '《我要幸福》', achievement: '德云社创始人，现代相声代表人物', status: 'living', statusText: '当代大师' },
          { id: 4, name: '姜昆', birthPeriod: '1950-', masterpiece: '《如此照相》', achievement: '相声表演艺术家，中国曲艺家协会主席', status: 'living', statusText: '艺术家' }
        ],
        2: [ // 评书
          { id: 1, name: '单田芳', birthPeriod: '1934-2018', masterpiece: '《隋唐演义》', achievement: '评书表演艺术家，"单氏评书"创始人', status: 'master', statusText: '艺术大师' },
          { id: 2, name: '刘兰芳', birthPeriod: '1944-', masterpiece: '《岳飞传》', achievement: '评书表演艺术家，中国曲艺家协会名誉主席', status: 'living', statusText: '艺术家' },
          { id: 3, name: '袁阔成', birthPeriod: '1929-2015', masterpiece: '《三国演义》', achievement: '评书表演艺术家，"袁派评书"创始人', status: 'master', statusText: '大师' },
          { id: 4, name: '田连元', birthPeriod: '1941-', masterpiece: '《杨家将》', achievement: '评书表演艺术家，现代评书改革者', status: 'living', statusText: '改革家' }
        ],
        3: [ // 京剧
          { id: 1, name: '梅兰芳', birthPeriod: '1894-1961', masterpiece: '《贵妃醉酒》', achievement: '京剧表演艺术家，"梅派"创始人', status: 'master', statusText: '艺术大师' },
          { id: 2, name: '程砚秋', birthPeriod: '1904-1958', masterpiece: '《锁麟囊》', achievement: '京剧表演艺术家，"程派"创始人', status: 'master', statusText: '大师' },
          { id: 3, name: '尚小云', birthPeriod: '1900-1976', masterpiece: '《昭君出塞》', achievement: '京剧表演艺术家，"尚派"创始人', status: 'master', statusText: '大师' },
          { id: 4, name: '荀慧生', birthPeriod: '1900-1968', masterpiece: '《红娘》', achievement: '京剧表演艺术家，"荀派"创始人', status: 'master', statusText: '大师' }
        ]
      }
      
      // 默认返回对应分类的数据，如果没有则返回空数组
      return fallbackData[this.id] || []
    },
    
    masterCount() {
      return this.detailedRepresentatives.filter(r => r.status === 'master').length
    },
    
    livingCount() {
      return this.detailedRepresentatives.filter(r => r.status === 'living').length
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
        // 从Supabase获取分类详情
        const { data: categoryData, error: categoryError } = await this.$supabase
          .from('categories')
          .select('*')
          .eq('id', parseInt(this.id))
          .single()
        
        if (categoryError) {
          console.error('获取分类详情失败:', categoryError)
          // 如果数据库连接失败，使用模拟数据
          this.useMockData()
          return
        }
        
        if (!categoryData) {
          this.errorMessage = '分类不存在'
          return
        }
        
        this.category = categoryData
        
        // 获取代表人物数据
        await this.fetchRepresentatives()
        
        // 获取相关视频
        await this.fetchRelatedVideos()
        
      } catch (error) {
        console.error('加载分类详情失败:', error)
        this.errorMessage = '加载分类详情失败，请检查网络连接'
        // 使用模拟数据作为备选方案
        this.useMockData()
      } finally {
        this.isLoading = false
      }
    },
    
    async fetchRepresentatives() {
      try {
        const { data, error } = await this.$supabase
          .from('representatives')
          .select('*')
          .eq('category_id', parseInt(this.id))
          .order('created_at', { ascending: true })
        
        if (error) throw error
        
        if (data && data.length > 0) {
          // 格式化数据库数据为前端需要的格式
          this.representativesData = data.map(rep => ({
            id: rep.id,
            name: rep.name,
            birthPeriod: rep.birth_period,
            masterpiece: rep.masterpiece,
            achievement: rep.artistic_achievement,
            status: rep.status,
            statusText: rep.status_text,
            avatarUrl: rep.avatar_url,
            biography: rep.biography
          }))
        } else {
          // 如果没有数据，使用模拟数据
          this.useMockRepresentatives()
        }
      } catch (error) {
        console.error('获取代表人物数据失败:', error)
        // 如果数据库获取失败，使用模拟数据
        this.useMockRepresentatives()
      }
    },
    
    async fetchRelatedVideos() {
      try {
        const { data, error } = await this.$supabase
          .from('videos')
          .select('*')
          .eq('category_id', parseInt(this.id))
          .limit(4)
          .order('views_count', { ascending: false })
        
        if (!error && data) {
          this.relatedVideos = data
        }
      } catch (error) {
        console.error('获取相关视频失败:', error)
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
          { id: 1, name: '郭德纲', birthPeriod: '1973-', masterpiece: '《我要幸福》', achievement: '德云社创始人，现代相声代表人物', status: 'living', statusText: '当代大师' },
          { id: 2, name: '于谦', birthPeriod: '1969-', masterpiece: '《我是黑社会》', achievement: '德云社搭档，相声表演艺术家', status: 'living', statusText: '艺术家' },
          { id: 3, name: '马三立', birthPeriod: '1914-2003', masterpiece: '《买猴》', achievement: '相声泰斗，马派相声创始人', status: 'master', statusText: '泰斗' },
          { id: 4, name: '侯宝林', birthPeriod: '1917-1993', masterpiece: '《戏剧与方言》', achievement: '相声艺术大师，创立"侯派"风格', status: 'master', statusText: '大师' }
        ],
        2: [
          { id: 1, name: '单田芳', birthPeriod: '1934-2018', masterpiece: '《隋唐演义》', achievement: '评书表演艺术家，"单氏评书"创始人', status: 'master', statusText: '艺术大师' },
          { id: 2, name: '刘兰芳', birthPeriod: '1944-', masterpiece: '《岳飞传》', achievement: '评书表演艺术家，中国曲艺家协会名誉主席', status: 'living', statusText: '艺术家' },
          { id: 3, name: '袁阔成', birthPeriod: '1929-2015', masterpiece: '《三国演义》', achievement: '评书表演艺术家，"袁派评书"创始人', status: 'master', statusText: '大师' },
          { id: 4, name: '田连元', birthPeriod: '1941-', masterpiece: '《杨家将》', achievement: '评书表演艺术家，现代评书改革者', status: 'living', statusText: '改革家' }
        ],
        3: [
          { id: 1, name: '梅兰芳', birthPeriod: '1894-1961', masterpiece: '《贵妃醉酒》', achievement: '京剧表演艺术家，"梅派"创始人', status: 'master', statusText: '艺术大师' },
          { id: 2, name: '程砚秋', birthPeriod: '1904-1958', masterpiece: '《锁麟囊》', achievement: '京剧表演艺术家，"程派"创始人', status: 'master', statusText: '大师' },
          { id: 3, name: '尚小云', birthPeriod: '1900-1976', masterpiece: '《昭君出塞》', achievement: '京剧表演艺术家，"尚派"创始人', status: 'master', statusText: '大师' },
          { id: 4, name: '荀慧生', birthPeriod: '1900-1968', masterpiece: '《红娘》', achievement: '京剧表演艺术家，"荀派"创始人', status: 'master', statusText: '大师' }
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

/* 表格视图样式 */
.representatives-table-section {
  margin-bottom: 2rem;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.table-header h3 {
  font-size: 1.3rem;
  color: #2c3e50;
  margin: 0;
}

.view-toggle {
  display: flex;
  gap: 0.5rem;
}

.view-toggle button {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  background: white;
  color: #666;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.view-toggle button.active {
  background: #8B4513;
  color: white;
  border-color: #8B4513;
}

.view-toggle button:hover:not(.active) {
  background: #f8f9fa;
}

.representatives-table {
  overflow-x: auto;
}

.table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.table th {
  background: #f8f9fa;
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  color: #2c3e50;
  border-bottom: 2px solid #e0e0e0;
}

.table td {
  padding: 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.table-row {
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.table-row:hover {
  background: #f8f9fa;
}

.name-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.name-cell i {
  color: #8B4513;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.status-badge.master {
  background: #ffe6e6;
  color: #d9534f;
}

.status-badge.living {
  background: #e6f3ff;
  color: #0275d8;
}

/* 网格视图样式 */
.representatives-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.representative-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #e0e0e0;
}

.representative-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border-color: #8B4513;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.avatar {
  width: 50px;
  height: 50px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
}

.card-info h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1.2rem;
  color: #2c3e50;
}

.period {
  color: #666;
  font-size: 0.9rem;
}

.card-content {
  margin-bottom: 1rem;
}

.masterpiece {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #8B4513;
}

.masterpiece i {
  color: #ffd700;
}

.achievement {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-footer {
  text-align: center;
}

/* 统计数据样式 */
.representatives-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-top: 2rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-item {
  text-align: center;
  padding: 1rem;
}

.stat-item i {
  font-size: 2rem;
  color: #8B4513;
  margin-bottom: 0.5rem;
}

.stat-value {
  display: block;
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
}

.stat-label {
  color: #666;
  font-size: 0.9rem;
}

/* 表格视图样式 */
.representatives-table-section {
  margin-bottom: 2rem;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.table-header h3 {
  font-size: 1.3rem;
  color: #2c3e50;
  margin: 0;
}

.view-toggle {
  display: flex;
  gap: 0.5rem;
}

.view-toggle button {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  background: white;
  color: #666;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.view-toggle button.active {
  background: #8B4513;
  color: white;
  border-color: #8B4513;
}

.view-toggle button:hover:not(.active) {
  background: #f8f9fa;
}

.representatives-table {
  overflow-x: auto;
}

.table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.table th {
  background: #f8f9fa;
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  color: #2c3e50;
  border-bottom: 2px solid #e0e0e0;
}

.table td {
  padding: 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.table-row {
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.table-row:hover {
  background: #f8f9fa;
}

.name-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.name-cell i {
  color: #8B4513;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.status-badge.master {
  background: #ffe6e6;
  color: #d9534f;
}

.status-badge.living {
  background: #e6f3ff;
  color: #0275d8;
}

/* 网格视图样式 */
.representatives-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.representative-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #e0e0e0;
}

.representative-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border-color: #8B4513;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.avatar {
  width: 50px;
  height: 50px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
}

.card-info h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1.2rem;
  color: #2c3e50;
}

.period {
  color: #666;
  font-size: 0.9rem;
}

.card-content {
  margin-bottom: 1rem;
}

.masterpiece {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #8B4513;
}

.masterpiece i {
  color: #ffd700;
}

.achievement {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-footer {
  text-align: center;
}

/* 统计数据样式 */
.representatives-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-top: 2rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-item {
  text-align: center;
  padding: 1rem;
}

.stat-item i {
  font-size: 2rem;
  color: #8B4513;
  margin-bottom: 0.5rem;
}

.stat-value {
  display: block;
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
}

.stat-label {
  color: #666;
  font-size: 0.9rem;
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