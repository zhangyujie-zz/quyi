-- 为视频表添加封面图片字段
-- 执行这个脚本来支持视频封面图片显示

-- 添加封面图片URL字段
ALTER TABLE videos 
ADD COLUMN thumbnail_url TEXT;

-- 添加注释说明
COMMENT ON COLUMN videos.thumbnail_url IS '视频封面图片URL';

-- 可选：为现有视频设置默认封面图片
UPDATE videos 
SET thumbnail_url = '/resource/image/首页相声.png' 
WHERE category_id = 1 AND thumbnail_url IS NULL;

UPDATE videos 
SET thumbnail_url = '/resource/image/首页评书.jpg' 
WHERE category_id = 2 AND thumbnail_url IS NULL;

UPDATE videos 
SET thumbnail_url = '/resource/image/首页京剧.jpg' 
WHERE category_id = 3 AND thumbnail_url IS NULL;

-- 可选：添加索引提高查询性能
CREATE INDEX idx_videos_thumbnail_url ON videos(thumbnail_url);

-- 验证修改
SELECT 
    id, 
    title, 
    category_id, 
    thumbnail_url,
    created_at
FROM videos 
ORDER BY id;