<template>
  <doc-alert title="【交易】交易订单" url="https://doc.iocoder.cn/mall/trade-order/" />
  <doc-alert title="【交易】购物车" url="https://doc.iocoder.cn/mall/trade-cart/" />

  <ContentWrap>
    <el-form
      ref="formRef"
      v-loading="formLoading"
      :model="formData"
      :rules="formRules"
      label-width="120px"
    >
      <el-form-item v-show="false" label="hideId">
        <el-input v-model="formData.id" />
      </el-form-item>
      <el-tabs v-model="activeMainTab">
        <!-- 售后 -->
        <el-tab-pane label="售后" name="afterSale">
          <el-form-item label="退款理由" prop="afterSaleRefundReasons">
            <el-select
              v-model="formData.afterSaleRefundReasons"
              allow-create
              filterable
              multiple
              placeholder="请直接输入退款理由"
            >
              <el-option
                v-for="reason in formData.afterSaleRefundReasons"
                :key="reason"
                :label="reason"
                :value="reason"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="退货理由" prop="afterSaleReturnReasons">
            <el-select
              v-model="formData.afterSaleReturnReasons"
              allow-create
              filterable
              multiple
              placeholder="请直接输入退货理由"
            >
              <el-option
                v-for="reason in formData.afterSaleReturnReasons"
                :key="reason"
                :label="reason"
                :value="reason"
              />
            </el-select>
          </el-form-item>

          <!-- 保存按钮区域 -->
          <div style="display: flex; align-items: center; justify-content: flex-end; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e4e7ed">
            <el-button
              :loading="formLoading"
              type="primary"
              size="default"
              @click="submitForm"
            >
              <Icon icon="ep:check" class="mr-5px" />
              保存配置
            </el-button>
          </div>
        </el-tab-pane>
        <!-- 配送 -->
        <el-tab-pane label="配送" name="delivery">
          <el-tabs type="border-card" v-model="activeDeliveryTab">
            <!-- Tab 1: 快递发货 -->
            <el-tab-pane label="快递发货" name="express">
              <!-- 基础配置卡片 -->
              <el-card shadow="never" style="margin-bottom: 20px; border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center">
                    <Icon icon="ep:setting" style="font-size: 18px; margin-right: 8px; color: #409eff" />
                    <span style="font-size: 16px; font-weight: 600">基础配置</span>
                  </div>
                </template>
                
                <!-- 启用开关 -->
                <el-form-item label="启用快递发货" prop="deliveryExpressEnabled" style="margin-bottom: 20px">
                  <el-switch v-model="formData.deliveryExpressEnabled" style="user-select: none" />
                  <el-text class="ml-10px" size="small" type="info">
                    开启后，用户可以在APP端选择快递发货
                  </el-text>
                </el-form-item>

                <!-- 全局包邮配置 -->
                <el-divider content-position="left" style="margin: 20px 0">
                  <span style="font-size: 14px; font-weight: 500; color: #606266">全局包邮配置</span>
                </el-divider>
                
                <el-form-item label="启用包邮" prop="deliveryExpressFreeEnabled" style="margin-bottom: 16px">
                  <el-switch
                    v-model="formData.deliveryExpressFreeEnabled"
                    style="user-select: none"
                  />
                  <el-text class="ml-10px" size="small" type="info"> 商城是否启用全场包邮</el-text>
                </el-form-item>
                
                <el-form-item
                  v-if="formData.deliveryExpressFreeEnabled"
                  label="满额包邮"
                  prop="deliveryExpressFreePrice"
                  style="margin-bottom: 0"
                >
                  <div style="display: flex; align-items: center; gap: 12px">
                    <el-input-number
                      v-model="formData.deliveryExpressFreePrice"
                      :min="0"
                      :precision="2"
                      class="!w-200px"
                      placeholder="请输入满额包邮"
                    />
                    <el-text size="small" type="info">
                      商城商品满多少金额即可包邮，单位：元
                    </el-text>
                  </div>
                </el-form-item>
              </el-card>
              <!-- 保存按钮区域 -->
              <el-card shadow="never" style="margin-bottom: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none">
                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; padding: 4px 0">
                  <div style="flex: 1; min-width: 200px; color: white">
                  </div>
                  <div style="flex-shrink: 0">
                    <el-button
                      :loading="formLoading"
                      type="primary"
                      size="default"
                      style="min-width: 120px; background: white; color: #667eea; border: none; font-weight: 500"
                      @click="submitForm"
                    >
                      <Icon icon="ep:check" class="mr-5px" />
                      保存基础配置
                    </el-button>
                  </div>
                </div>
              </el-card>

              <!-- 运费模板管理卡片 -->
              <el-card shadow="never" style="margin-bottom: 20px; border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center; justify-content: space-between">
                    <div style="display: flex; align-items: center">
                      <Icon icon="ep:document" style="font-size: 18px; margin-right: 8px; color: #409eff" />
                      <span style="font-size: 16px; font-weight: 600">运费模板管理</span>
                    </div>
                    <el-button
                      type="primary"
                      size="small"
                      @click="openExpressTemplateForm('create')"
                      v-hasPermi="['trade:delivery:express-template:create']"
                    >
                      <Icon icon="ep:plus" class="mr-5px" /> 新增模板
                    </el-button>
                  </div>
                </template>

                <!-- 运费模板计费方式说明 -->
                <el-collapse class="mb-20px">
                  <el-collapse-item name="expressChargeModeDescription">
                    <template #title>
                      <div style="display: flex; align-items: center">
                        <Icon
                          icon="ep:question-filled"
                          style="font-size: 16px; margin-right: 8px; color: #909399"
                        />
                        <span style="font-size: 14px; font-weight: 500">运费模板计费方式说明</span>
                      </div>
                    </template>

                  <el-card shadow="never" class="mb-0" style="border: 1px solid #e4e7ed">
                    <el-tabs type="border-card">
                      <!-- Tab 1: 按件计费 -->
                      <el-tab-pane label="按件计费">
                        <div style="padding: 16px">
                          <el-alert type="info" :closable="false" show-icon class="mb-15px">
                            <template #default>
                              <div>
                                <p class="mb-5px"
                                  ><strong>适用场景：</strong>商品数量明确，按件数计算运费</p
                                >
                                <p class="mb-0"><strong>示例：</strong>服装、日用品、小件商品等</p>
                              </div>
                            </template>
                          </el-alert>

                          <el-descriptions :column="1" border class="mb-15px">
                            <el-descriptions-item label="计算公式">
                              <div
                                style="
                                  font-family: 'Courier New', monospace;
                                  font-size: 13px;
                                  line-height: 1.8;
                                "
                              >
                                <div>总件数 = Σ(商品数量)</div>
                                <div>if (总件数 &lt;= 首件数) {</div>
                                <div style="margin-left: 20px">运费 = 首件价格</div>
                                <div>} else {</div>
                                <div style="margin-left: 20px">
                                  续件次数 = ⌈(总件数 - 首件数) / 续件数⌉
                                </div>
                                <div style="margin-left: 20px">
                                  运费 = 首件价格 + (续件价格 × 续件次数)
                                </div>
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
                                  → 总件数8件 &lt;= 首件10件，运费 = 10元
                                </div>
                              </div>
                              <div class="mt-10px">
                                <strong>场景2：</strong>购买12件商品
                                <div style="margin-left: 20px; color: #409eff">
                                  → 总件数12件 > 首件10件<br />
                                  → 续件次数 = ⌈(12-10)/5⌉ = ⌈0.4⌉ = 1次<br />
                                  → 运费 = 10 + (5 × 1) = 15元
                                </div>
                              </div>
                              <div class="mt-10px">
                                <strong>场景3：</strong>购买18件商品
                                <div style="margin-left: 20px; color: #e6a23c">
                                  → 总件数18件 > 首件10件<br />
                                  → 续件次数 = ⌈(18-10)/5⌉ = ⌈1.6⌉ = 2次<br />
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
                                <p class="mb-5px"
                                  ><strong>适用场景：</strong>商品重量差异大，按重量计算运费</p
                                >
                                <p class="mb-0"><strong>示例：</strong>生鲜、大件商品、重物等</p>
                              </div>
                            </template>
                          </el-alert>

                          <el-descriptions :column="1" border class="mb-15px">
                            <el-descriptions-item label="计算公式">
                              <div
                                style="
                                  font-family: 'Courier New', monospace;
                                  font-size: 13px;
                                  line-height: 1.8;
                                "
                              >
                                <div>总重量 = Σ(商品重量 × 商品数量)</div>
                                <div>if (总重量 &lt;= 首件重量) {</div>
                                <div style="margin-left: 20px">运费 = 首件价格</div>
                                <div>} else {</div>
                                <div style="margin-left: 20px">
                                  续件次数 = ⌈(总重量 - 首件重量) / 续件重量⌉
                                </div>
                                <div style="margin-left: 20px">
                                  运费 = 首件价格 + (续件价格 × 续件次数)
                                </div>
                                <div>}</div>
                              </div>
                            </el-descriptions-item>
                            <el-descriptions-item label="配置字段说明">
                              <div style="font-size: 12px; line-height: 1.8">
                                <div
                                  ><strong>首件重量：</strong
                                  >按首件价格计算的重量范围（单位：kg）</div
                                >
                                <div><strong>首件价格：</strong>首件重量范围内的固定运费</div>
                                <div
                                  ><strong>续件重量：</strong>超过首件后，每多少kg加收一次续费</div
                                >
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
                                  → 总重量2kg &lt;= 首件3kg，运费 = 10元
                                </div>
                              </div>
                              <div class="mt-10px">
                                <strong>场景2：</strong>购买3件商品，每件1.5kg（总重量4.5kg）
                                <div style="margin-left: 20px; color: #409eff">
                                  → 总重量4.5kg > 首件3kg<br />
                                  → 续件次数 = ⌈(4.5-3)/1⌉ = ⌈1.5⌉ = 2次<br />
                                  → 运费 = 10 + (3 × 2) = 16元
                                </div>
                              </div>
                              <div class="mt-10px">
                                <strong>场景3：</strong>购买1件商品，重量5kg
                                <div style="margin-left: 20px; color: #e6a23c">
                                  → 总重量5kg > 首件3kg<br />
                                  → 续件次数 = ⌈(5-3)/1⌉ = ⌈2⌉ = 2次<br />
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
                                <p class="mb-5px"
                                  ><strong>适用场景：</strong>商品体积大但重量轻，按体积计算运费</p
                                >
                                <p class="mb-0"
                                  ><strong>示例：</strong>家具、家电、大件包装商品等</p
                                >
                              </div>
                            </template>
                          </el-alert>

                          <el-descriptions :column="1" border class="mb-15px">
                            <el-descriptions-item label="计算公式">
                              <div
                                style="
                                  font-family: 'Courier New', monospace;
                                  font-size: 13px;
                                  line-height: 1.8;
                                "
                              >
                                <div>总体积 = Σ(商品体积 × 商品数量)</div>
                                <div>if (总体积 &lt;= 首件体积) {</div>
                                <div style="margin-left: 20px">运费 = 首件价格</div>
                                <div>} else {</div>
                                <div style="margin-left: 20px">
                                  续件次数 = ⌈(总体积 - 首件体积) / 续件体积⌉
                                </div>
                                <div style="margin-left: 20px">
                                  运费 = 首件价格 + (续件价格 × 续件次数)
                                </div>
                                <div>}</div>
                              </div>
                            </el-descriptions-item>
                            <el-descriptions-item label="配置字段说明">
                              <div style="font-size: 12px; line-height: 1.8">
                                <div
                                  ><strong>首件体积：</strong
                                  >按首件价格计算的体积范围（单位：m³）</div
                                >
                                <div><strong>首件价格：</strong>首件体积范围内的固定运费</div>
                                <div
                                  ><strong>续件体积：</strong>超过首件后，每多少m³加收一次续费</div
                                >
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
                                  → 总体积0.4m³ &lt;= 首件0.5m³，运费 = 20元
                                </div>
                              </div>
                              <div class="mt-10px">
                                <strong>场景2：</strong>购买1件商品，体积0.8m³
                                <div style="margin-left: 20px; color: #409eff">
                                  → 总体积0.8m³ > 首件0.5m³<br />
                                  → 续件次数 = ⌈(0.8-0.5)/0.3⌉ = ⌈1⌉ = 1次<br />
                                  → 运费 = 20 + (10 × 1) = 30元
                                </div>
                              </div>
                              <div class="mt-10px">
                                <strong>场景3：</strong>购买2件商品，每件0.4m³（总体积0.8m³）
                                <div style="margin-left: 20px; color: #e6a23c">
                                  → 总体积0.8m³ > 首件0.5m³<br />
                                  → 续件次数 = ⌈(0.8-0.5)/0.3⌉ = ⌈1⌉ = 1次<br />
                                  → 运费 = 20 + (10 × 1) = 30元
                                </div>
                              </div>
                            </div>
                          </el-card>
                        </div>
                      </el-tab-pane>
                    </el-tabs>
                  </el-card>
                </el-collapse-item>
              </el-collapse>

              <!-- 搜索区域 -->
              <el-form :inline="true" class="mb-15px" style="background: #f8f9fa; padding: 16px; border-radius: 4px">
                <el-form-item label="模板名称" style="margin-bottom: 0">
                  <el-input
                    v-model="expressTemplateQuery.name"
                    placeholder="请输入模板名称"
                    clearable
                    class="!w-240px"
                    @keyup.enter="handleExpressTemplateQuery"
                  />
                </el-form-item>
                <el-form-item style="margin-bottom: 0">
                  <el-button @click="handleExpressTemplateQuery">
                    <Icon icon="ep:search" class="mr-5px" /> 搜索
                  </el-button>
                  <el-button @click="resetExpressTemplateQuery">
                    <Icon icon="ep:refresh" class="mr-5px" /> 重置
                  </el-button>
                </el-form-item>
              </el-form>

              <!-- 运费模板列表 -->
              <el-table 
                v-loading="expressTemplateLoading" 
                :data="expressTemplateList"
                stripe
              >
                <el-table-column label="编号" prop="id" width="80" />
                <el-table-column label="模板名称" prop="name" min-width="150" />
                <el-table-column label="计费方式" prop="chargeMode" width="120">
                  <template #default="scope">
                    <dict-tag :type="DICT_TYPE.EXPRESS_CHARGE_MODE" :value="scope.row.chargeMode" />
                  </template>
                </el-table-column>
                <el-table-column label="排序" prop="sort" width="80" />
                <el-table-column
                  label="创建时间"
                  prop="createTime"
                  width="180"
                  :formatter="dateFormatter"
                />
                <el-table-column label="操作" width="150" align="center" fixed="right">
                  <template #default="scope">
                    <el-button
                      link
                      type="primary"
                      @click="openExpressTemplateForm('update', scope.row.id)"
                      v-hasPermi="['trade:delivery:express-template:update']"
                    >
                      编辑
                    </el-button>
                    <el-button
                      link
                      type="danger"
                      @click="handleExpressTemplateDelete(scope.row.id)"
                      v-hasPermi="['trade:delivery:express-template:delete']"
                    >
                      删除
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
              </el-card>
              <!-- 快递公司管理卡片 -->
              <el-card shadow="never" style="margin-bottom: 20px; border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center; justify-content: space-between">
                    <div style="display: flex; align-items: center">
                      <Icon icon="ep:truck" style="font-size: 18px; margin-right: 8px; color: #409eff" />
                      <span style="font-size: 16px; font-weight: 600">快递公司管理</span>
                    </div>
                    <el-button
                      type="primary"
                      size="small"
                      @click="openExpressForm('create')"
                      v-hasPermi="['trade:delivery:express:create']"
                    >
                      <Icon icon="ep:plus" class="mr-5px" /> 新增快递公司
                    </el-button>
                  </div>
                </template>

                <!-- 搜索区域 -->
                <el-form :inline="true" class="mb-15px" style="background: #f8f9fa; padding: 16px; border-radius: 4px">
                  <el-form-item label="快递公司名称" style="margin-bottom: 0">
                    <el-input
                      v-model="expressQuery.name"
                      placeholder="请输入快递公司名称"
                      clearable
                      class="!w-240px"
                      @keyup.enter="handleExpressQuery"
                    />
                  </el-form-item>
                  <el-form-item style="margin-bottom: 0">
                    <el-button @click="handleExpressQuery">
                      <Icon icon="ep:search" class="mr-5px" /> 搜索
                    </el-button>
                    <el-button @click="resetExpressQuery">
                      <Icon icon="ep:refresh" class="mr-5px" /> 重置
                    </el-button>
                  </el-form-item>
                </el-form>

                <!-- 快递公司列表 -->
                <el-table v-loading="expressLoading" :data="expressList" stripe>
                <el-table-column label="编号" prop="id" width="80" />
                <el-table-column label="快递公司编号" prop="code" width="120" />
                <el-table-column label="快递公司名称" prop="name" min-width="150" />
                <el-table-column label="快递公司logo" prop="logo" width="100">
                  <template #default="scope">
                    <el-image
                      v-if="scope.row.logo"
                      :src="scope.row.logo"
                      :preview-src-list="[scope.row.logo]"
                      style="width: 50px; height: 50px"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="排序" prop="sort" width="80" />
                <el-table-column label="状态" prop="status" width="100">
                  <template #default="scope">
                    <dict-tag :type="DICT_TYPE.COMMON_STATUS" :value="scope.row.status" />
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="150" align="center" fixed="right">
                  <template #default="scope">
                    <el-button
                      link
                      type="primary"
                      @click="openExpressForm('update', scope.row.id)"
                      v-hasPermi="['trade:delivery:express:update']"
                    >
                      编辑
                    </el-button>
                    <el-button
                      link
                      type="danger"
                      @click="handleExpressDelete(scope.row.id)"
                      v-hasPermi="['trade:delivery:express:delete']"
                    >
                      删除
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
              </el-card>
            </el-tab-pane>

            <!-- Tab 2: 门店自提 -->
            <el-tab-pane label="门店自提" name="pickUp">
              <!-- 基础配置卡片 -->
              <el-card shadow="never" style="margin-bottom: 20px; border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center">
                    <Icon icon="ep:setting" style="font-size: 18px; margin-right: 8px; color: #409eff" />
                    <span style="font-size: 16px; font-weight: 600">基础配置</span>
                  </div>
                </template>
                
                <!-- 启用开关 -->
                <el-form-item label="启用门店自提" prop="deliveryPickUpEnabled" style="margin-bottom: 0">
                  <el-switch v-model="formData.deliveryPickUpEnabled" style="user-select: none" />
                  <el-text class="ml-10px" size="small" type="info">
                    开启后，用户可以在APP端选择门店自提
                  </el-text>
                </el-form-item>
              </el-card>

              <!-- 保存按钮区域 -->
              <el-card shadow="never" style="margin-bottom: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none">
                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; padding: 4px 0">
                  <div style="flex: 1; min-width: 200px; color: white">
                  </div>
                  <div style="flex-shrink: 0">
                    <el-button
                      :loading="formLoading"
                      type="primary"
                      size="default"
                      style="min-width: 120px; background: white; color: #667eea; border: none; font-weight: 500"
                      @click="submitForm"
                    >
                      <Icon icon="ep:check" class="mr-5px" />
                      保存配置
                    </el-button>
                  </div>
                </div>
              </el-card>

              <!-- 门店管理 -->
              <el-card shadow="never" style="margin-bottom: 20px; border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center">
                    <Icon icon="ep:shop" style="font-size: 18px; margin-right: 8px; color: #409eff" />
                    <span style="font-size: 16px; font-weight: 600">门店管理</span>
                  </div>
                </template>
                
                <el-divider content-position="left" style="margin: 0 0 16px 0">门店列表</el-divider>
              <el-form :inline="true" class="mb-15px">
                <el-form-item label="门店名称">
                  <el-input
                    v-model="pickUpStoreQuery.name"
                    placeholder="请输入门店名称"
                    clearable
                    class="!w-240px"
                    @keyup.enter="handlePickUpStoreQuery"
                  />
                </el-form-item>
                <el-form-item>
                  <el-button @click="handlePickUpStoreQuery">
                    <Icon icon="ep:search" class="mr-5px" /> 搜索
                  </el-button>
                  <el-button @click="resetPickUpStoreQuery">
                    <Icon icon="ep:refresh" class="mr-5px" /> 重置
                  </el-button>
                  <el-button
                    type="primary"
                    @click="openPickUpStoreForm('create')"
                    v-hasPermi="['trade:delivery:pick-up-store:create']"
                  >
                    <Icon icon="ep:plus" class="mr-5px" /> 新增门店
                  </el-button>
                </el-form-item>
              </el-form>

              <el-table v-loading="pickUpStoreLoading" :data="pickUpStoreList">
                <el-table-column label="编号" prop="id" width="80" />
                <el-table-column label="门店名称" prop="name" min-width="150" />
                <el-table-column label="门店地址" prop="detailAddress" min-width="200" />
                <el-table-column label="联系电话" prop="phone" width="120" />
                <el-table-column label="营业时间" width="180">
                  <template #default="scope">
                    {{ scope.row.openingTime }} ~ {{ scope.row.closingTime }}
                  </template>
                </el-table-column>
                <el-table-column label="状态" prop="status" width="100">
                  <template #default="scope">
                    <dict-tag :type="DICT_TYPE.COMMON_STATUS" :value="scope.row.status" />
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="200" align="center" fixed="right">
                  <template #default="scope">
                    <el-button
                      link
                      type="primary"
                      @click="openPickUpStoreForm('update', scope.row.id)"
                      v-hasPermi="['trade:delivery:pick-up-store:update']"
                    >
                      编辑
                    </el-button>
                    <el-button
                      link
                      type="primary"
                      @click="openPickUpStoreFormBind(scope.row.id)"
                      v-hasPermi="['trade:delivery:pick-up-store:update']"
                    >
                      绑定店员
                    </el-button>
                    <el-button
                      link
                      type="danger"
                      @click="handlePickUpStoreDelete(scope.row.id)"
                      v-hasPermi="['trade:delivery:pick-up-store:delete']"
                    >
                      删除
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
              </el-card>
            </el-tab-pane>

            <!-- Tab 3: 同城配送 -->
            <el-tab-pane label="同城配送" name="sameCity">
              <!-- 启用开关 -->
              <el-form-item label="启用同城配送" prop="deliverySameCityEnabled">
                <el-switch v-model="formData.deliverySameCityEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，用户可以在APP端选择同城配送
                </el-text>
              </el-form-item>

              <!-- 同城配送包邮配置（提前展示） -->
              <el-divider content-position="left">同城配送包邮配置</el-divider>
              <el-form-item label="启用包邮" prop="sameCityFreeEnabled">
                <el-switch v-model="formData.sameCityFreeEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，满足条件可免同城配送费
                </el-text>
              </el-form-item>
              <el-form-item
                v-if="formData.sameCityFreeEnabled"
                label="满额包邮"
                prop="sameCityFreePrice"
              >
                <el-input-number
                  v-model="formData.sameCityFreePrice"
                  :min="0"
                  :precision="2"
                  class="!w-xs"
                  placeholder="满额包邮"
                />
                <el-text class="ml-10px" size="small" type="info">
                  订单金额满多少元可免同城配送费，单位：元
                </el-text>
              </el-form-item>

              <!-- 同城配送收费配置 -->
              <el-divider content-position="left">同城配送收费配置</el-divider>
              <el-form-item label="计费方式" prop="sameCityChargeMode">
                <el-radio-group v-model="formData.sameCityChargeMode">
                  <el-radio :value="1">按距离计费</el-radio>
                  <el-radio :value="2">固定费用</el-radio>
                  <el-radio :value="3">自定义费用</el-radio>
                </el-radio-group>
                <el-text class="ml-10px" size="small" type="info"> 选择同城配送的计费方式 </el-text>
              </el-form-item>

              <!-- 按距离计费配置 -->
              <template v-if="formData.sameCityChargeMode === 1">
                <!-- 字段配置说明 -->
                <el-collapse class="mb-20px">
                  <el-collapse-item name="configDescription">
                    <template #title>
                      <div style="display: flex; align-items: center">
                        <Icon
                          icon="ep:setting"
                          style="font-size: 18px; margin-right: 8px; color: #409eff"
                        />
                        <span style="font-size: 15px; font-weight: 600">配置项说明</span>
                      </div>
                    </template>
                    <el-descriptions :column="1" border>
                      <el-descriptions-item label="起步距离">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px">配送距离的起始范围</div>
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为3km，表示3公里内的配送都按起步价收费
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="起步价">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >起步距离内的固定配送费</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为10元，表示3km内统一收费10元
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="续距">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >超过起步距离后，每增加多少公里加收费用</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为1km，表示每超过1km就加收一次续费
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="续费">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >每增加一个续距单位收取的费用</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为5元，表示每超过1km加收5元
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="最大配送距离">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >支持同城配送的最大距离限制</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为20km，超过20km的地址将不支持同城配送
                          </div>
                        </div>
                      </el-descriptions-item>
                    </el-descriptions>
                  </el-collapse-item>
                </el-collapse>

                <!-- 配置表单 -->
                <el-form-item label="起步距离" prop="sameCityStartDistance">
                  <el-input-number
                    v-model="formData.sameCityStartDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="起步距离"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：公里</el-text>
                </el-form-item>
                <el-form-item label="起步价" prop="sameCityStartPrice">
                  <el-input-number
                    v-model="formData.sameCityStartPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="起步价"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：元</el-text>
                </el-form-item>
                <el-form-item label="续距" prop="sameCityExtraDistance">
                  <el-input-number
                    v-model="formData.sameCityExtraDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="续距"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：公里</el-text>
                </el-form-item>
                <el-form-item label="续费" prop="sameCityExtraPrice">
                  <el-input-number
                    v-model="formData.sameCityExtraPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="续费"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：元</el-text>
                </el-form-item>
                <el-form-item label="最大配送距离" prop="sameCityMaxDistance">
                  <el-input-number
                    v-model="formData.sameCityMaxDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="最大配送距离"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    超过此距离不支持同城配送，单位：公里
                  </el-text>
                </el-form-item>

                <!-- 实时计算示例 -->
                <el-card shadow="never" class="mt-20px" style="background: #f8f9fa">
                  <template #header>
                    <div style="display: flex; align-items: center">
                      <Icon
                        icon="ep:calculator"
                        style="font-size: 18px; margin-right: 8px; color: #67c23a"
                      />
                      <span style="font-size: 15px; font-weight: 600">实时计算示例</span>
                    </div>
                  </template>
                  <div style="padding: 12px 0">
                    <div
                      style="
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                        gap: 16px;
                      "
                    >
                      <div
                        style="
                          background: white;
                          padding: 16px;
                          border-radius: 8px;
                          border-left: 4px solid #409eff;
                        "
                      >
                        <div style="font-size: 12px; color: #909399; margin-bottom: 8px"
                          >2km距离</div
                        >
                        <div style="font-size: 20px; font-weight: 600; color: #409eff">
                          {{ formData.sameCityStartPrice || 0 }}元
                        </div>
                        <div style="font-size: 11px; color: #909399; margin-top: 4px"
                          >（在起步距离内）</div
                        >
                      </div>
                      <div
                        style="
                          background: white;
                          padding: 16px;
                          border-radius: 8px;
                          border-left: 4px solid #67c23a;
                        "
                      >
                        <div style="font-size: 12px; color: #909399; margin-bottom: 8px"
                          >5km距离</div
                        >
                        <div style="font-size: 20px; font-weight: 600; color: #67c23a">
                          {{
                            formData.sameCityStartPrice &&
                            formData.sameCityExtraPrice &&
                            formData.sameCityStartDistance
                              ? (
                                  formData.sameCityStartPrice +
                                  Math.ceil(
                                    (5 - formData.sameCityStartDistance) /
                                      (formData.sameCityExtraDistance || 1)
                                  ) *
                                    formData.sameCityExtraPrice
                                ).toFixed(2)
                              : 0
                          }}元
                        </div>
                        <div style="font-size: 11px; color: #909399; margin-top: 4px"
                          >（超过起步距离）</div
                        >
                      </div>
                      <div
                        style="
                          background: white;
                          padding: 16px;
                          border-radius: 8px;
                          border-left: 4px solid #e6a23c;
                        "
                      >
                        <div style="font-size: 12px; color: #909399; margin-bottom: 8px"
                          >10km距离</div
                        >
                        <div style="font-size: 20px; font-weight: 600; color: #e6a23c">
                          {{
                            formData.sameCityStartPrice &&
                            formData.sameCityExtraPrice &&
                            formData.sameCityStartDistance
                              ? (
                                  formData.sameCityStartPrice +
                                  Math.ceil(
                                    (10 - formData.sameCityStartDistance) /
                                      (formData.sameCityExtraDistance || 1)
                                  ) *
                                    formData.sameCityExtraPrice
                                ).toFixed(2)
                              : 0
                          }}元
                        </div>
                        <div style="font-size: 11px; color: #909399; margin-top: 4px"
                          >（超过起步距离）</div
                        >
                      </div>
                    </div>
                  </div>
                </el-card>
              </template>

              <!-- 固定费用配置 -->
              <template v-if="formData.sameCityChargeMode === 2">
                <el-form-item label="固定配送费" prop="sameCityFixedPrice">
                  <el-input-number
                    v-model="formData.sameCityFixedPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="固定配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：元</el-text>
                </el-form-item>
                <el-form-item label="最大配送距离" prop="sameCityMaxDistance">
                  <el-input-number
                    v-model="formData.sameCityMaxDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="最大配送距离"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    超过此距离不支持同城配送，单位：公里
                  </el-text>
                </el-form-item>
                <el-alert type="warning" :closable="false" show-icon class="mb-15px">
                  <template #default>
                    <div>
                      <p class="mb-5px"><strong>计费说明：</strong></p>
                      <p class="mb-0">无论距离远近，统一收取固定配送费</p>
                    </div>
                  </template>
                </el-alert>
              </template>

              <!-- 自定义费用配置 -->
              <template v-if="formData.sameCityChargeMode === 3">
                <el-form-item label="启用自定义费用" prop="sameCityCustomPriceEnabled">
                  <el-switch
                    v-model="formData.sameCityCustomPriceEnabled"
                    style="user-select: none"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    开启后，用户可在下单时手动填写同城配送费用
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.sameCityCustomPriceEnabled"
                  label="最低配送费"
                  prop="sameCityCustomMinPrice"
                >
                  <el-input-number
                    v-model="formData.sameCityCustomMinPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="最低配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    用户填写配送费的最低金额限制，单位：元
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.sameCityCustomPriceEnabled"
                  label="最高配送费"
                  prop="sameCityCustomMaxPrice"
                >
                  <el-input-number
                    v-model="formData.sameCityCustomMaxPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="最高配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    用户填写配送费的最高金额限制，单位：元（0表示不限制）
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.sameCityCustomPriceEnabled"
                  label="是否需要商家审核"
                  prop="sameCityCustomNeedAudit"
                >
                  <el-switch v-model="formData.sameCityCustomNeedAudit" style="user-select: none" />
                  <el-text class="ml-10px" size="small" type="info">
                    开启后，用户填写的配送费需要商家审核确认后才能支付
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.sameCityCustomPriceEnabled"
                  label="默认配送费"
                  prop="sameCityCustomDefaultPrice"
                >
                  <el-input-number
                    v-model="formData.sameCityCustomDefaultPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="默认配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    用户下单时显示的默认配送费，单位：元（用户可修改）
                  </el-text>
                </el-form-item>
                <el-alert type="warning" :closable="false" show-icon class="mb-15px">
                  <template #default>
                    <div>
                      <p class="mb-5px"><strong>使用说明：</strong></p>
                      <p class="mb-0"> • 用户选择同城配送后，可在下单页面手动填写配送费用 </p>
                      <p class="mb-0"> • 适用于商家与用户沟通后确定配送费的特殊场景 </p>
                      <p class="mb-0"> • 可设置费用范围限制，防止用户填写异常金额 </p>
                      <p class="mb-0"> • 如需商家审核，用户提交订单后需等待商家确认配送费 </p>
                    </div>
                  </template>
                </el-alert>
              </template>

              <!-- 配送范围管理 -->
              <el-divider content-position="left">配送范围管理</el-divider>
              <el-alert type="info" :closable="false" show-icon class="mb-15px">
                <template #default>
                  <div>
                    <p class="mb-5px"><strong>功能说明：</strong></p>
                    <p class="mb-0">
                      设置配送范围的文字描述，该说明将展示给用户，帮助用户了解同城配送的服务范围
                    </p>
                  </div>
                </template>
              </el-alert>
              <el-form-item label="配送范围限制说明" prop="sameCityDeliveryRangeDescription">
                <el-input
                  v-model="formData.sameCityDeliveryRangeDescription"
                  type="textarea"
                  :rows="4"
                  placeholder="请输入配送范围限制说明，例如：配送范围覆盖XX区域内，配送距离不超过XX公里，超过此范围暂不支持同城配送"
                  maxlength="500"
                  show-word-limit
                />
                <el-text class="mt-5px block" size="small" type="info">
                  该说明将显示在用户下单页面，帮助用户了解配送范围限制，建议包含配送区域、距离限制等信息
                </el-text>
              </el-form-item>

              <!-- 保存按钮区域 -->
              <el-card shadow="never" style="margin-bottom: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none">
                <div style="display: flex; align-items: center; justify-content: flex-end; flex-wrap: wrap; gap: 16px; padding: 4px 0">
                  <el-button
                    :loading="formLoading"
                    type="primary"
                    size="default"
                    style="min-width: 120px; background: white; color: #667eea; border: none; font-weight: 500"
                    @click="submitForm"
                  >
                    <Icon icon="ep:check" class="mr-5px" />
                    保存配置
                  </el-button>
                </div>
              </el-card>
            </el-tab-pane>

            <!-- Tab 4: 门店自配送 -->
            <el-tab-pane label="门店自配送" name="store">
              <!-- 启用开关 -->
              <el-form-item label="启用门店自配送" prop="deliveryStoreEnabled">
                <el-switch v-model="formData.deliveryStoreEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，用户可以在APP端选择门店自配送
                </el-text>
              </el-form-item>

              <!-- 门店自配送包邮配置（提前展示） -->
              <el-divider content-position="left">门店自配送包邮配置</el-divider>
              <el-form-item label="启用包邮" prop="storeFreeEnabled">
                <el-switch v-model="formData.storeFreeEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，满足条件可免门店自配送费
                </el-text>
              </el-form-item>
              <el-form-item v-if="formData.storeFreeEnabled" label="满额包邮" prop="storeFreePrice">
                <el-input-number
                  v-model="formData.storeFreePrice"
                  :min="0"
                  :precision="2"
                  class="!w-xs"
                  placeholder="满额包邮"
                />
                <el-text class="ml-10px" size="small" type="info">
                  订单金额满多少元可免门店自配送费，单位：元
                </el-text>
              </el-form-item>
              <!-- 门店自配送收费配置 -->
              <el-divider content-position="left">门店自配送收费配置</el-divider>
              <el-form-item label="计费方式" prop="storeChargeMode">
                <el-radio-group v-model="formData.storeChargeMode">
                  <el-radio :value="1">按距离计费</el-radio>
                  <el-radio :value="2">固定费用</el-radio>
                  <el-radio :value="3">自定义费用</el-radio>
                </el-radio-group>
                <el-text class="ml-10px" size="small" type="info">
                  选择门店自配送的计费方式
                </el-text>
              </el-form-item>

              <!-- 按距离计费配置 -->
              <template v-if="formData.storeChargeMode === 1">
                <!-- 字段配置说明 -->
                <el-collapse class="mb-20px">
                  <el-collapse-item name="storeConfigDescription">
                    <template #title>
                      <div style="display: flex; align-items: center">
                        <Icon
                          icon="ep:setting"
                          style="font-size: 18px; margin-right: 8px; color: #409eff"
                        />
                        <span style="font-size: 15px; font-weight: 600">配置项说明</span>
                      </div>
                    </template>
                    <el-descriptions :column="1" border>
                      <el-descriptions-item label="起步距离">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px">配送距离的起始范围</div>
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为3km，表示3公里内的配送都按起步价收费
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="起步价">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >起步距离内的固定配送费</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为10元，表示3km内统一收费10元
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="续距">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >超过起步距离后，每增加多少公里加收费用</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为1km，表示每超过1km就加收一次续费
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="续费">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >每增加一个续距单位收取的费用</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为5元，表示每超过1km加收5元
                          </div>
                        </div>
                      </el-descriptions-item>
                      <el-descriptions-item label="最大配送距离">
                        <div>
                          <div style="font-weight: 500; margin-bottom: 4px"
                            >支持门店自配送的最大距离限制</div
                          >
                          <div style="font-size: 12px; color: #909399">
                            例如：设置为20km，超过20km的地址将不支持门店自配送
                          </div>
                        </div>
                      </el-descriptions-item>
                    </el-descriptions>
                  </el-collapse-item>
                </el-collapse>

                <!-- 配置表单 -->
                <el-form-item label="起步距离" prop="storeStartDistance">
                  <el-input-number
                    v-model="formData.storeStartDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="起步距离"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：公里</el-text>
                </el-form-item>
                <el-form-item label="起步价" prop="storeStartPrice">
                  <el-input-number
                    v-model="formData.storeStartPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="起步价"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：元</el-text>
                </el-form-item>
                <el-form-item label="续距" prop="storeExtraDistance">
                  <el-input-number
                    v-model="formData.storeExtraDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="续距"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：公里</el-text>
                </el-form-item>
                <el-form-item label="续费" prop="storeExtraPrice">
                  <el-input-number
                    v-model="formData.storeExtraPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="续费"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：元</el-text>
                </el-form-item>
                <el-form-item label="最大配送距离" prop="storeMaxDistance">
                  <el-input-number
                    v-model="formData.storeMaxDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="最大配送距离"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    超过此距离不支持门店自配送，单位：公里
                  </el-text>
                </el-form-item>

                <!-- 实时计算示例 -->
                <el-card shadow="never" class="mt-20px" style="background: #f8f9fa">
                  <template #header>
                    <div style="display: flex; align-items: center">
                      <Icon
                        icon="ep:calculator"
                        style="font-size: 18px; margin-right: 8px; color: #67c23a"
                      />
                      <span style="font-size: 15px; font-weight: 600">实时计算示例</span>
                    </div>
                  </template>
                  <div style="padding: 12px 0">
                    <div
                      style="
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                        gap: 16px;
                      "
                    >
                      <div
                        style="
                          background: white;
                          padding: 16px;
                          border-radius: 8px;
                          border-left: 4px solid #409eff;
                        "
                      >
                        <div style="font-size: 12px; color: #909399; margin-bottom: 8px"
                          >2km距离</div
                        >
                        <div style="font-size: 20px; font-weight: 600; color: #409eff">
                          {{ formData.storeStartPrice || 0 }}元
                        </div>
                        <div style="font-size: 11px; color: #909399; margin-top: 4px"
                          >（在起步距离内）</div
                        >
                      </div>
                      <div
                        style="
                          background: white;
                          padding: 16px;
                          border-radius: 8px;
                          border-left: 4px solid #67c23a;
                        "
                      >
                        <div style="font-size: 12px; color: #909399; margin-bottom: 8px"
                          >5km距离</div
                        >
                        <div style="font-size: 20px; font-weight: 600; color: #67c23a">
                          {{
                            formData.storeStartPrice &&
                            formData.storeExtraPrice &&
                            formData.storeStartDistance
                              ? (
                                  formData.storeStartPrice +
                                  Math.ceil(
                                    (5 - formData.storeStartDistance) /
                                      (formData.storeExtraDistance || 1)
                                  ) *
                                    formData.storeExtraPrice
                                ).toFixed(2)
                              : 0
                          }}元
                        </div>
                        <div style="font-size: 11px; color: #909399; margin-top: 4px"
                          >（超过起步距离）</div
                        >
                      </div>
                      <div
                        style="
                          background: white;
                          padding: 16px;
                          border-radius: 8px;
                          border-left: 4px solid #e6a23c;
                        "
                      >
                        <div style="font-size: 12px; color: #909399; margin-bottom: 8px"
                          >10km距离</div
                        >
                        <div style="font-size: 20px; font-weight: 600; color: #e6a23c">
                          {{
                            formData.storeStartPrice &&
                            formData.storeExtraPrice &&
                            formData.storeStartDistance
                              ? (
                                  formData.storeStartPrice +
                                  Math.ceil(
                                    (10 - formData.storeStartDistance) /
                                      (formData.storeExtraDistance || 1)
                                  ) *
                                    formData.storeExtraPrice
                                ).toFixed(2)
                              : 0
                          }}元
                        </div>
                        <div style="font-size: 11px; color: #909399; margin-top: 4px"
                          >（超过起步距离）</div
                        >
                      </div>
                    </div>
                  </div>
                </el-card>
              </template>

              <!-- 固定费用配置 -->
              <template v-if="formData.storeChargeMode === 2">
                <el-form-item label="固定配送费" prop="storeFixedPrice">
                  <el-input-number
                    v-model="formData.storeFixedPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="固定配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">单位：元</el-text>
                </el-form-item>
                <el-form-item label="最大配送距离" prop="storeMaxDistance">
                  <el-input-number
                    v-model="formData.storeMaxDistance"
                    :min="0"
                    :precision="1"
                    class="!w-xs"
                    placeholder="最大配送距离"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    超过此距离不支持门店自配送，单位：公里
                  </el-text>
                </el-form-item>
                <el-alert type="warning" :closable="false" show-icon class="mb-15px">
                  <template #default>
                    <div>
                      <p class="mb-5px"><strong>计费说明：</strong></p>
                      <p class="mb-0">无论距离远近，统一收取固定配送费</p>
                    </div>
                  </template>
                </el-alert>
              </template>

              <!-- 自定义费用配置 -->
              <template v-if="formData.storeChargeMode === 3">
                <el-form-item label="启用自定义费用" prop="storeCustomPriceEnabled">
                  <el-switch v-model="formData.storeCustomPriceEnabled" style="user-select: none" />
                  <el-text class="ml-10px" size="small" type="info">
                    开启后，用户可在下单时手动填写门店自配送费用
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.storeCustomPriceEnabled"
                  label="最低配送费"
                  prop="storeCustomMinPrice"
                >
                  <el-input-number
                    v-model="formData.storeCustomMinPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="最低配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    用户填写配送费的最低金额限制，单位：元
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.storeCustomPriceEnabled"
                  label="最高配送费"
                  prop="storeCustomMaxPrice"
                >
                  <el-input-number
                    v-model="formData.storeCustomMaxPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="最高配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    用户填写配送费的最高金额限制，单位：元（0表示不限制）
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.storeCustomPriceEnabled"
                  label="是否需要商家审核"
                  prop="storeCustomNeedAudit"
                >
                  <el-switch v-model="formData.storeCustomNeedAudit" style="user-select: none" />
                  <el-text class="ml-10px" size="small" type="info">
                    开启后，用户填写的配送费需要商家审核确认后才能支付
                  </el-text>
                </el-form-item>
                <el-form-item
                  v-if="formData.storeCustomPriceEnabled"
                  label="默认配送费"
                  prop="storeCustomDefaultPrice"
                >
                  <el-input-number
                    v-model="formData.storeCustomDefaultPrice"
                    :min="0"
                    :precision="2"
                    class="!w-xs"
                    placeholder="默认配送费"
                  />
                  <el-text class="ml-10px" size="small" type="info">
                    用户下单时显示的默认配送费，单位：元（用户可修改）
                  </el-text>
                </el-form-item>
                <el-alert type="warning" :closable="false" show-icon class="mb-15px">
                  <template #default>
                    <div>
                      <p class="mb-5px"><strong>使用说明：</strong></p>
                      <p class="mb-0"> • 用户选择门店自配送后，可在下单页面手动填写配送费用 </p>
                      <p class="mb-0"> • 适用于商家与用户沟通后确定配送费的特殊场景 </p>
                      <p class="mb-0"> • 可设置费用范围限制，防止用户填写异常金额 </p>
                      <p class="mb-0"> • 如需商家审核，用户提交订单后需等待商家确认配送费 </p>
                    </div>
                  </template>
                </el-alert>
              </template>

              <!-- 门店配送范围管理 -->
              <el-divider content-position="left">门店配送范围管理</el-divider>
              <el-alert type="info" :closable="false" show-icon class="mb-15px">
                <template #default>
                  <div>
                    <p class="mb-5px"><strong>功能说明：</strong></p>
                    <p class="mb-0">
                      上传门店配送范围示意图，图片将用于展示给用户和客服，支持上传、修改、删除操作
                    </p>
                  </div>
                </template>
              </el-alert>
              <el-form-item label="配送范围示意图" prop="storeDeliveryRangeImageUrl">
                <UploadImg
                  v-model="formData.storeDeliveryRangeImageUrl"
                  :width="'100%'"
                  :height="'400px'"
                  :show-delete="true"
                  :show-btn-text="false"
                >
                  <template #tip>
                    <el-text size="small" type="info">
                      支持上传门店配送范围示意图，建议图片清晰，包含配送中心位置和覆盖范围标注
                    </el-text>
                  </template>
                </UploadImg>
              </el-form-item>

              <!-- 保存按钮区域 -->
              <el-card shadow="never" style="margin: 20px 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none">
                <div style="display: flex; align-items: center; justify-content: flex-end; flex-wrap: wrap; gap: 16px; padding: 4px 0">
                  <el-button
                    :loading="formLoading"
                    type="primary"
                    size="default"
                    style="min-width: 120px; background: white; color: #667eea; border: none; font-weight: 500"
                    @click="submitForm"
                  >
                    <Icon icon="ep:check" class="mr-5px" />
                    保存配置
                  </el-button>
                </div>
              </el-card>
            </el-tab-pane>
          </el-tabs>
        </el-tab-pane>

        <!-- 包装费 -->
        <el-tab-pane label="包装费" name="packaging">
          <el-form-item label="启用包装费" prop="packagingFeeEnabled">
            <el-switch v-model="formData.packagingFeeEnabled" style="user-select: none" />
            <el-text class="w-full" size="small" type="info"> 商城是否启用包装费</el-text>
          </el-form-item>
          <el-form-item
            v-if="formData.packagingFeeEnabled"
            label="包装费金额"
            prop="packagingFeePrice"
          >
            <el-input-number
              v-model="formData.packagingFeePrice"
              :min="0"
              :precision="2"
              class="!w-xs"
              placeholder="请输入包装费金额"
            />
            <el-text class="w-full" size="small" type="info">
              每笔订单收取的包装费金额，单位：元
            </el-text>
          </el-form-item>

          <el-form-item
            v-if="formData.packagingFeeEnabled"
            label="启用满额免包装费"
            prop="packagingFeeFreeEnabled"
          >
            <el-switch v-model="formData.packagingFeeFreeEnabled" style="user-select: none" />
            <el-text class="w-full" size="small" type="info">
              订单金额达到设定金额时，免收包装费
            </el-text>
          </el-form-item>

          <el-form-item
            v-if="formData.packagingFeeEnabled && formData.packagingFeeFreeEnabled"
            label="满额免包装费金额"
            prop="packagingFeeFreePrice"
          >
            <el-input-number
              v-model="formData.packagingFeeFreePrice"
              :min="0"
              :precision="2"
              class="!w-xs"
              placeholder="请输入满额免包装费金额"
            />
            <el-text class="w-full" size="small" type="info">
              订单金额达到此金额时，免收包装费，单位：元
            </el-text>
          </el-form-item>

          <!-- 保存按钮区域 -->
          <div style="display: flex; align-items: center; justify-content: flex-end; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e4e7ed">
            <el-button
              :loading="formLoading"
              type="primary"
              size="default"
              @click="submitForm"
            >
              <Icon icon="ep:check" class="mr-5px" />
              保存配置
            </el-button>
          </div>
        </el-tab-pane>
        <!-- 分销 -->
        <el-tab-pane label="分销" name="brokerage">
          <el-form-item label="分佣启用" prop="brokerageEnabled">
            <el-switch v-model="formData.brokerageEnabled" style="user-select: none" />
            <el-text class="w-full" size="small" type="info"> 商城是否开启分销模式</el-text>
          </el-form-item>
          <el-form-item label="分佣模式" prop="brokerageEnabledCondition">
            <el-radio-group v-model="formData.brokerageEnabledCondition">
              <el-radio
                v-for="dict in getIntDictOptions(DICT_TYPE.BROKERAGE_ENABLED_CONDITION)"
                :key="dict.value"
                :value="dict.value"
              >
                {{ dict.label }}
              </el-radio>
            </el-radio-group>
            <el-text class="w-full" size="small" type="info">
              人人分销：每个用户都可以成为推广员
            </el-text>
            <el-text class="w-full" size="small" type="info">
              指定分销：仅可在后台手动设置推广员
            </el-text>
          </el-form-item>
          <el-form-item label="分销关系绑定" prop="brokerageBindMode">
            <el-radio-group v-model="formData.brokerageBindMode">
              <el-radio
                v-for="dict in getIntDictOptions(DICT_TYPE.BROKERAGE_BIND_MODE)"
                :key="dict.value"
                :value="dict.value"
              >
                {{ dict.label }}
              </el-radio>
            </el-radio-group>
            <el-text class="w-full" size="small" type="info">
              首次绑定：只要用户没有推广人，随时都可以绑定推广关系
            </el-text>
            <el-text class="w-full" size="small" type="info">
              注册绑定：只有新用户注册时或首次进入系统时才可以绑定推广关系
            </el-text>
          </el-form-item>
          <el-form-item label="分销海报图">
            <UploadImgs v-model="formData.brokeragePosterUrls" height="125px" width="75px" />
            <el-text class="w-full" size="small" type="info">
              个人中心分销海报图片，建议尺寸 600x1000
            </el-text>
          </el-form-item>
          <el-form-item label="一级返佣比例" prop="brokerageFirstPercent">
            <el-input-number
              v-model="formData.brokerageFirstPercent"
              :max="100"
              :min="0"
              class="!w-xs"
              placeholder="请输入一级返佣比例"
            />
            <el-text class="w-full" size="small" type="info">
              订单交易成功后给推广人返佣的百分比
            </el-text>
          </el-form-item>
          <el-form-item label="二级返佣比例" prop="brokerageSecondPercent">
            <el-input-number
              v-model="formData.brokerageSecondPercent"
              :max="100"
              :min="0"
              class="!w-xs"
              placeholder="请输入二级返佣比例"
            />
            <el-text class="w-full" size="small" type="info">
              订单交易成功后给推广人的推荐人返佣的百分比
            </el-text>
          </el-form-item>
          <el-form-item label="佣金冻结天数" prop="brokerageFrozenDays">
            <el-input-number
              v-model="formData.brokerageFrozenDays"
              :min="0"
              class="!w-xs"
              placeholder="请输入佣金冻结天数"
            />
            <el-text class="w-full" size="small" type="info">
              防止用户退款，佣金被提现了，所以需要设置佣金冻结时间，单位：天
            </el-text>
          </el-form-item>
          <el-form-item label="提现最低金额" prop="brokerageWithdrawMinPrice">
            <el-input-number
              v-model="formData.brokerageWithdrawMinPrice"
              :min="0"
              :precision="2"
              class="!w-xs"
              placeholder="请输入提现最低金额"
            />
            <el-text class="w-full" size="small" type="info">
              用户提现最低金额限制，单位：元
            </el-text>
          </el-form-item>
          <el-form-item label="提现手续费" prop="brokerageWithdrawFeePercent">
            <el-input-number
              v-model="formData.brokerageWithdrawFeePercent"
              :max="100"
              :min="0"
              class="!w-xs"
              placeholder="请输入提现手续费"
            />
            <el-text class="w-full" size="small" type="info">
              提现手续费百分比，范围 0-100，0 为无提现手续费。例：设置 10，即收取 10% 手续费，提现
              10 元，到账 9 元，1 元手续费
            </el-text>
          </el-form-item>
          <el-form-item label="提现方式" prop="brokerageWithdrawTypes">
            <el-checkbox-group v-model="formData.brokerageWithdrawTypes">
              <el-checkbox
                v-for="dict in getIntDictOptions(DICT_TYPE.BROKERAGE_WITHDRAW_TYPE)"
                :key="dict.value"
                :value="dict.value"
              >
                {{ dict.label }}
              </el-checkbox>
            </el-checkbox-group>
            <el-text class="w-full" size="small" type="info"> 商城开通提现的付款方式</el-text>
          </el-form-item>

          <!-- 保存按钮区域 -->
          <div style="display: flex; align-items: center; justify-content: flex-end; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e4e7ed">
            <el-button
              :loading="formLoading"
              type="primary"
              size="default"
              @click="submitForm"
            >
              <Icon icon="ep:check" class="mr-5px" />
              保存配置
            </el-button>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-form>

    <!-- 运费模板表单弹窗 -->
    <ExpressTemplateForm ref="expressTemplateFormRef" @success="handleExpressTemplateQuery" />

    <!-- 快递公司表单弹窗 -->
    <ExpressForm ref="expressFormRef" @success="handleExpressQuery" />

    <!-- 门店自提表单弹窗 -->
    <PickUpStoreForm ref="pickUpStoreFormRef" @success="handlePickUpStoreQuery" />

    <!-- 门店自提绑定店员表单弹窗 -->
    <DeliveryPickUpStoreBindForm ref="pickUpStoreBindFormRef" />
  </ContentWrap>
</template>

<script lang="ts" setup>
import * as ConfigApi from '@/api/mall/trade/config'
import * as DeliveryExpressTemplateApi from '@/api/mall/trade/delivery/expressTemplate'
import * as DeliveryExpressApi from '@/api/mall/trade/delivery/express'
import * as DeliveryPickUpStoreApi from '@/api/mall/trade/delivery/pickUpStore'
import ExpressTemplateForm from '@/views/mall/trade/delivery/expressTemplate/ExpressTemplateForm.vue'
import ExpressForm from '@/views/mall/trade/delivery/express/ExpressForm.vue'
import PickUpStoreForm from '@/views/mall/trade/delivery/pickUpStore/PickUpStoreForm.vue'
import DeliveryPickUpStoreBindForm from '@/views/mall/trade/delivery/pickUpStore/DeliveryPickUpStoreBindForm.vue'
import { DICT_TYPE, getIntDictOptions } from '@/utils/dict'
import { dateFormatter } from '@/utils/formatTime'
import { cloneDeep } from 'lodash-es'
import UploadImg from '@/components/UploadFile/src/UploadImg.vue'

defineOptions({ name: 'TradeConfig' })

const message = useMessage() // 消息弹窗

const formLoading = ref(false) // 表单的加载中：1）修改时的数据加载；2）提交的按钮禁用
const formRef = ref()
const activeMainTab = ref('afterSale') // 当前激活的主Tab
const activeDeliveryTab = ref('express') // 当前激活的配送子Tab
const formData = ref({
  id: null,
  afterSaleRefundReasons: [],
  afterSaleReturnReasons: [],
  deliveryExpressEnabled: true, // 启用快递发货（默认开启）
  deliveryExpressFreeEnabled: false,
  deliveryExpressFreePrice: 0,
  deliveryPickUpEnabled: false,
  deliverySameCityEnabled: false, // 启用同城配送（功能开发中）
  // 同城配送收费配置
  sameCityChargeMode: 1, // 计费方式：1-按距离，2-固定费用，3-自定义费用
  sameCityStartDistance: 3, // 起步距离（公里）
  sameCityStartPrice: 10, // 起步价（元）
  sameCityExtraDistance: 1, // 续距（公里）
  sameCityExtraPrice: 5, // 续费（元）
  sameCityMaxDistance: 20, // 最大配送距离（公里）
  sameCityFixedPrice: 15, // 固定配送费（元）
  // 自定义费用配置（模式3）
  sameCityCustomPriceEnabled: true, // 启用自定义费用
  sameCityCustomMinPrice: 0, // 最低配送费（元）
  sameCityCustomMaxPrice: 0, // 最高配送费（元，0表示不限制）
  sameCityCustomNeedAudit: false, // 是否需要商家审核
  sameCityCustomDefaultPrice: 10, // 默认配送费（元）
  sameCityFreeEnabled: false, // 启用同城配送包邮
  sameCityFreePrice: 0, // 满额包邮金额（元）
  // 同城配送范围配置
  sameCityDeliveryCenterLatitude: undefined, // 配送中心纬度
  sameCityDeliveryCenterLongitude: undefined, // 配送中心经度
  sameCityDeliveryRange: 20, // 配送范围半径（公里）
  sameCityDeliveryRangeDescription: '', // 配送范围限制说明
  deliveryStoreEnabled: false, // 启用门店自配送（功能开发中）
  // 门店自配送收费配置
  storeChargeMode: 1, // 计费方式：1-按距离，2-固定费用，3-自定义费用
  storeStartDistance: 3, // 起步距离（公里）
  storeStartPrice: 10, // 起步价（元）
  storeExtraDistance: 1, // 续距（公里）
  storeExtraPrice: 5, // 续费（元）
  storeMaxDistance: 20, // 最大配送距离（公里）
  storeFixedPrice: 15, // 固定配送费（元）
  // 自定义费用配置（模式3）
  storeCustomPriceEnabled: true, // 启用自定义费用
  storeCustomMinPrice: 0, // 最低配送费（元）
  storeCustomMaxPrice: 0, // 最高配送费（元，0表示不限制）
  storeCustomNeedAudit: false, // 是否需要商家审核
  storeCustomDefaultPrice: 10, // 默认配送费（元）
  storeFreeEnabled: false, // 启用门店自配送包邮
  storeFreePrice: 0, // 满额包邮金额（元）
  storeDeliveryRangeImageUrl: '', // 门店配送范围示意图URL
  packagingFeeEnabled: false,
  packagingFeePrice: 0,
  packagingFeeFreeEnabled: false,
  packagingFeeFreePrice: 0,
  brokerageEnabled: false,
  brokerageEnabledCondition: undefined,
  brokerageBindMode: undefined,
  brokeragePosterUrls: [],
  brokerageFirstPercent: 0,
  brokerageSecondPercent: 0,
  brokerageWithdrawMinPrice: 0,
  brokerageWithdrawFeePercent: 0,
  brokerageFrozenDays: 0,
  brokerageWithdrawTypes: []
})

// ========== 运费模板管理 ==========
const expressTemplateLoading = ref(false)
const expressTemplateList = ref<any[]>([])
const expressTemplateQuery = reactive({
  pageNo: 1,
  pageSize: 10,
  name: '',
  chargeMode: undefined
})
const expressTemplateFormRef = ref()

const handleExpressTemplateQuery = async () => {
  expressTemplateQuery.pageNo = 1
  await getExpressTemplateList()
}

const resetExpressTemplateQuery = () => {
  expressTemplateQuery.name = ''
  expressTemplateQuery.chargeMode = undefined
  handleExpressTemplateQuery()
}

const getExpressTemplateList = async () => {
  expressTemplateLoading.value = true
  try {
    const data =
      await DeliveryExpressTemplateApi.getDeliveryExpressTemplatePage(expressTemplateQuery)
    expressTemplateList.value = data.list
  } finally {
    expressTemplateLoading.value = false
  }
}

const openExpressTemplateForm = (type: string, id?: number) => {
  expressTemplateFormRef.value.open(type, id)
}

const handleExpressTemplateDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await DeliveryExpressTemplateApi.deleteDeliveryExpressTemplate(id)
    message.success('删除成功')
    await getExpressTemplateList()
  } catch {}
}

// ========== 快递公司管理 ==========
const expressLoading = ref(false)
const expressList = ref<any[]>([])
const expressQuery = reactive({
  pageNo: 1,
  pageSize: 10,
  code: '',
  name: ''
})
const expressFormRef = ref()

const handleExpressQuery = async () => {
  expressQuery.pageNo = 1
  await getExpressList()
}

const resetExpressQuery = () => {
  expressQuery.code = ''
  expressQuery.name = ''
  handleExpressQuery()
}

const getExpressList = async () => {
  expressLoading.value = true
  try {
    const data = await DeliveryExpressApi.getDeliveryExpressPage(expressQuery)
    expressList.value = data.list
  } finally {
    expressLoading.value = false
  }
}

const openExpressForm = (type: string, id?: number) => {
  expressFormRef.value.open(type, id)
}

const handleExpressDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await DeliveryExpressApi.deleteDeliveryExpress(id)
    message.success('删除成功')
    await getExpressList()
  } catch {}
}

// ========== 门店自提管理 ==========
const pickUpStoreLoading = ref(false)
const pickUpStoreList = ref<any[]>([])
const pickUpStoreQuery = reactive({
  pageNo: 1,
  pageSize: 10,
  name: '',
  phone: undefined,
  status: undefined
})
const pickUpStoreFormRef = ref()
const pickUpStoreBindFormRef = ref()

const handlePickUpStoreQuery = async () => {
  pickUpStoreQuery.pageNo = 1
  await getPickUpStoreList()
}

const resetPickUpStoreQuery = () => {
  pickUpStoreQuery.name = ''
  pickUpStoreQuery.phone = undefined
  pickUpStoreQuery.status = undefined
  handlePickUpStoreQuery()
}

const getPickUpStoreList = async () => {
  pickUpStoreLoading.value = true
  try {
    const data = await DeliveryPickUpStoreApi.getDeliveryPickUpStorePage(pickUpStoreQuery)
    pickUpStoreList.value = data.list
  } finally {
    pickUpStoreLoading.value = false
  }
}

const openPickUpStoreForm = (type: string, id?: number) => {
  pickUpStoreFormRef.value.open(type, id)
}

const openPickUpStoreFormBind = (id: number) => {
  pickUpStoreBindFormRef.value.open(id)
}

const handlePickUpStoreDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await DeliveryPickUpStoreApi.deleteDeliveryPickUpStore(id)
    message.success('删除成功')
    await getPickUpStoreList()
  } catch {}
}

// ========== 门店自配送配送范围管理 ==========
// 注：配送范围管理功能已预留，待后续开发
const formRules = reactive({
  // 全局包邮价格：只有在启用包邮时才必填
  deliveryExpressFreePrice: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.deliveryExpressFreeEnabled && (!value || value <= 0)) {
          callback(new Error('启用包邮时，满额包邮金额必须大于0'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  // 包装费：只有在启用包装费时才必填
  packagingFeePrice: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.packagingFeeEnabled && (!value || value <= 0)) {
          callback(new Error('启用包装费时，包装费金额必须大于0'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  // 满额免包装费金额：只有在启用满额免包装费时才必填
  packagingFeeFreePrice: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.packagingFeeEnabled && formData.value.packagingFeeFreeEnabled && (!value || value <= 0)) {
          callback(new Error('启用满额免包装费时，满额免包装费金额必须大于0'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  // 分销相关字段：只有在启用分销时才必填
  brokerageEnabledCondition: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && !value) {
          callback(new Error('启用分佣时，分佣模式不能为空'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ],
  brokerageBindMode: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && !value) {
          callback(new Error('启用分佣时，分销关系绑定模式不能为空'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ],
  brokerageFirstPercent: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && (value === undefined || value === null)) {
          callback(new Error('启用分佣时，一级返佣比例不能为空'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  brokerageSecondPercent: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && (value === undefined || value === null)) {
          callback(new Error('启用分佣时，二级返佣比例不能为空'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  brokerageWithdrawMinPrice: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && (!value || value <= 0)) {
          callback(new Error('启用分佣时，用户提现最低金额必须大于0'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  brokerageWithdrawFeePercent: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && (value === undefined || value === null)) {
          callback(new Error('启用分佣时，提现手续费不能为空'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  brokerageFrozenDays: [
    {
      validator: (_rule, value, callback) => {
        if (formData.value.brokerageEnabled && (!value || value < 0)) {
          callback(new Error('启用分佣时，佣金冻结时间不能为空且必须大于等于0'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  brokerageWithdrawTypes: [
    {
      validator: (_rule, value, callback) => {
        if (
          formData.value.brokerageEnabled &&
          (!value || (Array.isArray(value) && value.length === 0))
        ) {
          callback(new Error('启用分佣时，提现方式不能为空'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ]
})

// 获取当前Tab需要保存的字段列表
const getCurrentTabFields = (): string[] => {
  const mainTab = activeMainTab.value
  const deliveryTab = activeDeliveryTab.value

  // 根据当前激活的Tab返回需要保存的字段
  if (mainTab === 'afterSale') {
    return ['afterSaleRefundReasons', 'afterSaleReturnReasons']
  } else if (mainTab === 'delivery') {
    if (deliveryTab === 'express') {
      return ['deliveryExpressEnabled', 'deliveryExpressFreeEnabled', 'deliveryExpressFreePrice']
    } else if (deliveryTab === 'pickUp') {
      return ['deliveryPickUpEnabled']
    } else if (deliveryTab === 'sameCity') {
      return [
        'deliverySameCityEnabled',
        'sameCityChargeMode',
        'sameCityStartDistance',
        'sameCityStartPrice',
        'sameCityExtraDistance',
        'sameCityExtraPrice',
        'sameCityMaxDistance',
        'sameCityFixedPrice',
        'sameCityCustomPriceEnabled',
        'sameCityCustomMinPrice',
        'sameCityCustomMaxPrice',
        'sameCityCustomNeedAudit',
        'sameCityCustomDefaultPrice',
        'sameCityFreeEnabled',
        'sameCityFreePrice',
        'sameCityDeliveryRangeDescription'
      ]
    } else if (deliveryTab === 'store') {
      return [
        'deliveryStoreEnabled',
        'storeChargeMode',
        'storeStartDistance',
        'storeStartPrice',
        'storeExtraDistance',
        'storeExtraPrice',
        'storeMaxDistance',
        'storeFixedPrice',
        'storeCustomPriceEnabled',
        'storeCustomMinPrice',
        'storeCustomMaxPrice',
        'storeCustomNeedAudit',
        'storeCustomDefaultPrice',
        'storeFreeEnabled',
        'storeFreePrice',
        'storeDeliveryRangeImageUrl'
      ]
    }
  } else if (mainTab === 'packaging') {
    return ['packagingFeeEnabled', 'packagingFeePrice', 'packagingFeeFreeEnabled', 'packagingFeeFreePrice']
  } else if (mainTab === 'brokerage') {
    return [
      'brokerageEnabled',
      'brokerageEnabledCondition',
      'brokerageBindMode',
      'brokeragePosterUrls',
      'brokerageFirstPercent',
      'brokerageSecondPercent',
      'brokerageWithdrawMinPrice',
      'brokerageWithdrawFeePercent',
      'brokerageFrozenDays',
      'brokerageWithdrawTypes'
    ]
  }
  return []
}

const submitForm = async () => {
  if (formLoading.value) return
  // 校验表单
  if (!formRef.value) {
    message.error('表单未初始化，请刷新页面重试')
    return
  }
  // 使用 Promise 方式验证，获取详细的错误信息
  // 只验证当前Tab的字段
  const currentTabFields = getCurrentTabFields()
  try {
    await new Promise<void>((resolve, reject) => {
      formRef.value.validate((valid: boolean, invalidFields: any) => {
        if (valid) {
          resolve()
        } else {
          // 过滤出当前Tab的错误字段
          const currentTabErrors: any = {}
          if (invalidFields) {
            Object.keys(invalidFields).forEach((field) => {
              if (currentTabFields.includes(field)) {
                currentTabErrors[field] = invalidFields[field]
              }
            })
          }
          // 如果当前Tab没有错误，但有其他Tab的错误，忽略
          if (Object.keys(currentTabErrors).length === 0) {
            resolve()
            return
          }
          console.error('表单验证失败，错误字段:', currentTabErrors)
          // 提取所有错误字段的名称和错误信息
          const errorMessages: string[] = []
          Object.keys(currentTabErrors).forEach((field) => {
            const fieldErrors = currentTabErrors[field]
            if (Array.isArray(fieldErrors) && fieldErrors.length > 0) {
              fieldErrors.forEach((err: any) => {
                if (err && err.message) {
                  errorMessages.push(err.message)
                }
              })
            }
          })
          // 显示具体的错误信息
          if (errorMessages.length > 0) {
            const errorText =
              errorMessages.length <= 3
                ? errorMessages.join('；')
                : errorMessages.slice(0, 3).join('；') + `等 ${errorMessages.length} 项错误`
            message.warning(`表单验证失败：${errorText}`)
          } else {
            message.warning('表单验证失败，请检查表单填写是否正确')
          }
          // 自动滚动到第一个错误字段
          const firstErrorField = Object.keys(currentTabErrors)[0]
          if (firstErrorField) {
            // 等待 DOM 更新后再滚动
            setTimeout(() => {
              const errorElement =
                document.querySelector(`[prop="${firstErrorField}"]`) ||
                document.querySelector(`[name="${firstErrorField}"]`) ||
                document.querySelector(`[aria-label*="${firstErrorField}"]`)
              if (errorElement) {
                errorElement.scrollIntoView({ behavior: 'smooth', block: 'center' })
              }
            }, 100)
          }
          reject(new Error('表单验证失败'))
        }
      })
    })
  } catch (error: any) {
    // 验证失败，已经在回调中显示了错误信息，直接返回
    return
  }
  // 提交请求
  formLoading.value = true
  try {
    // 只更新当前Tab的字段
    const currentTabFields = getCurrentTabFields()
    const formDataValue = unref(formData.value)
    
    // 如果是快递发货Tab，使用专门的快递发货接口
    if (activeMainTab.value === 'delivery' && activeDeliveryTab.value === 'express') {
      // 金额需要从元转换为分
      const deliveryExpressFreePrice = formDataValue.deliveryExpressFreePrice != null 
        ? Math.round(formDataValue.deliveryExpressFreePrice * 100) 
        : 0
      await ConfigApi.updateExpressConfig({
        deliveryExpressEnabled: formDataValue.deliveryExpressEnabled ?? false,
        deliveryExpressFreeEnabled: formDataValue.deliveryExpressFreeEnabled ?? false,
        deliveryExpressFreePrice: deliveryExpressFreePrice
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 如果只更新门店自提，使用专门的接口
    if (currentTabFields.length === 1 && currentTabFields[0] === 'deliveryPickUpEnabled') {
      await ConfigApi.updatePickUpConfig({
        deliveryPickUpEnabled: formDataValue.deliveryPickUpEnabled ?? false
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 如果是售后Tab，使用专门的售后接口
    if (activeMainTab.value === 'afterSale') {
      await ConfigApi.updateAfterSaleConfig({
        afterSaleRefundReasons: formDataValue.afterSaleRefundReasons || [],
        afterSaleReturnReasons: formDataValue.afterSaleReturnReasons || []
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 如果是包装费Tab，使用专门的包装费接口
    if (activeMainTab.value === 'packaging') {
      // 金额需要从元转换为分
      const packagingFeePrice = formDataValue.packagingFeePrice != null 
        ? Math.round(formDataValue.packagingFeePrice * 100) 
        : 0
      const packagingFeeFreePrice = formDataValue.packagingFeeFreePrice != null 
        ? Math.round(formDataValue.packagingFeeFreePrice * 100) 
        : 0
      await ConfigApi.updatePackagingConfig({
        packagingFeeEnabled: formDataValue.packagingFeeEnabled ?? false,
        packagingFeePrice: packagingFeePrice,
        packagingFeeFreeEnabled: formDataValue.packagingFeeFreeEnabled ?? false,
        packagingFeeFreePrice: packagingFeeFreePrice
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 如果是同城配送Tab，使用专门的同城配送接口
    if (activeMainTab.value === 'delivery' && activeDeliveryTab.value === 'sameCity') {
      // 金额需要从元转换为分
      const sameCityStartPrice = formDataValue.sameCityStartPrice != null 
        ? Math.round(formDataValue.sameCityStartPrice * 100) 
        : undefined
      const sameCityExtraPrice = formDataValue.sameCityExtraPrice != null 
        ? Math.round(formDataValue.sameCityExtraPrice * 100) 
        : undefined
      const sameCityFixedPrice = formDataValue.sameCityFixedPrice != null 
        ? Math.round(formDataValue.sameCityFixedPrice * 100) 
        : undefined
      const sameCityCustomMinPrice = formDataValue.sameCityCustomMinPrice != null 
        ? Math.round(formDataValue.sameCityCustomMinPrice * 100) 
        : undefined
      const sameCityCustomMaxPrice = formDataValue.sameCityCustomMaxPrice != null 
        ? Math.round(formDataValue.sameCityCustomMaxPrice * 100) 
        : undefined
      const sameCityCustomDefaultPrice = formDataValue.sameCityCustomDefaultPrice != null 
        ? Math.round(formDataValue.sameCityCustomDefaultPrice * 100) 
        : undefined
      const sameCityFreePrice = formDataValue.sameCityFreePrice != null 
        ? Math.round(formDataValue.sameCityFreePrice * 100) 
        : undefined
      
      await ConfigApi.updateSameCityConfig({
        deliverySameCityEnabled: formDataValue.deliverySameCityEnabled ?? false,
        sameCityChargeMode: formDataValue.sameCityChargeMode ?? 1,
        sameCityStartDistance: formDataValue.sameCityStartDistance,
        sameCityStartPrice: sameCityStartPrice,
        sameCityExtraDistance: formDataValue.sameCityExtraDistance,
        sameCityExtraPrice: sameCityExtraPrice,
        sameCityMaxDistance: formDataValue.sameCityMaxDistance,
        sameCityFixedPrice: sameCityFixedPrice,
        sameCityCustomPriceEnabled: formDataValue.sameCityCustomPriceEnabled,
        sameCityCustomMinPrice: sameCityCustomMinPrice,
        sameCityCustomMaxPrice: sameCityCustomMaxPrice,
        sameCityCustomNeedAudit: formDataValue.sameCityCustomNeedAudit,
        sameCityCustomDefaultPrice: sameCityCustomDefaultPrice,
        sameCityFreeEnabled: formDataValue.sameCityFreeEnabled,
        sameCityFreePrice: sameCityFreePrice,
        sameCityDeliveryRangeDescription: formDataValue.sameCityDeliveryRangeDescription
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 如果是门店自配送Tab，使用专门的门店自配送接口
    if (activeMainTab.value === 'delivery' && activeDeliveryTab.value === 'store') {
      // 金额需要从元转换为分
      const storeStartPrice = formDataValue.storeStartPrice != null 
        ? Math.round(formDataValue.storeStartPrice * 100) 
        : undefined
      const storeExtraPrice = formDataValue.storeExtraPrice != null 
        ? Math.round(formDataValue.storeExtraPrice * 100) 
        : undefined
      const storeFixedPrice = formDataValue.storeFixedPrice != null 
        ? Math.round(formDataValue.storeFixedPrice * 100) 
        : undefined
      const storeCustomMinPrice = formDataValue.storeCustomMinPrice != null 
        ? Math.round(formDataValue.storeCustomMinPrice * 100) 
        : undefined
      const storeCustomMaxPrice = formDataValue.storeCustomMaxPrice != null 
        ? Math.round(formDataValue.storeCustomMaxPrice * 100) 
        : undefined
      const storeCustomDefaultPrice = formDataValue.storeCustomDefaultPrice != null 
        ? Math.round(formDataValue.storeCustomDefaultPrice * 100) 
        : undefined
      const storeFreePrice = formDataValue.storeFreePrice != null 
        ? Math.round(formDataValue.storeFreePrice * 100) 
        : undefined
      
      await ConfigApi.updateStoreConfig({
        deliveryStoreEnabled: formDataValue.deliveryStoreEnabled ?? false,
        storeChargeMode: formDataValue.storeChargeMode ?? 1,
        storeStartDistance: formDataValue.storeStartDistance,
        storeStartPrice: storeStartPrice,
        storeExtraDistance: formDataValue.storeExtraDistance,
        storeExtraPrice: storeExtraPrice,
        storeMaxDistance: formDataValue.storeMaxDistance,
        storeFixedPrice: storeFixedPrice,
        storeCustomPriceEnabled: formDataValue.storeCustomPriceEnabled,
        storeCustomMinPrice: storeCustomMinPrice,
        storeCustomMaxPrice: storeCustomMaxPrice,
        storeCustomNeedAudit: formDataValue.storeCustomNeedAudit,
        storeCustomDefaultPrice: storeCustomDefaultPrice,
        storeFreeEnabled: formDataValue.storeFreeEnabled,
        storeFreePrice: storeFreePrice,
        storeDeliveryRangeImageUrl: formDataValue.storeDeliveryRangeImageUrl
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 如果是分销Tab，使用专门的分销接口
    if (activeMainTab.value === 'brokerage') {
      // 金额需要从元转换为分
      const brokerageWithdrawMinPrice = formDataValue.brokerageWithdrawMinPrice != null 
        ? Math.round(formDataValue.brokerageWithdrawMinPrice * 100) 
        : 0
      
      // 处理 brokeragePosterUrls：如果是字符串数组，直接使用；如果是字符串，转换为数组
      let brokeragePosterUrls: string[] = []
      if (formDataValue.brokeragePosterUrls) {
        if (Array.isArray(formDataValue.brokeragePosterUrls)) {
          brokeragePosterUrls = formDataValue.brokeragePosterUrls
        } else if (typeof formDataValue.brokeragePosterUrls === 'string') {
          brokeragePosterUrls = [formDataValue.brokeragePosterUrls]
        }
      }
      
      // 处理 brokerageWithdrawTypes：如果是数字数组，直接使用；如果是字符串数组，转换为数字数组
      let brokerageWithdrawTypes: number[] = []
      if (formDataValue.brokerageWithdrawTypes) {
        if (Array.isArray(formDataValue.brokerageWithdrawTypes)) {
          brokerageWithdrawTypes = formDataValue.brokerageWithdrawTypes.map(item => 
            typeof item === 'string' ? parseInt(item, 10) : item
          )
        }
      }
      
      await ConfigApi.updateBrokerageConfig({
        brokerageEnabled: formDataValue.brokerageEnabled ?? false,
        brokerageEnabledCondition: formDataValue.brokerageEnabledCondition ?? 1,
        brokerageBindMode: formDataValue.brokerageBindMode ?? 1,
        brokeragePosterUrls: brokeragePosterUrls,
        brokerageFirstPercent: formDataValue.brokerageFirstPercent ?? 0,
        brokerageSecondPercent: formDataValue.brokerageSecondPercent ?? 0,
        brokerageWithdrawMinPrice: brokerageWithdrawMinPrice,
        brokerageWithdrawFeePercent: formDataValue.brokerageWithdrawFeePercent ?? 0,
        brokerageFrozenDays: formDataValue.brokerageFrozenDays ?? 7,
        brokerageWithdrawTypes: brokerageWithdrawTypes
      })
      message.success('保存成功')
      await getConfig()
      return
    }
    
    // 其他情况使用通用保存接口
    // 先获取后端当前完整数据，确保其他Tab的数据不丢失
    const currentData = await ConfigApi.getTradeConfig()
    const data = currentData ? cloneDeep(currentData) : ({} as ConfigApi.ConfigVO)

    // 确保包含 id 字段（如果存在）
    if (formData.value.id) {
      ;(data as any).id = formData.value.id
    }

    currentTabFields.forEach((field) => {
      if (field in formDataValue) {
        ;(data as any)[field] = formDataValue[field as keyof typeof formDataValue]
      }
    })
    // 金额放大（后端以分为单位存储）
    // 只转换当前Tab相关的金额字段
    const moneyFields = [
      'deliveryExpressFreePrice',
      'brokerageWithdrawMinPrice',
      'packagingFeePrice',
      'sameCityStartPrice',
      'sameCityExtraPrice',
      'sameCityFixedPrice',
      'sameCityCustomMinPrice',
      'sameCityCustomMaxPrice',
      'sameCityCustomDefaultPrice',
      'sameCityFreePrice',
      'storeStartPrice',
      'storeExtraPrice',
      'storeFixedPrice',
      'storeCustomMinPrice',
      'storeCustomMaxPrice',
      'storeCustomDefaultPrice',
      'storeFreePrice'
    ]
    moneyFields.forEach((field) => {
      if (currentTabFields.includes(field)) {
        const value = (data as any)[field]
        if (value != null && typeof value === 'number') {
          ;(data as any)[field] = Math.round(value * 100)
        }
      }
    })
    await ConfigApi.saveTradeConfig(data)
    message.success('保存成功')
    // 保存成功后重新加载配置，确保数据同步
    await getConfig()
  } catch (error: any) {
    console.error('保存配置失败:', error)
    const errorMsg = error?.response?.data?.msg || error?.message || '保存失败，请检查配置是否正确'
    message.error(errorMsg)
  } finally {
    formLoading.value = false
  }
}

/** 查询交易中心配置 */
const getConfig = async () => {
  formLoading.value = true
  try {
    const data = await ConfigApi.getTradeConfig()
    if (data != null) {
      formData.value = data
      // 确保满额免包装费字段有默认值（防止后端没有返回这些字段）
      if (formData.value.packagingFeeFreeEnabled === undefined || formData.value.packagingFeeFreeEnabled === null) {
        formData.value.packagingFeeFreeEnabled = false
      }
      if (formData.value.packagingFeeFreePrice === undefined || formData.value.packagingFeeFreePrice === null) {
        formData.value.packagingFeeFreePrice = 0
      }
      // 金额缩小（后端以分为单位存储，前端以元为单位显示）
      if (data.deliveryExpressFreePrice) {
        formData.value.deliveryExpressFreePrice = data.deliveryExpressFreePrice / 100
      }
      if (data.brokerageWithdrawMinPrice) {
        formData.value.brokerageWithdrawMinPrice = data.brokerageWithdrawMinPrice / 100
      }
      if (data.packagingFeePrice != null) {
        formData.value.packagingFeePrice = data.packagingFeePrice / 100
      }
      // 处理满额免包装费字段
      if (data.packagingFeeFreeEnabled !== undefined && data.packagingFeeFreeEnabled !== null) {
        formData.value.packagingFeeFreeEnabled = Boolean(data.packagingFeeFreeEnabled)
      }
      if (data.packagingFeeFreePrice != null) {
        formData.value.packagingFeeFreePrice = data.packagingFeeFreePrice / 100
      }
      // 同城配送金额字段转换（分 → 元）
      if (data.sameCityStartPrice) {
        formData.value.sameCityStartPrice = data.sameCityStartPrice / 100
      }
      if (data.sameCityExtraPrice) {
        formData.value.sameCityExtraPrice = data.sameCityExtraPrice / 100
      }
      if (data.sameCityFixedPrice) {
        formData.value.sameCityFixedPrice = data.sameCityFixedPrice / 100
      }
      if (data.sameCityCustomMinPrice) {
        formData.value.sameCityCustomMinPrice = data.sameCityCustomMinPrice / 100
      }
      if (data.sameCityCustomMaxPrice) {
        formData.value.sameCityCustomMaxPrice = data.sameCityCustomMaxPrice / 100
      }
      if (data.sameCityCustomDefaultPrice) {
        formData.value.sameCityCustomDefaultPrice = data.sameCityCustomDefaultPrice / 100
      }
      if (data.sameCityFreePrice) {
        formData.value.sameCityFreePrice = data.sameCityFreePrice / 100
      }
      // 门店自配送金额字段转换（分 → 元）
      if (data.storeStartPrice) {
        formData.value.storeStartPrice = data.storeStartPrice / 100
      }
      if (data.storeExtraPrice) {
        formData.value.storeExtraPrice = data.storeExtraPrice / 100
      }
      if (data.storeFixedPrice) {
        formData.value.storeFixedPrice = data.storeFixedPrice / 100
      }
      if (data.storeCustomMinPrice) {
        formData.value.storeCustomMinPrice = data.storeCustomMinPrice / 100
      }
      if (data.storeCustomMaxPrice) {
        formData.value.storeCustomMaxPrice = data.storeCustomMaxPrice / 100
      }
      if (data.storeCustomDefaultPrice) {
        formData.value.storeCustomDefaultPrice = data.storeCustomDefaultPrice / 100
      }
      if (data.storeFreePrice) {
        formData.value.storeFreePrice = data.storeFreePrice / 100
      }
    }
  } finally {
    formLoading.value = false
  }
}

/** 初始化 **/
onMounted(() => {
  getConfig()
  // 初始化三个管理模块的列表
  getExpressTemplateList()
  getExpressList()
  getPickUpStoreList()
})
</script>

<style scoped lang="scss"></style>
