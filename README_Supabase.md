# Supabase 集成说明

## 配置说明

已成功将您的Supabase项目集成到曲艺展示网站中。以下是配置的详细信息：

### 环境变量
已创建 `.env.local` 文件，包含以下配置：
- `VITE_SUPABASE_URL`: https://hdayzxlqfggmiseanheq.supabase.co
- `VITE_SUPABASE_ANON_KEY`: 您的匿名密钥

### 数据库表结构
已创建完整的数据库表结构脚本 `supabase_tables.sql`，包含以下表：

#### 核心表
1. **categories** - 曲艺分类表
2. **videos** - 视频表
3. **users** - 用户表（用于收藏和观看历史）

#### 功能表
4. **user_favorites** - 用户收藏表
5. **user_watch_history** - 用户观看历史表
6. **comments** - 评论表
7. **search_keywords** - 搜索关键词记录表

### 服务工具
已创建 `VideoService` 类，提供以下功能：
- 获取分类列表
- 获取视频列表（支持分页、筛选、排序）
- 获取视频详情
- 搜索视频（支持中文全文搜索）
- 记录观看次数
- 记录搜索关键词
- 获取推荐视频
- 根据标签获取相关视频

## 使用方法

### 1. 在Supabase中创建表

登录您的Supabase控制台，进入SQL编辑器，运行 `supabase_tables.sql` 脚本创建所有表结构。

### 2. 在代码中使用

```javascript
import VideoService from '@/services/videoService'

// 获取所有分类
const categories = await VideoService.getCategories()

// 获取视频列表
const videos = await VideoService.getVideos({
  categoryId: 1, // 分类ID
  page: 1,
  pageSize: 12,
  sortBy: 'views_count', // 按观看次数排序
  sortOrder: 'desc'
})

// 搜索视频
const searchResults = await VideoService.searchVideos('相声')

// 获取视频详情
const videoDetail = await VideoService.getVideoDetail(1)

// 记录观看次数
await VideoService.incrementVideoViews(1)

// 记录搜索关键词
await VideoService.recordSearchKeyword('京剧')
```

### 3. Vue组件示例

```vue
<template>
  <div>
    <!-- 分类筛选 -->
    <select v-model="selectedCategory" @change="loadVideos">
      <option v-for="category in categories" :key="category.id" :value="category.id">
        {{ category.name }}
      </option>
    </select>

    <!-- 视频列表 -->
    <div v-for="video in videos" :key="video.id" class="video-card">
      <img :src="video.thumbnail_url" :alt="video.title">
      <h3>{{ video.title }}</h3>
      <p>{{ video.description }}</p>
      <span>观看次数: {{ video.views_count }}</span>
    </div>

    <!-- 分页 -->
    <div class="pagination">
      <button @click="prevPage" :disabled="currentPage === 1">上一页</button>
      <span>第 {{ currentPage }} 页 / 共 {{ totalPages }} 页</span>
      <button @click="nextPage" :disabled="currentPage >= totalPages">下一页</button>
    </div>
  </div>
</template>

<script>
import VideoService from '@/services/videoService'

export default {
  data() {
    return {
      categories: [],
      videos: [],
      selectedCategory: null,
      currentPage: 1,
      pageSize: 12,
      totalPages: 1
    }
  },
  async mounted() {
    await this.loadCategories()
    await this.loadVideos()
  },
  methods: {
    async loadCategories() {
      this.categories = await VideoService.getCategories()
    },
    async loadVideos() {
      const result = await VideoService.getVideos({
        categoryId: this.selectedCategory,
        page: this.currentPage,
        pageSize: this.pageSize
      })
      this.videos = result.videos
      this.totalPages = result.totalPages
    },
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadVideos()
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadVideos()
      }
    }
  }
}
</script>
```

## 高级功能

### 全文搜索
Supabase支持中文全文搜索，基于PostgreSQL的tsvector功能。搜索函数会自动对视频标题、描述和标签进行匹配。

### 实时订阅
可以添加实时订阅功能，监听数据变化：

```javascript
// 订阅视频数据变化
const subscription = supabase
  .from('videos')
  .on('*', payload => {
    console.log('数据变化:', payload)
  })
  .subscribe()
```

### 用户认证集成
如果需要用户功能，可以启用Supabase认证：

```javascript
// 用户注册
const { user, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password'
})

// 用户登录
const { user, error } = await supabase.auth.signIn({
  email: 'user@example.com',
  password: 'password'
})
```

## 下一步计划

1. **更新视频页面**：修改现有的视频展示页面，使用Supabase数据
2. **添加分类页面**：创建基于数据库的分类浏览页面
3. **实现搜索功能**：集成搜索服务，提供实时搜索建议
4. **用户功能**：实现收藏、观看历史、评论等功能
5. **管理后台**：创建视频上传和管理界面

## 注意事项

- 确保Supabase项目的Row Level Security策略已正确配置
- 视频文件可以存储在Supabase Storage中
- 定期备份数据库数据
- 监控API使用量和性能指标

您的Supabase集成已完成，现在可以开始使用真实的数据来驱动您的曲艺展示网站了！