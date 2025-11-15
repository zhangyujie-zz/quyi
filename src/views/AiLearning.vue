<template>
  <div class="ai-learning">
    <div class="container">
      <!-- 页面标题 -->
      <div class="page-header">
        <h1 class="page-title">AI学习助手</h1>
        <p class="page-subtitle">智能问答，助您深入理解曲艺艺术</p>
      </div>

      <!-- AI助手介绍 -->
      <section class="ai-intro">
        <div class="ai-intro-content">
          <div class="ai-intro-text">
            <h2>智能曲艺学习助手</h2>
            <p>
              我们的AI助手基于丰富的曲艺知识库，可以回答您关于各类曲艺艺术的疑问，
              包括历史渊源、表演技巧、代表人物、经典作品等全方位内容。
            </p>
            <ul class="ai-features">
              <li><i class="fas fa-comment"></i> 24小时在线解答</li>
              <li><i class="fas fa-book"></i> 丰富的专业知识库</li>
              <li><i class="fas fa-graduation-cap"></i> 个性化学习建议</li>
              <li><i class="fas fa-lightbulb"></i> 智能学习推荐</li>
            </ul>
          </div>
          <div class="ai-intro-image">
            <i class="fas fa-robot"></i>
          </div>
        </div>
      </section>

      <!-- 问答界面 -->
      <section class="qa-section">
        <div class="qa-container">
          <!-- 问答对话框 -->
          <div class="chat-container">
            <div class="chat-messages" ref="chatMessages">
              <div class="message ai-message">
                <div class="message-avatar">
                  <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                  <h4>曲艺AI助手</h4>
                  <p>您好！我是曲艺学习助手，很高兴为您服务。您可以问我任何关于曲艺艺术的问题，比如：</p>
                  <ul>
                    <li>• 相声的基本功有哪些？</li>
                    <li>• 京剧的四大行当是什么？</li>
                    <li>• 评书表演有哪些技巧？</li>
                    <li>• 豫剧的发展历史是怎样的？</li>
                  </ul>
                  <p>请随时提问，我会尽力为您解答！</p>
                </div>
              </div>
              
              <!-- 用户消息 -->
              <div 
                v-for="(message, index) in messages" 
                :key="index"
                :class="['message', message.type === 'user' ? 'user-message' : 'ai-message']"
              >
                <div class="message-avatar">
                  <i :class="message.type === 'user' ? 'fas fa-user' : 'fas fa-robot'"></i>
                </div>
                <div class="message-content">
                  <h4>{{ message.type === 'user' ? '您' : '曲艺AI助手' }}</h4>
                  <p>{{ message.content }}</p>
                  <span class="message-time">{{ message.time }}</span>
                </div>
              </div>
              
              <!-- 加载状态 -->
              <div v-if="isLoading" class="message ai-message">
                <div class="message-avatar">
                  <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                  <div class="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 输入框 -->
            <div class="chat-input">
              <div class="input-container">
                <input
                  type="text"
                  v-model="userInput"
                  placeholder="请输入您的问题..."
                  @keyup.enter="sendMessage"
                  :disabled="isLoading"
                  class="message-input"
                >
                <button 
                  @click="sendMessage" 
                  :disabled="!userInput.trim() || isLoading"
                  class="send-btn"
                >
                  <i class="fas fa-paper-plane"></i>
                </button>
              </div>
            </div>
          </div>

          <!-- 快速提问建议 -->
          <div class="quick-questions">
            <h3>快速提问</h3>
            <div class="quick-buttons">
              <button 
                v-for="(question, index) in quickQuestions" 
                :key="index"
                @click="quickQuestion(question)"
                class="quick-btn"
              >
                {{ question }}
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 学习资源推荐 -->
      <section class="learning-resources">
        <h2 class="section-title">推荐学习资源</h2>
        <div class="resources-grid">
          <div class="resource-card card" v-for="resource in recommendedResources" :key="resource.id">
            <i :class="resource.icon"></i>
            <h3>{{ resource.title }}</h3>
            <p>{{ resource.description }}</p>
            <router-link :to="resource.link" class="btn btn-secondary">
              查看详情 <i class="fas fa-arrow-right"></i>
            </router-link>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import { supabase } from '../config/supabase.js'

export default {
  name: 'AiLearning',
  data() {
    return {
      userInput: '',
      messages: [],
      isLoading: false,
      isConnected: false,
      quickQuestions: [
        '相声的基本功有哪些？',
        '京剧的四大行当是什么？',
        '如何学习评书表演？',
        '豫剧有哪些经典剧目？',
        '快板表演的技巧要点？',
        '山东快书的发展历史？'
      ],
      recommendedResources: [
        {
          id: 1,
          title: '相声艺术入门',
          description: '从基础到进阶，全面学习相声表演技巧',
          icon: 'fas fa-microphone-alt',
          link: '/videos?category=1'
        },
        {
          id: 2,
          title: '评书表演艺术',
          description: '掌握评书讲述技巧和表演方法',
          icon: 'fas fa-book-open',
          link: '/videos?category=2'
        },
        {
          id: 3,
          title: '京剧行当解析',
          description: '深入了解京剧各个行当的特点和表演技巧',
          icon: 'fas fa-mask',
          link: '/videos?category=3'
        },
        {
          id: 4,
          title: '地方戏曲欣赏',
          description: '探索各地特色戏曲艺术的魅力',
          icon: 'fas fa-landmark',
          link: '/categories'
        }
      ]
    }
  },
  async mounted() {
    await this.checkConnection()
    this.loadConversationHistory()
    this.scrollToBottom()
  },
  methods: {
    async checkConnection() {
      try {
        const { data, error } = await supabase.from('quyi_knowledge').select('count').limit(1)
        this.isConnected = !error
        if (error) {
          console.warn('Supabase连接失败，将使用本地知识库:', error.message)
        }
      } catch (error) {
        console.warn('Supabase连接检查失败:', error)
      }
    },

    async loadConversationHistory() {
      try {
        // 从本地存储加载对话历史
        const savedMessages = localStorage.getItem('quyi_ai_conversation')
        if (savedMessages) {
          this.messages = JSON.parse(savedMessages)
        }
      } catch (error) {
        console.warn('加载对话历史失败:', error)
      }
    },

    async sendMessage() {
      if (!this.userInput.trim()) return
      
      // 添加用户消息
      const userMessage = {
        type: 'user',
        content: this.userInput,
        time: this.getCurrentTime()
      }
      this.messages.push(userMessage)
      
      // 清空输入框
      const question = this.userInput
      this.userInput = ''
      
      // 保存对话历史
      this.saveConversationHistory()
      
      // 显示加载状态
      this.isLoading = true
      
      // 生成AI响应
      await this.generateAiResponse(question)
      this.isLoading = false
      this.scrollToBottom()
    },
    
    quickQuestion(question) {
      this.userInput = question
      this.sendMessage()
    },
    
    async generateAiResponse(question) {
      let response = '抱歉，我暂时无法回答这个问题。您可以尝试问一些关于曲艺艺术的基础知识，比如相声、评书、京剧等相关内容。'
      
      try {
        // 尝试从Supabase获取答案
        if (this.isConnected) {
          const { data, error } = await supabase
            .from('quyi_knowledge')
            .select('*')
            .or(`question.ilike.%${question}%,tags.ilike.%${question}%`)
            .limit(1)
            
          if (!error && data && data.length > 0) {
            response = data[0].answer
          } else {
            // 如果Supabase没有匹配，使用本地知识库
            response = this.getLocalResponse(question)
            
            // 记录未回答的问题以便后续优化
            await this.recordUnansweredQuestion(question)
          }
        } else {
          // 使用本地知识库
          response = this.getLocalResponse(question)
        }
      } catch (error) {
        console.warn('生成AI响应时出错:', error)
        response = this.getLocalResponse(question)
      }
      
      // 添加AI消息
      const aiMessage = {
        type: 'ai',
        content: response,
        time: this.getCurrentTime()
      }
      this.messages.push(aiMessage)
      
      // 保存对话历史
      this.saveConversationHistory()
    },
    
    getLocalResponse(question) {
      // 本地知识库
      const knowledgeBase = {
        '相声基本功': '相声的基本功主要包括：\n1. 说：口齿伶俐，语言表达清晰\n2. 学：模仿各种声音和人物\n3. 逗：幽默风趣，引人发笑\n4. 唱：表演唱腔和曲调\n这些基本功需要通过长期练习才能掌握。',
        '京剧四大行当': '京剧的四大行当是：\n1. 生：男性角色，包括老生、小生等\n2. 旦：女性角色，包括青衣、花旦等\n3. 净：性格鲜明的男性角色，脸谱化\n4. 丑：喜剧角色，表演幽默风趣\n每个行当都有独特的表演规范和技巧。',
        '评书表演技巧': '评书表演的主要技巧包括：\n1. 语言表达：口齿清晰，语气生动\n2. 节奏控制：快慢有序，张弛有度\n3. 人物塑造：通过声音变化表现不同角色\n4. 情节渲染：营造悬念，引人入胜\n5. 肢体语言：配合讲述做适当动作',
        '豫剧经典剧目': '豫剧的经典剧目有：\n1. 《穆桂英挂帅》\n2. 《朝阳沟》\n3. 《花木兰》\n4. 《七品芝麻官》\n5. 《程婴救孤》\n这些剧目展现了豫剧的艺术特色和魅力。',
        '快板表演技巧': '快板表演的技巧要点：\n1. 节奏感：掌握基本节奏型\n2. 语言清晰：吐字清楚，韵律感强\n3. 表情丰富：配合内容做适当表情\n4. 肢体协调：动作与语言相配合\n5. 即兴发挥：根据现场情况灵活调整',
        '山东快书历史': '山东快书的发展历程：\n1. 起源于明代的说唱艺术\n2. 清代逐渐形成独特风格\n3. 民国时期得到进一步发展\n4. 新中国成立后走向繁荣\n5. 现代不断创新，保持活力'
      }
      
      // 关键词匹配
      const keywords = Object.keys(knowledgeBase)
      const matchedKeyword = keywords.find(keyword => 
        question.toLowerCase().includes(keyword.toLowerCase())
      )
      
      if (matchedKeyword) {
        return knowledgeBase[matchedKeyword]
      } else if (question.includes('基本功') || question.includes('基础')) {
        return '学习曲艺艺术需要掌握基本功，建议您先从基础开始学习，逐步提高。具体可以观看我们的教学视频，或者咨询专业的曲艺老师。'
      } else if (question.includes('历史') || question.includes('发展')) {
        return '曲艺艺术有着悠久的历史，不同曲种有不同的发展历程。建议您查看相关分类的详细介绍，或者观看历史相关的视频内容。'
      } else if (question.includes('技巧') || question.includes('方法')) {
        return '表演技巧需要通过系统学习和实践来掌握。我们的视频课程中有详细的技巧讲解，建议您观看相关教学视频。'
      }
      
      return '抱歉，我暂时无法回答这个问题。您可以尝试问一些关于曲艺艺术的基础知识，比如相声、评书、京剧等相关内容。'
    },
    
    async recordUnansweredQuestion(question) {
      if (!this.isConnected) return
      
      try {
        await supabase
          .from('unanswered_questions')
          .insert([
            { 
              question: question,
              created_at: new Date().toISOString()
            }
          ])
      } catch (error) {
        console.warn('记录未回答问题失败:', error)
      }
    },
    
    saveConversationHistory() {
      try {
        localStorage.setItem('quyi_ai_conversation', JSON.stringify(this.messages))
      } catch (error) {
        console.warn('保存对话历史失败:', error)
      }
    },
    
    getCurrentTime() {
      const now = new Date()
      return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
    },
    
    scrollToBottom() {
      this.$nextTick(() => {
        const container = this.$refs.chatMessages
        if (container) {
          container.scrollTop = container.scrollHeight
        }
      })
    }
  }
}
</script>

<style scoped>
.page-header {
  text-align: center;
  margin-bottom: 3rem;
}

.page-title {
  font-size: 3rem;
  color: #2c3e50;
  margin-bottom: 1rem;
}

.page-subtitle {
  font-size: 1.2rem;
  color: #666;
  max-width: 600px;
  margin: 0 auto;
  line-height: 1.6;
}

.ai-intro {
  margin-bottom: 3rem;
}

.ai-intro-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3rem;
  align-items: center;
}

.ai-intro-text h2 {
  font-size: 2.5rem;
  color: #8B4513;
  margin-bottom: 1.5rem;
}

.ai-intro-text p {
  font-size: 1.1rem;
  line-height: 1.8;
  color: #666;
  margin-bottom: 1.5rem;
}

.ai-features {
  list-style: none;
}

.ai-features li {
  margin-bottom: 0.8rem;
  color: #666;
}

.ai-features i {
  color: #8B4513;
  margin-right: 0.5rem;
  width: 20px;
}

.ai-intro-image {
  text-align: center;
  font-size: 15rem;
  color: #8B4513;
  opacity: 0.8;
}

.qa-section {
  margin-bottom: 4rem;
}

.qa-container {
  max-width: 800px;
  margin: 0 auto;
}

.chat-container {
  background: white;
  border-radius: 15px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  margin-bottom: 2rem;
}

.chat-messages {
  height: 400px;
  overflow-y: auto;
  padding: 2rem;
  background: #f8f9fa;
}

.message {
  display: flex;
  margin-bottom: 1.5rem;
  gap: 1rem;
}

.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.user-message .message-avatar {
  background: linear-gradient(45deg, #3498db, #2980b9);
}

.ai-message .message-avatar {
  background: linear-gradient(45deg, #8B4513, #A0522D);
}

.message-content {
  background: white;
  padding: 1rem 1.5rem;
  border-radius: 15px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  max-width: 70%;
}

.user-message .message-content {
  background: linear-gradient(45deg, #3498db, #2980b9);
  color: white;
}

.message-content h4 {
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
  opacity: 0.8;
}

.message-content p {
  line-height: 1.6;
  white-space: pre-line;
}

.message-time {
  font-size: 0.8rem;
  opacity: 0.6;
  display: block;
  margin-top: 0.5rem;
}

.typing-indicator {
  display: flex;
  gap: 4px;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #8B4513;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.4;
  }
  30% {
    transform: translateY(-10px);
    opacity: 1;
  }
}

.chat-input {
  padding: 1.5rem 2rem;
  background: white;
  border-top: 1px solid #eee;
}

.input-container {
  display: flex;
  gap: 1rem;
}

.message-input {
  flex: 1;
  padding: 1rem 1.5rem;
  border: 2px solid #e0e0e0;
  border-radius: 25px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.message-input:focus {
  outline: none;
  border-color: #8B4513;
}

.send-btn {
  width: 50px;
  height: 50px;
  border: none;
  border-radius: 50%;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
}

.send-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(139, 69, 19, 0.3);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quick-questions {
  text-align: center;
}

.quick-questions h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.quick-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: center;
}

.quick-btn {
  padding: 0.5rem 1rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.9rem;
}

.quick-btn:hover {
  border-color: #8B4513;
  color: #8B4513;
}

.learning-resources {
  margin-bottom: 3rem;
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 3rem;
}

.resources-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
}

.resource-card {
  text-align: center;
  padding: 2rem;
}

.resource-card i {
  font-size: 3rem;
  color: #8B4513;
  margin-bottom: 1rem;
}

.resource-card h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.resource-card p {
  color: #666;
  margin-bottom: 1.5rem;
  line-height: 1.6;
}

@media (max-width: 768px) {
  .page-title {
    font-size: 2rem;
  }
  
  .ai-intro-content {
    grid-template-columns: 1fr;
    text-align: center;
  }
  
  .ai-intro-image {
    font-size: 8rem;
  }
  
  .chat-messages {
    height: 300px;
    padding: 1rem;
  }
  
  .message-content {
    max-width: 85%;
  }
  
  .input-container {
    flex-direction: column;
  }
  
  .send-btn {
    width: 100%;
    border-radius: 25px;
    height: 50px;
  }
  
  .quick-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .quick-btn {
    width: 100%;
    max-width: 300px;
  }
  
  .resources-grid {
    grid-template-columns: 1fr;
  }
}
</style>