-- ============================================================
-- 交易配置表结构设计
-- 数据库：MySQL 5.7+
-- 字符集：utf8mb4
-- 排序规则：utf8mb4_unicode_ci
-- ============================================================

-- 删除已存在的表（谨慎操作，仅用于开发环境）
-- DROP TABLE IF EXISTS `trade_config`;

-- ============================================================
-- 交易配置主表
-- ============================================================
CREATE TABLE IF NOT EXISTS `trade_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID（单例模式，固定为1）',
  
  -- ========== 售后配置 ==========
  `after_sale_refund_reasons` JSON NULL COMMENT '退款理由列表，JSON数组格式',
  `after_sale_return_reasons` JSON NULL COMMENT '退货理由列表，JSON数组格式',
  
  -- ========== 快递发货配置 ==========
  `delivery_express_enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用快递发货（0-否，1-是）',
  `delivery_express_free_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用全局包邮（0-否，1-是）',
  `delivery_express_free_price` BIGINT NOT NULL DEFAULT 0 COMMENT '满额包邮金额（单位：分）',
  
  -- ========== 同城配送配置 ==========
  `delivery_same_city_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用同城配送（0-否，1-是）',
  
  -- 同城配送-收费配置
  `same_city_charge_mode` TINYINT NOT NULL DEFAULT 1 COMMENT '同城配送计费方式（1-按距离，2-固定费用，3-自定义费用）',
  `same_city_start_distance` DECIMAL(10,2) NOT NULL DEFAULT 3.00 COMMENT '起步距离（单位：公里）',
  `same_city_start_price` BIGINT NOT NULL DEFAULT 0 COMMENT '起步价（单位：分）',
  `same_city_extra_distance` DECIMAL(10,2) NOT NULL DEFAULT 1.00 COMMENT '续距（单位：公里）',
  `same_city_extra_price` BIGINT NOT NULL DEFAULT 0 COMMENT '续费（单位：分）',
  `same_city_max_distance` DECIMAL(10,2) NOT NULL DEFAULT 20.00 COMMENT '最大配送距离（单位：公里）',
  `same_city_fixed_price` BIGINT NOT NULL DEFAULT 0 COMMENT '固定配送费（单位：分）',
  
  -- 同城配送-自定义费用配置
  `same_city_custom_price_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用自定义费用（0-否，1-是）',
  `same_city_custom_min_price` BIGINT NOT NULL DEFAULT 0 COMMENT '最低配送费（单位：分）',
  `same_city_custom_max_price` BIGINT NOT NULL DEFAULT 0 COMMENT '最高配送费（单位：分，0表示不限制）',
  `same_city_custom_need_audit` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否需要商家审核（0-否，1-是）',
  `same_city_custom_default_price` BIGINT NOT NULL DEFAULT 0 COMMENT '默认配送费（单位：分）',
  
  -- 同城配送-包邮配置
  `same_city_free_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用同城配送包邮（0-否，1-是）',
  `same_city_free_price` BIGINT NOT NULL DEFAULT 0 COMMENT '满额包邮金额（单位：分）',
  
  -- 同城配送-范围配置
  `same_city_delivery_center_latitude` DECIMAL(10,6) NULL COMMENT '配送中心纬度（范围：-90.000000 到 90.000000）',
  `same_city_delivery_center_longitude` DECIMAL(11,6) NULL COMMENT '配送中心经度（范围：-180.000000 到 180.000000）',
  `same_city_delivery_range` DECIMAL(10,2) NULL COMMENT '配送范围半径（单位：公里）',
  `same_city_delivery_range_description` TEXT NULL COMMENT '配送范围限制说明',
  
  -- ========== 门店自配送配置 ==========
  `delivery_store_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用门店自配送（0-否，1-是）',
  
  -- 门店自配送-收费配置
  `store_charge_mode` TINYINT NOT NULL DEFAULT 1 COMMENT '门店自配送计费方式（1-按距离，2-固定费用，3-自定义费用）',
  `store_start_distance` DECIMAL(10,2) NOT NULL DEFAULT 3.00 COMMENT '起步距离（单位：公里）',
  `store_start_price` BIGINT NOT NULL DEFAULT 0 COMMENT '起步价（单位：分）',
  `store_extra_distance` DECIMAL(10,2) NOT NULL DEFAULT 1.00 COMMENT '续距（单位：公里）',
  `store_extra_price` BIGINT NOT NULL DEFAULT 0 COMMENT '续费（单位：分）',
  `store_max_distance` DECIMAL(10,2) NOT NULL DEFAULT 20.00 COMMENT '最大配送距离（单位：公里）',
  `store_fixed_price` BIGINT NOT NULL DEFAULT 0 COMMENT '固定配送费（单位：分）',
  
  -- 门店自配送-自定义费用配置
  `store_custom_price_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用自定义费用（0-否，1-是）',
  `store_custom_min_price` BIGINT NOT NULL DEFAULT 0 COMMENT '最低配送费（单位：分）',
  `store_custom_max_price` BIGINT NOT NULL DEFAULT 0 COMMENT '最高配送费（单位：分，0表示不限制）',
  `store_custom_need_audit` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否需要商家审核（0-否，1-是）',
  `store_custom_default_price` BIGINT NOT NULL DEFAULT 0 COMMENT '默认配送费（单位：分）',
  
  -- 门店自配送-包邮配置
  `store_free_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用门店自配送包邮（0-否，1-是）',
  `store_free_price` BIGINT NOT NULL DEFAULT 0 COMMENT '满额包邮金额（单位：分）',
  
  -- 门店自配送-范围配置
  `store_delivery_range_image_url` VARCHAR(500) NULL COMMENT '门店配送范围示意图URL',
  
  -- ========== 包装费配置 ==========
  `packaging_fee_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用包装费（0-否，1-是）',
  `packaging_fee_price` BIGINT NOT NULL DEFAULT 0 COMMENT '包装费金额（单位：分）',
  
  -- ========== 分销配置 ==========
  `brokerage_enabled` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否启用分销（0-否，1-是）',
  `brokerage_enabled_condition` INT NULL COMMENT '分佣模式（字典值）',
  `brokerage_bind_mode` INT NULL COMMENT '分销关系绑定模式（字典值）',
  `brokerage_poster_urls` JSON NULL COMMENT '分销海报URL列表，JSON数组格式',
  `brokerage_first_percent` INT NOT NULL DEFAULT 0 COMMENT '一级返佣比例（单位：百分比，例如：10表示10%）',
  `brokerage_second_percent` INT NOT NULL DEFAULT 0 COMMENT '二级返佣比例（单位：百分比，例如：5表示5%）',
  `brokerage_withdraw_min_price` BIGINT NOT NULL DEFAULT 0 COMMENT '提现最低金额（单位：分）',
  `brokerage_withdraw_fee_percent` INT NOT NULL DEFAULT 0 COMMENT '提现手续费百分比（单位：百分比，例如：1表示1%）',
  `brokerage_frozen_days` INT NOT NULL DEFAULT 0 COMMENT '佣金冻结天数（单位：天）',
  `brokerage_withdraw_types` JSON NULL COMMENT '提现方式列表，JSON数组格式',
  
  -- ========== 通用字段 ==========
  `creator` VARCHAR(64) NULL DEFAULT '' COMMENT '创建者',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` VARCHAR(64) NULL DEFAULT '' COMMENT '更新者',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否删除（0-未删除，1-已删除）',
  `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户编号',
  
  PRIMARY KEY (`id`),
  KEY `idx_tenant_id` (`tenant_id`),
  KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交易配置表（单例模式）';

-- ============================================================
-- 插入默认配置记录（单例模式，固定id=1）
-- ============================================================
INSERT INTO `trade_config` (
  `id`,
  `delivery_express_enabled`,
  `after_sale_refund_reasons`,
  `after_sale_return_reasons`
) VALUES (
  1,
  1,
  JSON_ARRAY('不想要了', '买错了', '商品信息不符'),
  JSON_ARRAY('质量问题', '尺寸不合适', '颜色不符')
) ON DUPLICATE KEY UPDATE `update_time` = CURRENT_TIMESTAMP;

-- ============================================================
-- 添加表注释说明
-- ============================================================
-- 单例模式说明：
-- 1. 表中只有一条记录，固定 id=1
-- 2. 应用层需保证单例约束
-- 3. 所有配置都在这条记录中维护
-- 
-- 金额字段说明：
-- 1. 所有金额字段以"分"为单位存储（BIGINT类型）
-- 2. 前端显示时除以100转换为元
-- 3. 示例：10.50元 = 1050分
-- 
-- JSON字段说明：
-- 1. MySQL 5.7+ 支持JSON类型
-- 2. 可以存储数组格式数据
-- 3. 支持JSON函数查询和验证
-- ============================================================

