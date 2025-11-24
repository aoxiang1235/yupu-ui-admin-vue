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
      <el-tabs>
        <!-- 售后 -->
        <el-tab-pane label="售后">
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
        </el-tab-pane>
        <!-- 配送 -->
        <el-tab-pane label="配送">
          <el-tabs type="border-card">
            <!-- Tab 1: 快递发货 -->
            <el-tab-pane label="快递发货">
              <!-- 启用开关 -->
              <el-form-item label="启用快递发货" prop="deliveryExpressEnabled">
                <el-switch v-model="formData.deliveryExpressEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，用户可以在APP端选择快递发货
                </el-text>
              </el-form-item>

              <!-- 全局包邮配置 -->
              <el-divider content-position="left">全局包邮配置</el-divider>
              <el-form-item label="启用包邮" prop="deliveryExpressFreeEnabled">
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
              >
                <el-input-number
                  v-model="formData.deliveryExpressFreePrice"
                  :min="0"
                  :precision="2"
                  class="!w-xs"
                  placeholder="请输入满额包邮"
                />
                <el-text class="ml-10px" size="small" type="info">
                  商城商品满多少金额即可包邮，单位：元
                </el-text>
              </el-form-item>

              <!-- 运费模板管理 -->
              <el-divider content-position="left">运费模板管理</el-divider>
              <el-form :inline="true" class="mb-15px">
                <el-form-item label="模板名称">
                  <el-input
                    v-model="expressTemplateQuery.name"
                    placeholder="请输入模板名称"
                    clearable
                    class="!w-240px"
                    @keyup.enter="handleExpressTemplateQuery"
                  />
                </el-form-item>
                <el-form-item>
                  <el-button @click="handleExpressTemplateQuery">
                    <Icon icon="ep:search" class="mr-5px" /> 搜索
                  </el-button>
                  <el-button @click="resetExpressTemplateQuery">
                    <Icon icon="ep:refresh" class="mr-5px" /> 重置
                  </el-button>
                  <el-button
                    type="primary"
                    @click="openExpressTemplateForm('create')"
                    v-hasPermi="['trade:delivery:express-template:create']"
                  >
                    <Icon icon="ep:plus" class="mr-5px" /> 新增模板
                  </el-button>
                </el-form-item>
              </el-form>

              <el-table v-loading="expressTemplateLoading" :data="expressTemplateList">
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

              <!-- 快递公司管理 -->
              <el-divider content-position="left">快递公司管理</el-divider>
              <el-form :inline="true" class="mb-15px">
                <el-form-item label="快递公司名称">
                  <el-input
                    v-model="expressQuery.name"
                    placeholder="请输入快递公司名称"
                    clearable
                    class="!w-240px"
                    @keyup.enter="handleExpressQuery"
                  />
                </el-form-item>
                <el-form-item>
                  <el-button @click="handleExpressQuery">
                    <Icon icon="ep:search" class="mr-5px" /> 搜索
                  </el-button>
                  <el-button @click="resetExpressQuery">
                    <Icon icon="ep:refresh" class="mr-5px" /> 重置
                  </el-button>
                  <el-button
                    type="primary"
                    @click="openExpressForm('create')"
                    v-hasPermi="['trade:delivery:express:create']"
                  >
                    <Icon icon="ep:plus" class="mr-5px" /> 新增快递公司
                  </el-button>
                </el-form-item>
              </el-form>

              <el-table v-loading="expressLoading" :data="expressList">
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
            </el-tab-pane>

            <!-- Tab 2: 门店自提 -->
            <el-tab-pane label="门店自提">
              <!-- 启用开关 -->
              <el-form-item label="启用门店自提" prop="deliveryPickUpEnabled">
                <el-switch v-model="formData.deliveryPickUpEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，用户可以在APP端选择门店自提
                </el-text>
              </el-form-item>

              <!-- 门店管理 -->
              <el-divider content-position="left">门店管理</el-divider>
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
            </el-tab-pane>

            <!-- Tab 3: 同城配送 -->
            <el-tab-pane label="同城配送">
              <!-- 启用开关 -->
              <el-form-item label="启用同城配送" prop="deliverySameCityEnabled">
                <el-switch v-model="formData.deliverySameCityEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，用户可以在APP端选择同城配送（功能开发中）
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

              <!-- 同城配送包邮配置 -->
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

              <!-- 配送范围管理 -->
              <el-divider content-position="left">配送范围管理</el-divider>

              <el-card shadow="never" class="mb-20px" style="border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center; justify-content: space-between">
                    <div style="display: flex; align-items: center">
                      <Icon
                        icon="ep:location"
                        style="font-size: 20px; margin-right: 8px; color: #409eff"
                      />
                      <span style="font-size: 16px; font-weight: 600">配送中心位置</span>
                    </div>
                    <el-button type="primary" @click="openMapPicker">
                      <Icon icon="ep:map-location" class="mr-5px" /> 地图选择位置
                    </el-button>
                  </div>
                </template>

                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item label="配送中心纬度" prop="sameCityDeliveryCenterLatitude">
                      <el-input-number
                        v-model="formData.sameCityDeliveryCenterLatitude"
                        :min="-90"
                        :max="90"
                        :precision="6"
                        class="!w-full"
                        placeholder="请选择或输入纬度"
                        :controls="false"
                      />
                      <el-text class="mt-5px block" size="small" type="info">
                        纬度范围：-90 ~ 90
                      </el-text>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="配送中心经度" prop="sameCityDeliveryCenterLongitude">
                      <el-input-number
                        v-model="formData.sameCityDeliveryCenterLongitude"
                        :min="-180"
                        :max="180"
                        :precision="6"
                        class="!w-full"
                        placeholder="请选择或输入经度"
                        :controls="false"
                      />
                      <el-text class="mt-5px block" size="small" type="info">
                        经度范围：-180 ~ 180
                      </el-text>
                    </el-form-item>
                  </el-col>
                </el-row>

                <el-form-item v-if="sameCityDeliveryCenterAddress" label="选中地址">
                  <el-text type="success" style="font-size: 14px">
                    {{ sameCityDeliveryCenterAddress }}
                  </el-text>
                </el-form-item>
              </el-card>

              <el-card shadow="never" class="mb-20px" style="border: 1px solid #e4e7ed">
                <template #header>
                  <div style="display: flex; align-items: center">
                    <Icon
                      icon="ep:aim"
                      style="font-size: 20px; margin-right: 8px; color: #67c23a"
                    />
                    <span style="font-size: 16px; font-weight: 600">配送范围设置</span>
                  </div>
                </template>

                <el-form-item label="配送范围半径" prop="sameCityDeliveryRange">
                  <div style="display: flex; align-items: center; gap: 12px">
                    <el-input-number
                      v-model="formData.sameCityDeliveryRange"
                      :min="0"
                      :max="100"
                      :precision="1"
                      :step="1"
                      class="!w-200px"
                      placeholder="配送范围半径"
                    />
                    <el-text size="small" type="info">公里</el-text>
                    <el-text size="small" type="info" style="flex: 1">
                      以配送中心为圆心，支持配送的半径范围
                    </el-text>
                  </div>
                </el-form-item>

                <!-- 配置预览 -->
                <div
                  v-if="
                    formData.sameCityDeliveryCenterLatitude &&
                    formData.sameCityDeliveryCenterLongitude &&
                    formData.sameCityDeliveryRange
                  "
                  style="
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border-radius: 8px;
                    padding: 20px;
                    color: white;
                    margin-top: 16px;
                  "
                >
                  <div style="display: flex; align-items: center; margin-bottom: 12px">
                    <Icon icon="ep:view" style="font-size: 18px; margin-right: 8px; color: white" />
                    <span style="font-size: 15px; font-weight: 600">配置预览</span>
                  </div>
                  <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px">
                    <div>
                      <div style="font-size: 12px; opacity: 0.9; margin-bottom: 4px">
                        配送中心坐标
                      </div>
                      <div style="font-size: 14px; font-weight: 500">
                        {{ formData.sameCityDeliveryCenterLatitude }},
                        {{ formData.sameCityDeliveryCenterLongitude }}
                      </div>
                    </div>
                    <div>
                      <div style="font-size: 12px; opacity: 0.9; margin-bottom: 4px">
                        配送范围半径
                      </div>
                      <div style="font-size: 14px; font-weight: 500">
                        {{ formData.sameCityDeliveryRange }} 公里
                      </div>
                    </div>
                    <div style="grid-column: 1 / -1">
                      <div style="font-size: 12px; opacity: 0.9; margin-bottom: 4px">
                        配送覆盖范围
                      </div>
                      <div style="font-size: 14px; font-weight: 500">
                        距离配送中心
                        <span style="font-weight: 700; font-size: 16px; margin: 0 4px">
                          {{ formData.sameCityDeliveryRange }}
                        </span>
                        公里内的区域支持同城配送
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>

              <el-alert type="info" :closable="false" show-icon class="mb-15px">
                <template #default>
                  <div>
                    <p class="mb-5px"><strong>使用说明：</strong></p>
                    <p class="mb-5px">
                      • 点击"地图选择位置"按钮，可通过地图选择配送中心位置，自动获取经纬度坐标
                    </p>
                    <p class="mb-5px">
                      • 配送范围半径建议与上方"最大配送距离"保持一致，确保配置一致性
                    </p>
                    <p class="mb-0">
                      • 如果未配置配送范围，系统将使用"最大配送距离"作为默认配送范围限制
                    </p>
                  </div>
                </template>
              </el-alert>

              <!-- 包邮小区管理 -->
              <el-divider content-position="left">包邮小区管理</el-divider>
              <el-alert type="warning" :closable="false" show-icon class="mb-15px">
                <template #default>
                  <div>
                    <p class="mb-5px"><strong>功能说明：</strong></p>
                    <p class="mb-5px">
                      • 包邮小区内的订单无论订单金额多少，都享受同城配送包邮优惠
                    </p>
                    <p class="mb-5px">• 包邮小区配置会覆盖上方的"满额包邮"规则</p>
                    <p class="mb-0"
                      >• 通过地图选择小区位置，系统会自动判断订单地址是否在包邮小区范围内</p
                    >
                  </div>
                </template>
              </el-alert>

              <div style="margin-bottom: 15px">
                <el-button type="primary" @click="openFreeShippingCommunityForm('create')">
                  <Icon icon="ep:plus" class="mr-5px" /> 新增包邮小区
                </el-button>
              </div>

              <el-table
                v-loading="freeShippingCommunityLoading"
                :data="freeShippingCommunityList"
                border
              >
                <el-table-column label="序号" type="index" width="60" align="center" />
                <el-table-column
                  label="小区名称"
                  prop="name"
                  min-width="150"
                  show-overflow-tooltip
                />
                <el-table-column
                  label="详细地址"
                  prop="address"
                  min-width="200"
                  show-overflow-tooltip
                />
                <el-table-column label="经纬度" width="220" align="center">
                  <template #default="scope">
                    <el-text size="small" type="info">
                      {{ scope.row.latitude }}, {{ scope.row.longitude }}
                    </el-text>
                  </template>
                </el-table-column>
                <el-table-column
                  label="创建时间"
                  prop="createTime"
                  width="180"
                  align="center"
                  :formatter="dateFormatter"
                />
                <el-table-column label="操作" width="150" align="center" fixed="right">
                  <template #default="scope">
                    <el-button
                      link
                      type="primary"
                      @click="openFreeShippingCommunityForm('update', scope.row)"
                    >
                      编辑
                    </el-button>
                    <el-button
                      link
                      type="danger"
                      @click="handleFreeShippingCommunityDelete(scope.row)"
                    >
                      删除
                    </el-button>
                  </template>
                </el-table-column>
                <template #empty>
                  <el-empty description="暂无包邮小区，点击上方按钮添加" :image-size="100" />
                </template>
              </el-table>
            </el-tab-pane>

            <!-- Tab 4: 门店自配送 -->
            <el-tab-pane label="门店自配送">
              <!-- 启用开关 -->
              <el-form-item label="启用门店自配送" prop="deliveryStoreEnabled">
                <el-switch v-model="formData.deliveryStoreEnabled" style="user-select: none" />
                <el-text class="ml-10px" size="small" type="info">
                  开启后，用户可以在APP端选择门店自配送（功能开发中）
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

              <!-- 门店自配送包邮配置 -->
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

              <!-- 门店配送范围管理（预留） -->
              <el-divider content-position="left">门店配送范围管理</el-divider>
              <el-empty description="功能开发中，敬请期待" :image-size="100" />
            </el-tab-pane>
          </el-tabs>
        </el-tab-pane>

        <!-- 地图选择对话框 -->
        <el-dialog v-model="mapDialogVisible" title="选择配送中心位置" append-to-body width="800px">
          <IFrame class="h-609px" :src="tencentLbsUrl" />
        </el-dialog>

        <!-- 包邮小区表单弹窗 -->
        <el-dialog
          v-model="freeShippingCommunityDialogVisible"
          :title="freeShippingCommunityFormType === 'create' ? '新增包邮小区' : '编辑包邮小区'"
          width="600px"
          append-to-body
        >
          <el-form
            ref="freeShippingCommunityFormRef"
            :model="freeShippingCommunityFormData"
            :rules="freeShippingCommunityFormRules"
            label-width="100px"
          >
            <el-form-item label="小区名称" prop="name">
              <el-input
                v-model="freeShippingCommunityFormData.name"
                placeholder="请输入小区名称"
                clearable
              />
            </el-form-item>
            <el-form-item label="详细地址" prop="address">
              <el-input
                v-model="freeShippingCommunityFormData.address"
                type="textarea"
                :rows="2"
                placeholder="请输入详细地址"
                clearable
              />
            </el-form-item>
            <el-form-item label="选择位置">
              <el-button type="primary" @click="openCommunityMapPicker">
                <Icon icon="ep:map-location" class="mr-5px" /> 地图选择位置
              </el-button>
              <el-text class="ml-10px" size="small" type="info">
                通过地图选择小区位置，自动获取经纬度
              </el-text>
            </el-form-item>
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="纬度" prop="latitude">
                  <el-input-number
                    v-model="freeShippingCommunityFormData.latitude"
                    :min="-90"
                    :max="90"
                    :precision="6"
                    class="!w-full"
                    placeholder="纬度"
                    :controls="false"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="经度" prop="longitude">
                  <el-input-number
                    v-model="freeShippingCommunityFormData.longitude"
                    :min="-180"
                    :max="180"
                    :precision="6"
                    class="!w-full"
                    placeholder="经度"
                    :controls="false"
                  />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
          <template #footer>
            <el-button @click="freeShippingCommunityDialogVisible = false">取消</el-button>
            <el-button
              type="primary"
              @click="submitFreeShippingCommunityForm"
              :loading="freeShippingCommunityFormLoading"
            >
              确定
            </el-button>
          </template>
        </el-dialog>

        <!-- 小区地图选择对话框 -->
        <el-dialog
          v-model="communityMapDialogVisible"
          title="选择小区位置"
          append-to-body
          width="800px"
        >
          <IFrame class="h-609px" :src="tencentLbsUrl" />
        </el-dialog>

        <!-- 包装费 -->
        <el-tab-pane label="包装费">
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
        </el-tab-pane>
        <!-- 分销 -->
        <el-tab-pane label="分销">
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
        </el-tab-pane>
      </el-tabs>
      <!-- 保存 -->
      <el-form-item>
        <el-button :loading="formLoading" type="primary" @click="submitForm"> 保存</el-button>
      </el-form-item>
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
import { IFrame } from '@/components/IFrame'

defineOptions({ name: 'TradeConfig' })

const message = useMessage() // 消息弹窗

const formLoading = ref(false) // 表单的加载中：1）修改时的数据加载；2）提交的按钮禁用
const formRef = ref()
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
  sameCityFreeShippingCommunities: [] as any[], // 包邮小区列表
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
  packagingFeeEnabled: false,
  packagingFeePrice: 0,
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
  deliveryExpressFreePrice: [{ required: true, message: '满额包邮不能为空', trigger: 'blur' }],
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
  brokerageEnabledCondition: [{ required: true, message: '分佣模式不能为空', trigger: 'blur' }],
  brokerageBindMode: [{ required: true, message: '分销关系绑定模式不能为空', trigger: 'blur' }],
  brokerageFirstPercent: [{ required: true, message: '一级返佣比例不能为空', trigger: 'blur' }],
  brokerageSecondPercent: [{ required: true, message: '二级返佣比例不能为空', trigger: 'blur' }],
  brokerageWithdrawMinPrice: [
    { required: true, message: '用户提现最低金额不能为空', trigger: 'blur' }
  ],
  brokerageWithdrawFeePercent: [{ required: true, message: '提现手续费不能为空', trigger: 'blur' }],
  brokerageFrozenDays: [{ required: true, message: '佣金冻结时间不能为空', trigger: 'blur' }],
  brokerageWithdrawTypes: [
    {
      required: true,
      message: '提现方式不能为空',
      trigger: 'change'
    }
  ]
})

const submitForm = async () => {
  if (formLoading.value) return
  // 校验表单
  if (!formRef) return
  const valid = await formRef.value.validate()
  if (!valid) return
  // 提交请求
  formLoading.value = true
  try {
    const data = cloneDeep(unref(formData.value)) as unknown as ConfigApi.ConfigVO
    // 金额放大（后端以分为单位存储）
    if (data.deliveryExpressFreePrice) {
      data.deliveryExpressFreePrice = data.deliveryExpressFreePrice * 100
    }
    if (data.brokerageWithdrawMinPrice) {
      data.brokerageWithdrawMinPrice = data.brokerageWithdrawMinPrice * 100
    }
    if (data.packagingFeePrice) {
      data.packagingFeePrice = data.packagingFeePrice * 100
    }
    await ConfigApi.saveTradeConfig(data)
    message.success('保存成功')
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
      // 金额缩小（后端以分为单位存储，前端以元为单位显示）
      if (data.deliveryExpressFreePrice) {
        formData.value.deliveryExpressFreePrice = data.deliveryExpressFreePrice / 100
      }
      if (data.brokerageWithdrawMinPrice) {
        formData.value.brokerageWithdrawMinPrice = data.brokerageWithdrawMinPrice / 100
      }
      if (data.packagingFeePrice) {
        formData.value.packagingFeePrice = data.packagingFeePrice / 100
      }
    }
  } finally {
    formLoading.value = false
  }
}

// ========== 同城配送地图选择 ==========
const mapDialogVisible = ref(false) // 地图弹窗的是否展示
const tencentLbsUrl = ref('') // 腾讯位置服务 url
const sameCityDeliveryCenterAddress = ref('') // 配送中心地址

/** 打开地图选择器 */
const openMapPicker = async () => {
  if (!tencentLbsUrl.value) {
    await initTencentLbsMap()
  }
  // 设置配送中心选择回调
  ;(window as any).selectDeliveryCenterAddress = selectDeliveryCenterAddress
  // 清除小区选择回调
  delete (window as any).selectCommunityAddress
  mapDialogVisible.value = true
}

/** 选择配送中心位置 */
const selectDeliveryCenterAddress = function (loc: any): void {
  if (loc.latlng && loc.latlng.lat) {
    formData.value.sameCityDeliveryCenterLatitude = loc.latlng.lat
  }
  if (loc.latlng && loc.latlng.lng) {
    formData.value.sameCityDeliveryCenterLongitude = loc.latlng.lng
  }
  // 保存地址名称
  if (loc.poi && loc.poi.name) {
    sameCityDeliveryCenterAddress.value = loc.poi.name
  } else if (loc.addr) {
    sameCityDeliveryCenterAddress.value = loc.addr
  }
  mapDialogVisible.value = false
  message.success('配送中心位置已选择')
}

// 地图消息监听是否已初始化
let mapMessageListenerInitialized = false

/** 初始化腾讯地图 */
const initTencentLbsMap = async () => {
  // 初始化消息监听（只需要初始化一次）
  if (!mapMessageListenerInitialized) {
    window.addEventListener(
      'message',
      function (event) {
        // 接收位置信息，用户选择确认位置点后选点组件会触发该事件，回传用户的位置信息
        let loc = event.data
        if (loc && loc.module === 'locationPicker') {
          // 防止其他应用也会向该页面 post 信息，需判断 module 是否为 'locationPicker'
          // 根据当前打开的地图对话框类型，调用相应的回调函数
          if ((window as any).selectDeliveryCenterAddress) {
            ;(window.parent as any).selectDeliveryCenterAddress(loc)
          } else if ((window as any).selectCommunityAddress) {
            ;(window.parent as any).selectCommunityAddress(loc)
          }
        }
      },
      false
    )
    mapMessageListenerInitialized = true
  }
  const data = await ConfigApi.getTradeConfig()
  const key = (data as any).tencentLbsKey
  if (key) {
    tencentLbsUrl.value = `https://apis.map.qq.com/tools/locpicker?type=1&key=${key}&referer=myapp`
  } else {
    message.warning('未配置腾讯地图Key，无法使用地图选择功能')
  }
}

// ========== 包邮小区管理 ==========
const freeShippingCommunityLoading = ref(false)
const freeShippingCommunityList = ref<any[]>([])
const freeShippingCommunityDialogVisible = ref(false)
const freeShippingCommunityFormType = ref<'create' | 'update'>('create')
const freeShippingCommunityFormLoading = ref(false)
const freeShippingCommunityFormRef = ref()
const freeShippingCommunityFormData = ref({
  id: undefined,
  name: '',
  address: '',
  latitude: undefined,
  longitude: undefined
})
const freeShippingCommunityFormRules = reactive({
  name: [{ required: true, message: '小区名称不能为空', trigger: 'blur' }],
  address: [{ required: true, message: '详细地址不能为空', trigger: 'blur' }],
  latitude: [{ required: true, message: '纬度不能为空', trigger: 'blur' }],
  longitude: [{ required: true, message: '经度不能为空', trigger: 'blur' }]
})
const communityMapDialogVisible = ref(false)
const selectedCommunityAddress = ref('')

/** 打开包邮小区表单 */
const openFreeShippingCommunityForm = (type: 'create' | 'update', row?: any) => {
  freeShippingCommunityFormType.value = type
  freeShippingCommunityDialogVisible.value = true
  if (type === 'create') {
    freeShippingCommunityFormData.value = {
      id: undefined,
      name: '',
      address: '',
      latitude: undefined,
      longitude: undefined
    }
    selectedCommunityAddress.value = ''
  } else {
    freeShippingCommunityFormData.value = {
      id: row.id,
      name: row.name || '',
      address: row.address || '',
      latitude: row.latitude,
      longitude: row.longitude
    }
    selectedCommunityAddress.value = row.address || ''
  }
  freeShippingCommunityFormRef.value?.clearValidate()
}

/** 提交包邮小区表单 */
const submitFreeShippingCommunityForm = async () => {
  if (!freeShippingCommunityFormRef.value) return
  const valid = await freeShippingCommunityFormRef.value.validate()
  if (!valid) return

  freeShippingCommunityFormLoading.value = true
  try {
    const data = { ...freeShippingCommunityFormData.value }
    if (freeShippingCommunityFormType.value === 'create') {
      // 添加新小区到列表
      freeShippingCommunityList.value.push({
        id: Date.now(), // 临时ID，实际应该从后端返回
        name: data.name,
        address: data.address,
        latitude: data.latitude,
        longitude: data.longitude,
        createTime: new Date().getTime()
      })
      message.success('新增包邮小区成功')
    } else {
      // 更新小区信息
      const index = freeShippingCommunityList.value.findIndex((item) => item.id === data.id)
      if (index !== -1) {
        freeShippingCommunityList.value[index] = {
          ...freeShippingCommunityList.value[index],
          name: data.name,
          address: data.address,
          latitude: data.latitude,
          longitude: data.longitude
        }
      }
      message.success('更新包邮小区成功')
    }
    freeShippingCommunityDialogVisible.value = false
    // TODO: 这里应该调用后端API保存数据
    // 保存到formData中，随表单一起提交
    formData.value.sameCityFreeShippingCommunities = freeShippingCommunityList.value
  } finally {
    freeShippingCommunityFormLoading.value = false
  }
}

/** 删除包邮小区 */
const handleFreeShippingCommunityDelete = async (row: any) => {
  try {
    await message.delConfirm()
    const index = freeShippingCommunityList.value.findIndex((item) => item.id === row.id)
    if (index !== -1) {
      freeShippingCommunityList.value.splice(index, 1)
      message.success('删除成功')
      // 更新formData
      formData.value.sameCityFreeShippingCommunities = freeShippingCommunityList.value
    }
    // TODO: 这里应该调用后端API删除数据
  } catch {}
}

/** 打开小区地图选择器 */
const openCommunityMapPicker = async () => {
  if (!tencentLbsUrl.value) {
    await initTencentLbsMap()
  }
  // 设置小区选择回调
  ;(window as any).selectCommunityAddress = selectCommunityAddress
  // 清除配送中心选择回调
  delete (window as any).selectDeliveryCenterAddress
  communityMapDialogVisible.value = true
}

/** 选择小区位置 */
const selectCommunityAddress = function (loc: any): void {
  if (loc.latlng && loc.latlng.lat) {
    freeShippingCommunityFormData.value.latitude = loc.latlng.lat
  }
  if (loc.latlng && loc.latlng.lng) {
    freeShippingCommunityFormData.value.longitude = loc.latlng.lng
  }
  // 保存地址名称
  if (loc.poi && loc.poi.name) {
    freeShippingCommunityFormData.value.name = loc.poi.name
    selectedCommunityAddress.value = loc.poi.name
  }
  if (loc.addr) {
    freeShippingCommunityFormData.value.address = loc.addr
    if (!selectedCommunityAddress.value) {
      selectedCommunityAddress.value = loc.addr
    }
  }
  communityMapDialogVisible.value = false
  message.success('小区位置已选择')
}

/** 初始化 **/
onMounted(() => {
  getConfig()
  // 初始化三个管理模块的列表
  getExpressTemplateList()
  getExpressList()
  getPickUpStoreList()
  // 初始化包邮小区列表（如果有数据）
  if (formData.value.sameCityFreeShippingCommunities) {
    freeShippingCommunityList.value = formData.value.sameCityFreeShippingCommunities
  }
})
</script>
