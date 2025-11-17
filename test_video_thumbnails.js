// 测试视频封面图片功能
import { VideoService } from './src/services/videoService.js'

async function testVideoThumbnails() {
  console.log('🧪 测试视频封面图片功能...\n')
  
  try {
    // 1. 测试获取视频列表，检查是否有thumbnail_url字段
    console.log('1. 获取视频列表...')
    const result = await VideoService.getVideos({ page: 1, pageSize: 10 })
    
    if (result.videos && result.videos.length > 0) {
      console.log(`✅ 找到 ${result.videos.length} 个视频`)
      
      result.videos.forEach((video, index) => {
        console.log(`\n视频 ${index + 1}:`)
        console.log(`  标题: ${video.title}`)
        console.log(`  分类ID: ${video.category_id}`)
        console.log(`  封面URL: ${video.thumbnail_url || '❌ 无封面图片'}`)
        console.log(`  表演者: ${video.performer || '未知'}`)
      })
    } else {
      console.log('⚠️  未找到视频数据，使用默认数据')
    }
    
    // 2. 测试获取分类详情，检查相关视频的封面
    console.log('\n\n2. 测试分类详情中的视频封面...')
    const categoryDetail = await VideoService.getCategoryDetailWithRepresentatives(1)
    
    if (categoryDetail && categoryDetail.videos) {
      console.log(`✅ 相声分类相关视频: ${categoryDetail.videos.length} 个`)
      categoryDetail.videos.forEach((video, index) => {
        console.log(`  视频 ${index + 1}: ${video.title} - 封面: ${video.thumbnail_url || '❌ 无封面'}`)
      })
    }
    
    console.log('\n✅ 视频封面图片功能测试完成！')
    
  } catch (error) {
    console.error('❌ 测试失败:', error.message)
    console.log('💡 请确保：')
    console.log('   1. 数据库已连接')
    console.log('   2. 已执行 add_video_thumbnails.sql 脚本')
    console.log('   3. 视频表包含 thumbnail_url 字段')
  }
}

// 运行测试
testVideoThumbnails()