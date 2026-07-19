// 消息气泡组件 — 用户消息(品牌蓝右对齐) / AI回复(左对齐+头像)
// 遵循Kimi设计规范：用户气泡12vp圆角+4vp尾角，AI消息无边框+头像
import { ChatMessage, MessageRole } from '../../models/ChatModel';
import { ChatFontSize, KimiGradient, Spacing } from '../../common/DesignTokens';

@ComponentV2
export struct ChatMessageBubble {
  @Param message: ChatMessage = new ChatMessage(MessageRole.USER, '');
  @Param isLastMessage: boolean = false;

  build() {
    if (this.message.role === MessageRole.USER) {
      // 用户消息 — 右对齐，品牌蓝背景
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
          topLeft: 12,
          topRight: 12,
          bottomLeft: 12,
          bottomRight: 4
        })
        .linearGradient({
          angle: KimiGradient.ANGLE,
          colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    } else {
      // AI 回复 — 左对齐 + 头像 + 无边框容器
      Row() {
        // AI 头像
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
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 10 })

        // AI 消息内容
        Column() {
          Text(this.message.content)
            .fontSize(ChatFontSize.BODY)
            .fontColor($r('app.color.moon_text_primary'))
            .lineHeight(24)
            .textAlign(TextAlign.Start)
        }
        .padding({ top: Spacing.MD, bottom: Spacing.MD, left: 16, right: 16 })
        .constraintSize({ maxWidth: '78%' })
        .borderRadius({
          topLeft: 4,
          topRight: 12,
          bottomLeft: 12,
          bottomRight: 12
        })
        .backgroundColor($r('app.color.moon_ai_reply_bg'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    }
  }
}
