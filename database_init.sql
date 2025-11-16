-- 曲艺学习系统 - 数据库初始化脚本
-- 包含分类详情表结构和示例数据

-- 1. 首先创建详细的分类表（如果已有，则添加缺失字段）
-- 检查并添加categories表缺少的字段
DO $$ 
BEGIN
    -- 检查是否存在categories表
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
        CREATE TABLE categories (
            id BIGSERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            detailed_description TEXT,
            characteristics TEXT,
            performance_form TEXT,
            popularity VARCHAR(50),
            origin VARCHAR(100),
            image_url TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        );
    ELSE
        -- 如果表已存在，添加缺失的字段和约束
        ALTER TABLE categories ADD COLUMN IF NOT EXISTS detailed_description TEXT;
        ALTER TABLE categories ADD COLUMN IF NOT EXISTS characteristics TEXT;
        ALTER TABLE categories ADD COLUMN IF NOT EXISTS performance_form TEXT;
        ALTER TABLE categories ADD COLUMN IF NOT EXISTS popularity VARCHAR(50);
        ALTER TABLE categories ADD COLUMN IF NOT EXISTS origin VARCHAR(100);
        ALTER TABLE categories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
        
        -- 确保name字段有唯一约束
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE table_name = 'categories' AND constraint_type = 'UNIQUE'
        ) THEN
            ALTER TABLE categories ADD CONSTRAINT categories_name_key UNIQUE (name);
        END IF;
    END IF;
END $$;

-- 2. 创建代表人物表
CREATE TABLE IF NOT EXISTS representatives (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    birth_period VARCHAR(50),
    masterpiece VARCHAR(200),
    artistic_achievement TEXT,
    status VARCHAR(20) DEFAULT 'master',
    status_text VARCHAR(50),
    avatar_url TEXT,
    biography TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE (name, category_id)
);

-- 3. 插入示例分类数据
INSERT INTO categories (name, description, detailed_description, characteristics, performance_form, popularity, origin) VALUES
('相声', '中国传统喜剧表演艺术形式', '相声是中国传统喜剧表演艺术，以对话为主要形式，讲究说、学、逗、唱四门功课。起源于北京、天津地区，具有深厚的文化底蕴。相声艺术在长期发展中形成了多种流派和表演风格，是中国曲艺的重要组成部分。', '语言幽默、包袱迭出、互动性强、节奏明快、贴近生活', '对口相声、单口相声、群口相声', '国家级', '北京、天津'),
('评书', '口头讲述故事的传统艺术', '评书是口头讲述故事的传统艺术形式，演员一人分饰多角，通过语言、表情、动作展现故事情节。评书艺术具有悠久的历史，从古代说书人发展而来，是中国传统文化的重要载体。', '故事性强、语言生动、节奏鲜明、人物刻画细腻、情节引人入胜', '单人口述、坐姿表演', '国家级', '北京、河北'),
('京剧', '中国国粹戏曲艺术', '京剧是中国国粹戏曲艺术，融合唱、念、做、打多种表演形式，具有完整的艺术体系。京剧艺术博大精深，角色行当分明，音乐体系完整，是中国传统文化的瑰宝。', '唱念做打、程式化表演、华丽服饰、虚拟化动作、讲究身段', '舞台表演、戏曲演唱', '国家级', '北京'),
('豫剧', '河南地方戏曲代表', '豫剧是河南省的地方戏曲剧种，以中州音韵为演唱语言，具有浓郁的地方特色。豫剧唱腔高亢激昂，表演真实生动，深受中原地区群众喜爱。', '唱腔高亢、表演真实、地方特色浓郁、情感真挚', '戏曲舞台表演', '省级', '河南'),
('快板', '节奏明快的说唱艺术', '快板是一种节奏明快的说唱艺术形式，以竹板击节伴奏，语言诙谐幽默。快板艺术形式灵活，内容通俗易懂，具有广泛的群众基础。', '节奏明快、语言诙谐、形式灵活、通俗易懂', '说唱表演、竹板伴奏', '省级', '北京、天津'),
('山东快书', '山东地区的说唱艺术', '山东快书是流行于山东地区的说唱艺术，以山东方言表演，节奏明快，语言生动。山东快书具有浓厚的地方特色，反映了山东人民的生活和情感。', '方言特色、节奏明快、语言生动、地方韵味', '说唱表演、铜板伴奏', '省级', '山东'),
('昆曲', '中国最古老的戏曲形式', '昆曲是中国最古老的戏曲剧种之一，被誉为"百戏之祖"。昆曲唱腔婉转悠扬，表演细腻典雅，具有很高的艺术价值。', '唱腔婉转、表演细腻、典雅优美、艺术性强', '戏曲舞台表演', '国家级', '江苏、浙江'),
('二人转', '东北地区的民间艺术', '二人转是流行于东北地区的民间艺术形式，以二人对唱为主，表演活泼风趣。二人转艺术贴近生活，反映了东北人民的豪爽性格。', '表演活泼、风趣幽默、贴近生活、互动性强', '二人对唱、民间表演', '省级', '东北地区')
ON CONFLICT (name) DO UPDATE SET 
    detailed_description = EXCLUDED.detailed_description,
    characteristics = EXCLUDED.characteristics,
    performance_form = EXCLUDED.performance_form,
    popularity = EXCLUDED.popularity,
    origin = EXCLUDED.origin,
    updated_at = NOW();

-- 4. 插入代表人物数据
INSERT INTO representatives (category_id, name, birth_period, masterpiece, artistic_achievement, status, status_text, biography) VALUES
-- 相声代表人物
(1, '侯宝林', '1917-1993', '《戏剧与方言》', '相声艺术大师，创立"侯派"风格，对传统相声进行现代化改造', 'master', '艺术大师', '侯宝林是中国相声界的泰斗，他不仅继承和发展了传统相声，还开创了新的表演风格，被誉为"相声界的改革家"。'),
(1, '马三立', '1914-2003', '《买猴》', '相声泰斗，马派相声创始人，以其独特的"冷幽默"风格著称', 'master', '相声泰斗', '马三立的相声风格独特，语言精炼，被誉为"相声界的活化石"，他的作品影响了几代相声演员。'),
(1, '郭德纲', '1973-', '《我要幸福》', '德云社创始人，现代相声代表人物，复兴传统相声艺术', 'living', '当代大师', '郭德纲创办的德云社推动了相声艺术的现代复兴，培养了大批年轻观众，使相声艺术重新焕发活力。'),
(1, '于谦', '1969-', '《我是黑社会》', '德云社搭档，相声表演艺术家，捧哏艺术大师', 'living', '艺术家', '于谦的捧哏艺术炉火纯青，与郭德纲的搭档被誉为"黄金搭档"，在相声界享有盛誉。'),

-- 评书代表人物
(2, '单田芳', '1934-2018', '《隋唐演义》', '评书表演艺术家，"单氏评书"创始人', 'master', '艺术大师', '单田芳的评书风格独特，语言生动，塑造了众多经典人物形象，他的声音陪伴了几代人的成长。'),
(2, '刘兰芳', '1944-', '《岳飞传》', '评书表演艺术家，中国曲艺家协会名誉主席', 'living', '艺术家', '刘兰芳的评书作品家喻户晓，她的《岳飞传》影响了几代人，被誉为"评书女皇"。'),
(2, '袁阔成', '1929-2015', '《三国演义》', '评书表演艺术家，"袁派评书"创始人', 'master', '大师', '袁阔成的《三国演义》被誉为评书艺术的巅峰之作，他的表演艺术达到了炉火纯青的境界。'),
(2, '田连元', '1941-', '《杨家将》', '评书表演艺术家，现代评书改革者', 'living', '改革家', '田连元在传统评书基础上进行了现代化改革，作品更具时代感，深受年轻观众喜爱。'),

-- 京剧代表人物
(3, '梅兰芳', '1894-1961', '《贵妃醉酒》', '京剧表演艺术家，"梅派"创始人', 'master', '艺术大师', '梅兰芳是中国京剧的代表人物，他的表演艺术达到了极高的境界，对京剧艺术的发展做出了巨大贡献。'),
(3, '程砚秋', '1904-1958', '《锁麟囊》', '京剧表演艺术家，"程派"创始人', 'master', '大师', '程砚秋的唱腔独特，情感丰富，创造了程派艺术的辉煌，是京剧旦角艺术的代表人物。'),
(3, '尚小云', '1900-1976', '《昭君出塞》', '京剧表演艺术家，"尚派"创始人', 'master', '大师', '尚小云的表演风格刚健有力，塑造了许多巾帼英雄形象，在京剧武旦艺术上成就卓著。'),
(3, '荀慧生', '1900-1968', '《红娘》', '京剧表演艺术家，"荀派"创始人', 'master', '大师', '荀慧生的表演活泼灵动，擅长塑造活泼可爱的少女形象，创造了独特的荀派艺术风格。'),

-- 豫剧代表人物
(4, '常香玉', '1923-2004', '《花木兰》', '豫剧表演艺术家，常派艺术创始人', 'master', '艺术大师', '常香玉是豫剧艺术的代表人物，她的唱腔高亢激昂，表演真实感人，为豫剧艺术的发展做出了重要贡献。'),
(4, '马金凤', '1922-', '《穆桂英挂帅》', '豫剧表演艺术家，马派艺术创始人', 'living', '艺术家', '马金凤的表演艺术精湛，塑造了众多经典角色，是豫剧艺术的活化石。'),

-- 快板代表人物
(5, '高凤山', '1921-1993', '《学雷锋》', '快板表演艺术家，快板艺术改革者', 'master', '艺术大师', '高凤山对快板艺术进行了现代化改革，使快板艺术更加贴近现代生活，深受群众喜爱。'),
(5, '李润杰', '1917-2007', '《劫刑车》', '快板表演艺术家，快板书创始人', 'master', '大师', '李润杰创立了快板书这一新的艺术形式，丰富了快板艺术的表现力。'),

-- 山东快书代表人物
(6, '高元钧', '1916-1993', '《武松打虎》', '山东快书表演艺术家，高派艺术创始人', 'master', '艺术大师', '高元钧是山东快书的代表人物，他的表演风格独特，语言生动，为山东快书艺术的发展奠定了坚实基础。'),
(6, '孙镇业', '1944-', '《鲁达除霸》', '山东快书表演艺术家，孙派艺术传人', 'living', '艺术家', '孙镇业继承和发展了山东快书艺术，使这一传统艺术形式在新的时代焕发活力。'),

-- 昆曲代表人物
(7, '俞振飞', '1902-1993', '《牡丹亭》', '昆曲表演艺术家，昆曲艺术大师', 'master', '艺术大师', '俞振飞是昆曲艺术的代表人物，他的表演艺术精湛，对昆曲艺术的传承和发展做出了重要贡献。'),
(7, '张继青', '1938-', '《游园惊梦》', '昆曲表演艺术家，昆曲旦角艺术大师', 'living', '艺术家', '张继青的昆曲表演艺术达到了极高的境界，被誉为"昆曲皇后"。'),

-- 二人转代表人物
(8, '赵本山', '1957-', '《相亲》', '二人转表演艺术家，本山传媒创始人', 'living', '艺术大师', '赵本山将二人转艺术推向全国，培养了大批二人转演员，为二人转艺术的发展做出了巨大贡献。'),
(8, '高秀敏', '1959-2005', '《卖拐》', '二人转表演艺术家，小品演员', 'master', '艺术家', '高秀敏的表演真实生动，语言幽默，深受观众喜爱，是二人转艺术的优秀代表。')
ON CONFLICT (name, category_id) DO UPDATE SET 
    birth_period = EXCLUDED.birth_period,
    masterpiece = EXCLUDED.masterpiece,
    artistic_achievement = EXCLUDED.artistic_achievement,
    status = EXCLUDED.status,
    status_text = EXCLUDED.status_text,
    biography = EXCLUDED.biography,
    updated_at = NOW();

-- 5. 创建索引优化查询性能
CREATE INDEX IF NOT EXISTS idx_representatives_category_id ON representatives(category_id);
CREATE INDEX IF NOT EXISTS idx_representatives_status ON representatives(status);
CREATE INDEX IF NOT EXISTS idx_categories_popularity ON categories(popularity);

-- 6. 创建视图方便查询
CREATE OR REPLACE VIEW category_full_details AS
SELECT 
    c.*,
    COUNT(r.id) as representative_count,
    ARRAY_AGG(json_build_object('id', r.id, 'name', r.name, 'birth_period', r.birth_period)) as representative_list
FROM categories c
LEFT JOIN representatives r ON c.id = r.category_id
GROUP BY c.id;

-- 7. 创建存储过程获取分类详情
CREATE OR REPLACE FUNCTION get_category_full_details(category_id BIGINT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'category', row_to_json(c),
        'representatives', (
            SELECT json_agg(row_to_json(r))
            FROM representatives r
            WHERE r.category_id = category_id
            ORDER BY 
                CASE 
                    WHEN r.status = 'living' THEN 1
                    WHEN r.status = 'master' THEN 2
                    ELSE 3
                END,
                r.name
        ),
        'statistics', json_build_object(
            'representative_count', (SELECT COUNT(*) FROM representatives WHERE category_id = category_id),
            'has_modern_artists', EXISTS(SELECT 1 FROM representatives WHERE category_id = category_id AND status = 'living')
        )
    )
    INTO result
    FROM categories c
    WHERE c.id = category_id;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 8. 示例查询语句
COMMENT ON TABLE categories IS '曲艺分类表，包含详细的分类信息';
COMMENT ON TABLE representatives IS '曲艺代表人物表，记录各分类的代表人物信息';

-- 示例：查询分类详情
-- SELECT get_category_full_details(1);
-- SELECT * FROM category_full_details WHERE name = '相声';

-- 完成提示
SELECT '数据库初始化完成！已创建分类详情表和代表人物表，并插入示例数据。' as message;