// 测试Supabase连接
import('node-fetch').then(fetch => {
  const supabaseUrl = 'https://hdayzxlqfggmiseanheq.supabase.co'
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhkYXl6eGxxZmdnbWlzZWFuaGVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1MDc2ODIsImV4cCI6MjA3NzA4MzY4Mn0.eamwYnclJay6PMVj2S1UedZZQ3Wnbzvo7Oj0C5BbKcU'

  async function testConnection() {
    console.log('正在测试Supabase连接...')
    
    try {
      // 测试1: 基础API连接
      console.log('测试1: 基础连接测试')
      const response1 = await fetch(`${supabaseUrl}/rest/v1/`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`
        }
      })
      console.log('基础连接状态:', response1.status, response1.statusText)

      // 测试2: 分类表查询
      console.log('\n测试2: 分类表查询')
      const response2 = await fetch(`${supabaseUrl}/rest/v1/categories?select=*`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      })
      
      console.log('分类查询状态:', response2.status, response2.statusText)
      
      if (response2.ok) {
        const data = await response2.json()
        console.log('分类数据:', JSON.stringify(data, null, 2))
      } else {
        console.log('响应头:', Object.fromEntries(response2.headers.entries()))
        const text = await response2.text()
        console.log('响应内容:', text)
      }

      // 测试3: 数据库表结构检查
      console.log('\n测试3: 数据库表结构')
      const response3 = await fetch(`${supabaseUrl}/rest/v1/`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`
        }
      })
      
      console.log('数据库状态:', response3.status)
      
    } catch (error) {
      console.error('连接错误:', error.message)
      console.error('错误详情:', error)
    }
  }

  testConnection()
}).catch(err => {
  console.error('导入失败:', err)
  
  // 使用原生fetch
  testConnectionWithNativeFetch()
})

async function testConnectionWithNativeFetch() {
  console.log('使用原生fetch测试...')
  
  const supabaseUrl = 'https://hdayzxlqfggmiseanheq.supabase.co'
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhkYXl6eGxxZmdnbWlzZWFuaGVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1MDc2ODIsImV4cCI6MjA3NzA4MzY4Mn0.eamwYnclJay6PMVj2S1UedZZQ3Wnbzvo7Oj0C5BbKcU'

  try {
    const response = await fetch(`${supabaseUrl}/rest/v1/categories?select=*`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Accept': 'application/json'
      }
    })
    
    console.log('HTTP状态码:', response.status)
    console.log('状态文本:', response.statusText)
    
    if (response.ok) {
      const data = await response.json()
      console.log('成功获取数据:', data)
    } else {
      console.log('错误响应:', await response.text())
    }
  } catch (error) {
    console.error('网络错误:', error)
  }
}