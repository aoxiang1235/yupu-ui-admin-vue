# 字段验证 - 正确的SQL查询

## 问题说明

您提供的查询结果中出现了异常字段：
- `SELECT_RANGE`, `SORT_RANGE`, `SUM_SELECT_RANGE`, `SUM_SORT_RANGE`, `sort_using_range`
- 这些是 MySQL 内部统计字段，**不应该**出现在 `trade_config` 表中

## 正确的验证SQL

### 1. 验证同城配送距离字段

```sql
-- 查询同城配送的所有距离相关字段
SELECT 
    COLUMN_NAME as 字段名,
    COLUMN_TYPE as 字段类型,
    COLUMN_COMMENT as 字段注释
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME IN (
    'same_city_start_distance',
    'same_city_extra_distance',
    'same_city_max_distance',
    'same_city_delivery_range'
)
ORDER BY COLUMN_NAME;
```

**预期结果**（应该只有这4个字段）：
- `same_city_delivery_range` - decimal(10,2) - 配送范围半径（单位：公里）
- `same_city_extra_distance` - decimal(10,2) - 续距（单位：公里）
- `same_city_max_distance` - decimal(10,2) - 最大配送距离（单位：公里）
- `same_city_start_distance` - decimal(10,2) - 起步距离（单位：公里）

### 2. 验证门店自配送距离字段

```sql
-- 查询门店自配送的所有距离相关字段
SELECT 
    COLUMN_NAME as 字段名,
    COLUMN_TYPE as 字段类型,
    COLUMN_COMMENT as 字段注释
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME IN (
    'store_start_distance',
    'store_extra_distance',
    'store_max_distance'
)
ORDER BY COLUMN_NAME;
```

**预期结果**（应该只有这3个字段）：
- `store_extra_distance` - decimal(10,2) - 续距（单位：公里）
- `store_max_distance` - decimal(10,2) - 最大配送距离（单位：公里）
- `store_start_distance` - decimal(10,2) - 起步距离（单位：公里）

### 3. 验证所有同城配送字段

```sql
-- 查询所有同城配送字段
SELECT 
    COLUMN_NAME as 字段名,
    COLUMN_TYPE as 字段类型,
    COLUMN_DEFAULT as 默认值,
    IS_NULLABLE as 允许空,
    COLUMN_COMMENT as 字段注释
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'same_city%'
ORDER BY ORDINAL_POSITION;
```

### 4. 验证所有门店自配送字段

```sql
-- 查询所有门店自配送字段
SELECT 
    COLUMN_NAME as 字段名,
    COLUMN_TYPE as 字段类型,
    COLUMN_DEFAULT as 默认值,
    IS_NULLABLE as 允许空,
    COLUMN_COMMENT as 字段注释
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'trade_config' 
AND COLUMN_NAME LIKE 'store%'
ORDER BY ORDINAL_POSITION;
```

### 5. 验证表结构（避免异常字段）

```sql
-- 直接查看表结构
DESC trade_config;

-- 或者使用 SHOW COLUMNS
SHOW COLUMNS FROM trade_config LIKE 'same_city%';
SHOW COLUMNS FROM trade_config LIKE 'store%';
```

## 注意事项

1. **确保查询的是正确的表**
   - 表名应该是 `trade_config`
   - 数据库应该是指定的数据库（不是系统库）

2. **避免查询系统统计信息**
   - `SELECT_RANGE`, `SORT_RANGE` 等是 MySQL 内部字段
   - 不应该出现在用户表中

3. **使用正确的字段名**
   - 同城配送字段以 `same_city` 开头
   - 门店自配送字段以 `store` 开头
   - 启用开关字段是 `delivery_same_city_enabled` 和 `delivery_store_enabled`

## 建议

如果您的查询结果中出现了异常字段，请：
1. 确认是否查询了正确的表和数据库
2. 检查是否误查询了 MySQL 系统表
3. 使用上面提供的标准 SQL 重新验证

