import { AppColors, TabIcons, TabLabels } from '../common/Constants';
import { GlassEffect, Radius, Shadows, Spacing } from '../common/DesignTokens';

/**
 * 🌊 液态玻璃风格底部 Tab 栏
 * 
 * 设计规范：
 * - 悬浮固定在屏幕底部，水平居中
 * - 距底部间距：20px + 安全区底部高度
 * - 最高层级（z-index: 999）
 * - 穿透交互：Tab 栏容器区域不拦截底层内容的点击
 * - 纯透明玻璃质感，无模糊，仅通过透明度、边框高光和微弱光线折射体现“玻璃”质感
 */

// Tab 项数据接口
export interface TabItem {
  label: string;
  icon: Resource;
  index: number;
}

@ComponentV2
export struct LiquidTabBar {
  // 当前选中的 Tab 索引
  @Param @Require currentIndex: number = 0;
  // Tab 切换回调
  @Param onTabChange: (index: number) => void = () => {};
  // 安全区底部高度
  @Param safeAreaBottom: number = 0;

  // 按压状态
  @Local pressedIndex: number = -1;
  @Local pressScale: number = 1.0;

  // Tab 项列表
  private readonly tabItems: TabItem[] = [
    { label: TabLabels.HOME, icon: TabIcons.HOME, index: 0 },
    { label: TabLabels.COLLEGE, icon: TabIcons.COLLEGE, index: 1 },
    { label: TabLabels.STUDY, icon: TabIcons.STUDY, index: 2 },
    { label: TabLabels.VOLUNTEER, icon: TabIcons.VOLUNTEER, index: 3 }
  ];
  
  // Tab 栏高度
  private readonly tabBarHeight: number = 56;
  // 底部间距
  private readonly bottomSpacing: number = 20;
  // Tab 栏圆角
  private readonly tabBarRadius: number = Radius.XL;
  
  build() {
    Column() {
      // 使用 Stack 叠加多层，构建玻璃深度
      Stack() {
        // 第一层：透明背景 + 极低模糊（玻璃折射基底）
        Row()
          .width('100%')
          .height('100%')
          .borderRadius(this.tabBarRadius)
          .backgroundColor(GlassEffect.GLASS_BG_COLOR)
          .backgroundEffect({
            radius: GlassEffect.EFFECT_RADIUS,
            saturation: GlassEffect.SATURATION,
            brightness: GlassEffect.BRIGHTNESS,
            color: GlassEffect.MASK_COLOR
          })

        // 第二层：底部深度渐变（模拟玻璃厚度）
        Row()
          .width('100%')
          .height('100%')
          .borderRadius(this.tabBarRadius)
          .linearGradient({
            angle: 180,
            colors: [
              [GlassEffect.DEPTH_COLOR_START, 0.0],
              [GlassEffect.DEPTH_COLOR_END, 1.0]
            ]
          })

        // 第三层：顶部高光渐变（玻璃表面反射）
        Row()
          .width('100%')
          .height('100%')
          .borderRadius(this.tabBarRadius)
          .linearGradient({
            angle: 180,
            colors: [
              [GlassEffect.HIGHLIGHT_COLOR_START, 0.0],
              [GlassEffect.HIGHLIGHT_COLOR_END, 0.5]
            ]
          })

        // 第四层：内容层（Tab 项）
        Row() {
          ForEach(this.tabItems, (item: TabItem) => {
            this.tabItemBuilder(item);
          }, (item: TabItem) => `${item.index}`)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(this.tabBarHeight)
      // 四角圆角
      .borderRadius(this.tabBarRadius)
      // ✨ 玻璃边框 — 明亮的边缘高光
      .border({
        width: GlassEffect.BORDER_WIDTH,
        color: GlassEffect.BORDER_COLOR
      })
      // 🎨 阴影 — 悬浮感
      .shadow(Shadows.GLASS)
      // 裁剪圆角内容
      .clip(true)
    }
    .width('100%')
    .height(this.tabBarHeight + this.bottomSpacing + this.safeAreaBottom)
    .padding({
      left: Spacing.LG,
      right: Spacing.LG,
      bottom: this.bottomSpacing + this.safeAreaBottom
    })
    // 📍 定位：固定在底部
    .position({ x: 0, y: '100%' })
    .translate({ y: -this.tabBarHeight - this.bottomSpacing - this.safeAreaBottom })
    // 🔝 最高层级
    .zIndex(999)
    // 🖱️ 穿透交互：仅 Tab 栏本体可交互
    .hitTestBehavior(HitTestMode.Transparent)
  }
  
  /**
   * Tab 项构建器
   */
  @Builder
  tabItemBuilder(item: TabItem) {
    Stack({ alignContent: Alignment.Center }) {
      // 选中态背景指示器
      if (item.index === this.currentIndex) {
        Column()
          .width(48)
          .height(32)
          .borderRadius(Radius.FULL)
          .backgroundColor('#15007AFF')
          .animation({ duration: 250, curve: Curve.EaseOut })
      }

      // 图标 + 文字
      Column() {
        SymbolGlyph(item.icon)
          .fontSize(22)
          .fontColor([item.index === this.currentIndex ? AppColors.PRIMARY_COLOR : AppColors.TEXT_HINT])
          .scale({
            x: item.index === this.currentIndex ? 1.15 : 1.0,
            y: item.index === this.currentIndex ? 1.15 : 1.0
          })
          .animation({ duration: 200, curve: Curve.EaseOut })

        Text(item.label)
          .fontSize(10)
          .margin({ top: 3 })
          .fontColor(item.index === this.currentIndex ? AppColors.PRIMARY_COLOR : AppColors.TEXT_HINT)
          .fontWeight(item.index === this.currentIndex ? FontWeight.Medium : FontWeight.Normal)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('25%')
    .height('100%')
    .scale({
      x: this.pressedIndex === item.index ? this.pressScale : 1.0,
      y: this.pressedIndex === item.index ? this.pressScale : 1.0
    })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onClick(() => {
      if (item.index !== this.currentIndex) {
        this.onTabChange(item.index);
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedIndex = item.index;
        this.getUIContext()?.animateTo({
          duration: 100,
          curve: Curve.EaseOut,
        }, () => {
          this.pressScale = 0.88;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: 200,
          curve: Curve.EaseOut,
        }, () => {
          this.pressScale = 1.0;
        });
      }
    })
    .hitTestBehavior(HitTestMode.Default)
  }
}
