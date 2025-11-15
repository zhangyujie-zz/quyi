# 曲艺学习网站

一个基于Vue 3的现代曲艺艺术学习平台，致力于传承和推广中国传统曲艺艺术。

## 功能特性

- 🎭 **丰富的曲艺分类** - 相声、评书、京剧、地方戏曲等
- 📺 **高清视频教学** - 专业录制，多角度拍摄
- 🔍 **智能搜索** - 支持按分类、关键词搜索
- 📱 **响应式设计** - 完美适配各种设备
- 🎨 **现代化界面** - 优雅美观的用户体验

## 技术栈

- **前端框架**: Vue 3
- **路由管理**: Vue Router 4
- **构建工具**: Vite
- **样式**: 纯CSS + CSS Grid + Flexbox
- **图标**: Font Awesome
- **字体**: Google Fonts (Noto Serif SC)

## 项目结构

```
曲艺学习/
├── src/
│   ├── components/          # 公共组件
│   │   ├── Navbar.vue      # 导航栏
│   │   └── Footer.vue      # 页脚
│   ├── views/              # 页面组件
│   │   ├── Home.vue        # 首页
│   │   ├── Categories.vue  # 分类页面
│   │   ├── Videos.vue      # 视频页面
│   │   └── About.vue       # 关于我们
│   ├── router/             # 路由配置
│   │   └── index.js
│   ├── App.vue             # 根组件
│   ├── main.js            # 入口文件
│   └── style.css          # 全局样式
├── index.html              # HTML模板
├── package.json            # 项目配置
├── vite.config.js          # Vite配置
└── README.md              # 项目说明
```

## 快速开始

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000

### 构建生产版本

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 页面介绍

### 首页 (/)
- 英雄区域展示平台特色
- 平台优势介绍
- 热门曲艺类型展示

### 曲艺分类 (/categories)
- 按类型分类浏览曲艺
- 包含相声、评书、京剧、豫剧等
- 显示每个分类的视频数量和学员数量

### 视频学习 (/videos)
- 视频列表展示
- 支持按分类筛选
- 关键词搜索功能
- 视频详情弹窗预览

### 关于我们 (/about)
- 平台介绍和使命
- 特色功能展示
- 团队信息介绍
- 联系方式表单

## 特色功能

### 响应式设计
- 使用CSS Grid和Flexbox实现
- 完美适配桌面、平板、手机
- 移动端优化体验

### 现代化UI
- 渐变色彩方案
- 卡片式布局
- 流畅的动画效果
- 优雅的交互体验

### 搜索功能
- 实时搜索过滤
- 多维度匹配（标题、描述、标签）
- 分类筛选器

## 开发说明

### 自定义样式
主要样式定义在 `src/style.css` 中，包含：
- 全局样式重置
- 组件基础样式
- 响应式断点
- 动画效果

### 添加新功能
1. 在 `src/views/` 中创建新页面组件
2. 在 `src/router/index.js` 中添加路由
3. 更新导航菜单（如需）

### 数据管理
当前使用静态数据演示，实际项目中可以：
- 连接后端API
- 使用Vuex/Pinia进行状态管理
- 添加数据持久化

## 浏览器兼容性

- Chrome 60+
- Firefox 60+
- Safari 12+
- Edge 79+

## 贡献指南

欢迎提交Issue和Pull Request来改进项目。

## 许可证

MIT License