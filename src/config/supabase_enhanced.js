import { createClient } from '@supabase/supabase-js'

// 从环境变量获取Supabase配置
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// 检查环境变量是否已配置
if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('Supabase环境变量未配置，请检查.env.local文件')
}

// 针对Chrome浏览器的增强配置
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
    storage: typeof window !== 'undefined' ? window.localStorage : undefined
  },
  global: {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cache-Control': 'no-cache'
    }
  }
})

// 增强的连接测试函数
export const testConnectionWithRetry = async (maxRetries = 3) => {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`🔄 连接测试尝试 ${attempt}/${maxRetries}`)
      
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .limit(1)
      
      if (error) {
        console.error(`❌ 尝试 ${attempt} 失败:`, error)
        if (attempt === maxRetries) throw error
        
        // 等待一段时间后重试
        await new Promise(resolve => setTimeout(resolve, 1000 * attempt))
        continue
      }
      
      console.log('✅ 连接测试成功!')
      return { success: true, data }
      
    } catch (error) {
      console.error(`❌ 连接测试失败:`, error)
      if (attempt === maxRetries) {
        return { success: false, error }
      }
      
      await new Promise(resolve => setTimeout(resolve, 1000 * attempt))
    }
  }
}

// 浏览器兼容性检测
export const checkBrowserCompatibility = () => {
  const ua = navigator.userAgent
  const isChrome = /chrome|chromium/i.test(ua)
  const isEdge = /edg/i.test(ua)
  
  console.log('🌐 浏览器信息:', {
    userAgent: ua,
    isChrome,
    isEdge,
    supportsFetch: 'fetch' in window,
    supportsCrypto: 'crypto' in window
  })
  
  return { isChrome, isEdge }
}

// 清除浏览器缓存和存储
export const clearBrowserCache = () => {
  try {
    // 清除localStorage中的Supabase相关数据
    const keys = Object.keys(localStorage).filter(key => 
      key.includes('supabase') || key.includes('sb-')
    )
    
    keys.forEach(key => {
      localStorage.removeItem(key)
      console.log(`🗑️ 已清除缓存: ${key}`)
    })
    
    // 清除sessionStorage
    sessionStorage.clear()
    
    // 清除cookie
    document.cookie.split(';').forEach(cookie => {
      const eqPos = cookie.indexOf('=')
      const name = eqPos > -1 ? cookie.substr(0, eqPos).trim() : cookie.trim()
      if (name.includes('supabase')) {
        document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`
      }
    })
    
    console.log('✅ 浏览器缓存已清除')
    return true
  } catch (error) {
    console.error('❌ 清除缓存失败:', error)
    return false
  }
}

// 导出Supabase服务
export default {
  supabase,
  testConnectionWithRetry,
  checkBrowserCompatibility,
  clearBrowserCache
}