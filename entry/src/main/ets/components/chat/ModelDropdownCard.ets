// 模型选择悬浮卡片 — 从顶部向下弹出的白色大圆角卡片
// 非全屏遮罩Modal，透明背景，点击外部空白区域自动收回
import { modelStore, AiModel } from '../../stores/ModelStore';

@ComponentV2
export struct ModelDropdownCard {
  @Param isVisible: boolean = false;
  @Param onClose: () => void = () => {};
  @Local safeAreaTop: number = 0;

  aboutToAppear(): void {
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.isVisible) {
        // 透明点击层 — 点击外部空白区域收起卡片
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.onClose())
          .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseOut }))

        // 悬浮白色大圆角卡片 — 向下弹出
        Column() {
          ForEach(modelStore.getModels(), (model: AiModel) => {
            Row() {
              Column() {
                Text(model.name)
                  .fontSize(16)
                  .fontColor(model.id === modelStore.currentModelId
                    ? $r('app.color.brand_primary')
                    : $r('app.color.moon_text_primary'))
                  .fontWeight(FontWeight.Medium)
                Text(model.description)
                  .fontSize(13)
                  .fontColor($r('app.color.moon_text_secondary'))
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 选中状态显示 checkmark 图标
              if (model.id === modelStore.currentModelId) {
                SymbolGlyph($r('sys.symbol.checkmark'))
                  .fontSize(18)
                  .fontColor([$r('app.color.brand_primary')])
              }
            }
            .width('100%')
            .height(62)
            .padding({ left: 16, right: 16 })
            .borderRadius(12)
            .backgroundColor(model.id === modelStore.currentModelId
              ? $r('app.color.moon_selected_bg')
              : Color.Transparent)
            .margin({ left: 6, right: 6 })
            .onClick(() => {
              modelStore.switchModel(model.id);
              this.onClose();
            })
          }, (model: AiModel) => model.id)
        }
        .width(240)
        .borderRadius(24)
        .backgroundEffect({
          radius: 25,
          saturation: 1.8,
          brightness: 1.0,
          color: '#50FFFFFF'
        })
        .shadow({ radius: 30, color: '#15000000', offsetX: 0, offsetY: 8 })
        .padding({ top: 6, bottom: 6 })
        // 定位在顶栏正下方，水平居中
        .margin({ top: this.safeAreaTop + 64 })
        .transition(TransitionEffect.OPACITY
          .animation({ duration: 200, curve: Curve.EaseOut }))
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.isVisible ? HitTestMode.Transparent : HitTestMode.None)
  }
}
