/*
 * 组件注册
 *
 * 组件规范：
 * 1. 每个子目录就是一个独立的组件，每个目录包括以下三个文件：
 * 2. config.ts：组件配置，必选，用于定义组件、组件默认的属性、定义属性的类型
 * 3. index.vue：组件展示，用于展示组件的渲染效果。可以不提供，如 Page（页面设置），只需要属性配置表单即可
 * 4. property.vue：组件属性表单，用于配置组件，必选，
 *
 * 注：
 * 组件ID以config.ts中配置的id为准，与组件目录的名称无关，但还是建议组件目录的名称与组件ID保持一致
 */

// 导入组件界面模块
const viewModules: Record<string, any> = import.meta.glob('./*/*.vue')
// 导入配置模块
const configModules: Record<string, any> = import.meta.glob('./*/config.ts', { eager: true })

// 界面模块
const components = {}
// 组件配置模块
const componentConfigs = {}

// 组件界面的类型
type ViewType = 'index' | 'property'

/**
 * 注册组件的界面模块
 *
 * @param componentId 组件ID
 * @param configPath 配置模块的文件路径
 * @param viewType 组件界面的类型
 */
const registerComponentViewModule = (
  componentId: string,
  configPath: string,
  viewType: ViewType
) => {
  const viewPath = configPath.replace('config.ts', `${viewType}.vue`)
  const viewModule = viewModules[viewPath]
  if (viewModule) {
    // 定义异步组件
    components[componentId] = defineAsyncComponent(viewModule)
  }
}

// 注册
// 调试：打印所有扫描到的配置文件（始终输出，便于排查）
console.log('[组件注册] 扫描到的配置文件:', Object.keys(configModules))
console.log('[组件注册] 配置文件总数:', Object.keys(configModules).length)
console.log('[组件注册] 检查 StoreCard 配置路径:', './StoreCard/config.ts' in configModules || Object.keys(configModules).find(key => key.includes('StoreCard')))

Object.keys(configModules).forEach((modulePath: string) => {
  try {
    const module = configModules[modulePath]
    // 调试：打印模块内容（始终输出，便于排查）
    console.log(`[组件注册] 处理模块: ${modulePath}`, {
      hasModule: !!module,
      hasComponent: !!(module?.component),
      componentId: module?.component?.id,
      componentName: module?.component?.name
    })
    
    const component = module?.component
    if (!component) {
      console.warn(`[组件注册失败] ${modulePath}: 模块中没有 component 导出`, {
        moduleKeys: module ? Object.keys(module) : [],
        moduleType: typeof module
      })
      return
    }
    const componentId = component?.id
    if (componentId) {
      // 注册组件
      componentConfigs[componentId] = component
      // 注册预览界面
      registerComponentViewModule(componentId, modulePath, 'index')
      // 注册属性配置表单
      registerComponentViewModule(`${componentId}Property`, modulePath, 'property')
      // 调试日志（始终输出）
      console.log(`[组件注册成功] ${componentId}: ${component.name}`, {
        icon: component.icon,
        hasProperty: !!component.property
      })
    } else {
      console.warn(`[组件注册失败] ${modulePath}: component.id 不存在`, {
        component: component,
        componentKeys: component ? Object.keys(component) : []
      })
    }
  } catch (error) {
    console.error(`[组件注册错误] ${modulePath}:`, error)
  }
})

// 调试：打印所有已注册的组件（始终输出，便于排查）
console.log('[组件注册] 已注册的组件列表:', Object.keys(componentConfigs))
console.log('[组件注册] 已注册组件总数:', Object.keys(componentConfigs).length)
console.log('[组件注册] StoreCard 是否存在:', 'StoreCard' in componentConfigs)
if ('StoreCard' in componentConfigs) {
  console.log('[组件注册] StoreCard 组件详情:', componentConfigs['StoreCard'])
} else {
  console.warn('[组件注册] StoreCard 组件未找到！请检查配置文件是否正确导出 component')
}

export { components, componentConfigs }
