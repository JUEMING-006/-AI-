import { AppColors } from '../common/Constants';
import { Spacing } from '../common/DesignTokens';

@ComponentV2
export struct EmptyView {
  @Param message: string = '暂无数据';
  @Param icon: Resource = $r('sys.symbol.doc');

  build() {
    Column() {
      SymbolGlyph(this.icon)
        .fontSize(48)
        .fontColor([AppColors.TEXT_HINT])
      Text(this.message)
        .fontSize(14)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Spacing.XXL, bottom: Spacing.XXL })
  }
}
