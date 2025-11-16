// 分类详情API接口调用示例
// 这个文件展示了如何使用videoService.js中的分类相关API接口

import { VideoService } from './src/services/videoService.js'

// 示例1: 获取分类详情
async function exampleGetCategoryDetail() {
  console.log('=== 示例1: 获取分类详情 ===')
  
  try {
    const categoryDetail = await VideoService.getCategoryDetail(1) // 相声分类ID
    console.log('分类详情:', categoryDetail)
    
    if (categoryDetail) {
      console.log('分类名称:', categoryDetail.name)
      console.log('分类描述:', categoryDetail.description)
      console.log('详细描述:', categoryDetail.detailed_description)
      console.log('代表人物:', categoryDetail.representatives)
      console.log('起源地:', categoryDetail.origin)
      console.log('艺术特点:', categoryDetail.characteristics)
    }
  } catch (error) {
    console.error('获取分类详情失败:', error)
  }
}

// 示例2: 获取分类详情完整数据（包含代表人物和视频）
async function exampleGetCategoryDetailWithRepresentatives() {
  console.log('\n=== 示例2: 获取分类详情完整数据 ===')
  
  try {
    const completeData = await VideoService.getCategoryDetailWithRepresentatives(1)
    console.log('完整分类数据:', completeData)
    
    if (completeData) {
      console.log('分类信息:', completeData.category)
      console.log('代表人物数量:', completeData.representatives.length)
      console.log('相关视频数量:', completeData.videos.length)
      
      // 显示代表人物信息
      completeData.representatives.forEach((rep, index) => {
        console.log(`代表人物 ${index + 1}:`, rep.name, '-', rep.masterpiece)
      })
    }
  } catch (error) {
    console.error('获取完整分类数据失败:', error)
  }
}

// 示例3: 单独获取分类下的代表人物
async function exampleGetCategoryRepresentatives() {
  console.log('\n=== 示例3: 获取分类代表人物 ===')
  
  try {
    const representatives = await VideoService.getCategoryRepresentatives(1)
    console.log('代表人物列表:', representatives)
    
    representatives.forEach((rep, index) => {
      console.log(`代表人物 ${index + 1}:`)
      console.log('  姓名:', rep.name)
      console.log('  出生年代:', rep.birth_period)
      console.log('  代表作品:', rep.masterpiece)
      console.log('  艺术成就:', rep.artistic_achievement)
      console.log('  状态:', rep.status_text)
    })
  } catch (error) {
    console.error('获取代表人物失败:', error)
  }
}

// 示例4: 获取分类下的相关视频
async function exampleGetCategoryVideos() {
  console.log('\n=== 示例4: 获取分类相关视频 ===')
  
  try {
    const videos = await VideoService.getCategoryVideos(1, 3) // 获取3个视频
    console.log('相关视频列表:', videos)
    
    videos.forEach((video, index) => {
      console.log(`视频 ${index + 1}:`)
      console.log('  标题:', video.title)
      console.log('  描述:', video.description)
      console.log('  观看次数:', video.views_count)
      console.log('  点赞数:', video.likes_count)
      console.log('  时长:', video.duration + '秒')
    })
  } catch (error) {
    console.error('获取相关视频失败:', error)
  }
}

// 示例5: 获取分类统计数据
async function exampleGetCategoryStats() {
  console.log('\n=== 示例5: 获取分类统计数据 ===')
  
  try {
    const stats = await VideoService.getCategoryStats(1)
    console.log('分类统计数据:', stats)
    
    console.log('视频数量:', stats.videoCount)
    console.log('代表人物数量:', stats.representativeCount)
    console.log('总观看次数:', stats.totalViews)
  } catch (error) {
    console.error('获取统计数据失败:', error)
  }
}

// 示例6: 演示所有分类的详情获取
async function exampleAllCategories() {
  console.log('\n=== 示例6: 获取所有分类的详情 ===')
  
  // 假设的分类ID列表
  const categoryIds = [1, 2, 3] // 相声、评书、京剧
  
  for (const categoryId of categoryIds) {
    try {
      const categoryDetail = await VideoService.getCategoryDetail(categoryId)
      
      if (categoryDetail) {
        console.log(`\n分类ID: ${categoryId}`)
        console.log('名称:', categoryDetail.name)
        console.log('描述:', categoryDetail.description)
        
        // 获取统计数据
        const stats = await VideoService.getCategoryStats(categoryId)
        console.log('视频数量:', stats.videoCount)
        console.log('代表人物数量:', stats.representativeCount)
      }
    } catch (error) {
      console.error(`获取分类 ${categoryId} 详情失败:`, error)
    }
  }
}

// 运行所有示例
async function runAllExamples() {
  console.log('开始运行分类详情API接口示例...\n')
  
  await exampleGetCategoryDetail()
  await exampleGetCategoryDetailWithRepresentatives()
  await exampleGetCategoryRepresentatives()
  await exampleGetCategoryVideos()
  await exampleGetCategoryStats()
  await exampleAllCategories()
  
  console.log('\n=== 所有示例运行完成 ===')
}

// 如果直接运行此文件
if (typeof require !== 'undefined' && require.main === module) {
  runAllExamples().catch(console.error)
}

// 导出示例函数供其他模块使用
export {
  exampleGetCategoryDetail,
  exampleGetCategoryDetailWithRepresentatives,
  exampleGetCategoryRepresentatives,
  exampleGetCategoryVideos,
  exampleGetCategoryStats,
  exampleAllCategories,
  runAllExamples
}