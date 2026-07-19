// 追问建议卡片组 — 水平滚动的建议问题卡片
// 遵循Kimi设计规范：卡片式设计，品牌色文字，圆角边框
import { ChatFontSize, Spacing } from '../../common/DesignTokens';

@ComponentV2
export struct SuggestionCards {
  @Param suggestions: string[] = [];
  @Param onSuggestionClick: (suggestion: string) => void = (_s: string) => {};

  build() {
    if (this.suggestions.length > 0) {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.suggestions, (suggestion: string, index: number) => {
            Text(suggestion)
              .fontSize(ChatFontSize.SUGGESTION)
              .fontColor($r('app.color.brand_primary'))
              .padding({ top: 8, bottom: 8, left: 14, right: 14 })
              .borderRadius(16)
              .backgroundColor($r('app.color.moon_suggestion_bg'))
              .border({ width: 1, color: $r('app.color.moon_suggestion_border') })
              .onClick(() => {
                this.onSuggestionClick(suggestion);
              })
          }, (suggestion: string, index: number) => `${index}_${suggestion}`)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ top: Spacing.SM, bottom: Spacing.SM })
    }
  }
}
