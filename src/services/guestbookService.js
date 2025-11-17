import { supabase } from '../config/supabase.js'

export class GuestbookService {
  // 获取公开留言
  static async getGuestbooks(limit = 20, offset = 0) {
    try {
      const { data, error } = await supabase
        .from('guestbook')
        .select('*')
        .eq('is_public', true)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1)

      if (error) {
        console.error('获取留言失败:', error)
        return []
      }

      return data || []
    } catch (error) {
      console.error('获取留言异常:', error)
      return []
    }
  }

  // 提交留言
  static async submitGuestbook(contactName, contactInfo, content) {
    try {
      const guestbookData = {
        contact_name: contactName.trim() || '匿名访客',
        contact_info: contactInfo.trim() || null,
        content: content.trim(),
        is_public: true
      }

      const { data, error } = await supabase
        .from('guestbook')
        .insert([guestbookData])
        .select()
        .single()

      if (error) {
        console.error('提交留言失败:', error)
        
        // 根据错误类型提供具体错误信息
        if (error.code === '42501') {
          throw new Error('留言功能暂时不可用，请稍后重试')
        } else if (error.code === 'PGRST116') {
          throw new Error('留言内容不能为空')
        } else {
          throw new Error('留言提交失败，请稍后重试')
        }
      }

      return data
    } catch (error) {
      console.error('提交留言异常:', error)
      throw error
    }
  }

  // 点赞留言
  static async likeGuestbook(guestbookId) {
    try {
      const { data, error } = await supabase.rpc('increment_guestbook_likes', {
        guestbook_id: guestbookId
      })

      if (error) {
        console.error('点赞留言失败:', error)
        throw new Error('点赞失败')
      }

      return data
    } catch (error) {
      console.error('点赞留言异常:', error)
      throw error
    }
  }

  // 删除留言（管理员功能）
  static async deleteGuestbook(guestbookId) {
    try {
      const { error } = await supabase
        .from('guestbook')
        .delete()
        .eq('id', guestbookId)

      if (error) {
        console.error('删除留言失败:', error)
        throw new Error('删除留言失败')
      }

      return true
    } catch (error) {
      console.error('删除留言异常:', error)
      throw error
    }
  }

  // 获取留言总数
  static async getGuestbookCount() {
    try {
      const { count, error } = await supabase
        .from('guestbook')
        .select('*', { count: 'exact', head: true })
        .eq('is_public', true)

      if (error) {
        console.error('获取留言总数失败:', error)
        return 0
      }

      return count || 0
    } catch (error) {
      console.error('获取留言总数异常:', error)
      return 0
    }
  }
}