// 模型选择底部弹出面板 — 从底部滑入的模式卡片列表
// 使用 transition + TransitionEffect.move 实现官方标准动画
import { ChatRadius, ChatFontSize, Spacing } from '../../common/DesignTokens';
import { modelStore, AiModel } from '../../stores/ModelStore';

@ComponentV2
export struct ModelSelectorSheet {
  @Param isVisible: boolean = false;
  @Param onClose: () => void = () => {};
  @Local safeAreaBottom: number = 0;

  aboutToAppear(): void {
    this.safeAreaBottom = AppStorage.get<number>('safeAreaBottom') ?? 0;
  }

  build() {
    // Stack 始终渲染，但关闭时 hitTestBehavior=None 不拦截触摸
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.isVisible) {
        // 蒙层 — 淡入淡出
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.moon_mask'))
          .onClick(() => this.onClose())
          .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseOut }))

        // 底部面板 — 从底部滑入
        Column() {
          // 拖拽指示器
          Column()
            .width(36)
            .height(4)
            .borderRadius(2)
            .backgroundColor($r('app.color.moon_text_hint'))
            .margin({ top: 12, bottom: Spacing.LG })

          // 标题
          Row() {
            Text('选择模型')
              .fontSize(ChatFontSize.TITLE)
              .fontColor($r('app.color.moon_text_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ left: 16, bottom: Spacing.LG })

          // 模型列表
          ForEach(modelStore.getModels(), (model: AiModel, index: number) => {
            Row() {
              Column() {
                Text(model.name)
                  .fontSize(ChatFontSize.TITLE)
                  .fontColor($r('app.color.moon_text_primary'))
                  .fontWeight(FontWeight.Medium)
                Text(model.description)
                  .fontSize(ChatFontSize.SOURCE_DESC)
                  .fontColor($r('app.color.moon_text_secondary'))
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 选中标记
              if (model.id === modelStore.currentModelId) {
                SymbolGlyph($r('sys.symbol.checkmark'))
                  .fontSize(20)
                  .fontColor([$r('app.color.brand_primary')])
              }
            }
            .width('100%')
            .height(72)
            .padding({ left: 16, right: 16 })
            .borderRadius(ChatRadius.CARD)
            .backgroundColor(model.id === modelStore.currentModelId
              ? $r('app.color.moon_selected_bg')
              : $r('app.color.moon_input_bg'))
            .border({
              width: model.id === modelStore.currentModelId ? 2 : 0.5,
              color: model.id === modelStore.currentModelId
                ? $r('app.color.brand_primary')
                : $r('app.color.moon_divider')
            })
            .margin({ bottom: Spacing.SM, left: 16, right: 16 })
            .onClick(() => {
              modelStore.switchModel(model.id);
              this.onClose();
            })
          }, (model: AiModel, index: number) => model.id)
        }
        .width('100%')
        .borderRadius({ topLeft: ChatRadius.SHEET_TOP, topRight: ChatRadius.SHEET_TOP })
        .backgroundColor($r('app.color.moon_sheet_bg'))
        .padding({ bottom: this.safeAreaBottom + 16 })
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 250, curve: Curve.EaseOut }))
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.isVisible ? HitTestMode.Default : HitTestMode.None)
  }
}
