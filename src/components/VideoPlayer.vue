<template>
  <div class="video-player" v-if="video">
    <div class="player-container">
      <!-- 视频播放器 -->
      <div class="player-wrapper">
        <!-- 如果是B站链接，使用iframe嵌入播放器 -->
        <iframe
          v-if="isBilibili"
          class="video-iframe"
          :src="bilibiliEmbedUrl"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen
        ></iframe>

        <!-- 否则使用原生video播放直链视频 -->
        <video 
          v-else
          ref="videoElement" 
          :src="videoUrl" 
          controls 
          class="video-element"
          @play="onPlay"
          @pause="onPause"
          @timeupdate="onTimeUpdate"
          @ended="onEnded"
        >
          您的浏览器不支持视频播放。
        </video>
        
        <!-- 自定义播放控制（仅对原生video生效） -->
        <div class="custom-controls" v-if="!isBilibili && !isPlaying">
          <button class="play-button" @click="playVideo">
            <i class="fas fa-play"></i>
          </button>
        </div>
      </div>
      
      <!-- 视频信息 -->
      <div class="video-info">
        <h1 class="video-title">{{ video.title }}</h1>
        <div class="video-meta">
          <span class="meta-item">
            <i class="fas fa-user"></i> {{ video.performer || '未知表演者' }}
          </span>
          <span class="meta-item">
            <i class="fas fa-eye"></i> {{ video.views_count || 0 }} 次观看
          </span>
          <span class="meta-item">
            <i class="fas fa-clock"></i> {{ formatDuration(video.duration) }}
          </span>
          <span class="meta-item">
            <i class="fas fa-calendar"></i> {{ formatDate(video.performance_date) }}
          </span>
        </div>
        <!-- 无真实音视频源提示（例如使用测试数据时） -->
        <p v-if="!videoUrl" class="no-source-tip">
          当前为测试示例数据，仅展示封面和信息，无实际音视频源。
        </p>
        
        <!-- 视频描述 -->
        <div class="video-description">
          <p>{{ video.description }}</p>
        </div>
        
        <!-- 标签 -->
        <div class="video-tags">
          <span v-for="tag in (video.tags || [])" :key="tag" class="tag">{{ tag }}</span>
        </div>
        
        <!-- 操作按钮 -->
        <div class="video-actions">
          <button class="btn btn-outline" @click="toggleLike">
            <i :class="[isLiked ? 'fas' : 'far', 'fa-heart']"></i>
            {{ video.likes_count || 0 }} 赞
          </button>
          <button class="btn btn-outline" @click="toggleFavorite">
            <i :class="[isFavorited ? 'fas' : 'far', 'fa-star']"></i>
            收藏
          </button>
          <button class="btn btn-outline" @click="shareVideo">
            <i class="fas fa-share-alt"></i>
            分享
          </button>
        </div>
      </div>
    </div>
    
    <!-- 相关视频 -->
    <div class="related-videos" v-if="relatedVideos.length > 0">
      <h3>相关视频</h3>
      <div class="related-grid">
        <div 
          v-for="relatedVideo in relatedVideos" 
          :key="relatedVideo.id"
          class="related-card"
          @click="playRelatedVideo(relatedVideo)"
        >
          <div class="related-thumbnail">
            <i class="fas fa-play-circle"></i>
            <div class="duration">{{ formatDuration(relatedVideo.duration) }}</div>
          </div>
          <div class="related-info">
            <h4>{{ relatedVideo.title }}</h4>
            <p>{{ relatedVideo.performer }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <!-- 加载状态 -->
  <div v-else-if="loading" class="loading">
    <div class="spinner"></div>
    <p>正在加载视频...</p>
  </div>
  
  <!-- 错误状态 -->
  <div v-else class="error-state">
    <i class="fas fa-exclamation-triangle"></i>
    <h3>视频加载失败</h3>
    <p>抱歉，无法加载该视频内容。</p>
    <button class="btn" @click="$router.push('/videos')">返回视频列表</button>
  </div>
</template>

<script>
import { VideoService } from '../services/videoService.js'

export default {
  name: 'VideoPlayer',
  props: {
    videoId: {
      type: [String, Number],
      required: true
    }
  },
  data() {
    return {
      video: null,
      relatedVideos: [],
      loading: false,
      isPlaying: false,
      currentTime: 0,
      isLiked: false,
      isFavorited: false
    }
  },
  computed: {
    videoUrl() {
      return this.video?.video_url || ''
    },

    // 是否为B站链接
    isBilibili() {
      return /bilibili\.com\/(video|bangumi)/.test(this.videoUrl)
    },

    // 根据保存的B站链接构造可嵌入的player地址（简单从URL中提取BV号）
    bilibiliEmbedUrl() {
      if (!this.isBilibili) return ''

      try {
        const url = this.videoUrl
        const bvMatch = url.match(/BV[0-9A-Za-z]+/)
        if (bvMatch) {
          const bvid = bvMatch[0]
          // 使用B站通用嵌入播放器地址
          return `https://player.bilibili.com/player.html?bvid=${bvid}&page=1&high_quality=1&danmaku=0`
        }
        // 找不到BV号时退回原链接（可能仍然无法播放）
        return url
      } catch (e) {
        return this.videoUrl
      }
    }
  },
  watch: {
    videoId: {
      immediate: true,
      async handler(newVideoId) {
        if (newVideoId) {
          await this.loadVideoData()
        }
      }
    }
  },
  methods: {
    async loadVideoData() {
      this.loading = true
      try {
        // 加载视频详情
        this.video = await VideoService.getVideoDetail(this.videoId)
        
        if (this.video && this.video.tags) {
          // 加载相关视频
          this.relatedVideos = await VideoService.getRelatedVideosByTags(this.video.tags, 4)
        }
        
        // 增加观看次数
        await VideoService.incrementVideoViews(this.videoId)
      } catch (error) {
        console.error('加载视频数据失败:', error)
        this.video = null
      } finally {
        this.loading = false
      }
    },
    
    playVideo() {
      if (this.$refs.videoElement) {
        this.$refs.videoElement.play()
      }
    },
    
    onPlay() {
      this.isPlaying = true
    },
    
    onPause() {
      this.isPlaying = false
    },
    
    onTimeUpdate(event) {
      this.currentTime = event.target.currentTime
    },
    
    onEnded() {
      this.isPlaying = false
      // 可以在这里添加播放完成后的逻辑
    },
    
    toggleLike() {
      this.isLiked = !this.isLiked
      // TODO: 实现点赞功能
    },
    
    toggleFavorite() {
      this.isFavorited = !this.isFavorited
      // TODO: 实现收藏功能
    },
    
    shareVideo() {
      if (navigator.share) {
        navigator.share({
          title: this.video.title,
          text: this.video.description,
          url: window.location.href
        })
      } else {
        // 回退到复制链接
        navigator.clipboard.writeText(window.location.href)
        alert('链接已复制到剪贴板')
      }
    },
    
    playRelatedVideo(relatedVideo) {
      this.$router.push(`/video/${relatedVideo.id}`)
    },
    
    formatDuration(seconds) {
      if (!seconds) return '00:00'
      const minutes = Math.floor(seconds / 60)
      const remainingSeconds = seconds % 60
      return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
    },
    
    formatDate(dateString) {
      if (!dateString) return '未知日期'
      const date = new Date(dateString)
      return date.toLocaleDateString('zh-CN')
    }
  }
}
</script>

<style scoped>
.video-player {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.player-container {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.player-wrapper {
  position: relative;
  background: #000;
}

.video-element {
  width: 100%;
  height: 500px;
  display: block;
}

.video-iframe {
  width: 100%;
  height: 100%;
  border: none;
  display: block;
}

.custom-controls {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.3);
}

.play-button {
  background: rgba(139, 69, 19, 0.9);
  border: none;
  border-radius: 50%;
  width: 80px;
  height: 80px;
  color: white;
  font-size: 2rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-button:hover {
  transform: scale(1.1);
  background: rgba(160, 82, 45, 0.9);
}

.video-info {
  padding: 2rem;
}

.video-title {
  font-size: 2rem;
  margin-bottom: 1rem;
  color: #2c3e50;
  line-height: 1.3;
}

.video-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
  color: #666;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.meta-item i {
  color: #8B4513;
}

.video-description {
  margin-bottom: 1.5rem;
  line-height: 1.6;
  color: #555;
}

.no-source-tip {
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  border-radius: 6px;
  background: #fff3cd;
  color: #856404;
  font-size: 0.9rem;
}

.video-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
}

.tag {
  background: #f0f0f0;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.9rem;
  color: #666;
}

.video-actions {
  display: flex;
  gap: 1rem;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.btn-outline {
  background: transparent;
  border: 2px solid #e0e0e0;
  color: #666;
}

.btn-outline:hover {
  border-color: #8B4513;
  color: #8B4513;
}

.related-videos {
  margin-top: 3rem;
}

.related-videos h3 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  color: #2c3e50;
}

.related-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.related-card {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.related-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.related-thumbnail {
  position: relative;
  height: 140px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.related-thumbnail i {
  font-size: 2rem;
  opacity: 0.8;
}

.duration {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0, 0, 0, 0.7);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
}

.related-info {
  padding: 1rem;
}

.related-info h4 {
  font-size: 1rem;
  margin-bottom: 0.5rem;
  color: #2c3e50;
  line-height: 1.3;
}

.related-info p {
  color: #666;
  font-size: 0.9rem;
}

.loading, .error-state {
  text-align: center;
  padding: 4rem 2rem;
}

.spinner {
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

.error-state i {
  font-size: 4rem;
  color: #e74c3c;
  margin-bottom: 1rem;
}

@media (max-width: 768px) {
  .video-player {
    padding: 1rem;
  }
  
  .video-element {
    height: 300px;
  }
  
  .video-title {
    font-size: 1.5rem;
  }
  
  .video-meta {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .video-actions {
    flex-direction: column;
  }
  
  .related-grid {
    grid-template-columns: 1fr;
  }
}
</style>