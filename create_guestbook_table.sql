-- 创建留言表
CREATE TABLE public.guestbook (
  id bigserial NOT NULL,
  contact_name varchar(100) NULL,
  contact_info varchar(255) NULL, -- 电话或邮箱
  content text NOT NULL,
  is_public boolean DEFAULT true NULL,
  likes_count integer DEFAULT 0 NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  updated_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT guestbook_pkey PRIMARY KEY (id)
) TABLESPACE pg_default;

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_guestbook_created_at ON public.guestbook USING btree (created_at desc) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_guestbook_is_public ON public.guestbook USING btree (is_public) TABLESPACE pg_default;

-- 启用行级安全策略
ALTER TABLE guestbook ENABLE ROW LEVEL SECURITY;

-- 创建留言表的策略
CREATE POLICY "Enable read access for public guestbook entries" ON guestbook
    FOR SELECT USING (is_public = true);

CREATE POLICY "Enable insert for all users" ON guestbook
    FOR INSERT WITH CHECK (is_public = true);

-- 创建点赞函数
CREATE OR REPLACE FUNCTION increment_guestbook_likes(guestbook_id BIGINT)
RETURNS INTEGER AS $$
DECLARE
    new_likes_count INTEGER;
BEGIN
    UPDATE guestbook 
    SET likes_count = COALESCE(likes_count, 0) + 1,
        updated_at = NOW()
    WHERE id = guestbook_id
    RETURNING likes_count INTO new_likes_count;
    
    RETURN new_likes_count;
END;
$$ LANGUAGE plpgsql;