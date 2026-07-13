import { AppColors } from '../common/Constants';
import { FontSize, Spacing, Radius } from '../common/DesignTokens';

@ComponentV2
export struct TagSelector {
  @Param tags: string[] = [];
  @Param selectedTags: string[] = [];
  @Param onTagSelect: (tag: string) => void = () => {};
  @Param multiSelect: boolean = false;

  private isSelected(tag: string): boolean {
    return this.selectedTags.indexOf(tag) >= 0;
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.tags, (tag: string) => {
        Text(tag)
          .fontSize(FontSize.BODY)
          .fontColor(this.isSelected(tag) ? AppColors.CARD_COLOR : AppColors.TEXT_SECONDARY)
          .backgroundColor(this.isSelected(tag) ? AppColors.PRIMARY_COLOR : AppColors.CARD_COLOR)
          .border({
            width: this.isSelected(tag) ? 0 : 1,
            color: this.isSelected(tag) ? 'transparent' : AppColors.DIVIDER_COLOR
          })
          .borderRadius(Radius.SM)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .margin({ right: Spacing.SM, bottom: Spacing.SM })
          .scale({
            x: this.isSelected(tag) ? 1.02 : 1,
            y: this.isSelected(tag) ? 1.02 : 1
          })
          .animation({ duration: 200, curve: Curve.EaseInOut })
          .onClick(() => {
            this.onTagSelect(tag);
          })
      }, (tag: string) => tag)
    }
    .width('100%')
  }
}
