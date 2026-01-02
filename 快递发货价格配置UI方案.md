# 快递发货价格配置UI方案

## 📋 设计方案概述

在快递发货配置页面添加详细的价格配置说明，帮助用户理解运费计算规则和配置逻辑。

## 🎨 UI设计方案

### 1. 全局包邮配置说明

**位置：** 在"全局包邮配置"区域下方

**设计：** 使用 `el-collapse` 折叠面板，包含详细说明

```vue
<!-- 全局包邮配置说明 -->
<el-collapse class="mb-20px">
  <el-collapse-item name="globalFreeShippingDescription">
    <template #title>
      <div style="display: flex; align-items: center">
        <Icon
          icon="ep:info-filled"
          style="font-size: 18px; margin-right: 8px; color: #409eff"
        />
        <span style="font-size: 15px; font-weight: 600">全局包邮配置说明</span>
      </div>
    </template>
    <el-descriptions :column="1" border>
      <el-descriptions-item label="功能说明">
        <div>
          <div style="font-weight: 500; margin-bottom: 4px">全商城统一的包邮规则</div>
          <div style="font-size: 12px; color: #909399">
            开启后，所有订单只要满足条件即可享受包邮优惠，无需额外配置
          </div>
        </div>
      </el-descriptions-item>
      <el-descriptions-item label="判断条件">
        <div>
          <div style="font-weight: 500; margin-bottom: 4px">订单应付金额 >= 满额包邮金额</div>
          <div style="font-size: 12px; color: #909399">
            例如：设置满100元包邮，订单金额达到或超过100元时，运费自动为0
          </div>
        </div>
      </el-descriptions-item>
      <el-descriptions-item label="优先级">
        <div>
          <div style="font-weight: 500; margin-bottom: 4px">最高优先级</div>
          <div style="font-size: 12px; color: #909399">
            全局包邮优先级最高，满足条件后直接包邮，不再计算运费模板费用
          </div>
        </div>
      </el-descriptions-item>
      <el-descriptions-item label="与其他包邮规则的关系">
        <div>
          <div style="font-weight: 500; margin-bottom: 4px">包邮规则优先级顺序：</div>
          <div style="font-size: 12px; color: #909399; line-height: 1.8">
            1. <strong>全局包邮</strong>（最高优先级）<br/>
            2. <strong>活动包邮</strong>（满减送活动）<br/>
            3. <strong>运费模板包邮</strong>（按区域和模板配置）
          </div>
        </div>
      </el-descriptions-item>
    </el-descriptions>
  </el-collapse-item>
</el-collapse>
```

### 2. 运费模板计费方式说明

**位置：** 在"运费模板管理"区域下方

**设计：** 使用 `el-card` 卡片展示三种计费方式的详细说明和计算示例

```vue
<!-- 运费模板计费方式说明 -->
<el-card shadow="never" class="mb-20px" style="border: 1px solid #e4e7ed">
  <template #header>
    <div style="display: flex; align-items: center">
      <Icon
        icon="ep:document"
        style="font-size: 20px; margin-right: 8px; color: #409eff"
      />
      <span style="font-size: 16px; font-weight: 600">运费模板计费方式说明</span>
    </div>
  </template>

  <el-tabs type="border-card">
    <!-- Tab 1: 按件计费 -->
    <el-tab-pane label="按件计费">
      <div style="padding: 16px">
        <el-alert type="info" :closable="false" show-icon class="mb-15px">
          <template #default>
            <div>
              <p class="mb-5px"><strong>适用场景：</strong>商品数量明确，按件数计算运费</p>
              <p class="mb-0"><strong>示例：</strong>服装、日用品、小件商品等</p>
            </div>
          </template>
        </el-alert>

        <el-descriptions :column="1" border class="mb-15px">
          <el-descriptions-item label="计算公式">
            <div style="font-family: 'Courier New', monospace; font-size: 13px; line-height: 1.8">
              <div>总件数 = Σ(商品数量)</div>
              <div v-if="false">if (总件数 <= 首件数) {</div>
              <div style="margin-left: 20px">运费 = 首件价格</div>
              <div>} else {</div>
              <div style="margin-left: 20px">续件次数 = ⌈(总件数 - 首件数) / 续件数⌉</div>
              <div style="margin-left: 20px">运费 = 首件价格 + (续件价格 × 续件次数)</div>
              <div>}</div>
            </div>
          </el-descriptions-item>
          <el-descriptions-item label="配置字段说明">
            <div style="font-size: 12px; line-height: 1.8">
              <div><strong>首件数：</strong>按首件价格计算的商品件数范围</div>
              <div><strong>首件价格：</strong>首件数范围内的固定运费</div>
              <div><strong>续件数：</strong>超过首件后，每多少件加收一次续费</div>
              <div><strong>续件价格：</strong>每增加一个续件单位收取的费用</div>
            </div>
          </el-descriptions-item>
        </el-descriptions>

        <el-card shadow="never" style="background: #f8f9fa">
          <template #header>
            <span style="font-size: 14px; font-weight: 600">计算示例</span>
          </template>
          <div style="font-size: 13px; line-height: 1.8">
            <div class="mb-10px">
              <strong>配置：</strong>
              <ul style="margin: 8px 0; padding-left: 20px">
                <li>首件：10件内，运费10元</li>
                <li>续件：每5件，加收5元</li>
              </ul>
            </div>
            <div>
              <strong>场景1：</strong>购买8件商品
              <div style="margin-left: 20px; color: #67c23a">
                → 总件数8件 ≤ 首件10件，运费 = 10元
              </div>
            </div>
            <div class="mt-10px">
              <strong>场景2：</strong>购买12件商品
              <div style="margin-left: 20px; color: #409eff">
                → 总件数12件 > 首件10件<br/>
                → 续件次数 = ⌈(12-10)/5⌉ = ⌈0.4⌉ = 1次<br/>
                → 运费 = 10 + (5 × 1) = 15元
              </div>
            </div>
            <div class="mt-10px">
              <strong>场景3：</strong>购买18件商品
              <div style="margin-left: 20px; color: #e6a23c">
                → 总件数18件 > 首件10件<br/>
                → 续件次数 = ⌈(18-10)/5⌉ = ⌈1.6⌉ = 2次<br/>
                → 运费 = 10 + (5 × 2) = 20元
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </el-tab-pane>

    <!-- Tab 2: 按重量计费 -->
    <el-tab-pane label="按重量计费">
      <div style="padding: 16px">
        <el-alert type="info" :closable="false" show-icon class="mb-15px">
          <template #default>
            <div>
              <p class="mb-5px"><strong>适用场景：</strong>商品重量差异大，按重量计算运费</p>
              <p class="mb-0"><strong>示例：</strong>生鲜、大件商品、重物等</p>
            </div>
          </template>
        </el-alert>

        <el-descriptions :column="1" border class="mb-15px">
          <el-descriptions-item label="计算公式">
            <div style="font-family: 'Courier New', monospace; font-size: 13px; line-height: 1.8">
              <div>总重量 = Σ(商品重量 × 商品数量)</div>
              <div>if (总重量 <= 首件重量) {</div>
              <div style="margin-left: 20px">运费 = 首件价格</div>
              <div>} else {</div>
              <div style="margin-left: 20px">续件次数 = ⌈(总重量 - 首件重量) / 续件重量⌉</div>
              <div style="margin-left: 20px">运费 = 首件价格 + (续件价格 × 续件次数)</div>
              <div>}</div>
            </div>
          </el-descriptions-item>
          <el-descriptions-item label="配置字段说明">
            <div style="font-size: 12px; line-height: 1.8">
              <div><strong>首件重量：</strong>按首件价格计算的重量范围（单位：kg）</div>
              <div><strong>首件价格：</strong>首件重量范围内的固定运费</div>
              <div><strong>续件重量：</strong>超过首件后，每多少kg加收一次续费</div>
              <div><strong>续件价格：</strong>每增加一个续件单位收取的费用</div>
            </div>
          </el-descriptions-item>
        </el-descriptions>

        <el-card shadow="never" style="background: #f8f9fa">
          <template #header>
            <span style="font-size: 14px; font-weight: 600">计算示例</span>
          </template>
          <div style="font-size: 13px; line-height: 1.8">
            <div class="mb-10px">
              <strong>配置：</strong>
              <ul style="margin: 8px 0; padding-left: 20px">
                <li>首件：3kg内，运费10元</li>
                <li>续件：每1kg，加收3元</li>
              </ul>
            </div>
            <div>
              <strong>场景1：</strong>购买2件商品，每件1kg（总重量2kg）
              <div style="margin-left: 20px; color: #67c23a">
                → 总重量2kg ≤ 首件3kg，运费 = 10元
              </div>
            </div>
            <div class="mt-10px">
              <strong>场景2：</strong>购买3件商品，每件1.5kg（总重量4.5kg）
              <div style="margin-left: 20px; color: #409eff">
                → 总重量4.5kg > 首件3kg<br/>
                → 续件次数 = ⌈(4.5-3)/1⌉ = ⌈1.5⌉ = 2次<br/>
                → 运费 = 10 + (3 × 2) = 16元
              </div>
            </div>
            <div class="mt-10px">
              <strong>场景3：</strong>购买1件商品，重量5kg
              <div style="margin-left: 20px; color: #e6a23c">
                → 总重量5kg > 首件3kg<br/>
                → 续件次数 = ⌈(5-3)/1⌉ = ⌈2⌉ = 2次<br/>
                → 运费 = 10 + (3 × 2) = 16元
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </el-tab-pane>

    <!-- Tab 3: 按体积计费 -->
    <el-tab-pane label="按体积计费">
      <div style="padding: 16px">
        <el-alert type="info" :closable="false" show-icon class="mb-15px">
          <template #default>
            <div>
              <p class="mb-5px"><strong>适用场景：</strong>商品体积大但重量轻，按体积计算运费</p>
              <p class="mb-0"><strong>示例：</strong>家具、家电、大件包装商品等</p>
            </div>
          </template>
        </el-alert>

        <el-descriptions :column="1" border class="mb-15px">
          <el-descriptions-item label="计算公式">
            <div style="font-family: 'Courier New', monospace; font-size: 13px; line-height: 1.8">
              <div>总体积 = Σ(商品体积 × 商品数量)</div>
              <div>if (总体积 <= 首件体积) {</div>
              <div style="margin-left: 20px">运费 = 首件价格</div>
              <div>} else {</div>
              <div style="margin-left: 20px">续件次数 = ⌈(总体积 - 首件体积) / 续件体积⌉</div>
              <div style="margin-left: 20px">运费 = 首件价格 + (续件价格 × 续件次数)</div>
              <div>}</div>
            </div>
          </el-descriptions-item>
          <el-descriptions-item label="配置字段说明">
            <div style="font-size: 12px; line-height: 1.8">
              <div><strong>首件体积：</strong>按首件价格计算的体积范围（单位：m³）</div>
              <div><strong>首件价格：</strong>首件体积范围内的固定运费</div>
              <div><strong>续件体积：</strong>超过首件后，每多少m³加收一次续费</div>
              <div><strong>续件价格：</strong>每增加一个续件单位收取的费用</div>
            </div>
          </el-descriptions-item>
        </el-descriptions>

        <el-card shadow="never" style="background: #f8f9fa">
          <template #header>
            <span style="font-size: 14px; font-weight: 600">计算示例</span>
          </template>
          <div style="font-size: 13px; line-height: 1.8">
            <div class="mb-10px">
              <strong>配置：</strong>
              <ul style="margin: 8px 0; padding-left: 20px">
                <li>首件：0.5m³内，运费20元</li>
                <li>续件：每0.3m³，加收10元</li>
              </ul>
            </div>
            <div>
              <strong>场景1：</strong>购买1件商品，体积0.4m³
              <div style="margin-left: 20px; color: #67c23a">
                → 总体积0.4m³ ≤ 首件0.5m³，运费 = 20元
              </div>
            </div>
            <div class="mt-10px">
              <strong>场景2：</strong>购买1件商品，体积0.8m³
              <div style="margin-left: 20px; color: #409eff">
                → 总体积0.8m³ > 首件0.5m³<br/>
                → 续件次数 = ⌈(0.8-0.5)/0.3⌉ = ⌈1⌉ = 1次<br/>
                → 运费 = 20 + (10 × 1) = 30元
              </div>
            </div>
            <div class="mt-10px">
              <strong>场景3：</strong>购买2件商品，每件0.4m³（总体积0.8m³）
              <div style="margin-left: 20px; color: #e6a23c">
                → 总体积0.8m³ > 首件0.5m³<br/>
                → 续件次数 = ⌈(0.8-0.5)/0.3⌉ = ⌈1⌉ = 1次<br/>
                → 运费 = 20 + (10 × 1) = 30元
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </el-tab-pane>
  </el-tabs>
</el-card>
```

### 3. 包邮规则优先级说明

**位置：** 在运费模板说明下方

**设计：** 使用 `el-alert` 警告框展示优先级关系

```vue
<!-- 包邮规则优先级说明 -->
<el-alert type="warning" :closable="false" show-icon class="mb-15px">
  <template #default>
    <div>
      <p class="mb-5px"><strong>包邮规则优先级说明：</strong></p>
      <div style="font-size: 13px; line-height: 2">
        <div>
          <strong style="color: #e6a23c">1. 全局包邮</strong>（最高优先级）
          <div style="margin-left: 20px; color: #909399">
            订单金额 >= 满额包邮金额 → 直接包邮，不再计算运费
          </div>
        </div>
        <div class="mt-10px">
          <strong style="color: #409eff">2. 活动包邮</strong>
          <div style="margin-left: 20px; color: #909399">
            参与满减送活动且满足活动包邮条件 → 包邮
          </div>
        </div>
        <div class="mt-10px">
          <strong style="color: #67c23a">3. 运费模板包邮</strong>
          <div style="margin-left: 20px; color: #909399">
            订单件数/重量/体积 <= 包邮件数/重量/体积 且 订单金额 >= 包邮金额 → 包邮
          </div>
        </div>
        <div class="mt-10px" style="color: #909399">
          <strong>注意：</strong>如果都不满足，则按运费模板计算运费
        </div>
      </div>
    </div>
  </template>
</el-alert>
```

### 4. 运费分摊说明

**位置：** 在包邮规则说明下方

**设计：** 使用 `el-card` 卡片展示运费分摊逻辑

```vue
<!-- 运费分摊说明 -->
<el-card shadow="never" class="mb-20px" style="border: 1px solid #e4e7ed">
  <template #header>
    <div style="display: flex; align-items: center">
      <Icon
        icon="ep:share"
        style="font-size: 20px; margin-right: 8px; color: #67c23a"
      />
      <span style="font-size: 16px; font-weight: 600">运费分摊说明</span>
    </div>
  </template>

  <div style="padding: 16px">
    <el-descriptions :column="1" border>
      <el-descriptions-item label="分摊规则">
        <div style="font-size: 13px; line-height: 1.8">
          <div>当订单包含多个商品时，运费会按比例分摊到每个商品</div>
        </div>
      </el-descriptions-item>
      <el-descriptions-item label="分摊方式">
        <div style="font-size: 13px; line-height: 1.8">
          <div><strong>按计费值比例分摊：</strong></div>
          <div style="margin-left: 20px; margin-top: 8px">
            <div>• 按件计费：按商品数量比例分摊</div>
            <div>• 按重量计费：按商品重量比例分摊</div>
            <div>• 按体积计费：按商品体积比例分摊</div>
          </div>
        </div>
      </el-descriptions-item>
      <el-descriptions-item label="计算示例">
        <div style="font-size: 13px; line-height: 1.8">
          <div class="mb-10px">
            <strong>场景：</strong>订单总运费20元，包含2个商品
          </div>
          <div>
            <strong>商品A：</strong>数量5件，计费值占比 5/8 = 62.5%<br/>
            <span style="margin-left: 20px">→ 分摊运费 = 20 × 62.5% = 12.5元</span>
          </div>
          <div class="mt-5px">
            <strong>商品B：</strong>数量3件，计费值占比 3/8 = 37.5%<br/>
            <span style="margin-left: 20px">→ 分摊运费 = 20 × 37.5% = 7.5元</span>
          </div>
        </div>
      </el-descriptions-item>
    </el-descriptions>
  </div>
</el-card>
```

## 📍 完整布局位置

```
交易配置 → 配送 → 快递发货
├── 启用快递发货（开关）
│
├── 全局包邮配置
│   ├── 启用包邮（开关）
│   ├── 满额包邮（输入框）
│   └── 📘 全局包邮配置说明（折叠面板）
│
├── 运费模板管理
│   ├── 搜索和列表
│   └── 📘 运费模板计费方式说明（卡片，包含3个Tab）
│
├── 📘 包邮规则优先级说明（警告框）
│
├── 📘 运费分摊说明（卡片）
│
└── 快递公司管理
    └── 搜索和列表
```

## 🎯 设计要点

1. **折叠式设计**：主要说明使用折叠面板，不占用过多空间
2. **Tab切换**：三种计费方式使用Tab切换，清晰分类
3. **示例展示**：每个计费方式都提供多个计算示例，便于理解
4. **优先级说明**：明确展示包邮规则的优先级关系
5. **视觉层次**：使用不同颜色和图标区分不同类型的信息

## ✅ 实现建议

1. 所有说明区域都可以折叠/展开，默认折叠
2. 使用统一的图标和颜色风格
3. 计算公式使用等宽字体，便于阅读
4. 示例使用不同颜色区分不同场景
5. 保持与同城配送说明UI的一致性
