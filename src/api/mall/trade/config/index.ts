import request from '@/config/axios'

export interface ConfigVO {
  id?: number | null
  afterSaleRefundReasons?: string[]
  afterSaleReturnReasons?: string[]
  deliveryExpressEnabled?: boolean
  deliveryExpressFreeEnabled?: boolean
  deliveryExpressFreePrice?: number
  deliveryPickUpEnabled?: boolean
  deliverySameCityEnabled?: boolean // 启用同城配送（功能开发中）
  // 同城配送收费配置
  sameCityChargeMode?: number // 计费方式：1-按距离，2-固定费用，3-自定义费用
  sameCityStartDistance?: number // 起步距离（公里）
  sameCityStartPrice?: number // 起步价（元）
  sameCityExtraDistance?: number // 续距（公里）
  sameCityExtraPrice?: number // 续费（元）
  sameCityMaxDistance?: number // 最大配送距离（公里）
  sameCityFixedPrice?: number // 固定配送费（元）
  // 自定义费用配置（模式3）
  sameCityCustomPriceEnabled?: boolean // 启用自定义费用
  sameCityCustomMinPrice?: number // 最低配送费（元）
  sameCityCustomMaxPrice?: number // 最高配送费（元，0表示不限制）
  sameCityCustomNeedAudit?: boolean // 是否需要商家审核
  sameCityCustomDefaultPrice?: number // 默认配送费（元）
  sameCityFreeEnabled?: boolean // 启用同城配送包邮
  sameCityFreePrice?: number // 满额包邮金额（元）
  // 同城配送范围配置
  sameCityDeliveryCenterLatitude?: number // 配送中心纬度
  sameCityDeliveryCenterLongitude?: number // 配送中心经度
  sameCityDeliveryRange?: number // 配送范围半径（公里）
  // 包邮小区配置
  sameCityFreeShippingCommunities?: Array<{
    id?: number // 小区ID
    name: string // 小区名称
    address: string // 详细地址
    latitude: number // 纬度
    longitude: number // 经度
    createTime?: number // 创建时间
  }>
  deliveryStoreEnabled?: boolean // 启用门店自配送（功能开发中）
  // 门店自配送收费配置
  storeChargeMode?: number // 计费方式：1-按距离，2-固定费用，3-自定义费用
  storeStartDistance?: number // 起步距离（公里）
  storeStartPrice?: number // 起步价（元）
  storeExtraDistance?: number // 续距（公里）
  storeExtraPrice?: number // 续费（元）
  storeMaxDistance?: number // 最大配送距离（公里）
  storeFixedPrice?: number // 固定配送费（元）
  // 自定义费用配置（模式3）
  storeCustomPriceEnabled?: boolean // 启用自定义费用
  storeCustomMinPrice?: number // 最低配送费（元）
  storeCustomMaxPrice?: number // 最高配送费（元，0表示不限制）
  storeCustomNeedAudit?: boolean // 是否需要商家审核
  storeCustomDefaultPrice?: number // 默认配送费（元）
  storeFreeEnabled?: boolean // 启用门店自配送包邮
  storeFreePrice?: number // 满额包邮金额（元）
  packagingFeeEnabled?: boolean
  packagingFeePrice?: number
  brokerageEnabled?: boolean
  brokerageEnabledCondition?: number
  brokerageBindMode?: number
  brokeragePosterUrls?: string | string[]
  brokerageFirstPercent?: number
  brokerageSecondPercent?: number
  brokerageWithdrawMinPrice?: number
  brokerageFrozenDays?: number
  brokerageWithdrawFeePercent?: number
  brokerageWithdrawTypes?: string | number[]
}

// 查询交易中心配置详情
export const getTradeConfig = async () => {
  return await request.get({ url: `/trade/config/get` })
}

// 保存交易中心配置
export const saveTradeConfig = async (data: ConfigVO) => {
  return await request.put({ url: `/trade/config/save`, data })
}
