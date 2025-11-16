import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Categories from '../views/Categories.vue'
import CategoryDetail from '../views/CategoryDetail.vue'
import Videos from '../views/Videos.vue'
import About from '../views/About.vue'
import AIChat from '../views/AIChat.vue'
import VideoPlayer from '../components/VideoPlayer.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/categories',
    name: 'Categories',
    component: Categories
  },
  {
    path: '/category/:id',
    name: 'CategoryDetail',
    component: CategoryDetail,
    props: true
  },
  {
    path: '/videos',
    name: 'Videos',
    component: Videos
  },
  {
    path: '/ai-chat',
    name: 'AIChat',
    component: AIChat
  },
  {
    path: '/about',
    name: 'About',
    component: About
  },
  {
    path: '/video/:id',
    name: 'VideoPlayer',
    component: VideoPlayer,
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router