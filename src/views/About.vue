<template>
  <div class="about">
    <div class="container">
      <!-- 页面标题 -->
      <div class="page-header">
        <h1 class="page-title">联系我们</h1>
      </div>

      <!-- 留言表单 -->
      <section class="contact-section">
        <div class="contact-form card">
          <h3>留言咨询</h3>
          <form @submit.prevent="submitContact">
            <div class="form-group">
              <textarea v-model="contactForm.message" placeholder="请输入您的留言内容" rows="8" required></textarea>
            </div>
            <button type="submit" class="btn">发送留言</button>
          </form>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'About',
  data() {
    return {
      contactForm: {
        message: ''
      }
    }
  },
  methods: {
    submitContact() {
      // 这里可以添加表单提交逻辑
      alert('感谢您的留言！我们会尽快与您联系。')
      this.contactForm = { message: '' }
    }
  }
}
</script>

<style scoped>
.page-header {
  text-align: center;
  margin-bottom: 4rem;
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

.intro-section {
  margin-bottom: 4rem;
}

.intro-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3rem;
  align-items: center;
}

.intro-text h2 {
  font-size: 2.5rem;
  color: #8B4513;
  margin-bottom: 1.5rem;
}

.intro-text p {
  font-size: 1.1rem;
  line-height: 1.8;
  color: #666;
  margin-bottom: 1rem;
}

.intro-image {
  text-align: center;
  font-size: 15rem;
  color: #8B4513;
  opacity: 0.8;
}

.features-section {
  margin-bottom: 4rem;
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 3rem;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
}

.feature-item {
  text-align: center;
  padding: 2rem;
}

.feature-item i {
  font-size: 3rem;
  color: #8B4513;
  margin-bottom: 1rem;
}

.feature-item h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
}

.team-section {
  margin-bottom: 4rem;
}

.team-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
}

.team-member {
  text-align: center;
  padding: 2rem;
}

.member-avatar {
  width: 100px;
  height: 100px;
  background: linear-gradient(45deg, #8B4513, #A0522D);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem;
  color: white;
  font-size: 2.5rem;
}

.team-member h3 {
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.member-title {
  color: #8B4513;
  font-weight: 600;
  margin-bottom: 1rem;
}

.member-bio {
  color: #666;
  line-height: 1.6;
}

.contact-section {
  margin-bottom: 4rem;
}

.contact-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3rem;
}

.contact-item {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
}

.contact-item i {
  font-size: 2rem;
  color: #8B4513;
  margin-right: 1rem;
  width: 60px;
}

.contact-item h4 {
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.contact-item p {
  color: #666;
}

.contact-form {
  padding: 2rem;
}

.contact-form h3 {
  margin-bottom: 1.5rem;
  color: #2c3e50;
  text-align: center;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #8B4513;
}

.form-group textarea {
  resize: vertical;
  min-height: 120px;
}

@media (max-width: 768px) {
  .page-title {
    font-size: 2rem;
  }
  
  .intro-content {
    grid-template-columns: 1fr;
    text-align: center;
  }
  
  .intro-image {
    font-size: 8rem;
  }
  
  .contact-content {
    grid-template-columns: 1fr;
  }
  
  .features-grid,
  .team-grid {
    grid-template-columns: 1fr;
  }
}
</style>