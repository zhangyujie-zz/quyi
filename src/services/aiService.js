/**
 * DeepSeek AI对话服务
 * 使用DeepSeek API进行对话
 */

export class AIService {
  static API_KEY = 'sk-8a2db8ef29ce411c8cc63bfe3aaf1f32'
  static API_URL = 'https://api.deepseek.com/v1/chat/completions'

  /**
   * 发送消息给AI并获取回复
   * @param {string} message - 用户消息
   * @param {Array} conversationHistory - 对话历史
   * @returns {Promise<string>} - AI回复
   */
  static async sendMessage(message, conversationHistory = []) {
    try {
      const messages = [
        {
          role: 'system',
          content: `你是一个曲艺文化助手，专门帮助用户了解中国传统文化和曲艺知识。
请用简洁、友好的语言回答用户关于曲艺、传统文化的问题。
重点介绍相声、评书、京剧等传统艺术形式的历史、特点、代表人物。
如果用户的问题超出曲艺范围，可以适当扩展到相关传统文化领域。
保持回答的专业性和趣味性。`
        },
        ...conversationHistory,
        {
          role: 'user',
          content: message
        }
      ]

      const response = await fetch(this.API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.API_KEY}`
        },
        body: JSON.stringify({
          model: 'deepseek-chat',
          messages: messages,
          temperature: 0.7,
          max_tokens: 1000,
          stream: false
        })
      })

      if (!response.ok) {
        throw new Error(`API请求失败: ${response.status}`)
      }

      const data = await response.json()
      
      if (data.choices && data.choices.length > 0) {
        return data.choices[0].message.content
      } else {
        throw new Error('API返回数据格式异常')
      }
    } catch (error) {
      console.error('AI对话服务错误:', error)
      throw new Error(`对话失败: ${error.message}`)
    }
  }

  /**
   * 获取预定义的问题列表
   * @returns {Array} - 推荐问题列表
   */
  static getSuggestedQuestions() {
    return [
      {
        id: 1,
        text: '能介绍一下相声艺术的特点吗？',
        category: '相声'
      },
      {
        id: 2,
        text: '评书和说书有什么区别？',
        category: '评书'
      },
      {
        id: 3,
        text: '传统曲艺有哪些表演形式？',
        category: '综合'
      },
      {
        id: 4,
        text: '京剧的四大行当有哪些？',
        category: '京剧'
      }
    ]
  }
}

export default AIService