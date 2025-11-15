<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-content">
        <div class="footer-section">
          <h3>曲艺学习</h3>
          <p>传承中华优秀传统文化，推广曲艺艺术学习</p>
          <div class="social-links">
            <a href="#" class="social-link"><i class="fab fa-weixin"></i></a>
            <a href="#" class="social-link"><i class="fab fa-weibo"></i></a>
            <a href="#" class="social-link"><i class="fab fa-qq"></i></a>
          </div>
        </div>
        
        <div class="footer-section">
          <h4>快速链接</h4>
          <ul>
            <li><router-link to="/">首页</router-link></li>
            <li><router-link to="/categories">曲艺分类</router-link></li>
            <li><router-link to="/videos">视频学习</router-link></li>
            <li><router-link to="/about">关于我们</router-link></li>
          </ul>
        </div>
        
        <div class="footer-section">
          <h4>联系方式</h4>
          <ul>
            <li><i class="fas fa-envelope"></i> contact@quyi.com</li>
            <li><i class="fas fa-phone"></i> 400-123-4567</li>
            <li><i class="fas fa-map-marker-alt"></i> 北京市东城区</li>
          </ul>
        </div>
      </div>
      
      <div class="footer-bottom">
        <p>&copy; 2025 曲艺学习平台. 保留所有权利.</p>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'Footer'
}
</script>

<style scoped>
.footer-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.footer-section h3 {
  color: #f8c471;
  margin-bottom: 1rem;
  font-size: 1.5rem;
}

.footer-section h4 {
  color: #f8c471;
  margin-bottom: 1rem;
}

.footer-section p {
  color: #bdc3c7;
  line-height: 1.6;
}

.footer-section ul {
  list-style: none;
}

.footer-section ul li {
  margin-bottom: 0.5rem;
  color: #bdc3c7;
}

.footer-section ul li a {
  color: #bdc3c7;
  text-decoration: none;
  transition: color 0.3s ease;
}

.footer-section ul li a:hover {
  color: #f8c471;
}

.social-links {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

.social-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  color: #bdc3c7;
  text-decoration: none;
  transition: all 0.3s ease;
}

.social-link:hover {
  background: #f8c471;
  color: #2c3e50;
  transform: translateY(-2px);
}

.footer-bottom {
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding-top: 1rem;
  text-align: center;
  color: #bdc3c7;
}

@media (max-width: 768px) {
  .footer-content {
    grid-template-columns: 1fr;
    text-align: center;
  }
  
  .social-links {
    justify-content: center;
  }
}
</style>