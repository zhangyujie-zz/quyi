<template>
  <div class="home">
    <!-- 轮播图区域 -->
    <section class="carousel-section">
      <div class="carousel-container">
        <!-- 轮播图主体 -->
        <div class="carousel">
          <div 
            v-for="(slide, index) in carouselSlides" 
            :key="slide.id"
            class="slide"
            :class="{ active: currentSlide === index }"
            :style="{ backgroundImage: `url(${slide.image})` }"
          >
            <div class="slide-overlay"></div>
            <div class="slide-content">
              <div class="slide-info">
                <span class="slide-title">{{ slide.title }}</span>
                <span class="slide-description">{{ slide.description }}</span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 轮播图指示器 -->
        <div class="carousel-indicators">
          <button 
            v-for="(slide, index) in carouselSlides" 
            :key="slide.id"
            class="indicator"
            :class="{ active: currentSlide === index }"
            @click="goToSlide(index)"
          ></button>
        </div>
        
        <!-- 轮播图导航按钮 -->
        <button class="carousel-nav prev" @click="prevSlide">
          <i class="fas fa-chevron-left"></i>
        </button>
        <button class="carousel-nav next" @click="nextSlide">
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>
    </section>

    <!-- 近期曲艺动态 -->
    <section class="events">
      <div class="container">
        <h2 class="section-title">近期曲艺动态</h2>
        <div class="event-list">
          <div 
            v-for="event in recentEvents" 
            :key="event.id"
            class="event-item"
            @click="showEventModal(event)"
          >
            <div class="event-item-content">
              <div class="event-info">
                <div class="event-type">
                  <span :class="event.typeClass">{{ event.type }}</span>
                </div>
                <h4 class="event-title">{{ event.title }}</h4>
                <p class="event-description">{{ event.description }}</p>
              </div>
              <div class="event-meta">
                <p class="event-date">{{ event.date }}</p>
                <p class="event-location">{{ event.location }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 动态详情弹窗 -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">{{ selectedEvent.title }}</h3>
          <button class="modal-close" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <div class="event-details">
            <div class="detail-item">
              <span class="detail-label">事件类型：</span>
              <span class="detail-value event-type-badge" :class="selectedEvent.typeClass">{{ selectedEvent.type }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">活动时间：</span>
              <span class="detail-value">{{ selectedEvent.date }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">活动地点：</span>
              <span class="detail-value">{{ selectedEvent.location }}</span>
            </div>
            <div class="detail-item full-width">
              <span class="detail-label">活动描述：</span>
              <p class="detail-description">{{ selectedEvent.description }}</p>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="closeModal">关闭</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { VideoService } from '../services/videoService.js'

export default {
  name: 'Home',
  data() {
    return {
      recentEvents: [],
      featuredVideos: [],
      loading: true,
      currentSlide: 0,
      carouselInterval: null,
      carouselSlides: [],
      showModal: false,
      selectedEvent: null
    }
  },
  async mounted() {
    await this.loadData()
    this.startCarousel()
  },
  
  beforeUnmount() {
    this.stopCarousel()
  },
  
  methods: {
    async loadData() {
      try {
        // 加载轮播图数据
        const carouselData = await VideoService.getCarouselSlides()
        console.log('从数据库获取的轮播图数据:', carouselData)
        
        if (carouselData && carouselData.length > 0) {
          this.carouselSlides = carouselData.map(slide => ({
            id: slide.id,
            title: slide.title,
            description: slide.description,
            image: slide.image_url
          }))
          console.log('成功加载数据库轮播图数据:', this.carouselSlides)
        } else {
          console.log('数据库中没有轮播图数据，使用默认数据')
          this.setDefaultData()
        }
        
        // 加载近期动态
        const eventsData = await VideoService.getRecentEvents()
        console.log('从数据库获取的近期动态数据:', eventsData)
        
        if (eventsData && eventsData.length > 0) {
          this.recentEvents = eventsData.map(event => ({
            id: event.id,
            title: event.title,
            description: event.description,
            type: event.event_type,
            typeClass: this.getEventTypeClass(event.event_type),
            date: this.formatDate(event.event_date),
            location: event.location
          }))
          console.log('成功加载数据库近期动态数据:', this.recentEvents)
        } else {
          console.log('数据库中没有近期动态数据，使用默认数据')
          this.recentEvents = this.getDefaultEvents()
        }
        
        // 加载推荐视频
        this.featuredVideos = await VideoService.getRecommendedVideos(3)
      } catch (error) {
        console.error('加载首页数据失败:', error)
        console.log('使用默认数据')
        // 设置默认数据以防连接失败
        this.setDefaultData()
      } finally {
        this.loading = false
      }
    },
    
    setDefaultData() {
      this.carouselSlides = [
        {
          id: 1,
          title: '传统相声艺术',
          description: '品味经典相声，感受语言艺术的魅力',
          image: 'https://images.unsplash.com/photo-1517330323742-98449c5d72f5?w=1200&h=600&fit=crop'
        },
        {
          id: 2,
          title: '精彩评书表演',
          description: '聆听历史故事，沉浸于评书的艺术世界',
          image: 'https://images.unsplash.com/photo-1516900448138-898720e93639?w=1200&h=600&fit=crop'
        },
        {
          id: 3,
          title: '京剧国粹经典',
          description: '欣赏国粹艺术，传承中华文化精髓',
          image: 'https://images.unsplash.com/photo-1573164713714-d95e436ab8d6?w=1200&h=600&fit=crop'
        },
        {
          id: 4,
          title: '地方戏曲荟萃',
          description: '探索各地特色戏曲，体验多元文化魅力',
          image: 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=1200&h=600&fit=crop'
        }
      ]
      
      this.recentEvents = this.getDefaultEvents()
    },
    
    getDefaultEvents() {
      return [
        {
          id: 1,
          title: '2024年度相声大会开票',
          description: '全国著名相声演员齐聚一堂，带来精彩纷呈的相声表演',
          type: '开票信息',
          typeClass: 'ticket',
          date: '2024-03-15',
          location: '北京国家大剧院'
        },
        {
          id: 2,
          title: '传统戏曲艺术节晚会',
          description: '汇集各地传统戏曲精华，展现中华文化魅力',
          type: '晚会',
          typeClass: 'gala',
          date: '2024-03-20',
          location: '上海大剧院'
        },
        {
          id: 3,
          title: '全国青年评书大赛决赛',
          description: '青年评书演员竞技，发掘新一代评书人才',
          type: '比赛',
          typeClass: 'competition',
          date: '2024-04-10',
          location: '天津曲艺中心'
        }
      ]
    },
    
    getEventTypeClass(eventType) {
      const classMap = {
        '开票信息': 'ticket',
        '晚会': 'gala',
        '比赛': 'competition',
        '演出': 'performance'
      }
      return classMap[eventType] || 'default'
    },
    
    formatDate(dateString) {
      const date = new Date(dateString)
      return date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    },
    
    viewEventDetails(eventId) {
      this.$router.push(`/events/${eventId}`)
    },
    
    goToVideo(videoId) {
      this.$router.push(`/video/${videoId}`)
    },
    
    // 轮播图相关方法
    startCarousel() {
      this.carouselInterval = setInterval(() => {
        this.nextSlide()
      }, 5000) // 5秒自动切换
    },
    
    stopCarousel() {
      if (this.carouselInterval) {
        clearInterval(this.carouselInterval)
        this.carouselInterval = null
      }
    },
    
    nextSlide() {
      this.currentSlide = (this.currentSlide + 1) % this.carouselSlides.length
    },
    
    prevSlide() {
      this.currentSlide = (this.currentSlide - 1 + this.carouselSlides.length) % this.carouselSlides.length
    },
    
    goToSlide(index) {
      this.currentSlide = index
    },
    
    // 弹窗相关方法
    showEventModal(event) {
      this.selectedEvent = event
      this.showModal = true
      // 禁止背景滚动
      document.body.style.overflow = 'hidden'
    },
    
    closeModal() {
      this.showModal = false
      this.selectedEvent = null
      // 恢复背景滚动
      document.body.style.overflow = ''
    }
  }
}
</script>

<style scoped>
/* 轮播图样式 */
.carousel-section {
  position: relative;
  height: 600px;
  overflow: hidden;
}

.carousel-container {
  position: relative;
  height: 100%;
  width: 100%;
}

.carousel {
  position: relative;
  height: 100%;
  width: 100%;
}

.slide {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0;
  transition: opacity 0.8s ease-in-out;
  display: flex;
  align-items: center;
  justify-content: center;
}

.slide.active {
  opacity: 1;
}

.slide-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    135deg,
    rgba(139, 69, 19, 0.7) 0%,
    rgba(160, 82, 45, 0.5) 50%,
    rgba(139, 69, 19, 0.3) 100%
  );
}

.slide-content {
  position: absolute;
  bottom: 40px;
  left: 0;
  right: 0;
  z-index: 2;
  color: white;
  padding: 0 2rem;
}

.slide-info {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 80px;
  max-width: 1000px;
  margin: 0 auto;
}

.slide-title {
  font-size: 2.2rem;
  font-weight: 700;
  text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.8);
  animation: fadeInUp 0.8s ease-out;
  margin: 0;
  letter-spacing: 1px;
}

.slide-description {
  font-size: 1.3rem;
  text-shadow: 2px 2px 6px rgba(0, 0, 0, 0.8);
  animation: fadeInUp 0.8s ease-out 0.2s both;
  margin: 0;
  opacity: 0.95;
}

.btn {
  padding: 12px 30px;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.1rem;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn-primary {
  background: #f39c12;
  color: white;
  border: 2px solid #f39c12;
}

.btn-primary:hover {
  background: #e67e22;
  border-color: #e67e22;
  transform: translateY(-2px);
}

.btn-outline {
  background: transparent;
  color: white;
  border: 2px solid white;
}

.btn-outline:hover {
  background: white;
  color: #8B4513;
  transform: translateY(-2px);
}

/* 轮播图指示器 */
.carousel-indicators {
  position: absolute;
  bottom: 30px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 10px;
  z-index: 3;
}

.indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.5);
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.indicator.active {
  background: #f39c12;
  transform: scale(1.2);
}

.indicator:hover {
  background: rgba(255, 255, 255, 0.8);
}

/* 轮播图导航按钮 */
.carousel-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.2);
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  z-index: 3;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.carousel-nav:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-50%) scale(1.1);
}

.carousel-nav.prev {
  left: 20px;
}

.carousel-nav.next {
  right: 20px;
}

/* 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 近期曲艺动态样式 - 横条式 */
.events {
  padding: 80px 0;
  background: #f8f9fa;
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 60px;
  font-weight: 700;
}

.event-list {
  max-width: 1000px;
  margin: 0 auto;
}

.event-item {
  background: white;
  border-radius: 8px;
  margin-bottom: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  border-left: 4px solid transparent;
}

.event-item:hover {
  transform: translateX(5px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
  border-left-color: #8B4513;
}

.event-item-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
}

.event-info {
  flex: 1;
  margin-right: 30px;
}

.event-type {
  margin-bottom: 8px;
}

.event-type span {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.event-type span.ticket {
  background: #e8f5e8;
  color: #2e7d32;
}

.event-type span.gala {
  background: #e3f2fd;
  color: #1565c0;
}

.event-type span.competition {
  background: #fce4ec;
  color: #c2185b;
}

.event-type span.performance {
  background: #fff3e0;
  color: #ef6c00;
}

.event-type span.default {
  background: #f5f5f5;
  color: #616161;
}

.event-title {
  font-size: 1.3rem;
  color: #2c3e50;
  margin-bottom: 8px;
  font-weight: 600;
  line-height: 1.4;
}

.event-description {
  color: #5a6c7d;
  line-height: 1.5;
  font-size: 0.95rem;
  margin-bottom: 0;
}

.event-meta {
  text-align: right;
  min-width: 180px;
}

.event-date {
  color: #e74c3c;
  font-weight: 600;
  margin-bottom: 5px;
  font-size: 0.9rem;
}

.event-location {
  color: #7f8c8d;
  font-size: 0.85rem;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .carousel-section {
    height: 500px;
  }
  
  .slide-content {
    bottom: 60px;
    padding: 0 1rem;
  }
  
  .slide-info {
    flex-direction: column;
    gap: 30px;
    max-width: 90%;
  }
  
  .slide-title {
    font-size: 1.6rem;
  }
  
  .slide-description {
    font-size: 1.1rem;
  }
  
  .carousel-nav {
    width: 40px;
    height: 40px;
    font-size: 1rem;
  }
  
  .carousel-nav.prev {
    left: 10px;
  }
  
  .carousel-nav.next {
    right: 10px;
  }
  
  .events {
    padding: 60px 0;
  }
  
  .section-title {
    font-size: 2rem;
    margin-bottom: 40px;
  }
  
  .event-item-content {
    flex-direction: column;
    align-items: flex-start;
    padding: 15px 20px;
  }
  
  .event-info {
    margin-right: 0;
    margin-bottom: 15px;
    width: 100%;
  }
  
  .event-meta {
    text-align: left;
    width: 100%;
  }
  
  .event-title {
    font-size: 1.2rem;
  }
  
  .event-description {
    font-size: 0.9rem;
  }
}

/* 弹窗样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  background: white;
  border-radius: 12px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.3s ease;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 25px 30px 20px;
  border-bottom: 1px solid #eee;
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}

.modal-title {
  font-size: 1.5rem;
  color: #2c3e50;
  font-weight: 600;
  margin: 0;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #7f8c8d;
  cursor: pointer;
  padding: 5px;
  border-radius: 50%;
  transition: all 0.3s ease;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  background: #f5f5f5;
  color: #e74c3c;
  transform: rotate(90deg);
}

.modal-body {
  padding: 30px;
}

.event-details {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-item {
  display: flex;
  align-items: flex-start;
}

.detail-item.full-width {
  flex-direction: column;
  gap: 10px;
}

.detail-label {
  font-weight: 600;
  color: #2c3e50;
  min-width: 80px;
  margin-right: 15px;
}

.detail-value {
  color: #5a6c7d;
  line-height: 1.5;
}

.event-type-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-description {
  color: #5a6c7d;
  line-height: 1.6;
  margin: 0;
  font-size: 1rem;
}

.modal-footer {
  padding: 20px 30px 30px;
  border-top: 1px solid #eee;
  text-align: right;
}

.btn-secondary {
  background: #8B4513;
  color: white;
  border: none;
  padding: 10px 25px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: #A0522D;
  transform: translateY(-2px);
}

/* 弹窗动画 */
@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .modal-content {
    max-width: 95%;
    margin: 10px;
  }
  
  .modal-header {
    padding: 20px 25px 15px;
  }
  
  .modal-title {
    font-size: 1.3rem;
  }
  
  .modal-body {
    padding: 25px;
  }
  
  .detail-item {
    flex-direction: column;
    gap: 8px;
  }
  
  .detail-label {
    min-width: auto;
    margin-right: 0;
  }
}
</style>