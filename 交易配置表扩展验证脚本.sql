-- ============================================================
-- 交易配置表扩展验证脚本
-- 执行 ALTER 语句后，运行此脚本验证扩展结果
-- ============================================================

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

-- 1.2 统计总字段数（应该有约70个字段）
SELECT 
    COUNT(*) as total_fields,
    GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) as all_fields
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config';

-- ============================================================
-- 二、验证新增字段
-- ============================================================

-- 2.1 检查快递发货启用开关
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME = 'delivery_express_enabled';

-- 2.2 检查同城配送字段（应该有30个字段）
SELECT 
    COUNT(*) as same_city_field_count,
    GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') as same_city_fields
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%';

-- 显示所有同城配送字段详情
SELECT 
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

-- 2.3 检查门店自配送字段（应该有20个字段）
SELECT 
    COUNT(*) as store_field_count,
    GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') as store_fields
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%';

-- 显示所有门店自配送字段详情
SELECT 
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
-- 三、验证字段类型
-- ============================================================

-- 3.1 检查金额字段类型（应该是 int）
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE '%price' 
AND COLUMN_TYPE != 'int'
ORDER BY COLUMN_NAME;

-- 3.2 检查布尔字段类型（应该是 bit 或 tinyint）
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE '%enabled'
ORDER BY COLUMN_NAME;

-- 3.3 检查距离字段类型（应该是 decimal）
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE '%distance' 
OR COLUMN_NAME LIKE '%range'
ORDER BY COLUMN_NAME;

-- ============================================================
-- 四、验证字段默认值
-- ============================================================

-- 4.1 检查同城配送字段默认值
SELECT 
    COLUMN_NAME,
    COLUMN_DEFAULT,
    CASE 
        WHEN COLUMN_DEFAULT IS NULL THEN '⚠️ 无默认值'
        WHEN COLUMN_DEFAULT = '' THEN '⚠️ 空字符串'
        ELSE '✅ 有默认值'
    END as default_status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%'
ORDER BY COLUMN_NAME;

-- 4.2 检查门店自配送字段默认值
SELECT 
    COLUMN_NAME,
    COLUMN_DEFAULT,
    CASE 
        WHEN COLUMN_DEFAULT IS NULL THEN '⚠️ 无默认值'
        WHEN COLUMN_DEFAULT = '' THEN '⚠️ 空字符串'
        ELSE '✅ 有默认值'
    END as default_status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%'
ORDER BY COLUMN_NAME;

-- ============================================================
-- 五、验证数据完整性
-- ============================================================

-- 5.1 检查配置记录是否存在
SELECT 
    id,
    delivery_express_enabled,
    delivery_same_city_enabled,
    delivery_store_enabled,
    create_time,
    update_time
FROM trade_config 
WHERE id = 1;

-- 5.2 检查新增字段的默认值是否正确应用
SELECT 
    id,
    -- 快递发货
    delivery_express_enabled,
    -- 同城配送
    delivery_same_city_enabled,
    same_city_charge_mode,
    same_city_start_distance,
    same_city_start_price,
    -- 门店自配送
    delivery_store_enabled,
    store_charge_mode,
    store_start_distance,
    store_start_price
FROM trade_config 
WHERE id = 1;

-- ============================================================
-- 六、生成字段清单报告
-- ============================================================

-- 6.1 生成完整的字段清单（按顺序）
SELECT 
    ORDINAL_POSITION as position,
    COLUMN_NAME as field_name,
    COLUMN_TYPE as field_type,
    COLUMN_DEFAULT as default_value,
    IS_NULLABLE as nullable,
    COLUMN_COMMENT as comment
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config'
ORDER BY ORDINAL_POSITION;

-- 6.2 按模块分组统计字段
SELECT 
    CASE 
        WHEN COLUMN_NAME LIKE 'after_sale%' THEN '售后配置'
        WHEN COLUMN_NAME LIKE 'delivery_express%' THEN '快递发货配置'
        WHEN COLUMN_NAME LIKE 'same_city%' OR COLUMN_NAME = 'delivery_same_city_enabled' THEN '同城配送配置'
        WHEN COLUMN_NAME LIKE 'store%' OR COLUMN_NAME = 'delivery_store_enabled' THEN '门店自配送配置'
        WHEN COLUMN_NAME LIKE 'packaging%' THEN '包装费配置'
        WHEN COLUMN_NAME LIKE 'brokerage%' THEN '分销配置'
        WHEN COLUMN_NAME IN ('id', 'creator', 'create_time', 'updater', 'update_time', 'deleted', 'tenant_id') THEN '通用字段'
        ELSE '其他'
    END as module,
    COUNT(*) as field_count,
    GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') as fields
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config'
GROUP BY module
ORDER BY 
    CASE module
        WHEN '售后配置' THEN 1
        WHEN '快递发货配置' THEN 2
        WHEN '同城配送配置' THEN 3
        WHEN '门店自配送配置' THEN 4
        WHEN '包装费配置' THEN 5
        WHEN '分销配置' THEN 6
        WHEN '通用字段' THEN 7
        ELSE 8
    END;

-- ============================================================
-- 七、验证结果总结
-- ============================================================

-- 7.1 生成验证摘要
SELECT 
    '字段总数' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) >= 70 THEN '✅ 正常' ELSE '⚠️ 字段数异常' END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config'

UNION ALL

SELECT 
    '同城配送字段数' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 30 THEN '✅ 正常' ELSE '⚠️ 字段数异常' END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%'

UNION ALL

SELECT 
    '门店自配送字段数' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 20 THEN '✅ 正常' ELSE '⚠️ 字段数异常' END as status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%'

UNION ALL

SELECT 
    '配置记录数' as check_item,
    COUNT(*) as result,
    CASE WHEN COUNT(*) = 1 THEN '✅ 正常' ELSE '⚠️ 记录数异常' END as status
FROM trade_config 
WHERE id = 1;

-- ============================================================
-- 八、常见问题排查
-- ============================================================

-- 8.1 检查是否有重复字段
SELECT 
    COLUMN_NAME,
    COUNT(*) as count
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config'
GROUP BY COLUMN_NAME
HAVING COUNT(*) > 1;

-- 8.2 检查是否有NULL值的NOT NULL字段
SELECT 
    COLUMN_NAME,
    IS_NULLABLE,
    COLUMN_TYPE
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND IS_NULLABLE = 'NO' 
AND COLUMN_DEFAULT IS NULL
AND COLUMN_NAME NOT IN ('id', 'creator', 'updater');

-- 8.3 检查字段注释是否完整
SELECT 
    COLUMN_NAME,
    COLUMN_COMMENT,
    CASE 
        WHEN COLUMN_COMMENT IS NULL OR COLUMN_COMMENT = '' THEN '⚠️ 缺少注释'
        ELSE '✅ 有注释'
    END as comment_status
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME NOT LIKE 'id'
ORDER BY COLUMN_NAME;

-- ============================================================
-- 验证完成！
-- ============================================================
-- 如果以上所有检查都通过，说明扩展成功
-- 如果有警告或错误，请检查并修复后重新执行
-- ============================================================

