<template>
  <nav class="navbar">
    <div class="container">
      <div class="nav-content">
        <div class="logo">
          <router-link to="/" class="logo-link">
            <i class="fas fa-music"></i>
            <span>曲艺学习</span>
          </router-link>
        </div>
        
        <div class="nav-links">
          <router-link to="/" class="nav-link">首页</router-link>
          <router-link to="/categories" class="nav-link">曲艺分类</router-link>
          <router-link to="/videos" class="nav-link">视频展示</router-link>
          <router-link to="/ai-chat" class="nav-link">AI对话</router-link>
          <router-link to="/about" class="nav-link">关于我们</router-link>
        </div>
        
        <div class="nav-search">
          <div class="search-box">
            <i class="fas fa-search search-icon"></i>
            <input 
              type="text" 
              class="search-input" 
              placeholder="搜索曲艺内容..."
              v-model="searchQuery"
              @keyup.enter="handleSearch"
            >
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<script>
export default {
  name: 'Navbar',
  data() {
    return {
      searchQuery: ''
    }
  },
  methods: {
    handleSearch() {
      if (this.searchQuery.trim()) {
        this.$router.push(`/videos?search=${encodeURIComponent(this.searchQuery)}`)
      }
    }
  }
}
</script>

<style scoped>
.nav-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
}

.logo-link {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: #8B4513;
  font-size: 1.5rem;
  font-weight: 700;
}

.logo-link i {
  font-size: 2rem;
  margin-right: 0.5rem;
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-link {
  text-decoration: none;
  color: #333;
  font-weight: 500;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  transition: all 0.3s ease;
}

.nav-link:hover,
.nav-link.router-link-active {
  background: linear-gradient(45deg, #8B4513, #A0522D);
  color: white;
}

.nav-search {
  flex: 0 1 300px;
}

@media (max-width: 768px) {
  .nav-content {
    flex-direction: column;
    gap: 1rem;
  }
  
  .nav-links {
    gap: 1rem;
  }
  
  .nav-search {
    width: 100%;
    max-width: 300px;
  }
}
</style>