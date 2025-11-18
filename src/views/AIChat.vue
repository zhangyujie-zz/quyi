<template>
  <div class="ai-chat-layout">
    <!-- 统一的对话页面 -->
    <div class="chat-container">
      <!-- 页面标题区域 -->
      <div class="page-header">
        <h1>曲艺AI助手</h1>
      </div>

      <!-- 主要内容区域 -->
      <div class="main-content">
        <!-- 左侧快速提问区域 - 现在集成在对话页面内 -->
        <div class="questions-section">
          <div class="questions-header">
            <h2>您可以提问以下问题：</h2>
          </div>
          <div class="questions-list">
            <button 
              v-for="question in suggestedQuestions" 
              :key="question.id"
              @click="useSuggestedQuestion(question.text)"
              class="question-btn"
            >
              <div class="question-content">
                <span class="question-category">{{ question.category }}</span>
                <span class="question-text">{{ question.text }}</span>
              </div>
            </button>
          </div>
        </div>

        <!-- 右侧对话区域 -->
        <div class="dialogue-section">
          <!-- 消息区域 -->
          <div class="messages-container" ref="messagesContainer">
            <div v-if="messages.length === 0" class="welcome-message">
              <div class="welcome-content">
                <h3>您好！我是曲艺AI助手</h3>
                <p>我可以帮您了解传统曲艺知识，或者回答您关于曲艺的任何问题</p>
                <p>您可以从左侧选择一个问题开始对话，或者直接输入您的问题</p>
              </div>
            </div>
            
            <div v-else class="messages-list">
              <div 
                v-for="(message, index) in messages" 
                :key="index"
                :class="['message', message.role]"
              >
                <div class="message-avatar">
                  <i v-if="message.role === 'user'" class="fas fa-user"></i>
                  <i v-else class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                  <!-- 用户消息保持纯文本 -->
                  <div 
                    v-if="message.role === 'user'" 
                    class="message-text"
                  >
                    {{ message.content }}
                  </div>
                  <!-- AI 消息支持基础 HTML 格式（段落/换行） -->
                  <div 
                    v-else 
                    class="message-text ai-message-text"
                    v-html="message.content"
                  ></div>
                  <div class="message-time">{{ formatTime(message.timestamp) }}</div>
                </div>
              </div>
              
              <!-- 加载状态 -->
              <div v-if="isLoading" class="message assistant">
                <div class="message-avatar">
                  <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                  <div class="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                    <span>AI正在思考...</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 输入区域 -->
          <div class="input-container">
            <div class="input-wrapper">
              <textarea
                v-model="inputMessage"
                @keydown.enter.prevent="handleSendMessage"
                placeholder="输入您的问题..."
                rows="1"
                class="message-input"
                ref="messageInput"
              ></textarea>
              <button 
                @click="handleSendMessage" 
                :disabled="isLoading || !inputMessage.trim()"
                class="send-btn"
              >
                <i class="fas fa-paper-plane"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { AIService } from '../services/aiService.js'

export default {
  name: 'AIChat',
  data() {
    return {
      messages: [],
      inputMessage: '',
      isLoading: false,
      suggestedQuestions: [
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
  },
  
  mounted() {
    this.focusInput()
  },
  
  methods: {
    async handleSendMessage() {
      const message = this.inputMessage.trim()
      if (!message || this.isLoading) return

      // 添加用户消息
      this.addMessage('user', message)
      this.inputMessage = ''
      
      // 显示加载状态
      this.isLoading = true
      
      try {
        // 构建对话历史
        const conversationHistory = this.messages.map(msg => ({
          role: msg.role,
          content: msg.content
        }))
        
        // 发送消息给AI
        const response = await AIService.sendMessage(message, conversationHistory)
        
        // 对AI回复做基础格式化（段落 + 换行），再添加到对话中
        const formatted = this.formatAIResponse(response)
        this.addMessage('assistant', formatted)
        
      } catch (error) {
        console.error('发送消息失败:', error)
        this.addMessage('assistant', '抱歉，我暂时无法回答您的问题。请稍后再试或尝试其他问题。')
      } finally {
        this.isLoading = false
        this.focusInput()
      }
    },
    
    addMessage(role, content) {
      this.messages.push({
        role,
        content,
        timestamp: new Date()
      })
      
      // 滚动到底部
      this.$nextTick(() => {
        this.scrollToBottom()
      })
    },
    
    useSuggestedQuestion(question) {
      this.inputMessage = question
      this.focusInput()
    },
    
    focusInput() {
      this.$nextTick(() => {
        if (this.$refs.messageInput) {
          this.$refs.messageInput.focus()
        }
      })
    },
    
    scrollToBottom() {
      const container = this.$refs.messagesContainer
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    },
    
    formatTime(timestamp) {
      return new Date(timestamp).toLocaleTimeString('zh-CN', {
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    
    // 将AI返回的纯文本转换成简单HTML，保留段落和换行
    formatAIResponse(rawText) {
      if (!rawText) return ''
      const text = String(rawText).trim()
      if (!text) return ''

      return text
        .replace(/\r?\n{2,}/g, '</p><p>')
        .replace(/\r?\n/g, '<br>')
        .replace(/^/, '<p>')
        .replace(/$/, '</p>')
    }
  }
}
</script>

<style scoped>
.ai-chat-layout {
  height: 100vh;
  background: #f8f9fa;
  padding: 20px;
}

/* 统一的对话容器 */
.chat-container {
  height: 100%;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 页面标题区域 */
.page-header {
  background: #8B4513;
  color: white;
  padding: 24px 20px 20px 20px;
  border-radius: 16px 16px 0 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  text-align: center;
}

.page-header h1 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 600;
}

.page-subtitle {
  margin: 0;
  opacity: 0.9;
  font-size: 16px;
  font-weight: 500;
}

/* 主要内容区域 */
.main-content {
  flex: 1;
  display: flex;
  min-height: 0;
  padding-top: 16px;  /* 在主要内容区域顶部添加间距 */
}

/* 左侧快速提问区域 - 现在集成在页面内 */
.questions-section {
  width: 280px;
  min-width: 280px;
  background: white;   /* 与右侧对话区域背景保持一致 */
  display: flex;
  flex-direction: column;
  margin-top: 20px;    /* 上方边距 */
  margin-left: 20px;   /* 左侧边距 */
  margin-bottom: 20px; /* 下方边距 */
}

.questions-header {
  padding: 16px 20px;
  margin-bottom: 16px;
  margin-top: 0;
}

.questions-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  text-align: left;
  color: #666;
}

.questions-list {
  padding: 0 16px 16px 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  overflow: visible;  /* 去掉滚动框 */
  height: auto;  /* 确保高度自适应 */
}

.question-btn {
  width: 100%;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.3s;
  text-align: left;
  box-shadow: 0 2px 4px rgba(0,0,0,0.04);
}

.question-btn:hover {
  border-color: #8B4513;
  background: #f8f5f2;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(139, 69, 19, 0.15);
}

.question-content {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.question-category {
  background: #8B4513;
  color: white;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
  width: fit-content;
}

.question-text {
  font-size: 14px;
  line-height: 1.4;
  color: #333;
  font-weight: 500;
}

/* 右侧对话区域 */
.dialogue-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
}

.welcome-message {
  text-align: center;
  padding: 80px 20px;
}

.welcome-content h3 {
  color: #2c3e50;
  margin-bottom: 16px;
  font-size: 28px;
  font-weight: 600;
}

.welcome-content p {
  color: #666;
  margin-bottom: 16px;
  font-size: 18px;
  line-height: 1.6;
}

.messages-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.message {
  display: flex;
  gap: 12px;
  max-width: 100%;
}

.message.user {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #8B4513;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.message.user .message-avatar {
  background: #2c3e50;
}

.message-content {
  max-width: 70%;
  display: flex;
  flex-direction: column;
}

.message.user .message-content {
  align-items: flex-end;
}

.message-text {
  background: white;
  padding: 12px 16px;
  border-radius: 18px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  line-height: 1.4;
  word-wrap: break-word;
}

.message.user .message-text {
  background: #8B4513;
  color: white;
}

.message-time {
  font-size: 12px;
  color: #999;
  margin-top: 5px;
}

.typing-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #ccc;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: 0s; }
.typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
.typing-indicator span:nth-child(3) { animation-delay: 0.4s; }

.typing-indicator span:last-child {
  background: transparent;
  color: #666;
  font-size: 12px;
  animation: none;
  width: auto;
  height: auto;
}

@keyframes typing {
  0%, 60%, 100% { transform: scale(0.8); opacity: 0.5; }
  30% { transform: scale(1); opacity: 1; }
}

.input-container {
  border-top: 1px solid #e0e0e0;
  background: white;
  padding: 20px;
}

.input-wrapper {
  display: flex;
  align-items: flex-end;
  gap: 12px;
  max-width: 600px;
  margin: 0 auto;
}

.message-input {
  flex: 1;
  border: 1px solid #e0e0e0;
  border-radius: 20px;
  padding: 12px 16px;
  font-size: 14px;
  resize: none;
  outline: none;
  transition: border-color 0.3s;
  max-height: 120px;
}

.message-input:focus {
  border-color: #8B4513;
}

.send-btn {
  background: #8B4513;
  color: white;
  border: none;
  border-radius: 50%;
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.3s;
}

.send-btn:hover:not(:disabled) {
  background: #A0522D;
}

.send-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .ai-chat-layout {
    padding: 10px;
  }
  
  .main-content {
    flex-direction: column;
  }
  
  .questions-section {
    width: 100%;
    height: auto;
    max-height: 200px;
    border-right: none;
    border-bottom: 1px solid #e0e0e0;
  }
  
  .questions-list {
    display: flex;
    overflow-x: auto;
    padding: 10px 15px;
    gap: 10px;
  }
  
  .question-btn {
    min-width: 200px;
    margin-bottom: 0;
  }
  
  .messages-container {
    padding: 15px;
  }
  
  .message-content {
    max-width: 85%;
  }
  
  .input-container {
    padding: 15px;
  }
  
  .welcome-message {
    padding: 60px 15px;
  }
}
</style>