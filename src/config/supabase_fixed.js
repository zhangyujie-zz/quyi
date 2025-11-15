import { createClient } from '@supabase/supabase-js'

// 从环境变量获取Supabase配置
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// 检查环境变量是否已配置
if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('Supabase环境变量未配置，请检查.env.local文件')
}

// 创建Supabase客户端 - 使用最简配置
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true
  }
})

// 导出Supabase服务
export default {
  supabase
}