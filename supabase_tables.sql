-- Supabase数据库表结构脚本
-- 用于创建曲艺展示网站所需的表（视频相关）

-- 曲艺分类表
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    -- 分类详情字段
    detailed_description TEXT, -- 详细描述
    representatives TEXT, -- 代表人物，多个用逗号分隔
    origin VARCHAR(200), -- 起源地
    characteristics TEXT, -- 特点
    performance_form TEXT, -- 表演形式
    popularity VARCHAR(50), -- 流行程度（国家级、省级、地方级等）
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 视频表
CREATE TABLE IF NOT EXISTS videos (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category_id BIGINT REFERENCES categories(id),
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    duration INTEGER NOT NULL, -- 视频时长（秒）
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    performer VARCHAR(100), -- 表演者
    performance_date DATE, -- 表演日期
    quality VARCHAR(20) DEFAULT 'HD', -- 视频质量
    tags TEXT[], -- 标签数组
    is_featured BOOLEAN DEFAULT FALSE, -- 是否推荐
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 用户表（用于收藏和观看历史）
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    username VARCHAR(100),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- 用户收藏表
CREATE TABLE IF NOT EXISTS user_favorites (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    video_id BIGINT REFERENCES videos(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, video_id)
);

-- 用户观看历史表
CREATE TABLE IF NOT EXISTS user_watch_history (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    video_id BIGINT REFERENCES videos(id) ON DELETE CASCADE,
    watch_duration INTEGER DEFAULT 0, -- 观看时长（秒）
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 评论表
CREATE TABLE IF NOT EXISTS comments (
    id BIGSERIAL PRIMARY KEY,
    video_id BIGINT REFERENCES videos(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_id BIGINT REFERENCES comments(id) ON DELETE CASCADE, -- 回复的评论ID
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 轮播图表
CREATE TABLE IF NOT EXISTS carousel_slides (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    link_url VARCHAR(500),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 搜索关键词记录表
CREATE TABLE IF NOT EXISTS search_keywords (
    id BIGSERIAL PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL,
    search_count INTEGER DEFAULT 1,
    last_searched TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(keyword)
);

-- 插入示例分类数据
INSERT INTO categories (name, description, icon, sort_order, detailed_description, representatives, origin, characteristics, performance_form, popularity) VALUES
('相声', '传统相声艺术表演', 'microphone', 1, '相声是中国传统的一种喜剧表演形式，主要通过对话、笑话和幽默来娱乐观众。相声通常由两人合作表演，一捧一逗，讲究语言的艺术性和幽默感。', '郭德纲、于谦、马三立、侯宝林', '北京、天津', '语言幽默、包袱迭出、互动性强', '对口相声、单口相声、群口相声', '国家级'),
('评书', '评书讲述艺术', 'book-open', 2, '评书是一种传统的口头文学表演形式，讲述者通过生动的声音和肢体语言讲述历史故事、神话传说等。评书艺术强调语言的节奏感和感染力。', '单田芳、刘兰芳、袁阔成、田连元', '北京、河北', '故事性强、语言生动、节奏鲜明', '单人口述、坐姿表演', '国家级'),
('京剧', '中国传统戏曲艺术', 'mask', 3, '京剧是中国最具代表性的戏曲艺术形式之一，融合了唱、念、做、打等多种表演元素。京剧以其独特的化妆、服装和表演程式而闻名。', '梅兰芳、程砚秋、尚小云、荀慧生', '北京', '唱念做打、程式化表演、华丽服饰', '舞台表演、戏曲演唱', '国家级'),
('豫剧', '河南地方戏曲', 'landmark', 4, '豫剧是河南地区的主要地方戏曲剧种，以其高亢激昂的唱腔和贴近生活的表演风格而著称，深受中原地区群众喜爱。', '常香玉、马金凤、崔兰田、阎立品', '河南', '唱腔高亢、表演朴实、贴近生活', '地方戏曲表演', '省级'),
('快板', '快板表演艺术', 'music', 5, '快板是一种节奏明快的表演艺术，表演者使用竹板击打出节奏，配合说唱表演。快板艺术节奏感强，富有韵律美。', '李润杰、高凤山、张志宽', '华北地区', '节奏明快、韵律感强、语言精炼', '竹板伴奏、说唱表演', '省级'),
('山东快书', '山东地方曲艺', 'theater-masks', 6, '山东快书是山东地区特有的曲艺形式，以山东方言表演，内容多为民间故事和英雄传说，具有浓厚的地方特色。', '高元钧、杨立德、刘司昌', '山东', '方言特色、豪放粗犷、故事性强', '铜板伴奏、方言说唱', '省级'),
('昆曲', '昆曲艺术表演', 'drama-masks', 7, '昆曲是中国最古老的戏曲剧种之一，以其优雅的唱腔、细腻的表演和精美的文学性而著称，被誉为“百戏之祖”。', '俞振飞、韩世昌、白云生', '江苏昆山', '唱腔优雅、表演细腻、文学性强', '传统戏曲表演', '国家级'),
('二人转', '东北二人转艺术', 'users', 8, '二人转是东北地区流行的民间艺术形式，通常由一男一女两人表演，融合了说唱、舞蹈和小品等多种艺术元素。', '赵本山、小沈阳、宋小宝', '东北三省', '幽默风趣、互动性强、贴近生活', '二人对唱、舞蹈表演', '省级')
ON CONFLICT (name) DO UPDATE SET 
    detailed_description = EXCLUDED.detailed_description,
    representatives = EXCLUDED.representatives,
    origin = EXCLUDED.origin,
    characteristics = EXCLUDED.characteristics,
    performance_form = EXCLUDED.performance_form,
    popularity = EXCLUDED.popularity;

-- 插入示例轮播图数据
INSERT INTO carousel_slides (title, description, image_url, link_url, sort_order) VALUES
('传统相声艺术', '品味经典相声，感受语言艺术的魅力', '/resource/image/首页相声.png', '/videos?category=1', 1),
('精彩评书表演', '聆听历史故事，沉浸于评书的艺术世界', '/resource/image/首页评书.jpg', '/videos?category=2', 2),
('京剧国粹经典', '欣赏国粹艺术，传承中华文化精髓', '/resource/image/首页京剧.jpg', '/videos?category=3', 3),
('地方戏曲荟萃', '探索各地特色戏曲，体验多元文化魅力', '/resource/image/首页地方戏曲.jpg', '/videos', 4)
ON CONFLICT DO NOTHING;

-- 插入示例轮播图数据
INSERT INTO carousel_slides (title, description, image_url, link_url, sort_order) VALUES
('传统相声艺术', '品味经典相声，感受语言艺术的魅力', '/resource/image/首页相声.png', '/videos?category=1', 1),
('精彩评书表演', '聆听历史故事，沉浸于评书的艺术世界', '/resource/image/首页评书.jpg', '/videos?category=2', 2),
('京剧国粹经典', '欣赏国粹艺术，传承中华文化精髓', '/resource/image/首页京剧.jpg', '/videos?category=3', 3),
('地方戏曲荟萃', '探索各地特色戏曲，体验多元文化魅力', '/resource/image/首页地方戏曲.jpg', '/videos', 4)
ON CONFLICT DO NOTHING;

-- 插入示例视频数据（占位数据）
INSERT INTO videos (title, description, category_id, video_url, thumbnail_url, duration, performer, quality, tags, is_featured) VALUES
('经典相声：对口相声表演', '传统相声的精彩表演，展现相声艺术的魅力', 1, '/videos/xiangsheng-1.mp4', '/thumbnails/xiangsheng-1.jpg', 1800, '郭德纲、于谦', 'HD', '{"相声","传统","幽默"}', true),

('评书：三国演义选段', '评书艺术家讲述三国演义精彩片段', 2, '/videos/pingshu-1.mp4', '/thumbnails/pingshu-1.jpg', 2400, '单田芳', 'HD', '{"评书","三国","历史"}', true),

('京剧：霸王别姬', '经典京剧霸王别姬选段', 3, '/videos/jingju-1.mp4', '/thumbnails/jingju-1.jpg', 1500, '梅兰芳', 'HD', '{"京剧","经典","戏曲"}', false),

('豫剧：穆桂英挂帅', '豫剧经典剧目穆桂英挂帅选段', 4, '/videos/yuju-1.mp4', '/thumbnails/yuju-1.jpg', 2700, '常香玉', 'HD', '{"豫剧","传统","经典"}', true),

('快板艺术表演', '快板艺术的精彩表演展示', 5, '/videos/kuaiban-1.mp4', '/thumbnails/kuaiban-1.jpg', 1200, '李金斗', 'HD', '{"快板","节奏","表演"}', false),

('山东快书：武松打虎', '山东快书经典段子武松打虎', 6, '/videos/shandong-1.mp4', '/thumbnails/shandong-1.jpg', 900, '孙镇业', 'HD', '{"山东快书","经典","武术"}', true)
ON CONFLICT DO NOTHING;

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_videos_category_id ON videos(category_id);
CREATE INDEX IF NOT EXISTS idx_videos_is_featured ON videos(is_featured);
CREATE INDEX IF NOT EXISTS idx_videos_created_at ON videos(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_videos_views_count ON videos(views_count DESC);
CREATE INDEX IF NOT EXISTS idx_videos_tags ON videos USING gin(tags);

CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_video_id ON user_favorites(video_id);

CREATE INDEX IF NOT EXISTS idx_user_watch_history_user_id ON user_watch_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_watch_history_video_id ON user_watch_history(video_id);

CREATE INDEX IF NOT EXISTS idx_comments_video_id ON comments(video_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);

-- 轮播图表索引
CREATE INDEX IF NOT EXISTS idx_carousel_slides_sort_order ON carousel_slides(sort_order);
CREATE INDEX IF NOT EXISTS idx_carousel_slides_is_active ON carousel_slides(is_active);

-- 启用行级安全策略
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_watch_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_keywords ENABLE ROW LEVEL SECURITY;

-- 创建策略（允许匿名用户读取）
CREATE POLICY "允许任何人读取分类" ON categories FOR SELECT USING (true);
CREATE POLICY "允许任何人读取视频" ON videos FOR SELECT USING (true);
CREATE POLICY "允许任何人读取评论" ON comments FOR SELECT USING (true);
CREATE POLICY "允许任何人读取轮播图" ON carousel_slides FOR SELECT USING (true);
CREATE POLICY "允许任何人记录搜索关键词" ON search_keywords FOR INSERT WITH CHECK (true);
CREATE POLICY "允许任何人更新搜索关键词" ON search_keywords FOR UPDATE USING (true);

-- 用户相关策略（需要登录）
CREATE POLICY "用户只能操作自己的数据" ON users FOR ALL USING (auth.uid() = id);
CREATE POLICY "用户只能操作自己的收藏" ON user_favorites FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "用户只能操作自己的观看历史" ON user_watch_history FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "用户只能操作自己的评论" ON comments FOR ALL USING (auth.uid() = user_id);

-- 创建视图：视频详情视图
CREATE OR REPLACE VIEW video_details AS
SELECT 
    v.*,
    c.name as category_name,
    c.description as category_description,
    COUNT(DISTINCT uf.id) as favorite_count,
    AVG(wh.watch_duration) as avg_watch_duration
FROM videos v
LEFT JOIN categories c ON v.category_id = c.id
LEFT JOIN user_favorites uf ON v.id = uf.video_id
LEFT JOIN user_watch_history wh ON v.id = wh.video_id
GROUP BY v.id, c.id;

-- 插入代表人物数据
INSERT INTO representatives (category_id, name, birth_period, masterpiece, artistic_achievement, status, status_text, avatar_url, biography) VALUES
-- 相声代表人物
(1, '郭德纲', '1973-', '《我要幸福》', '德云社创始人，现代相声代表人物', 'active', '当代大师', '/avatars/guodegang.jpg', '郭德纲，1973年生于天津，中国相声演员、德云社创始人。他以其独特的表演风格和幽默感，将相声艺术推向了新的高度。'),
(1, '于谦', '1969-', '《我是黑社会》', '德云社搭档，相声表演艺术家', 'active', '艺术家', '/avatars/yuqian.jpg', '于谦，1969年生于北京，中国相声演员，与郭德纲搭档多年，表演风格沉稳幽默。'),
(1, '马三立', '1914-2003', '《买猴》', '相声泰斗，马派相声创始人', 'inactive', '泰斗', '/avatars/masanli.jpg', '马三立，1914-2003，相声表演艺术家，被誉为相声泰斗，创立了独特的马派相声风格。'),
(1, '侯宝林', '1917-1993', '《戏剧与方言》', '相声艺术大师，创立"侯派"风格', 'inactive', '大师', '/avatars/houbaolin.jpg', '侯宝林，1917-1993，相声表演艺术家，对相声艺术的发展作出了重要贡献。'),

-- 评书代表人物
(2, '单田芳', '1934-2018', '《隋唐演义》', '评书表演艺术家，"单氏评书"创始人', 'inactive', '艺术大师', '/avatars/shandianfang.jpg', '单田芳，1934-2018，评书表演艺术家，以其独特的嗓音和讲述风格闻名。'),
(2, '刘兰芳', '1944-', '《岳飞传》', '评书表演艺术家，中国曲艺家协会名誉主席', 'active', '艺术家', '/avatars/liulanfang.jpg', '刘兰芳，1944年生于辽宁，评书表演艺术家，以其精彩的《岳飞传》而闻名。'),
(2, '袁阔成', '1929-2015', '《三国演义》', '评书表演艺术家，"袁派评书"创始人', 'inactive', '大师', '/avatars/yuankuocheng.jpg', '袁阔成，1929-2015，评书表演艺术家，对《三国演义》的评书演绎尤为经典。'),
(2, '田连元', '1941-', '《杨家将》', '评书表演艺术家，现代评书改革者', 'active', '改革家', '/avatars/tianlianyuan.jpg', '田连元，1941年生于河北，评书表演艺术家，致力于评书艺术的改革创新。'),

-- 京剧代表人物
(3, '梅兰芳', '1894-1961', '《贵妃醉酒》', '京剧表演艺术家，"梅派"创始人', 'inactive', '艺术大师', '/avatars/meilanfang.jpg', '梅兰芳，1894-1961，京剧表演艺术家，被誉为"四大名旦"之首，创立了梅派艺术。'),
(3, '程砚秋', '1904-1958', '《锁麟囊》', '京剧表演艺术家，"程派"创始人', 'inactive', '大师', '/avatars/chengyanqiu.jpg', '程砚秋，1904-1958，京剧表演艺术家，创立了程派艺术，以其独特的唱腔闻名。'),
(3, '尚小云', '1900-1976', '《昭君出塞》', '京剧表演艺术家，"尚派"创始人', 'inactive', '大师', '/avatars/shangxiaoyun.jpg', '尚小云，1900-1976，京剧表演艺术家，创立了尚派艺术，表演风格独特。'),
(3, '荀慧生', '1900-1968', '《红娘》', '京剧表演艺术家，"荀派"创始人', 'inactive', '大师', '/avatars/xunhuisheng.jpg', '荀慧生，1900-1968，京剧表演艺术家，创立了荀派艺术，对京剧旦角艺术有重要影响。'),

-- 豫剧代表人物
(4, '常香玉', '1923-2004', '《花木兰》', '豫剧表演艺术家，"常派"创始人', 'inactive', '大师', '/avatars/changxiangyu.jpg', '常香玉，1923-2004，豫剧表演艺术家，以其精彩的《花木兰》而闻名。'),
(4, '马金凤', '1922-', '《穆桂英挂帅》', '豫剧表演艺术家，"马派"创始人', 'active', '艺术家', '/avatars/majinfeng.jpg', '马金凤，1922年生于河南，豫剧表演艺术家，以其独特的表演风格闻名。'),
(4, '崔兰田', '1924-2003', '《秦香莲》', '豫剧表演艺术家，"崔派"创始人', 'inactive', '大师', '/avatars/cuiliantian.jpg', '崔兰田，1924-2003，豫剧表演艺术家，对豫剧艺术的发展作出了重要贡献。'),
(4, '阎立品', '1920-2004', '《秦雪梅》', '豫剧表演艺术家，"阎派"创始人', 'inactive', '大师', '/avatars/yanlipin.jpg', '阎立品，1920-2004，豫剧表演艺术家，创立了独特的阎派表演风格。'),

-- 快板代表人物
(5, '李润杰', '1917-1990', '《劫刑车》', '快板艺术大师，快板艺术改革者', 'inactive', '大师', '/avatars/lirunjie.jpg', '李润杰，1917-1990，快板表演艺术家，对快板艺术的发展作出了重要贡献。'),
(5, '高凤山', '1921-1993', '《同仁堂》', '快板表演艺术家，快板艺术传承者', 'inactive', '艺术家', '/avatars/gaofengshan.jpg', '高凤山，1921-1993，快板表演艺术家，致力于快板艺术的传承与发展。'),
(5, '张志宽', '1941-', '《奇袭白虎团》', '快板表演艺术家，现代快板代表人物', 'active', '艺术家', '/avatars/zhangzhikuan.jpg', '张志宽，1941年生于天津，快板表演艺术家，以其独特的表演风格闻名。'),

-- 山东快书代表人物
(6, '高元钧', '1916-1993', '《武松打虎》', '山东快书艺术大师，"高派"创始人', 'inactive', '大师', '/avatars/gaoyuanjun.jpg', '高元钧，1916-1993，山东快书表演艺术家，对山东快书艺术的发展作出了重要贡献。'),
(6, '杨立德', '1923-2018', '《鲁达除霸》', '山东快书表演艺术家，艺术传承者', 'inactive', '艺术家', '/avatars/yanglide.jpg', '杨立德，1923-2018，山东快书表演艺术家，致力于山东快书艺术的传承。'),
(6, '刘司昌', '1937-', '《大实话》', '山东快书表演艺术家，现代创新者', 'active', '艺术家', '/avatars/liusichang.jpg', '刘司昌，1937年生于山东，山东快书表演艺术家，对山东快书艺术进行了创新。'),

-- 昆曲代表人物
(7, '俞振飞', '1902-1993', '《牡丹亭》', '昆曲表演艺术家，"俞派"创始人', 'inactive', '大师', '/avatars/yuzhenfei.jpg', '俞振飞，1902-1993，昆曲表演艺术家，对昆曲艺术的传承与发展作出了重要贡献。'),
(7, '韩世昌', '1898-1977', '《长生殿》', '昆曲表演艺术家，昆曲艺术传承者', 'inactive', '艺术家', '/avatars/hanshichang.jpg', '韩世昌，1898-1977，昆曲表演艺术家，致力于昆曲艺术的传承。'),
(7, '白云生', '1902-1972', '《玉簪记》', '昆曲表演艺术家，昆曲艺术改革者', 'inactive', '艺术家', '/avatars/baiyunsheng.jpg', '白云生，1902-1972，昆曲表演艺术家，对昆曲艺术进行了重要改革。'),

-- 二人转代表人物
(8, '赵本山', '1957-', '《相亲》', '二人转表演艺术家，本山传媒创始人', 'active', '艺术大师', '/avatars/zhaobenshan.jpg', '赵本山，1957年生于辽宁，二人转表演艺术家，以其独特的表演风格和幽默感闻名。'),
(8, '小沈阳', '1981-', '《不差钱》', '二人转表演艺术家，赵本山弟子', 'active', '艺术家', '/avatars/xiaoshenyang.jpg', '小沈阳，1981年生于辽宁，二人转表演艺术家，以其精彩的表演深受观众喜爱。'),
(8, '宋小宝', '1981-', '《相亲》', '二人转表演艺术家，喜剧演员', 'active', '艺术家', '/avatars/songxiaobao.jpg', '宋小宝，1981年生于吉林，二人转表演艺术家，以其独特的喜剧风格闻名。')
ON CONFLICT DO NOTHING;

-- 为代表人物表创建索引
CREATE INDEX IF NOT EXISTS idx_representatives_category_id ON representatives(category_id);
CREATE INDEX IF NOT EXISTS idx_representatives_status ON representatives(status);

-- 启用代表人物表的行级安全策略
ALTER TABLE representatives ENABLE ROW LEVEL SECURITY;
CREATE POLICY "允许任何人读取代表人物" ON representatives FOR SELECT USING (true);

-- 创建函数：增加视频观看次数
CREATE OR REPLACE FUNCTION increment_video_views(video_id_param BIGINT)
RETURNS VOID AS $$
BEGIN
    UPDATE videos 
    SET views_count = views_count + 1 
    WHERE id = video_id_param;
END;
$$ LANGUAGE plpgsql;

-- 创建函数：搜索视频
CREATE OR REPLACE FUNCTION search_videos(search_query TEXT)
RETURNS TABLE(
    id BIGINT,
    title VARCHAR,
    description TEXT,
    category_name VARCHAR,
    relevance REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id,
        v.title,
        v.description,
        c.name as category_name,
        ts_rank(
            to_tsvector('chinese', v.title || ' ' || v.description || ' ' || array_to_string(v.tags, ' ')),
            to_tsquery('chinese', search_query)
        ) as relevance
    FROM videos v
    LEFT JOIN categories c ON v.category_id = c.id
    WHERE to_tsvector('chinese', v.title || ' ' || v.description || ' ' || array_to_string(v.tags, ' ')) 
          @@ to_tsquery('chinese', search_query)
    ORDER BY relevance DESC, v.created_at DESC;
END;
$$ LANGUAGE plpgsql;