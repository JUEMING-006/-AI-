// 消息气泡组件 — 用户消息(品牌蓝右对齐) / AI回复(左对齐+头像)
// 遵循Kimi设计规范：用户气泡12vp圆角+4vp尾角，AI消息玻璃质感容器+头像光晕
import { ChatMessage, MessageRole } from '../../models/ChatModel';
import { ChatFontSize, ChatRadius, KimiGradient, LiquidGlass, Spacing } from '../../common/DesignTokens';

@ComponentV2
export struct ChatMessageBubble {
  @Param message: ChatMessage = new ChatMessage(MessageRole.USER, '');
  @Param isLastMessage: boolean = false;
  // 入场动画状态
  @Local appearOpacity: number = 0;
  @Local appearTranslateY: number = 8;

  aboutToAppear(): void {
    this.getUIContext()?.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.appearOpacity = 1;
      this.appearTranslateY = 0;
    });
  }

  build() {
    if (this.message.role === MessageRole.USER) {
      // 用户消息 — 右对齐，品牌蓝微妙渐变背景
      Row() {
        Column() {
          Text(this.message.content)
            .fontSize(ChatFontSize.BODY)
            .fontColor('#FFFFFF')
            .lineHeight(24)
            .textAlign(TextAlign.Start)
        }
        .padding({ top: Spacing.MD, bottom: Spacing.MD, left: 16, right: 16 })
        .constraintSize({ maxWidth: '75%' })
        .borderRadius({
          topLeft: ChatRadius.MESSAGE,
          topRight: ChatRadius.MESSAGE,
          bottomLeft: ChatRadius.MESSAGE,
          bottomRight: ChatRadius.BUBBLE_TAIL
        })
        .linearGradient({
          angle: KimiGradient.ANGLE,
          colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
        })
        .shadow({ radius: 6, color: '#1A003399', offsetX: 0, offsetY: 2 })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      .opacity(this.appearOpacity)
      .translate({ y: this.appearTranslateY })
    } else {
      // AI 回复 — 左对齐 + 头像光晕 + 玻璃质感容器
      Row() {
        // AI 头像 — 品牌蓝渐变 + 微妙光晕
        Column() {
          SymbolGlyph($r('sys.symbol.lightbulb'))
            .fontSize(18)
            .fontColor(['#FFFFFF'])
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .linearGradient({
          angle: KimiGradient.ANGLE,
          colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
        })
        .shadow({ radius: 8, color: '#300066FF', offsetX: 0, offsetY: 2 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 10 })

        // AI 消息内容 — 玻璃质感容器
        Column() {
          Text(this.message.content)
            .fontSize(ChatFontSize.BODY)
            .fontColor($r('app.color.moon_ai_reply_text'))
            .lineHeight(24)
            .textAlign(TextAlign.Start)
        }
        .padding({ top: Spacing.MD, bottom: Spacing.MD, left: 16, right: 16 })
        .constraintSize({ maxWidth: '78%' })
        .borderRadius({
          topLeft: ChatRadius.BUBBLE_TAIL,
          topRight: ChatRadius.MESSAGE,
          bottomLeft: ChatRadius.MESSAGE,
          bottomRight: ChatRadius.MESSAGE
        })
        .backgroundColor($r('app.color.moon_ai_reply_bg'))
        .backgroundBlurStyle(BlurStyle.COMPONENT_THIN)
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      .opacity(this.appearOpacity)
      .translate({ y: this.appearTranslateY })
    }
  }
}
