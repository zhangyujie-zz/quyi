-- 分类详情相关数据库代码
-- 独立的文件，包含分类详情相关的所有数据库操作

-- 1. 首先检查并更新categories表结构，添加详情字段
ALTER TABLE categories ADD COLUMN IF NOT EXISTS detailed_description TEXT;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS characteristics TEXT;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS performance_form TEXT;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS popularity VARCHAR(50);
ALTER TABLE categories ADD COLUMN IF NOT EXISTS origin VARCHAR(100);

-- 2. 创建代表人物表
CREATE TABLE IF NOT EXISTS representatives (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    birth_period VARCHAR(50),
    masterpiece VARCHAR(200),
    artistic_achievement TEXT,
    status VARCHAR(20) DEFAULT 'active',
    status_text VARCHAR(50),
    avatar_url TEXT,
    biography TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- 3. 更新categories表数据，添加详细描述
UPDATE categories SET 
    detailed_description = '相声是中国传统喜剧表演艺术，以对话为主要形式，讲究说、学、逗、唱四门功课。起源于北京、天津地区，具有深厚的文化底蕴。',
    characteristics = '语言幽默、包袱迭出、互动性强、节奏明快',
    performance_form = '对口相声、单口相声、群口相声',
    popularity = '国家级',
    origin = '北京、天津'
WHERE name = '相声';

UPDATE categories SET 
    detailed_description = '评书是口头讲述故事的传统艺术形式，演员一人分饰多角，通过语言、表情、动作展现故事情节。',
    characteristics = '故事性强、语言生动、节奏鲜明、人物刻画细腻',
    performance_form = '单人口述、坐姿表演',
    popularity = '国家级',
    origin = '北京、河北'
WHERE name = '评书';

UPDATE categories SET 
    detailed_description = '京剧是中国国粹戏曲艺术，融合唱、念、做、打多种表演形式，具有完整的艺术体系。',
    characteristics = '唱念做打、程式化表演、华丽服饰、虚拟化动作',
    performance_form = '舞台表演、戏曲演唱',
    popularity = '国家级',
    origin = '北京'
WHERE name = '京剧';

-- 4. 插入代表人物数据
INSERT INTO representatives (category_id, name, birth_period, masterpiece, artistic_achievement, status, status_text, biography) VALUES
-- 相声代表人物
(1, '侯宝林', '1917-1993', '《戏剧与方言》', '相声艺术大师，创立"侯派"风格，对传统相声进行现代化改造', 'master', '艺术大师', '侯宝林是中国相声界的泰斗，他不仅继承和发展了传统相声，还开创了新的表演风格。'),
(1, '马三立', '1914-2003', '《买猴》', '相声泰斗，马派相声创始人，以其独特的"冷幽默"风格著称', 'master', '相声泰斗', '马三立的相声风格独特，语言精炼，被誉为"相声界的活化石"。'),
(1, '郭德纲', '1973-', '《我要幸福》', '德云社创始人，现代相声代表人物，复兴传统相声艺术', 'living', '当代大师', '郭德纲创办的德云社推动了相声艺术的现代复兴，培养了大批年轻观众。'),
(1, '姜昆', '1950-', '《如此照相》', '相声表演艺术家，中国曲艺家协会主席', 'living', '艺术家', '姜昆的作品紧跟时代步伐，反映社会现实，深受观众喜爱。'),

-- 评书代表人物
(2, '单田芳', '1934-2018', '《隋唐演义》', '评书表演艺术家，"单氏评书"创始人', 'master', '艺术大师', '单田芳的评书风格独特，语言生动，塑造了众多经典人物形象。'),
(2, '刘兰芳', '1944-', '《岳飞传》', '评书表演艺术家，中国曲艺家协会名誉主席', 'living', '艺术家', '刘兰芳的评书作品家喻户晓，她的《岳飞传》影响了几代人。'),
(2, '袁阔成', '1929-2015', '《三国演义》', '评书表演艺术家，"袁派评书"创始人', 'master', '大师', '袁阔成的《三国演义》被誉为评书艺术的巅峰之作。'),
(2, '田连元', '1941-', '《杨家将》', '评书表演艺术家，现代评书改革者', 'living', '改革家', '田连元在传统评书基础上进行了现代化改革，作品更具时代感。'),

-- 京剧代表人物
(3, '梅兰芳', '1894-1961', '《贵妃醉酒》', '京剧表演艺术家，"梅派"创始人', 'master', '艺术大师', '梅兰芳是中国京剧的代表人物，他的表演艺术达到了极高的境界。'),
(3, '程砚秋', '1904-1958', '《锁麟囊》', '京剧表演艺术家，"程派"创始人', 'master', '大师', '程砚秋的唱腔独特，情感丰富，创造了程派艺术的辉煌。'),
(3, '尚小云', '1900-1976', '《昭君出塞》', '京剧表演艺术家，"尚派"创始人', 'master', '大师', '尚小云的表演风格刚健有力，塑造了许多巾帼英雄形象。'),
(3, '荀慧生', '1900-1968', '《红娘》', '京剧表演艺术家，"荀派"创始人', 'master', '大师', '荀慧生的表演活泼灵动，擅长塑造活泼可爱的少女形象。');

-- 5. 获取分类详情的函数
CREATE OR REPLACE FUNCTION get_category_details(category_id_param BIGINT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'id', c.id,
        'name', c.name,
        'description', c.description,
        'detailed_description', c.detailed_description,
        'origin', c.origin,
        'characteristics', c.characteristics,
        'performance_form', c.performance_form,
        'popularity', c.popularity,
        'created_at', c.created_at,
        'video_count', (SELECT COUNT(*) FROM videos WHERE category_id = c.id),
        'representatives_count', (SELECT COUNT(*) FROM representatives WHERE category_id = c.id),
        'recent_videos', (
            SELECT json_agg(json_build_object(
                'id', v.id,
                'title', v.title,
                'description', v.description,
                'thumbnail_url', v.thumbnail_url,
                'views_count', v.views_count,
                'duration', v.duration
            ))
            FROM videos v
            WHERE v.category_id = c.id
            ORDER BY v.created_at DESC
            LIMIT 6
        )
    )
    INTO result
    FROM categories c
    WHERE c.id = category_id_param;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 2. 获取分类下的代表人物列表
CREATE OR REPLACE FUNCTION get_category_representatives(category_id_param BIGINT)
RETURNS TABLE(
    id BIGINT,
    name VARCHAR,
    birth_period VARCHAR,
    masterpiece VARCHAR,
    artistic_achievement VARCHAR,
    status VARCHAR,
    status_text VARCHAR,
    avatar_url TEXT,
    biography TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        r.birth_period,
        r.masterpiece,
        r.artistic_achievement,
        r.status,
        r.status_text,
        r.avatar_url,
        r.biography
    FROM representatives r
    WHERE r.category_id = category_id_param
    ORDER BY 
        CASE 
            WHEN r.status = 'active' THEN 1
            WHEN r.status = 'inactive' THEN 2
            ELSE 3
        END,
        r.name;
END;
$$ LANGUAGE plpgsql;

-- 3. 获取分类下的视频统计
CREATE OR REPLACE FUNCTION get_category_video_stats(category_id_param BIGINT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_videos', (SELECT COUNT(*) FROM videos WHERE category_id = category_id_param),
        'total_views', (SELECT COALESCE(SUM(views_count), 0) FROM videos WHERE category_id = category_id_param),
        'average_rating', (SELECT COALESCE(AVG(rating), 0) FROM videos WHERE category_id = category_id_param),
        'popular_videos', (
            SELECT json_agg(json_build_object(
                'id', v.id,
                'title', v.title,
                'views_count', v.views_count,
                'likes_count', v.likes_count
            ))
            FROM videos v
            WHERE v.category_id = category_id_param
            ORDER BY v.views_count DESC
            LIMIT 5
        )
    )
    INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 4. 更新分类浏览次数的函数
CREATE OR REPLACE FUNCTION increment_category_views(category_id_param BIGINT)
RETURNS VOID AS $$
BEGIN
    -- 这里可以添加浏览次数字段到categories表，如果需要的话
    -- UPDATE categories SET view_count = COALESCE(view_count, 0) + 1 WHERE id = category_id_param;
    NULL; -- 暂时不实现，如果需要可以添加
END;
$$ LANGUAGE plpgsql;

-- 示例：调用分类详情函数
-- SELECT get_category_details(1);
-- SELECT * FROM get_category_representatives(1);
-- SELECT get_category_video_stats(1);