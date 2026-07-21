// 底部输入区 — 深度思考/搜索开关 + 胶囊输入容器 + 附件/发送按钮 + AI生成提示
// 液态玻璃质感 + 按压反馈微动画
import { ChatFontSize, ChatRadius, KimiGradient, LiquidGlass } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';

@ComponentV2
export struct ChatInputBar {
  @Param onSend: (content: string) => void = (_c: string) => {};
  @Param onPlusClick: () => void = () => {};
  @Param onNavigate: (route: string) => void = (_r: string) => {};
  @Param disabled: boolean = false;
  @Local inputValue: string = '';
  @Local sendButtonScale: number = 1.0;
  @Local deepThinkingEnabled: boolean = false;
  @Local searchEnabled: boolean = false;

  // 发送按钮按压反馈
  private onSendTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.getUIContext()?.animateTo({ duration: AnimConfig.BUTTON_PRESS_DURATION, curve: AnimConfig.BUTTON_PRESS_CURVE }, () => {
        this.sendButtonScale = 0.88;
      });
    } else {
      this.getUIContext()?.animateTo({ duration: AnimConfig.BUTTON_RELEASE_DURATION, curve: AnimConfig.BUTTON_RELEASE_CURVE }, () => {
        this.sendButtonScale = 1.0;
      });
    }
  }

  build() {
    Column() {
      // 深度思考 + 搜索 开关
      Row({ space: 8 }) {
        // 深度思考开关
        Button() {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.lightbulb'))
              .fontSize(13)
              .fontColor([this.deepThinkingEnabled ? '#FFFFFF' : $r('app.color.moon_text_secondary')])
            Text('深度思考')
              .fontSize(13)
              .fontColor(this.deepThinkingEnabled ? '#FFFFFF' : $r('app.color.moon_text_secondary'))
          }
        }
        .type(ButtonType.Normal)
        .height(28)
        .padding({ left: 10, right: 10 })
        .borderRadius(14)
        .backgroundColor(this.deepThinkingEnabled ? $r('app.color.brand_primary') : $r('app.color.moon_function_tag_bg'))
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .onClick(() => {
          this.deepThinkingEnabled = !this.deepThinkingEnabled;
        })

        // 搜索开关
        Button() {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.magnifyingglass'))
              .fontSize(13)
              .fontColor([this.searchEnabled ? '#FFFFFF' : $r('app.color.moon_text_secondary')])
            Text('搜索')
              .fontSize(13)
              .fontColor(this.searchEnabled ? '#FFFFFF' : $r('app.color.moon_text_secondary'))
          }
        }
        .type(ButtonType.Normal)
        .height(28)
        .padding({ left: 10, right: 10 })
        .borderRadius(14)
        .backgroundColor(this.searchEnabled ? $r('app.color.brand_primary') : $r('app.color.moon_function_tag_bg'))
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .onClick(() => {
          this.searchEnabled = !this.searchEnabled;
        })
      }
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 8 })

      // 输入容器 — 集成式布局，附件按钮+输入框+发送按钮在同一行
      Row() {
        // 附件按钮 — 点击触发回调
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(18)
            .fontColor([$r('app.color.moon_text_secondary')])
        }
        .type(ButtonType.Circle)
        .width(32)
        .height(32)
        .backgroundColor($r('app.color.moon_icon_bg'))
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .borderRadius(16)
        .margin({ right: 8 })
        .onClick(() => {
          this.onPlusClick();
        })

        // 输入框
        TextArea({ text: this.inputValue, placeholder: '有问题尽管问我...' })
          .fontSize(ChatFontSize.BODY)
          .fontColor($r('app.color.moon_text_primary'))
          .placeholderColor($r('app.color.moon_text_hint'))
          .placeholderFont({ size: ChatFontSize.BODY })
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding({ left: 0, right: 0, top: 8, bottom: 8 })
          .constraintSize({ minHeight: 36, maxHeight: 100 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.inputValue = value;
          })

        // 发送按钮（有内容时）或语音按钮（无内容时）
        if (this.inputValue.trim().length > 0 && !this.disabled) {
          Button() {
            SymbolGlyph($r('sys.symbol.arrow_up'))
              .fontSize(16)
              .fontColor(['#FFFFFF'])
          }
          .type(ButtonType.Circle)
          .width(30)
          .height(30)
          .scale({ x: this.sendButtonScale, y: this.sendButtonScale })
          .linearGradient({
            angle: KimiGradient.ANGLE,
            colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
          })
          .shadow({ radius: 6, color: '#200066FF', offsetX: 0, offsetY: 2 })
          .margin({ left: 8 })
          .onClick(() => {
            const content: string = this.inputValue.trim();
            if (content.length > 0 && !this.disabled) {
              this.onSend(content);
              this.inputValue = '';
            }
          })
          .onTouch((event: TouchEvent) => this.onSendTouch(event))
        } else {
          // 语音按钮
          Button() {
            SymbolGlyph($r('sys.symbol.mic'))
              .fontSize(16)
              .fontColor([$r('app.color.moon_text_hint')])
          }
          .type(ButtonType.Circle)
          .width(30)
          .height(30)
          .backgroundColor($r('app.color.moon_function_tag_bg'))
          .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
          .shadow(LiquidGlass.SHADOW_CONTAINER)
          .borderRadius(15)
          .margin({ left: 8 })
        }
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundBlurStyle(LiquidGlass.CONTAINER_BLUR)
      .backgroundEffect({
        radius: LiquidGlass.CONTAINER_RADIUS,
        saturation: LiquidGlass.CONTAINER_SATURATION,
        brightness: LiquidGlass.CONTAINER_BRIGHTNESS,
        color: LiquidGlass.CONTAINER_COLOR
      })
      .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
      .shadow(LiquidGlass.SHADOW_CONTAINER)
      .borderRadius(ChatRadius.INPUT)
      .margin({ left: 16, right: 16 })

      // AI生成提示文字
      Text('内容由AI生成')
        .fontSize(11)
        .fontColor($r('app.color.moon_text_hint'))
        .margin({ top: 6 })
    }
    .width('100%')
    .padding({ top: 6, bottom: 8 })
    .backgroundColor(Color.Transparent)
  }
}
