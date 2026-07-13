import { AppColors } from '../common/Constants';

@ComponentV2
export struct SearchBar {
  @Param placeholder: string = '搜索…';
  @Param onSearch: (keyword: string) => void = () => {};
  @Local keyword: string = '';
  @Local isFocused: boolean = false;

  build() {
    Row() {
      Search({ placeholder: this.placeholder, value: this.keyword })
        .placeholderColor(AppColors.TEXT_HINT)
        .placeholderFont({ size: 14 })
        .height(40)
        .layoutWeight(1)
        .backgroundColor('transparent')
        .onFocus(() => {
          this.isFocused = true;
        })
        .onBlur(() => {
          this.isFocused = false;
        })
        .onSubmit((value: string) => {
          this.onSearch(value);
        })
        .onChange((value: string) => {
          this.keyword = value;
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.isFocused ? AppColors.CARD_COLOR : AppColors.BLUR_BG)
    .borderRadius(22)
    .border({
      width: this.isFocused ? 1 : 0,
      color: this.isFocused ? AppColors.PRIMARY_COLOR : 'transparent'
    })
    .animation({ duration: 200, curve: Curve.EaseInOut })
  }
}
