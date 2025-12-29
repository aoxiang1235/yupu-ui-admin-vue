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
  sameCityDeliveryRangeDescription?: string // 配送范围限制说明
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
  storeDeliveryRangeImageUrl?: string // 门店配送范围示意图URL
  packagingFeeEnabled?: boolean
  packagingFeePrice?: number
  packagingFeeFreeEnabled?: boolean
  packagingFeeFreePrice?: number
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

// 更新快递发货配置（仅更新快递发货字段）
export const updateExpressConfig = async (data: {
  deliveryExpressEnabled: boolean
  deliveryExpressFreeEnabled: boolean
  deliveryExpressFreePrice: number
}) => {
  return await request.put({ url: `/trade/config/update-express`, data })
}

// 更新门店自提配置（仅更新门店自提字段）
export const updatePickUpConfig = async (data: { deliveryPickUpEnabled: boolean }) => {
  return await request.put({ url: `/trade/config/update-pickup`, data })
}

// 更新售后配置（仅更新售后字段）
export const updateAfterSaleConfig = async (data: {
  afterSaleRefundReasons: string[]
  afterSaleReturnReasons: string[]
}) => {
  return await request.put({ url: `/trade/config/update-aftersale`, data })
}

// 更新包装费配置（仅更新包装费字段）
export const updatePackagingConfig = async (data: {
  packagingFeeEnabled: boolean
  packagingFeePrice: number
  packagingFeeFreeEnabled?: boolean
  packagingFeeFreePrice?: number
}) => {
  return await request.put({ url: `/trade/config/update-packaging`, data })
}

// 更新同城配送配置（仅更新同城配送字段）
export const updateSameCityConfig = async (data: {
  deliverySameCityEnabled: boolean
  sameCityChargeMode: number
  sameCityStartDistance?: number
  sameCityStartPrice?: number
  sameCityExtraDistance?: number
  sameCityExtraPrice?: number
  sameCityMaxDistance?: number
  sameCityFixedPrice?: number
  sameCityCustomPriceEnabled?: boolean
  sameCityCustomMinPrice?: number
  sameCityCustomMaxPrice?: number
  sameCityCustomNeedAudit?: boolean
  sameCityCustomDefaultPrice?: number
  sameCityFreeEnabled?: boolean
  sameCityFreePrice?: number
  sameCityDeliveryRangeDescription?: string
}) => {
  return await request.put({ url: `/trade/config/update-samecity`, data })
}

// 更新门店自配送配置（仅更新门店自配送字段）
export const updateStoreConfig = async (data: {
  deliveryStoreEnabled: boolean
  storeChargeMode: number
  storeStartDistance?: number
  storeStartPrice?: number
  storeExtraDistance?: number
  storeExtraPrice?: number
  storeMaxDistance?: number
  storeFixedPrice?: number
  storeCustomPriceEnabled?: boolean
  storeCustomMinPrice?: number
  storeCustomMaxPrice?: number
  storeCustomNeedAudit?: boolean
  storeCustomDefaultPrice?: number
  storeFreeEnabled?: boolean
  storeFreePrice?: number
  storeDeliveryRangeImageUrl?: string
}) => {
  return await request.put({ url: `/trade/config/update-store`, data })
}

// 更新分销配置（仅更新分销字段）
export const updateBrokerageConfig = async (data: {
  brokerageEnabled: boolean
  brokerageEnabledCondition: number
  brokerageBindMode: number
  brokeragePosterUrls?: string[]
  brokerageFirstPercent: number
  brokerageSecondPercent: number
  brokerageWithdrawMinPrice: number
  brokerageWithdrawFeePercent: number
  brokerageFrozenDays: number
  brokerageWithdrawTypes: number[]
}) => {
  return await request.put({ url: `/trade/config/update-brokerage`, data })
}
