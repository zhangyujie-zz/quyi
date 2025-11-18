<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-content">
        <div class="footer-section">
          <h3>曲艺学习</h3>
          <p>传承中华优秀传统文化，推广曲艺艺术学习</p>
        </div>
        
        <div class="footer-section">
          <h4>学习说明</h4>
          <ul>
            <li>本项目仅供学习使用</li>
            <li>内容来源于网络学习资源</li>
            <li>如涉及侵权请联系删除</li>
            <li>禁止用于商业用途</li>
          </ul>
        </div>
        
        <div class="footer-section">
          <h4>联系方式</h4>
          <ul>
            <li><i class="fas fa-envelope"></i> learn@quyi-study.edu</li>
            <li><i class="fas fa-phone"></i> 010-6228-0001</li>
            <li><i class="fas fa-map-marker-alt"></i> 北京市海淀区</li>
          </ul>
        </div>
      </div>
      
      <div class="footer-bottom">
        <p>&copy; 2025 曲艺学习平台. 仅供学习使用.</p>
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
}
</style>