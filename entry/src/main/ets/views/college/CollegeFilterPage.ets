import { AppColors, PROVINCE_LIST, ButtonStyles } from '../../common/Constants';
import { Radius } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { TagSelector } from '../../components/TagSelector';
import { NavHeader } from '../../components/NavHeader';

// 院校类型选项
const COLLEGE_TYPE_OPTIONS: string[] = ['全部', '公办', '民办', '职业本科'];

// 回调参数接口
interface FilterResult {
  province: string;
  type: string;
}

@ComponentV2
export struct CollegeFilterPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local selectedProvince: string[] = [];
  @Local selectedType: string[] = ['全部'];
  @Local confirmScale: number = 1.0;
  @Local confirmOpacity: number = 1.0;
  @Local resetScale: number = 1.0;
  @Local resetOpacity: number = 1.0;

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '院校筛选' })

        Scroll() {
          Column() {
          // 省份选择
          Text('选择省份')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.Start)

          TagSelector({
            tags: PROVINCE_LIST,
            selectedTags: this.selectedProvince,
            onTagSelect: (tag: string) => {
              this.onProvinceSelect(tag);
            },
            multiSelect: false
          })

          Divider()
            .color(AppColors.DIVIDER_COLOR)
            .margin({ top: 16, bottom: 16 })

          // 院校类型选择
          Text('院校类型')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ bottom: 12 })
            .alignSelf(ItemAlign.Start)

          TagSelector({
            tags: COLLEGE_TYPE_OPTIONS,
            selectedTags: this.selectedType,
            onTagSelect: (tag: string) => {
              this.onTypeSelect(tag);
            },
            multiSelect: false
          })

          // 确认按钮（主按钮风格）
          Button('确认筛选')
            .width('100%')
            .height(44)
            .fontSize(16)
            .fontColor(ButtonStyles.PRIMARY_BTN_TEXT)
            .backgroundColor(ButtonStyles.PRIMARY_BTN_BG)
            .borderRadius(Radius.BUTTON)
            .margin({ top: 32 })
            .scale({ x: this.confirmScale, y: this.confirmScale })
            .opacity(this.confirmOpacity)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_PRESS_DURATION,
                  curve: AnimConfig.BUTTON_PRESS_CURVE,
                }, () => {
                  this.confirmScale = AnimConfig.BUTTON_PRESS_SCALE;
                  this.confirmOpacity = AnimConfig.BUTTON_PRESS_OPACITY;
                });
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_RELEASE_DURATION,
                  curve: AnimConfig.BUTTON_RELEASE_CURVE,
                }, () => {
                  this.confirmScale = 1.0;
                  this.confirmOpacity = 1.0;
                });
              }
            })
            .onClick(() => {
              this.onConfirm();
            })

          // 重置按钮（次按钮风格）
          Button('重置')
            .width('100%')
            .height(44)
            .fontSize(16)
            .fontColor(ButtonStyles.SECONDARY_BTN_TEXT)
            .backgroundColor(ButtonStyles.SECONDARY_BTN_BG)
            .borderRadius(Radius.BUTTON)
            .border({ width: 1, color: ButtonStyles.SECONDARY_BTN_BORDER })
            .margin({ top: 12 })
            .scale({ x: this.resetScale, y: this.resetScale })
            .opacity(this.resetOpacity)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_PRESS_DURATION,
                  curve: AnimConfig.BUTTON_PRESS_CURVE,
                }, () => {
                  this.resetScale = AnimConfig.BUTTON_PRESS_SCALE;
                  this.resetOpacity = AnimConfig.BUTTON_PRESS_OPACITY;
                });
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_RELEASE_DURATION,
                  curve: AnimConfig.BUTTON_RELEASE_CURVE,
                }, () => {
                  this.resetScale = 1.0;
                  this.resetOpacity = 1.0;
                });
              }
            })
            .onClick(() => {
              this.onReset();
            })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  private onProvinceSelect(tag: string): void {
    if (this.selectedProvince.length > 0 && this.selectedProvince[0] === tag) {
      this.selectedProvince = [];
    } else {
      this.selectedProvince = [tag];
    }
  }

  private onTypeSelect(tag: string): void {
    this.selectedType = [tag];
  }

  private onConfirm(): void {
    const result: FilterResult = {
      province: this.selectedProvince.length > 0 ? this.selectedProvince[0] : '',
      type: this.selectedType[0] === '全部' ? '' : this.selectedType[0],
    };
    AppStorage.setOrCreate('filterResult', result);
    this.pathStack.pop();
  }

  private onReset(): void {
    this.selectedProvince = [];
    this.selectedType = ['全部'];
  }
}
