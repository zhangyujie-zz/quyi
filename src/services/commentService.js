import { supabase } from '../config/supabase.js'

export class CommentService {
  // 获取视频评论
  static async getComments(videoId) {
    try {
      // 由于用户可能未登录，我们只获取评论基本信息，不关联用户表
      const { data, error } = await supabase
        .from('comments')
        .select('*')
        .eq('video_id', videoId)
        .is('parent_id', null) // 只获取顶级评论
        .order('created_at', { ascending: false })

      if (error) {
        console.error('获取评论失败:', error)
        return []
      }

      // 格式化评论数据，所有评论都显示为匿名用户
      return data.map(comment => ({
        id: comment.id,
        content: comment.content,
        created_at: comment.created_at,
        likes_count: comment.likes_count || 0,
        user_name: '匿名用户',
        avatar_url: null
      }))
    } catch (error) {
      console.error('获取评论异常:', error)
      return []
    }
  }

  // 提交评论（不需要登录）
  static async submitComment(videoId, content, userId = null) {
    try {
      const commentData = {
        video_id: videoId,
        content: content.trim(),
        user_id: userId // 如果用户未登录则为 null
      }

      const { data, error } = await supabase
        .from('comments')
        .insert([commentData])
        .select()
        .single()

      if (error) {
        console.error('提交评论失败:', error)
        
        // 根据错误类型提供更具体的错误信息
        if (error.code === '42501') {
          throw new Error('评论功能暂时不可用，请稍后重试')
        } else if (error.code === 'PGRST116') {
          throw new Error('评论内容不能为空')
        } else if (error.code === '23514') {
          throw new Error('无效的视频ID')
        } else {
          throw new Error('评论提交失败，请稍后重试')
        }
      }

      // 格式化返回的评论数据
      return {
        id: data.id,
        content: data.content,
        created_at: data.created_at,
        likes_count: data.likes_count || 0,
        user_name: '匿名用户',
        avatar_url: null
      }
    } catch (error) {
      console.error('提交评论异常:', error)
      throw error
    }
  }

  // 点赞评论
  static async likeComment(commentId) {
    try {
      const { data, error } = await supabase.rpc('increment_comment_likes', {
        comment_id: commentId
      })

      if (error) {
        console.error('点赞评论失败:', error)
        throw new Error('点赞失败')
      }

      return data
    } catch (error) {
      console.error('点赞评论异常:', error)
      throw error
    }
  }

  // 删除评论
  static async deleteComment(commentId, userId = null) {
    try {
      let query = supabase
        .from('comments')
        .eq('id', commentId)

      // 如果提供了用户ID，则检查权限
      if (userId) {
        query = query.eq('user_id', userId)
      }

      const { error } = await query.delete()

      if (error) {
        console.error('删除评论失败:', error)
        throw new Error('删除评论失败')
      }

      return true
    } catch (error) {
      console.error('删除评论异常:', error)
      throw error
    }
  }
}