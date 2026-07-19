# 前端重构为AI对话应用

## 核心决策（已确认）
- **应用类型**：从工具型应用转型为AI对话应用（参考Kimi）
- **视觉风格**：蓝紫渐变 `#4A6CF7→#8B5CF6` + 鸿蒙液态玻璃融合，月之亮面/暗面主题
- **默认假设**（未确认项，可在确认时调整）：
  - 现有功能页面（院校/志愿/学习/政策）保留，从侧边栏菜单进入，不删除已实现代码
  - AI后端采用Mock数据优先，前端先完成UI和交互，后续再对接真实大模型API

## 阶段0：保存计划文档（满足用户要求）
- 将本计划保存到 `.qoder/plans/前端重构为AI对话应用.md`
- 方便后续记忆断开时重新读取恢复上下文

## 阶段1：设计系统迁移
**目标**：将品牌色从Apple蓝迁移到蓝紫渐变，建立月之亮面/暗面主题

修改文件：
- `entry/src/main/ets/common/Constants.ets`：
  - PRIMARY_COLOR: `#007AFF` → `#4A6CF7`（渐变起始色）
  - 新增 PRIMARY_GRADIENT_END_KIMI: `#8B5CF6`（渐变终止色）
  - 新增月之亮面色系：BG_PAGE `#FFFFFF`、BG_CONTENT `#F8F9FA`、TEXT_PRIMARY `#1A1A2E`、TEXT_SECONDARY `#6B7280`、DIVIDER `#E5E7EB`、INPUT_BG `#F3F4F6`
  - 新增月之暗面色系：BG_PAGE_DARK `#0F0F1A`、BG_CONTENT_DARK `#1A1A2E`、AI_REPLY_BG_DARK `#252540`
  - 液态玻璃材质色保留（GLASS_XLIGHT/LIGHT/MEDIUM等）
- `entry/src/main/ets/common/DesignTokens.ets`：
  - 新增 KimiGradient 配置类（135°蓝紫渐变方向，符合memory规范）
  - 新增 ChatRadius（输入框22vp胶囊形、消息气泡18dp、工具栏标签16dp）
  - 保留现有 GlassEffect 液态玻璃参数
- `entry/src/main/resources/base/element/color.json` + `dark/element/color.json`：
  - 新增月之亮面/暗面颜色资源，支持深色模式自动切换

## 阶段2：AI对话数据层
**目标**：建立对话数据模型、状态管理、Mock服务

新建文件：
- `entry/src/main/ets/models/ChatModel.ets`：
  - ChatMessage 类（id/role/content/timestamp/thinking/sources/suggestions）
  - Conversation 类（id/title/messages/createdAt/updatedAt）
  - MessageRole 枚举（USER/AI/THINKING）
  - ThinkingStep 类（步骤文字/状态/图标）
  - SourceRef 类（引用来源：标题/描述/链接）
- `entry/src/main/ets/stores/ChatStore.ets`：
  - @ObservedV2 类，@Trace 追踪 conversations/currentConversation/messages
  - 当前对话、历史对话列表、新建/删除/切换对话
  - 流式消息追加（模拟AI逐字输出）
- `entry/src/main/ets/services/ChatService.ets`：
  - sendMessage(message): Promise<void> 异步发送
  - Mock AI回复逻辑（根据关键词返回预设回答，模拟思考过程）
  - 流式输出（每50ms追加一段文字）
  - 后续可替换为真实API调用

## 阶段3：AI对话核心组件
**目标**：构建Kimi风格的对话UI组件库

新建文件（`entry/src/main/ets/components/chat/`）：
- `ChatMessageBubble.ets`：消息气泡
  - 用户消息：右对齐，蓝紫渐变背景，白字，圆角18vp（左上/左下/右上）+ 6vp（右下）
  - AI回复：左对齐，无边界容器风格（浅色透明/暗色#252540），主文字色，圆角18vp
  - 最大宽度75%，内边距12/16，字体15fp，行高1.6
- `ThinkingProcess.ets`：思考过程可折叠容器
  - 背景#F3F4F6（亮）/#1F1F3A（暗），圆角12vp
  - 步骤列表（搜索/分析/整理），每步前有图标动画
  - 展开/折叠动画200ms ease-out
- `SuggestionCards.ets`：追问建议卡片组
  - 水平滚动，卡片圆角12vp，1px边框#E5E7EB
  - 文字13vp品牌色#4A6CF7，点击态淡蓝紫背景
- `SourceReference.ets`：引用来源展示
  - 左边框3dp蓝紫渐变，背景rgba(74,108,247,0.05)，圆角8vp
- `ChatInputBar.ets`：底部输入区
  - 容器：月之亮面#FFFFFF/暗面#1A1A2E，顶部分隔线
  - 输入框：背景#F3F4F6/#252540，圆角22vp胶囊形，占位"有问题尽管问我..."
  - 附件按钮[+] 44×44vp（左），语音按钮 44×44vp（右）
  - 发送按钮：蓝紫渐变背景+白箭头，空内容时灰色禁用
  - 高度56-120vp自动展开

## 阶段4：顶部导航栏与模型选择
**目标**：Kimi风格顶部栏 + 模型切换BottomSheet

新建文件：
- `entry/src/main/ets/components/chat/ChatTopBar.ets`：
  - 高度56dp，月之亮面/暗面背景，液态玻璃模糊
  - 左：侧边栏按钮 48×48dp
  - 中：模型选择器（当前模型名 + 下拉箭头），16sp Medium
  - 右：用户头像 32×32dp 圆形
- `entry/src/main/ets/components/chat/ModelSelectorSheet.ets`：
  - 底部BottomSheet弹出，顶部圆角16dp
  - 模式卡片：快速模式/思考模式/联网搜索/K3（72dp高，圆角12dp）
  - 选中态：蓝紫渐变边框2dp + 浅渐变背景 + 右侧✓图标
- `entry/src/main/ets/stores/ModelStore.ets`：
  - 当前选中模型、模型列表、切换逻辑

## 阶段5：侧边栏改造
**目标**：将现有首页侧边栏改为Kimi风格对话历史侧边栏

修改/新建文件：
- `entry/src/main/ets/components/chat/SideMenu.ets`（新建，替代现有首页侧边栏逻辑）：
  - 宽度280dp，全屏高度，月之亮面#FFFFFF/暗面#0F0F1A背景
  - 液态玻璃模糊效果
  - 展开动画：从左滑入250ms ease-out
  - 蒙层：rgba(0,0,0,0.5)，点击关闭
  - 顶部用户区72dp：头像48dp + 用户名16sp + VIP徽章
  - "新建对话"按钮：44dp高，蓝紫渐变背景，圆角22vp胶囊形
  - 历史对话列表：按时间分组（今天/昨天/7天内/更早）
    - 对话项48dp高，圆角8vp，标题14sp单行省略
    - 选中态：rgba(74,108,247,0.1)背景
  - 底部功能区：设置/会员/帮助/退出（每项48dp）
  - **原有功能入口**（保留）：院校库/志愿填报/学习计划/政策资讯 作为菜单项

## 阶段6：AI对话主页整合
**目标**：新建对话主页，整合所有组件

新建文件：
- `entry/src/main/ets/views/chat/ChatPage.ets`：
  - 整体布局：Stack（侧边栏蒙层 + 主内容）
  - 主内容：Column（ChatTopBar + 对话列表 + ChatInputBar）
  - 对话列表：List + LazyForEach，垂直滚动
  - 空对话态：欢迎引导（Logo + 建议提问卡片）
  - 消息入场动画：透明度淡入 + Y轴上移20vp，逐项延迟50ms
  - 底部输入栏固定，适配安全区

## 阶段7：入口架构改造
**目标**：将应用入口从4Tab架构改为单AI对话主页

修改文件：
- `entry/src/main/ets/pages/Index.ets`：
  - 移除4个Tab页面切换逻辑
  - 主内容改为 ChatPage
  - 侧边栏触发改为 ChatTopBar 的按钮
  - 保留 Navigation 用于跳转子页面（院校/志愿等原有功能）
  - LiquidTabBar 移除或改为可选（Kimi无底部Tab）
- `entry/src/main/ets/router/RouterMap.ets`：
  - 保留原有路由（院校/志愿/学习等页面）
  - 新增对话历史详情页路由（如需要）

## 阶段8：Mock数据与联调
**目标**：完成Mock AI对话流程，确保可运行

- ChatService 实现Mock逻辑：
  - 预设回答库（专升本相关问题）
  - 模拟思考过程（3步：搜索资料/分析信息/整理结论）
  - 流式输出效果
  - 随机生成追问建议
- 联调：发送消息 → 思考过程 → AI回复 → 追问建议 完整流程
- 后续对接真实API时，只需替换 ChatService 实现

## 实施顺序与依赖
1. 阶段0（保存计划） → 阶段1（设计系统） — 基础，无依赖
2. 阶段2（数据层） — 依赖阶段1的类型定义
3. 阶段3（对话组件） — 依赖阶段1+2
4. 阶段4（顶部栏+模型选择） — 依赖阶段1
5. 阶段5（侧边栏） — 依赖阶段2
6. 阶段6（对话主页） — 依赖3+4+5
7. 阶段7（入口改造） — 依赖6
8. 阶段8（Mock联调） — 依赖7

## 风险与注意事项
- **不删除现有功能代码**：原有 views/college、views/volunteer、views/study 等保留，仅从侧边栏进入
- **液态玻璃保留**：玻璃效果参数（GlassEffect）保持，与新蓝紫渐变融合
- **深色模式**：月之亮面/暗面通过 resources/base + resources/dark 实现
- **安全区适配**：顶部栏和输入栏需适配状态栏和导航栏
- **memory规范**：渐变方向统一135°（PRIMARY_COLOR → PRIMARY_GRADIENT_END），符合已记录的代码风格规范

---

## 实施进度跟踪

### 已完成 ✅

#### 阶段0：保存计划文档 ✅
- 文件：`.qoder/plans/前端重构为AI对话应用.md`

#### 阶段1：设计系统迁移 ✅
- `common/Constants.ets`（7.7KB）：PRIMARY_COLOR→#4A6CF7，新增 PRIMARY_GRADIENT_END、GLASS_XLIGHT、Moon Light/Dark 色系（MOON_LIGHT_*/MOON_DARK_*）、ButtonStyles更新
- `common/DesignTokens.ets`（5.3KB）：新增 KimiGradient 类（ANGLE=135, START_COLOR=#4A6CF7, END_COLOR=#8B5CF6）、ChatRadius 类（INPUT=22, MESSAGE=18）、ChatFontSize 类。移除了返回 LinearGradient 类型的 linearGradient() 方法（类型不存在）
- `resources/base/element/color.json`：新增 moon_bg_page, moon_bg_content, moon_ai_reply_bg, moon_text_primary/secondary/hint, moon_divider, moon_input_bg, brand_primary, brand_gradient_end（亮色值）
- `resources/dark/element/color.json`：同上颜色名，暗色值（如 moon_bg_page=#0F0F1A）

#### 阶段2：AI对话数据层 ✅
- `models/ChatModel.ets`（2.9KB）：MessageRole枚举、ThinkingStatus枚举、ConversationGroup枚举、ThinkingStep/SourceRef/ChatMessage/Conversation类（均@ObservedV2+@Trace）、getConversationGroup()函数
- `stores/ChatStore.ets`（4.5KB）：@ObservedV2类，conversations/currentConversation/isAiResponding；方法：addUserMessage/startAiMessage/appendAiContent/addThinkingStep/updateThinkingStep/addSources/addSuggestions/finishAiMessage/createNewConversation/selectConversation/deleteConversation/clearCurrent；通过AppStorageV2.connect连接为全局单例chatStore
- `services/ChatService.ets`（7.6KB）：Mock AI服务，关键词匹配（专升本条件/考试/院校/志愿/学习），流式输出（50ms/2字），思考过程模拟（3步×800ms），随机追问建议

#### 阶段3：AI对话核心组件 ✅
- `components/chat/ChatMessageBubble.ets`（2.0KB）：用户消息右对齐+蓝紫渐变+白字+圆角18/6；AI消息左对齐+无边界容器+85%最大宽度
- `components/chat/ThinkingProcess.ets`（2.4KB）：可折叠思考步骤容器，LoadingProgress/checkmark图标，展开折叠动画
- `components/chat/SuggestionCards.ets`（1.3KB）：水平滚动建议卡片，品牌色文字，边框+圆角样式
- `components/chat/SourceReference.ets`（1.8KB）：引用来源，左侧蓝紫条3vp，5%透明背景，标题+描述
- `components/chat/ChatInputBar.ets`（3.2KB）：底部输入区，plus按钮+TextArea(22vp胶囊)+发送/语音按钮切换，安全区适配

#### 阶段4：顶部导航栏与模型选择 ✅
- `stores/ModelStore.ets`（1.5KB）：AiModel类，ModelStore含currentModelId/currentModelName(@Trace)，4个模型（快速/思考/搜索/K3），switchModel()方法
- `components/chat/ChatTopBar.ets`（2.4KB）：顶部栏，menu按钮+模型选择器文字+chevron_down+用户头像(渐变圆形JM)，液态玻璃模糊背景，安全区顶部适配
- `components/chat/ModelSelectorSheet.ets`（3.3KB）：底部弹出Sheet，蒙层+拖拽指示器+模型卡片(72dp,选中态2px边框+checkmark)，安全区底部适配

### 待实施 ⏳

#### 阶段5：侧边栏改造（对话历史+功能入口）— ✅ 已完成
- 新建 `components/chat/SideMenu.ets`（356行）
- 宽度280dp，全屏高度，Moon Light背景，液态玻璃模糊
- 蒙层rgba(0,0,0,0.5)，点击关闭
- 顶部用户区72dp：头像48dp(蓝紫渐变)+用户名+VIP徽章
- “新建对话”按钮：44dp高，蓝紫渐变背景，22vp胶囊形
- 历史对话列表：按时间分组（今天/昨天/7天内/更早），对话项44dp高，选中态rgba(74,108,247,0.1)
- 原有功能入口：院校库/志愿填报/学习计划/政策资讯
- 底部功能菜单：设置/会员/帮助/退出

#### 阶段6：AI对话主页整合（ChatPage）— ✅ 已完成
- 新建 `views/chat/ChatPage.ets`（199行）
- Stack布局：主内容区 + SideMenu覆盖层 + ModelSelectorSheet覆盖层
- 主内容：Column（ChatTopBar + 对话列表/空状态 + ChatInputBar）
- 空对话态：Logo(蓝紫渐变圆形)+欢迎语+默认建议卡片
- 消息列表：List + ForEach，含思考过程/消息气泡/引用来源/追问建议
- 底部输入栏固定，disabled状态绑定chatStore.isAiResponding

#### 阶段7：入口架构改造（Index.ets）— ✅ 已完成
- 修改 `pages/Index.ets`（31行）：移除4Tab切换+LiquidTabBar，主内容改为ChatPage
- 保留Navigation+routerMap用于跳转子页面
- expandSafeArea保留，安全区由各组件内部适配

#### 阶段8：Mock数据与联调 — ✅ 已完成
- ChatService Mock逻辑已在阶段2完成（关键词匹配+流式输出+思考过程）
- ChatPage整合完整对话流程：发送消息→思考过程→AI回复→追问建议
- 侧边栏可新建/切换/删除对话，原有功能页面可从侧边栏进入
- 图标修复：sys.symbol.line_horizontal_3 → sys.symbol.more（HarmonyOS无此图标名）
- 构建工具仅在DevEco Studio IDE中可用，需在IDE中编译验证

## 关键技术决策记录

### 1. 渐变方向统一135°
- 蓝紫渐变 `#4A6CF7→#8B5CF6` 统一使用 135° 角度
- 组件中使用 `.linearGradient({ angle: 135, colors: [[#4A6CF7, 0.0], [#8B5CF6, 1.0]] })`
- DesignTokens.ets 中移除了返回 LinearGradient 类型的 linearGradient() 方法（该类型在ArkTS中不存在）

### 2. V2状态管理架构
- 所有Store类使用 @ObservedV2 + @Trace
- 全局单例通过 `AppStorageV2.connect(StoreClass, 'key', () => new StoreClass())!` 连接
- 组件中使用 @Local + AppStorageV2.connect 获取store实例

### 3. 已知潜在问题（待编译验证）
- `sys.symbol.line_horizontal_3`（menu图标）可能不是预定义系统图标名
- `sys.symbol.arrow_up`（发送按钮）可能需要替换为预定义名
- `sys.symbol.mic`、`sys.symbol.chevron_up/down` 可能需调整
- 安全图标名参考 Constants.ets：house, building, calendar, doc, checkmark, star, arrow_right, bell, clock, bookmark, lightbulb, magnifyingglass, plus 等

### 4. 文件保留策略
- 原有 views/college、views/volunteer、views/study 等代码不删除
- 通过侧边栏菜单进入原有功能页面
- 原有 Service（CollegeService/VolunteerService等）保留

