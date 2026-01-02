-- ============================================================
-- 交易配置表扩展验证脚本
-- 使用方法：在MySQL客户端中执行，或使用以下命令：
-- mysql -uroot -p123456 ruoyi-vue-pro < 交易配置表扩展-执行验证.sql
-- ============================================================

-- 使用数据库（请根据实际情况修改数据库名）
USE ruoyi-vue-pro;

-- ============================================================
-- 一、基础验证
-- ============================================================

-- 1.1 检查表是否存在
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CREATE_TIME,
    UPDATE_TIME
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config';

-- 1.2 统计总字段数（应该有60个字段）
SELECT 
    COUNT(*) as total_fields,
    '预期60个字段' as note
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config';

-- ============================================================
-- 二、验证新增字段
-- ============================================================

-- 2.1 检查快递发货启用开关
SELECT 
    '快递发货启用开关' as check_item,
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    COLUMN_COMMENT,
    CASE 
        WHEN COLUMN_NAME = 'delivery_express_enabled' THEN '✅ 字段存在'
        ELSE '❌ 字段不存在'
    END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME = 'delivery_express_enabled';

-- 2.2 检查同城配送字段（应该有18个字段，不包括delivery_same_city_enabled）
SELECT 
    '同城配送字段统计' as check_item,
    COUNT(*) as same_city_field_count,
    '预期18个字段（same_city%开头）' as expected,
    CASE 
        WHEN COUNT(*) = 18 THEN '✅ 字段数量正确'
        WHEN COUNT(*) > 18 THEN '⚠️ 字段数量超出预期'
        ELSE '❌ 字段数量不足'
    END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%';

-- 显示所有同城配送字段详情
SELECT 
    '同城配送字段详情' as check_item,
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%'
ORDER BY ORDINAL_POSITION;

-- 2.3 检查门店自配送字段（应该有15个字段，不包括delivery_store_enabled）
SELECT 
    '门店自配送字段统计' as check_item,
    COUNT(*) as store_field_count,
    '预期15个字段（store%开头）' as expected,
    CASE 
        WHEN COUNT(*) = 15 THEN '✅ 字段数量正确'
        WHEN COUNT(*) > 15 THEN '⚠️ 字段数量超出预期'
        ELSE '❌ 字段数量不足'
    END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%';

-- 显示所有门店自配送字段详情
SELECT 
    '门店自配送字段详情' as check_item,
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%'
ORDER BY ORDINAL_POSITION;

-- ============================================================
-- 三、验证关键字段
-- ============================================================

-- 3.1 检查关键字段是否存在
SELECT 
    '关键字段检查' as check_item,
    COLUMN_NAME,
    CASE 
        WHEN COLUMN_NAME IS NOT NULL THEN '✅ 存在'
        ELSE '❌ 不存在'
    END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME IN (
    'delivery_express_enabled',
    'delivery_same_city_enabled',
    'same_city_charge_mode',
    'same_city_start_price',
    'same_city_delivery_range_description',
    'delivery_store_enabled',
    'store_charge_mode',
    'store_start_price',
    'store_delivery_range_image_url'
)
ORDER BY COLUMN_NAME;

-- ============================================================
-- 四、验证数据完整性
-- ============================================================

-- 4.1 检查配置记录是否存在
SELECT 
    '配置记录检查' as check_item,
    id,
    delivery_express_enabled,
    delivery_same_city_enabled,
    delivery_store_enabled,
    same_city_charge_mode,
    store_charge_mode,
    CASE 
        WHEN id = 1 THEN '✅ 记录存在'
        ELSE '⚠️ 记录ID不是1'
    END as status
FROM trade_config 
WHERE id = 1;

-- 4.2 检查新增字段的默认值
SELECT 
    '默认值检查' as check_item,
    COLUMN_NAME,
    COLUMN_DEFAULT,
    CASE 
        WHEN COLUMN_DEFAULT IS NOT NULL THEN '✅ 有默认值'
        WHEN IS_NULLABLE = 'YES' THEN '⚠️ 允许NULL'
        ELSE '❌ 无默认值且不允许NULL'
    END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND (
    COLUMN_NAME LIKE 'same_city%' 
    OR COLUMN_NAME LIKE 'store%'
    OR COLUMN_NAME = 'delivery_express_enabled'
)
ORDER BY COLUMN_NAME;

-- ============================================================
-- 五、生成验证摘要
-- ============================================================

SELECT 
    '验证摘要' as summary,
    '字段总数' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 60 THEN '✅ 正常' ELSE '⚠️ 字段数异常' END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config'

UNION ALL

SELECT 
    '验证摘要' as summary,
    '同城配送字段数（same_city%开头）' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 18 THEN '✅ 正常' ELSE '⚠️ 字段数异常' END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%'

UNION ALL

SELECT 
    '验证摘要' as summary,
    '门店自配送字段数（store%开头）' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 15 THEN '✅ 正常' ELSE '⚠️ 字段数异常' END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%'

UNION ALL

SELECT 
    '验证摘要' as summary,
    '配置记录数' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 1 THEN '✅ 正常' ELSE '⚠️ 记录数异常' END as status
FROM trade_config 
WHERE id = 1;

-- ============================================================
-- 验证完成！
-- ============================================================
-- 如果以上所有检查都显示 ✅，说明扩展成功
-- 如果有 ⚠️ 或 ❌，请检查并修复
-- ============================================================

