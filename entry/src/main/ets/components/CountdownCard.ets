import { AppColors } from '../common/Constants';
import { Radius, Shadows, Spacing, FontSize } from '../common/DesignTokens';
import { AnimConfig } from '../common/AnimationHelper';
import { getDaysCountdown } from '../common/Utils';

@ComponentV2
export struct CountdownCard {
  @Param examDate: string = '';
  @Param title: string = '距离考试';
  @Local daysRemaining: number = 0;

  aboutToAppear(): void {
    this.daysRemaining = getDaysCountdown(this.examDate);
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
      Row() {
        Text(`${this.daysRemaining}`)
          .fontSize(FontSize.DISPLAY)
          .fontWeight(FontWeight.Lighter)
          .fontColor(AppColors.PRIMARY_COLOR)
          .animation({
            duration: AnimConfig.BOUNCE_DURATION,
            curve: AnimConfig.BOUNCE_CURVE
          })
        Text('天')
          .fontSize(FontSize.TITLE)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ left: Spacing.XS, bottom: Spacing.SM })
          .alignSelf(ItemAlign.End)
      }
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: Spacing.SM })

      Text(this.examDate)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: Spacing.SM })
    }
    .width('100%')
    .padding(Spacing.XL)
    .borderRadius(Radius.XL)
    .backgroundColor(AppColors.CARD_COLOR)
    .shadow(Shadows.CARD)
  }
}
