-- ============================================================
-- 交易配置表扩展 ALTER 语句
-- 基于现有表结构，新增同城配送和门店自配送配置字段
-- 保持与现有表风格一致（bit、int、varchar等）
-- ============================================================

-- ============================================================
-- 一、新增快递发货启用开关字段
-- ============================================================
ALTER TABLE `trade_config`
ADD COLUMN `delivery_express_enabled` bit DEFAULT b'1' NOT NULL COMMENT '是否启用快递发货' AFTER `delivery_express_free_price`;

-- ============================================================
-- 二、新增同城配送配置字段
-- ============================================================

-- 2.1 基础开关
ALTER TABLE `trade_config`
ADD COLUMN `delivery_same_city_enabled` bit DEFAULT b'0' NOT NULL COMMENT '是否启用同城配送' AFTER `delivery_pick_up_enabled`;

-- 2.2 同城配送-收费配置
ALTER TABLE `trade_config`
ADD COLUMN `same_city_charge_mode` tinyint DEFAULT 1 NOT NULL COMMENT '同城配送计费方式（1-按距离，2-固定费用，3-自定义费用）' AFTER `delivery_same_city_enabled`,
ADD COLUMN `same_city_start_distance` decimal(10,2) DEFAULT 3.00 NOT NULL COMMENT '起步距离（单位：公里）' AFTER `same_city_charge_mode`,
ADD COLUMN `same_city_start_price` int DEFAULT 0 NOT NULL COMMENT '起步价（单位：分）' AFTER `same_city_start_distance`,
ADD COLUMN `same_city_extra_distance` decimal(10,2) DEFAULT 1.00 NOT NULL COMMENT '续距（单位：公里）' AFTER `same_city_start_price`,
ADD COLUMN `same_city_extra_price` int DEFAULT 0 NOT NULL COMMENT '续费（单位：分）' AFTER `same_city_extra_distance`,
ADD COLUMN `same_city_max_distance` decimal(10,2) DEFAULT 20.00 NOT NULL COMMENT '最大配送距离（单位：公里）' AFTER `same_city_extra_price`,
ADD COLUMN `same_city_fixed_price` int DEFAULT 0 NOT NULL COMMENT '固定配送费（单位：分）' AFTER `same_city_max_distance`;

-- 2.3 同城配送-自定义费用配置
ALTER TABLE `trade_config`
ADD COLUMN `same_city_custom_price_enabled` bit DEFAULT b'0' NOT NULL COMMENT '是否启用自定义费用' AFTER `same_city_fixed_price`,
ADD COLUMN `same_city_custom_min_price` int DEFAULT 0 NOT NULL COMMENT '最低配送费（单位：分）' AFTER `same_city_custom_price_enabled`,
ADD COLUMN `same_city_custom_max_price` int DEFAULT 0 NOT NULL COMMENT '最高配送费（单位：分，0表示不限制）' AFTER `same_city_custom_min_price`,
ADD COLUMN `same_city_custom_need_audit` bit DEFAULT b'0' NOT NULL COMMENT '是否需要商家审核' AFTER `same_city_custom_max_price`,
ADD COLUMN `same_city_custom_default_price` int DEFAULT 0 NOT NULL COMMENT '默认配送费（单位：分）' AFTER `same_city_custom_need_audit`;

-- 2.4 同城配送-包邮配置
ALTER TABLE `trade_config`
ADD COLUMN `same_city_free_enabled` bit DEFAULT b'0' NOT NULL COMMENT '是否启用同城配送包邮' AFTER `same_city_custom_default_price`,
ADD COLUMN `same_city_free_price` int DEFAULT 0 NOT NULL COMMENT '满额包邮金额（单位：分）' AFTER `same_city_free_enabled`;

-- 2.5 同城配送-范围配置
ALTER TABLE `trade_config`
ADD COLUMN `same_city_delivery_center_latitude` decimal(10,6) NULL COMMENT '配送中心纬度（范围：-90.000000 到 90.000000）' AFTER `same_city_free_price`,
ADD COLUMN `same_city_delivery_center_longitude` decimal(11,6) NULL COMMENT '配送中心经度（范围：-180.000000 到 180.000000）' AFTER `same_city_delivery_center_latitude`,
ADD COLUMN `same_city_delivery_range` decimal(10,2) NULL COMMENT '配送范围半径（单位：公里）' AFTER `same_city_delivery_center_longitude`,
ADD COLUMN `same_city_delivery_range_description` text NULL COMMENT '配送范围限制说明' AFTER `same_city_delivery_range`;

-- ============================================================
-- 三、新增门店自配送配置字段
-- ============================================================

-- 3.1 基础开关
ALTER TABLE `trade_config`
ADD COLUMN `delivery_store_enabled` bit DEFAULT b'0' NOT NULL COMMENT '是否启用门店自配送' AFTER `same_city_delivery_range_description`;

-- 3.2 门店自配送-收费配置
ALTER TABLE `trade_config`
ADD COLUMN `store_charge_mode` tinyint DEFAULT 1 NOT NULL COMMENT '门店自配送计费方式（1-按距离，2-固定费用，3-自定义费用）' AFTER `delivery_store_enabled`,
ADD COLUMN `store_start_distance` decimal(10,2) DEFAULT 3.00 NOT NULL COMMENT '起步距离（单位：公里）' AFTER `store_charge_mode`,
ADD COLUMN `store_start_price` int DEFAULT 0 NOT NULL COMMENT '起步价（单位：分）' AFTER `store_start_distance`,
ADD COLUMN `store_extra_distance` decimal(10,2) DEFAULT 1.00 NOT NULL COMMENT '续距（单位：公里）' AFTER `store_start_price`,
ADD COLUMN `store_extra_price` int DEFAULT 0 NOT NULL COMMENT '续费（单位：分）' AFTER `store_extra_distance`,
ADD COLUMN `store_max_distance` decimal(10,2) DEFAULT 20.00 NOT NULL COMMENT '最大配送距离（单位：公里）' AFTER `store_extra_price`,
ADD COLUMN `store_fixed_price` int DEFAULT 0 NOT NULL COMMENT '固定配送费（单位：分）' AFTER `store_max_distance`;

-- 3.3 门店自配送-自定义费用配置
ALTER TABLE `trade_config`
ADD COLUMN `store_custom_price_enabled` bit DEFAULT b'0' NOT NULL COMMENT '是否启用自定义费用' AFTER `store_fixed_price`,
ADD COLUMN `store_custom_min_price` int DEFAULT 0 NOT NULL COMMENT '最低配送费（单位：分）' AFTER `store_custom_price_enabled`,
ADD COLUMN `store_custom_max_price` int DEFAULT 0 NOT NULL COMMENT '最高配送费（单位：分，0表示不限制）' AFTER `store_custom_min_price`,
ADD COLUMN `store_custom_need_audit` bit DEFAULT b'0' NOT NULL COMMENT '是否需要商家审核' AFTER `store_custom_max_price`,
ADD COLUMN `store_custom_default_price` int DEFAULT 0 NOT NULL COMMENT '默认配送费（单位：分）' AFTER `store_custom_need_audit`;

-- 3.4 门店自配送-包邮配置
ALTER TABLE `trade_config`
ADD COLUMN `store_free_enabled` bit DEFAULT b'0' NOT NULL COMMENT '是否启用门店自配送包邮' AFTER `store_custom_default_price`,
ADD COLUMN `store_free_price` int DEFAULT 0 NOT NULL COMMENT '满额包邮金额（单位：分）' AFTER `store_free_enabled`;

-- 3.5 门店自配送-范围配置
ALTER TABLE `trade_config`
ADD COLUMN `store_delivery_range_image_url` varchar(500) NULL COMMENT '门店配送范围示意图URL' AFTER `store_free_price`;

-- ============================================================
-- 四、验证新增字段
-- ============================================================
-- 执行以下SQL查看新增字段
-- DESC trade_config;

-- 查看所有同城配送相关字段
-- SHOW COLUMNS FROM trade_config LIKE 'same_city%';

-- 查看所有门店自配送相关字段
-- SHOW COLUMNS FROM trade_config LIKE 'store%';

-- ============================================================
-- 五、回滚脚本（如果需要回滚，请谨慎操作）
-- ============================================================
/*
-- 删除门店自配送字段
ALTER TABLE `trade_config`
DROP COLUMN `store_delivery_range_image_url`,
DROP COLUMN `store_free_price`,
DROP COLUMN `store_free_enabled`,
DROP COLUMN `store_custom_default_price`,
DROP COLUMN `store_custom_need_audit`,
DROP COLUMN `store_custom_max_price`,
DROP COLUMN `store_custom_min_price`,
DROP COLUMN `store_custom_price_enabled`,
DROP COLUMN `store_fixed_price`,
DROP COLUMN `store_max_distance`,
DROP COLUMN `store_extra_price`,
DROP COLUMN `store_extra_distance`,
DROP COLUMN `store_start_price`,
DROP COLUMN `store_start_distance`,
DROP COLUMN `store_charge_mode`,
DROP COLUMN `delivery_store_enabled`;

-- 删除同城配送字段
ALTER TABLE `trade_config`
DROP COLUMN `same_city_delivery_range_description`,
DROP COLUMN `same_city_delivery_range`,
DROP COLUMN `same_city_delivery_center_longitude`,
DROP COLUMN `same_city_delivery_center_latitude`,
DROP COLUMN `same_city_free_price`,
DROP COLUMN `same_city_free_enabled`,
DROP COLUMN `same_city_custom_default_price`,
DROP COLUMN `same_city_custom_need_audit`,
DROP COLUMN `same_city_custom_max_price`,
DROP COLUMN `same_city_custom_min_price`,
DROP COLUMN `same_city_custom_price_enabled`,
DROP COLUMN `same_city_fixed_price`,
DROP COLUMN `same_city_max_distance`,
DROP COLUMN `same_city_extra_price`,
DROP COLUMN `same_city_extra_distance`,
DROP COLUMN `same_city_start_price`,
DROP COLUMN `same_city_start_distance`,
DROP COLUMN `same_city_charge_mode`,
DROP COLUMN `delivery_same_city_enabled`;

-- 删除快递发货启用开关
ALTER TABLE `trade_config`
DROP COLUMN `delivery_express_enabled`;
*/

-- ============================================================
-- 六、字段说明
-- ============================================================
-- 1. 所有金额字段使用 int 类型，单位：分（与现有表保持一致）
-- 2. 所有布尔字段使用 bit 类型（与现有表保持一致）
-- 3. 距离字段使用 decimal(10,2) 类型，支持小数点后2位
-- 4. 坐标字段使用 decimal(10,6) 或 decimal(11,6) 类型，支持6位小数
-- 5. 文本字段使用 text 或 varchar 类型，根据长度选择
-- 6. 所有字段都设置了合理的默认值
-- ============================================================

