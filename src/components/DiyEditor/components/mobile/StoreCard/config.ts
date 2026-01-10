import { ComponentStyle, DiyComponent } from '@/components/DiyEditor/util'

/** 店铺卡片属性 */
export interface StoreCardProperty {
  // 店铺编号
  storeId?: number
  // 组件样式
  style: ComponentStyle
}

// 定义组件
export const component = {
  id: 'StoreCard',
  name: '店铺卡片',
  icon: 'mdi:store',
  property: {
    storeId: undefined,
    style: {
      bgType: 'color',
      bgColor: '',
      marginLeft: 8,
      marginRight: 8,
      marginBottom: 8,
      padding: 8
    } as ComponentStyle
  }
} as DiyComponent<StoreCardProperty>

