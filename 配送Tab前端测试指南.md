# 配送Tab前端测试指南

## 测试环境准备

### 1. 启动前端服务
```bash
cd yupu-ui-admin-vue
npm run dev
# 或
pnpm dev
```

### 2. 访问页面
- 打开浏览器访问：`http://localhost:3000`
- 登录系统
- 导航到：`商城管理` -> `交易中心` -> `交易配置`

## 测试场景

### 一、快递发货 Tab 测试

#### 1.1 基础功能测试
- [ ] 打开"配送"主Tab
- [ ] 切换到"快递发货"子Tab
- [ ] 验证页面元素显示：
  - 启用快递发货开关
  - 启用包邮开关
  - 满额包邮输入框（当启用包邮时显示）
  - 保存基础配置按钮

#### 1.2 表单交互测试
- [ ] 点击"启用快递发货"开关，验证状态切换
- [ ] 点击"启用包邮"开关，验证：
  - 开关状态切换
  - "满额包邮"输入框显示/隐藏
- [ ] 在"满额包邮"输入框中输入数值：
  - 输入正数（如：299）
  - 输入0
  - 输入负数（应该被限制或提示错误）

#### 1.3 提交测试
- [ ] 修改"启用快递发货"为 `true`，点击"保存基础配置"
  - 验证：显示"保存成功"提示
  - 验证：页面数据刷新
  - 验证：其他Tab数据未受影响
- [ ] 修改"启用包邮"为 `true`，设置"满额包邮"为 `299`，点击保存
  - 验证：保存成功
  - 验证：金额正确转换（前端元 -> 后端分：299 * 100 = 29900）
- [ ] 打开浏览器开发者工具 -> Network，验证请求：
  - 请求URL：`/admin-api/trade/config/update-express`
  - 请求方法：`PUT`
  - 请求体：只包含快递发货相关字段
    ```json
    {
      "deliveryExpressEnabled": true,
      "deliveryExpressFreeEnabled": true,
      "deliveryExpressFreePrice": 29900
    }
    ```

#### 1.4 数据隔离测试
- [ ] 在快递发货Tab修改配置并保存
- [ ] 切换到其他Tab（门店自提、同城配送、门店自配送）
- [ ] 验证：其他Tab的配置数据未受影响

---

### 二、门店自提 Tab 测试

#### 2.1 基础功能测试
- [ ] 切换到"门店自提"子Tab
- [ ] 验证页面元素显示：
  - 启用门店自提开关
  - 保存配置按钮

#### 2.2 表单交互测试
- [ ] 点击"启用门店自提"开关，验证状态切换

#### 2.3 提交测试
- [ ] 修改"启用门店自提"为 `true`，点击"保存配置"
  - 验证：显示"保存成功"提示
  - 验证：请求URL：`/admin-api/trade/config/update-pickup`
  - 验证：请求体只包含 `{"deliveryPickUpEnabled": true}`

---

### 三、同城配送 Tab 测试

#### 3.1 基础功能测试
- [ ] 切换到"同城配送"子Tab
- [ ] 验证页面元素显示：
  - 启用同城配送开关
  - 同城配送包邮配置
  - 同城配送收费配置（三种计费模式）
  - 配送范围管理
  - 保存配置按钮

#### 3.2 计费模式测试

**模式1：按距离计费**
- [ ] 选择"按距离计费"
- [ ] 填写配置：
  - 起步距离：3
  - 起步价：10
  - 续距：1
  - 续费：5
  - 最大配送距离：20
- [ ] 点击"保存配置"
  - 验证：请求包含所有按距离计费相关字段
  - 验证：金额字段正确转换（元 -> 分）

**模式2：固定费用**
- [ ] 选择"固定费用"
- [ ] 填写配置：
  - 固定配送费：15
  - 最大配送距离：20
- [ ] 点击"保存配置"
  - 验证：请求包含固定费用相关字段

**模式3：自定义费用**
- [ ] 选择"自定义费用"
- [ ] 启用"启用自定义费用"开关
- [ ] 填写配置：
  - 最低配送费：0
  - 最高配送费：99
  - 是否需要商家审核：是/否
  - 默认配送费：10
- [ ] 点击"保存配置"
  - 验证：请求包含自定义费用相关字段

#### 3.3 提交测试
- [ ] 修改同城配送配置，点击"保存配置"
  - 验证：请求URL：`/admin-api/trade/config/update-samecity`
  - 验证：请求体只包含同城配送相关字段（17个字段）
  - 验证：其他Tab数据未受影响

---

### 四、门店自配送 Tab 测试

#### 4.1 基础功能测试
- [ ] 切换到"门店自配送"子Tab
- [ ] 验证页面元素显示：
  - 启用门店自配送开关
  - 门店自配送包邮配置
  - 门店自配送收费配置（三种计费模式）
  - 门店配送范围管理
  - 保存配置按钮

#### 4.2 计费模式测试
- [ ] 测试三种计费模式（同"同城配送"测试）

#### 4.3 图片上传测试
- [ ] 在"配送范围示意图"中上传图片
- [ ] 点击"保存配置"
  - 验证：`storeDeliveryRangeImageUrl` 字段正确保存

#### 4.4 提交测试
- [ ] 修改门店自配送配置，点击"保存配置"
  - 验证：请求URL：`/admin-api/trade/config/update-store`
  - 验证：请求体只包含门店自配送相关字段（16个字段）
  - 验证：其他Tab数据未受影响

---

## 浏览器开发者工具测试

### 1. 网络请求监控
1. 打开浏览器开发者工具（F12）
2. 切换到"Network"标签
3. 勾选"Preserve log"（保留日志）
4. 执行操作（修改配置、点击保存）
5. 查看请求：
   - 请求URL是否正确
   - 请求方法是否为 `PUT`
   - 请求头是否包含 `tenant-id`、`authorization` 等
   - 请求体是否只包含当前Tab的字段

### 2. 控制台日志
1. 切换到"Console"标签
2. 查看是否有错误信息
3. 查看是否有警告信息

### 3. Vue DevTools（可选）
1. 安装 Vue DevTools 浏览器扩展
2. 打开 Vue DevTools
3. 查看组件状态：
   - `activeMainTab`：当前主Tab
   - `activeDeliveryTab`：当前配送子Tab
   - `formData`：表单数据
   - 验证数据是否正确更新

---

## 自动化测试脚本（可选）

### 使用 Playwright 或 Cypress

```javascript
// 示例：Playwright 测试脚本
test('快递发货Tab保存测试', async ({ page }) => {
  // 登录
  await page.goto('http://localhost:3000')
  await page.fill('#username', 'admin')
  await page.fill('#password', 'admin123')
  await page.click('button[type="submit"]')
  
  // 导航到交易配置页面
  await page.click('text=商城管理')
  await page.click('text=交易中心')
  await page.click('text=交易配置')
  
  // 切换到配送Tab
  await page.click('text=配送')
  
  // 切换到快递发货Tab
  await page.click('text=快递发货')
  
  // 修改配置
  await page.click('input[type="checkbox"][aria-label="启用快递发货"]')
  await page.fill('input[placeholder="请输入满额包邮"]', '299')
  
  // 监听网络请求
  const [response] = await Promise.all([
    page.waitForResponse(resp => 
      resp.url().includes('/admin-api/trade/config/update-express') && 
      resp.request().method() === 'PUT'
    ),
    page.click('button:has-text("保存基础配置")')
  ])
  
  // 验证请求
  const requestData = response.request().postDataJSON()
  expect(requestData).toHaveProperty('deliveryExpressEnabled')
  expect(requestData).toHaveProperty('deliveryExpressFreeEnabled')
  expect(requestData).toHaveProperty('deliveryExpressFreePrice', 29900)
  
  // 验证响应
  const responseData = await response.json()
  expect(responseData.code).toBe(0)
  expect(responseData.data).toBe(true)
})
```

---

## 测试检查清单

### 功能测试
- [ ] 所有Tab都能正常切换
- [ ] 所有表单字段都能正常输入
- [ ] 所有开关都能正常切换
- [ ] 所有保存按钮都能正常提交
- [ ] 保存成功后显示提示信息
- [ ] 保存成功后数据自动刷新

### 数据隔离测试
- [ ] 快递发货Tab保存不影响其他Tab
- [ ] 门店自提Tab保存不影响其他Tab
- [ ] 同城配送Tab保存不影响其他Tab
- [ ] 门店自配送Tab保存不影响其他Tab

### 数据转换测试
- [ ] 金额字段正确转换（元 -> 分）
- [ ] 距离字段正确保存（BigDecimal）
- [ ] 布尔字段正确保存

### 错误处理测试
- [ ] 网络错误时显示错误提示
- [ ] 表单验证失败时显示错误信息
- [ ] 必填字段为空时显示验证错误

---

## 常见问题排查

### 1. 保存后数据没有更新
- 检查：Network请求是否成功（状态码200）
- 检查：响应数据是否正确
- 检查：`getConfig()` 方法是否被调用

### 2. 保存后其他Tab数据被清空
- 检查：是否使用了正确的独立接口
- 检查：后端接口是否正确实现数据合并

### 3. 金额显示不正确
- 检查：前端显示时是否从分转换为元（除以100）
- 检查：提交时是否从元转换为分（乘以100）

### 4. 表单验证不通过
- 检查：必填字段是否都有值
- 检查：数值字段是否符合验证规则（@PositiveOrZero等）

---

## 测试报告模板

```
测试日期：2025-XX-XX
测试人员：XXX
测试环境：Chrome 142 / Firefox XX / Safari XX

测试结果：
✅ 快递发货Tab：通过
✅ 门店自提Tab：通过
✅ 同城配送Tab：通过
✅ 门店自配送Tab：通过
✅ 数据隔离：通过
✅ 数据转换：通过

发现问题：
1. [问题描述]
2. [问题描述]

修复建议：
1. [建议]
2. [建议]
```

