-- 修复 comments 表的行级安全策略
-- 允许匿名用户（未认证用户）插入评论

-- 1. 禁用 RLS 暂时
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;

-- 2. 删除现有的策略（如果存在）
DROP POLICY IF EXISTS "Users can insert their own comments" ON comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON comments;
DROP POLICY IF EXISTS "Users can view all comments" ON comments;

-- 3. 创建新的策略

-- 允许所有人查看评论（包括匿名用户）
CREATE POLICY "Enable read access for all users" ON comments
    FOR SELECT USING (true);

-- 允许已登录用户插入评论
CREATE POLICY "Enable insert for authenticated users" ON comments
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 允许匿名用户插入评论（user_id 为 NULL）
CREATE POLICY "Enable insert for anonymous users" ON comments
    FOR INSERT WITH CHECK (auth.uid() IS NULL AND user_id IS NULL);

-- 允许已登录用户更新自己的评论
CREATE POLICY "Enable update for own comments" ON comments
    FOR UPDATE USING (auth.uid() = user_id);

-- 允许已登录用户删除自己的评论
CREATE POLICY "Enable delete for own comments" ON comments
    FOR DELETE USING (auth.uid() = user_id);

-- 4. 重新启用 RLS
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- 5. 为匿名评论创建一个特殊的函数来处理默认值
CREATE OR REPLACE FUNCTION set_anonymous_comment_id()
RETURNS TRIGGER AS $$
BEGIN
    -- 如果用户未认证，确保 user_id 为 NULL
    IF auth.uid() IS NULL THEN
        NEW.user_id = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建触发器
DROP TRIGGER IF EXISTS set_comment_user_id ON comments;
CREATE TRIGGER set_comment_user_id
    BEFORE INSERT ON comments
    FOR EACH ROW
    EXECUTE FUNCTION set_anonymous_comment_id();