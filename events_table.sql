-- 近期曲艺动态表结构
CREATE TABLE IF NOT EXISTS events (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- 事件类型：开票信息、晚会、比赛等
    event_date DATE NOT NULL,
    location VARCHAR(200) NOT NULL,
    image_url TEXT,
    link_url VARCHAR(500),
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 插入示例近期曲艺动态数据
INSERT INTO events (title, description, event_type, event_date, location, image_url, link_url, is_featured, sort_order) VALUES
('2024年度相声大会开票', '全国著名相声演员齐聚一堂，带来精彩纷呈的相声表演', '开票信息', '2024-03-15', '北京国家大剧院', 'https://images.unsplash.com/photo-1517330323742-98449c5d72f5?w=400&h=300&fit=crop', '/events/1', true, 1),

('传统戏曲艺术节晚会', '汇集各地传统戏曲精华，展现中华文化魅力', '晚会', '2024-03-20', '上海大剧院', 'https://images.unsplash.com/photo-1573164713714-d95e436ab8d6?w=400&h=300&fit=crop', '/events/2', true, 2),

('全国青年评书大赛决赛', '青年评书演员竞技，发掘新一代评书人才', '比赛', '2024-04-10', '天津曲艺中心', 'https://images.unsplash.com/photo-1516900448138-898720e93639?w=400&h=300&fit=crop', '/events/3', true, 3),

('京剧经典剧目展演', '传统京剧经典剧目重现舞台，感受国粹魅力', '演出', '2024-04-15', '北京梅兰芳大剧院', 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=400&h=300&fit=crop', '/events/4', false, 4),

('地方戏曲巡演开票', '豫剧、黄梅戏、越剧等地方戏曲全国巡演', '开票信息', '2024-04-20', '全国主要城市', 'https://images.unsplash.com/photo-1573246123716-6b1784bf5f83?w=400&h=300&fit=crop', '/events/5', true, 5),

('快板艺术年度颁奖典礼', '表彰在快板艺术领域做出突出贡献的艺术家', '晚会', '2024-05-05', '山东济南', 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=300&fit=crop', '/events/6', false, 6)
ON CONFLICT DO NOTHING;

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_events_event_date ON events(event_date DESC);
CREATE INDEX IF NOT EXISTS idx_events_event_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_is_featured ON events(is_featured);
CREATE INDEX IF NOT EXISTS idx_events_sort_order ON events(sort_order);

-- 启用行级安全策略
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "允许任何人读取事件" ON events FOR SELECT USING (true);

-- 创建近期事件视图
CREATE OR REPLACE VIEW recent_events AS
SELECT 
    id,
    title,
    description,
    event_type,
    event_date,
    location,
    image_url,
    link_url,
    is_featured,
    sort_order
FROM events
WHERE event_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY event_date DESC, sort_order ASC
LIMIT 6;