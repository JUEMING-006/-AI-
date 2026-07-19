// 思考过程可折叠容器 — 显示AI推理步骤（搜索/分析/整理）
// 遵循Kimi设计规范：折叠容器，步骤图标动画
import { ThinkingStep, ThinkingStatus } from '../../models/ChatModel';
import { ChatFontSize, Spacing } from '../../common/DesignTokens';

@ComponentV2
export struct ThinkingProcess {
  @Param steps: ThinkingStep[] = [];
  @Local expanded: boolean = true;

  build() {
    Column() {
      // 标题行（可点击展开/折叠）
      Row() {
        SymbolGlyph($r('sys.symbol.lightbulb'))
          .fontSize(14)
          .fontColor([$r('app.color.moon_text_secondary')])
        Text('思考过程')
          .fontSize(ChatFontSize.STEP)
          .fontColor($r('app.color.moon_text_secondary'))
          .margin({ left: 6 })
        Blank()
        SymbolGlyph(this.expanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
          .fontSize(12)
          .fontColor([$r('app.color.moon_text_hint')])
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .onClick(() => {
        this.getUIContext()?.animateTo({
          duration: 200,
          curve: Curve.EaseOut,
        }, () => {
          this.expanded = !this.expanded;
        });
      })

      // 步骤列表（展开时显示）
      if (this.expanded) {
        ForEach(this.steps, (step: ThinkingStep, index: number) => {
          Row() {
            if (step.status === ThinkingStatus.LOADING) {
              LoadingProgress()
                .width(14)
                .height(14)
                .color($r('app.color.brand_primary'))
            } else {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize(12)
                .fontColor([$r('app.color.color_success')])
            }
            Text(step.text)
              .fontSize(ChatFontSize.STEP)
              .fontColor($r('app.color.moon_text_secondary'))
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 5, bottom: 5 })
        }, (step: ThinkingStep, index: number) => `${index}_${step.text}`)
      }
    }
    .width('100%')
    .borderRadius(12)
    .backgroundColor($r('app.color.moon_thinking_bg'))
    .margin({ left: 16, right: 16, top: 4, bottom: 4 })
  }
}
