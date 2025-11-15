// 测试数据库连接
const { supabase } = require('./src/config/supabase.js')

async function testConnection() {
  console.log('正在测试Supabase数据库连接...')
  
  try {
    // 测试分类查询
    const { data: categories, error } = await supabase
      .from('categories')
      .select('*')
      .limit(5)
    
    if (error) {
      console.error('数据库连接失败:', error)
      return false
    }
    
    console.log('✅ 数据库连接成功!')
    console.log(`✅ 找到 ${categories.length} 个分类:`)
    categories.forEach(cat => {
      console.log(`   - ${cat.name} (${cat.description})`)
    })
    
    // 测试视频查询
    const { data: videos } = await supabase
      .from('videos')
      .select('*')
      .limit(5)
    
    console.log(`✅ 找到 ${videos.length} 个视频:`)
    videos.forEach(video => {
      console.log(`   - ${video.title} (${video.performer})`)
    })
    
    return true
  } catch (error) {
    console.error('测试过程中出现错误:', error)
    return false
  }
}

// 运行测试
testConnection().then(success => {
  if (success) {
    console.log('\n🎉 所有测试通过！数据库连接正常。')
  } else {
    console.log('\n❌ 测试失败，请检查配置。')
  }
})