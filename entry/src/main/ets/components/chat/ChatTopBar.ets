// 顶部导航栏 — 侧边栏按钮 + 模型选择器 + 静音按钮
// 遵循Kimi设计规范：56dp高度，液态玻璃背景，规范间距
import { ChatFontSize, LiquidGlass } from '../../common/DesignTokens';
import { modelStore } from '../../stores/ModelStore';

@ComponentV2
export struct ChatTopBar {
  @Param onMenuClick: () => void = () => {};
  @Param onModelClick: () => void = () => {};
  @Param onNewChat: () => void = () => {};
  @Local safeAreaTop: number = 0;
  @Local isMuted: boolean = false;

  aboutToAppear(): void {
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
  }

  build() {
    Column() {
      Row() {
        // 侧边栏触发按钮（液态玻璃）
        Button() {
          SymbolGlyph($r('sys.symbol.more'))
            .fontSize(20)
            .fontColor([$r('app.color.moon_text_primary')])
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('app.color.moon_icon_bg'))
        .backgroundBlurStyle(LiquidGlass.BUTTON_BLUR)
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .onClick(() => this.onMenuClick())

        // 模型选择器（液态玻璃胶囊，无下拉箭头）
        Button() {
          Text(modelStore.currentModelName)
            .fontSize(ChatFontSize.TITLE)
            .fontColor($r('app.color.moon_text_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .type(ButtonType.Normal)
        .height(40)
        .padding({ left: 14, right: 14 })
        .backgroundColor($r('app.color.moon_icon_bg'))
        .backgroundBlurStyle(LiquidGlass.BUTTON_BLUR)
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .borderRadius(20)
        .margin({ left: 4 })
        .onClick(() => this.onModelClick())

        Blank()

        // 新建对话 + 静音 融合药丸按钮
        Row() {
          // 新建对话按钮
          Button() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(18)
              .fontColor([$r('app.color.moon_text_primary')])
          }
          .type(ButtonType.Circle)
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.onNewChat())

          // 分隔线
          Divider()
            .vertical(true)
            .height(20)
            .color($r('app.color.moon_divider'))
            .strokeWidth(1)

          // 静音按钮
          Button() {
            SymbolGlyph(this.isMuted ? $r('sys.symbol.speaker_slash') : $r('sys.symbol.speaker_wave_2'))
              .fontSize(18)
              .fontColor([this.isMuted
                ? $r('app.color.moon_text_hint')
                : $r('app.color.moon_text_primary')])
          }
          .type(ButtonType.Circle)
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.isMuted = !this.isMuted;
          })
        }
        .height(40)
        .backgroundColor($r('app.color.moon_icon_bg'))
        .backgroundBlurStyle(LiquidGlass.BUTTON_BLUR)
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .borderRadius(20)
        .margin({ right: 12 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12 })

      // 底部分隔线 — 增强视觉边界
      Divider()
        .color($r('app.color.moon_divider'))
        .strokeWidth(1)
    }
    .width('100%')
    .padding({ top: this.safeAreaTop })
    .backgroundColor($r('app.color.moon_chat_bar_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
  }
}
