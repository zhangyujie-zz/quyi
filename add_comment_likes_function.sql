-- 创建一个函数来增加评论点赞数
CREATE OR REPLACE FUNCTION increment_comment_likes(comment_id BIGINT)
RETURNS INTEGER AS $$
DECLARE
    new_likes_count INTEGER;
BEGIN
    -- 增加评论的点赞数
    UPDATE comments 
    SET likes_count = COALESCE(likes_count, 0) + 1,
        updated_at = NOW()
    WHERE id = comment_id
    RETURNING likes_count INTO new_likes_count;
    
    RETURN new_likes_count;
END;
$$ LANGUAGE plpgsql;

-- 为点赞功能创建一个触发器来确保 likes_count 不为负数
CREATE OR REPLACE FUNCTION prevent_negative_likes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.likes_count < 0 THEN
        NEW.likes_count = 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
DROP TRIGGER IF EXISTS check_likes_trigger ON comments;
CREATE TRIGGER check_likes_trigger
    BEFORE UPDATE ON comments
    FOR EACH ROW
    EXECUTE FUNCTION prevent_negative_likes();