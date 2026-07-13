import { AppColors } from '../common/Constants';

@ComponentV2
export struct LoadingView {
  @Param message: string = '加载中…';

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(AppColors.PRIMARY_COLOR)
      Text(this.message)
        .fontSize(14)
        .fontColor(AppColors.TEXT_HINT)
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
