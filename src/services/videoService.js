import { supabase } from '../config/supabase.js'

export class VideoService {
  /**
   * 获取轮播图数据
   */
  static async getCarouselSlides() {
    try {
      console.log('正在从Supabase获取轮播图数据...')
      const { data, error } = await supabase
        .from('carousel_slides')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true })
      
      if (error) {
        console.error('获取轮播图数据失败:', error)
        throw error
      }
      
      console.log('轮播图数据查询结果:', data)
      return data || []
    } catch (error) {
      console.error('获取轮播图数据失败:', error)
      return []
    }
  }

  /**
   * 获取所有分类
   */
  static async getCategories() {
    try {
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .order('sort_order', { ascending: true })
      
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('获取分类失败:', error)
      return []
    }
  }

  /**
   * 获取分类详情
   * @param {number} categoryId - 分类ID
   */
  static async getCategoryDetail(categoryId) {
    try {
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .eq('id', categoryId)
        .single()
      
      if (error) throw error
      return data
    } catch (error) {
      console.error('获取分类详情失败:', error)
      return null
    }
  }

  /**
   * 获取视频列表
   * @param {Object} options - 查询选项
   */
  static async getVideos(options = {}) {
    const {
      categoryId = null,
      page = 1,
      pageSize = 12,
      sortBy = 'created_at',
      sortOrder = 'desc',
      featured = false
    } = options

    try {
      let query = supabase
        .from('videos')
        .select('*', { count: 'exact' })

      // 条件筛选
      if (categoryId) {
        query = query.eq('category_id', categoryId)
      }

      if (featured) {
        query = query.eq('is_featured', true)
      }

      // 排序
      query = query.order(sortBy, { ascending: sortOrder === 'asc' })

      // 分页
      const from = (page - 1) * pageSize
      const to = from + pageSize - 1
      query = query.range(from, to)

      const { data, error, count } = await query
      
      if (error) throw error
      
      return {
        videos: data || [],
        total: count || 0,
        page,
        pageSize,
        totalPages: Math.ceil((count || 0) / pageSize)
      }
    } catch (error) {
      console.error('获取视频列表失败:', error)
      return { videos: [], total: 0, page, pageSize, totalPages: 0 }
    }
  }

  /**
   * 获取视频详情
   * @param {number} videoId - 视频ID
   */
  static async getVideoDetail(videoId) {
    try {
      // 使用视图获取详细数据
      const { data, error } = await supabase
        .from('video_details')
        .select('*')
        .eq('id', videoId)
        .single()
      
      if (error) throw error
      return data
    } catch (error) {
      console.error('获取视频详情失败:', error)
      return null
    }
  }

  /**
   * 搜索视频
   * @param {string} query - 搜索关键词
   * @param {Object} options - 搜索选项
   */
  static async searchVideos(query, options = {}) {
    const { page = 1, pageSize = 12 } = options

    try {
      // 使用搜索函数
      const { data, error } = await supabase
        .rpc('search_videos', { search_query: query })
      
      if (error) throw error

      // 手动分页
      const startIndex = (page - 1) * pageSize
      const endIndex = startIndex + pageSize
      const paginatedData = (data || []).slice(startIndex, endIndex)

      return {
        videos: paginatedData,
        total: (data || []).length,
        page,
        pageSize,
        totalPages: Math.ceil((data || []).length / pageSize)
      }
    } catch (error) {
      console.error('搜索视频失败:', error)
      return { videos: [], total: 0, page, pageSize, totalPages: 0 }
    }
  }

  /**
   * 增加视频观看次数
   * @param {number} videoId - 视频ID
   */
  static async incrementVideoViews(videoId) {
    try {
      // 使用函数增加观看次数
      const { error } = await supabase
        .rpc('increment_video_views', { video_id_param: videoId })
      
      if (error) throw error
      return true
    } catch (error) {
      console.error('增加观看次数失败:', error)
      return false
    }
  }

  /**
   * 记录搜索关键词
   * @param {string} keyword - 搜索关键词
   */
  static async recordSearchKeyword(keyword) {
    if (!keyword.trim()) return

    try {
      // 检查关键词是否已存在
      const { data: existing } = await supabase
        .from('search_keywords')
        .select('id, search_count')
        .eq('keyword', keyword)
        .single()

      if (existing) {
        // 更新现有记录
        const { error } = await supabase
          .from('search_keywords')
          .update({
            search_count: existing.search_count + 1,
            last_searched: new Date().toISOString()
          })
          .eq('id', existing.id)
        
        if (error) throw error
      } else {
        // 插入新记录
        const { error } = await supabase
          .from('search_keywords')
          .insert([{
            keyword: keyword,
            search_count: 1,
            last_searched: new Date().toISOString()
          }])
        
        if (error) throw error
      }
    } catch (error) {
      console.error('记录搜索关键词失败:', error)
    }
  }

  /**
   * 获取热门搜索关键词
   */
  static async getPopularKeywords(limit = 10) {
    try {
      const { data, error } = await supabase
        .from('search_keywords')
        .select('keyword, search_count')
        .order('search_count', { ascending: false })
        .limit(limit)
      
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('获取热门关键词失败:', error)
      return []
    }
  }

  /**
   * 获取推荐视频（基于观看次数和收藏数）
   */
  static async getRecommendedVideos(limit = 6) {
    try {
      const { data, error } = await supabase
        .from('videos')
        .select('*')
        .order('views_count', { ascending: false })
        .order('likes_count', { ascending: false })
        .limit(limit)
      
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('获取推荐视频失败:', error)
      return []
    }
  }

  /**
   * 获取近期曲艺动态
   */
  static async getRecentEvents(limit = 6) {
    try {
      console.log('正在从Supabase获取近期动态数据...')
      const { data, error } = await supabase
        .from('events')
        .select('*')
        .order('event_date', { ascending: false })
        .order('sort_order', { ascending: true })
        .limit(limit)
      
      if (error) {
        console.error('获取近期动态失败:', error)
        throw error
      }
      
      console.log('近期动态数据查询结果:', data)
      return data || []
    } catch (error) {
      console.error('获取近期动态失败:', error)
      return []
    }
  }

  /**
   * 根据标签获取相关视频
   * @param {string[]} tags - 标签数组
   * @param {number} limit - 限制数量
   */
  static async getRelatedVideosByTags(tags, limit = 4) {
    if (!tags || tags.length === 0) return []

    try {
      const { data, error } = await supabase
        .from('videos')
        .select('*')
        .overlaps('tags', tags)
        .limit(limit)
      
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('根据标签获取相关视频失败:', error)
      return []
    }
  }
}

export default VideoService