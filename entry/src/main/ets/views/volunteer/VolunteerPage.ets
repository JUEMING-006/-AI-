import { AppColors, RouteNames, ButtonStyles } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { volunteerService } from '../../services/VolunteerService';
import { CommonCard } from '../../components/CommonCard';

// 三梯度颜色
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

@ComponentV2
export struct VolunteerPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local btnScale: number[] = [1.0, 1.0, 1.0, 1.0];
  @Local btnOpacity: number[] = [1.0, 1.0, 1.0, 1.0];
  @Local tierScale: number[] = [1.0, 1.0, 1.0];
  @Local tierOpacity: number[] = [1.0, 1.0, 1.0];

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('志愿匹配')
          .fontSize(FontSize.TITLE + 4)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ top: Spacing.LG, bottom: Spacing.SM })

        // 引导区：成绩录入卡片
        CommonCard() {
          this.scoreGuideContent()
        }

        // 快速概览区（已录入后显示）
        if (volunteerService.hasScore) {
          CommonCard() {
            this.overviewContent()
          }
        }
      }
      .width('100%')
      .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.XL, bottom: Spacing.XL })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  scoreGuideContent() {
    if (!volunteerService.hasScore) {
      // 未录入：引导录入
      Column() {
        SymbolGlyph($r('sys.symbol.doc'))
          .fontSize(40)
          .fontColor([AppColors.PRIMARY_COLOR])
        Text('录入成绩开始匹配')
          .fontSize(FontSize.SUBTITLE)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: Spacing.MD })
        Button('录入成绩')
          .width('100%')
          .height(48)
          .fontSize(FontSize.SUBTITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ButtonStyles.PRIMARY_BTN_TEXT)
          .backgroundColor(ButtonStyles.PRIMARY_BTN_BG)
          .borderRadius(Radius.BUTTON)
          .margin({ top: Spacing.LG })
          .scale({ x: this.btnScale[0], y: this.btnScale[0] })
          .opacity(this.btnOpacity[0])
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.getUIContext()?.animateTo({
                duration: AnimConfig.BUTTON_PRESS_DURATION,
                curve: AnimConfig.BUTTON_PRESS_CURVE,
              }, () => {
                const newScale: number[] = [...this.btnScale];
                newScale[0] = AnimConfig.BUTTON_PRESS_SCALE;
                this.btnScale = newScale;
                const newOpacity: number[] = [...this.btnOpacity];
                newOpacity[0] = AnimConfig.BUTTON_PRESS_OPACITY;
                this.btnOpacity = newOpacity;
              });
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.getUIContext()?.animateTo({
                duration: AnimConfig.BUTTON_RELEASE_DURATION,
                curve: AnimConfig.BUTTON_RELEASE_CURVE,
              }, () => {
                const newScale: number[] = [...this.btnScale];
                newScale[0] = 1.0;
                this.btnScale = newScale;
                const newOpacity: number[] = [...this.btnOpacity];
                newOpacity[0] = 1.0;
                this.btnOpacity = newOpacity;
              });
            }
          })
          .onClick(() => {
            this.pathStack.pushPath({ name: RouteNames.SCORE_INPUT });
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    } else {
      // 已录入：显示总分 + 操作按钮
      Column() {
        Text('已录入成绩')
          .fontSize(FontSize.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
        Text(`${volunteerService.currentScore.totalScore}`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY_COLOR)
          .margin({ top: Spacing.XS })
        Text('总分')
          .fontSize(FontSize.BODY)
          .fontColor(AppColors.TEXT_HINT)
        Row() {
          Button('查看推荐')
            .layoutWeight(1)
            .height(40)
            .fontSize(FontSize.BODY)
            .fontColor(ButtonStyles.PRIMARY_BTN_TEXT)
            .backgroundColor(ButtonStyles.PRIMARY_BTN_BG)
            .borderRadius(Radius.BUTTON)
            .scale({ x: this.btnScale[1], y: this.btnScale[1] })
            .opacity(this.btnOpacity[1])
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_PRESS_DURATION,
                  curve: AnimConfig.BUTTON_PRESS_CURVE,
                }, () => {
                  const newScale: number[] = [...this.btnScale];
                  newScale[1] = AnimConfig.BUTTON_PRESS_SCALE;
                  this.btnScale = newScale;
                  const newOpacity: number[] = [...this.btnOpacity];
                  newOpacity[1] = AnimConfig.BUTTON_PRESS_OPACITY;
                  this.btnOpacity = newOpacity;
                });
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_RELEASE_DURATION,
                  curve: AnimConfig.BUTTON_RELEASE_CURVE,
                }, () => {
                  const newScale: number[] = [...this.btnScale];
                  newScale[1] = 1.0;
                  this.btnScale = newScale;
                  const newOpacity: number[] = [...this.btnOpacity];
                  newOpacity[1] = 1.0;
                  this.btnOpacity = newOpacity;
                });
              }
            })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_RESULT });
            })
          Button('重新录入')
            .layoutWeight(1)
            .height(40)
            .fontSize(FontSize.BODY)
            .backgroundColor(ButtonStyles.SECONDARY_BTN_BG)
            .fontColor(ButtonStyles.SECONDARY_BTN_TEXT)
            .borderRadius(Radius.BUTTON)
            .border({ width: 1, color: ButtonStyles.SECONDARY_BTN_BORDER })
            .margin({ left: Spacing.MD })
            .scale({ x: this.btnScale[2], y: this.btnScale[2] })
            .opacity(this.btnOpacity[2])
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_PRESS_DURATION,
                  curve: AnimConfig.BUTTON_PRESS_CURVE,
                }, () => {
                  const newScale: number[] = [...this.btnScale];
                  newScale[2] = AnimConfig.BUTTON_PRESS_SCALE;
                  this.btnScale = newScale;
                  const newOpacity: number[] = [...this.btnOpacity];
                  newOpacity[2] = AnimConfig.BUTTON_PRESS_OPACITY;
                  this.btnOpacity = newOpacity;
                });
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_RELEASE_DURATION,
                  curve: AnimConfig.BUTTON_RELEASE_CURVE,
                }, () => {
                  const newScale: number[] = [...this.btnScale];
                  newScale[2] = 1.0;
                  this.btnScale = newScale;
                  const newOpacity: number[] = [...this.btnOpacity];
                  newOpacity[2] = 1.0;
                  this.btnOpacity = newOpacity;
                });
              }
            })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteNames.SCORE_INPUT });
            })
        }
        .width('100%')
        .margin({ top: Spacing.LG })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  overviewContent() {
    Column() {
      Text('推荐概览')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: Spacing.MD })
      Row() {
        this.tierBadge('冲刺', volunteerService.currentPlan.rushCount, RUSH_COLOR, 0)
        this.tierBadge('稳妥', volunteerService.currentPlan.stableCount, STABLE_COLOR, 1)
        this.tierBadge('保底', volunteerService.currentPlan.safeCount, SAFE_COLOR, 2)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      Button('查看详细推荐')
        .width('100%')
        .height(40)
        .fontSize(FontSize.BODY)
        .fontColor(ButtonStyles.PRIMARY_BTN_TEXT)
        .backgroundColor(ButtonStyles.PRIMARY_BTN_BG)
        .borderRadius(Radius.BUTTON)
        .margin({ top: Spacing.LG })
        .scale({ x: this.btnScale[3], y: this.btnScale[3] })
        .opacity(this.btnOpacity[3])
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_PRESS_DURATION,
              curve: AnimConfig.BUTTON_PRESS_CURVE,
            }, () => {
              const newScale: number[] = [...this.btnScale];
              newScale[3] = AnimConfig.BUTTON_PRESS_SCALE;
              this.btnScale = newScale;
              const newOpacity: number[] = [...this.btnOpacity];
              newOpacity[3] = AnimConfig.BUTTON_PRESS_OPACITY;
              this.btnOpacity = newOpacity;
            });
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_RELEASE_DURATION,
              curve: AnimConfig.BUTTON_RELEASE_CURVE,
            }, () => {
              const newScale: number[] = [...this.btnScale];
              newScale[3] = 1.0;
              this.btnScale = newScale;
              const newOpacity: number[] = [...this.btnOpacity];
              newOpacity[3] = 1.0;
              this.btnOpacity = newOpacity;
            });
          }
        })
        .onClick(() => {
          this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_RESULT });
        })
    }
    .width('100%')
  }

  @Builder
  tierBadge(label: string, count: number, color: string, index: number) {
    Row() {
      // 左侧彩色边框
      Column()
        .width(4)
        .height(48)
        .backgroundColor(color)
        .borderRadius(2)
      Column() {
        Text(`${count}`)
          .fontSize(FontSize.DISPLAY)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
        Text(`${label}院校`)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: Spacing.XS })
        Text('所')
          .fontSize(11)
          .fontColor(AppColors.TEXT_HINT)
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ left: Spacing.SM })
    }
    .shadow(Shadows.GLASS)
    .backgroundColor(AppColors.GLASS_LIGHT)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
    .borderRadius(Radius.SM)
    .padding({ left: Spacing.SM, right: Spacing.SM, top: Spacing.SM, bottom: Spacing.SM })
    .scale({ x: this.tierScale[index], y: this.tierScale[index] })
    .opacity(this.tierOpacity[index])
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_PRESS_DURATION,
          curve: AnimConfig.LIQUID_PRESS_CURVE,
        }, () => {
          const newScale: number[] = [...this.tierScale];
          newScale[index] = AnimConfig.PRESS_SCALE;
          this.tierScale = newScale;
          const newOpacity: number[] = [...this.tierOpacity];
          newOpacity[index] = AnimConfig.PRESS_OPACITY;
          this.tierOpacity = newOpacity;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_RELEASE_DURATION,
          curve: AnimConfig.LIQUID_RELEASE_CURVE,
        }, () => {
          const newScale: number[] = [...this.tierScale];
          newScale[index] = 1.0;
          this.tierScale = newScale;
          const newOpacity: number[] = [...this.tierOpacity];
          newOpacity[index] = 1.0;
          this.tierOpacity = newOpacity;
        });
      }
    })
  }
}
