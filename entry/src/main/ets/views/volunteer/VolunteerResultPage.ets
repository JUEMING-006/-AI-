import { AppColors } from '../../common/Constants';
import { FontSize, Spacing, Radius } from '../../common/DesignTokens';
import { AnimConfig, getStaggerDelay } from '../../common/AnimationHelper';
import { RecommendCollege, VolunteerPlan } from '../../models/VolunteerModel';
import { volunteerService } from '../../services/VolunteerService';
import { LoadingView } from '../../components/LoadingView';
import { CommonCard } from '../../components/CommonCard';

// 三梯度颜色常量
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

// 推荐院校卡片组件（液态玻璃 + 按压边框加深）
@ComponentV2
struct RecommendCardItem {
  @Param college: RecommendCollege = new RecommendCollege();
  @Param tierColor: string = '#FF6B6B';
  @Param visible: boolean = false;
  @Param onTap: (college: RecommendCollege) => void = () => {};
  @Local pressScale: number = 1.0;
  @Local pressOpacity: number = 1.0;
  @Local pressBorderWidth: number = 0;

  build() {
    if (this.visible) {
      Column() {
        CommonCard({ marginTop: Spacing.SM, enablePressAnim: false }) {
          Column() {
            Row() {
              Column() {
                Text(this.college.name)
                  .fontSize(FontSize.BODY)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppColors.TEXT_PRIMARY)
                Text(this.college.type)
                  .fontSize(FontSize.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .margin({ top: Spacing.XS })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Stack() {
                Progress({ value: this.college.probability, total: 100, type: ProgressType.Ring })
                  .width(48)
                  .height(48)
                  .color(this.tierColor)
                  .backgroundColor('#F0F0F0')
                  .style({ strokeWidth: 5 })
                Text(`${this.college.probability}%`)
                  .fontSize(FontSize.CAPTION)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.tierColor)
              }
            }
            .width('100%')

            Row() {
              Text(`去年最低分：${this.college.lastYearMinScore}`)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_HINT)
              Blank()
              Text(`招生：${this.college.enrollCount}人`)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_HINT)
            }
            .width('100%')
            .margin({ top: Spacing.SM })
          }
        }
      }
      .width('100%')
      .border({
        width: this.college.isSelected ? 1.5 + this.pressBorderWidth : this.pressBorderWidth,
        color: this.college.isSelected ? this.tierColor : AppColors.GLASS_BORDER
      })
      .scale({ x: this.pressScale, y: this.pressScale })
      .opacity(this.pressOpacity)
      .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 15 })))
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.getUIContext()?.animateTo({
            duration: AnimConfig.LIQUID_PRESS_DURATION,
            curve: AnimConfig.LIQUID_PRESS_CURVE,
          }, () => {
            this.pressScale = AnimConfig.PRESS_SCALE;
            this.pressOpacity = AnimConfig.PRESS_OPACITY;
            this.pressBorderWidth = 1;
          });
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.getUIContext()?.animateTo({
            duration: AnimConfig.LIQUID_RELEASE_DURATION,
            curve: AnimConfig.LIQUID_RELEASE_CURVE,
          }, () => {
            this.pressScale = 1.0;
            this.pressOpacity = 1.0;
            this.pressBorderWidth = 0;
          });
        }
      })
      .onClick(() => {
        this.onTap(this.college);
      })
    }
  }
}

@ComponentV2
export struct VolunteerResultPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local plan: VolunteerPlan = new VolunteerPlan();
  @Local isLoading: boolean = true;
  @Local cardVisible: boolean[] = [];
  @Local rushList: RecommendCollege[] = [];
  @Local stableList: RecommendCollege[] = [];
  @Local safeList: RecommendCollege[] = [];
  @Local returnBtnScale: number = 1.0;
  @Local returnBtnOpacity: number = 1.0;

  aboutToAppear(): void {
    this.loadResult();
  }

  private loadResult(): void {
    if (volunteerService.hasScore) {
      this.plan = volunteerService.currentPlan;
    }
    this.isLoading = false;
    // 分组
    const rush: RecommendCollege[] = [];
    const stable: RecommendCollege[] = [];
    const safe: RecommendCollege[] = [];
    for (const c of this.plan.recommendations) {
      if (c.tier === '冲刺') {
        rush.push(c);
      } else if (c.tier === '稳妥') {
        stable.push(c);
      } else {
        safe.push(c);
      }
    }
    this.rushList = rush;
    this.stableList = stable;
    this.safeList = safe;
    // Stagger 入场动画
    this.cardVisible = this.plan.recommendations.map((): boolean => false);
    this.plan.recommendations.forEach((_: RecommendCollege, index: number) => {
      setTimeout(() => {
        const updated: boolean[] = [...this.cardVisible];
        updated[index] = true;
        this.cardVisible = updated;
      }, getStaggerDelay(index));
    });
  }

  private getTierColor(tier: string): string {
    if (tier === '冲刺') {
      return RUSH_COLOR;
    } else if (tier === '稳妥') {
      return STABLE_COLOR;
    }
    return SAFE_COLOR;
  }

  private isCardVisible(globalIndex: number): boolean {
    return this.cardVisible.length > globalIndex && this.cardVisible[globalIndex];
  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        LoadingView({ message: '加载志愿推荐结果...' })
      } else if (this.plan.recommendations.length === 0) {
        Column() {
          Text('暂无推荐结果')
            .fontSize(FontSize.SUBTITLE)
            .fontColor(AppColors.TEXT_HINT)
          Text('请先录入成绩进行志愿匹配')
            .fontSize(FontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: Spacing.SM })
          Button('返回录入')
            .width(120)
            .height(40)
            .fontSize(FontSize.BODY)
            .backgroundColor(AppColors.PRIMARY_COLOR)
            .margin({ top: Spacing.XL })
            .scale({ x: this.returnBtnScale, y: this.returnBtnScale })
            .opacity(this.returnBtnOpacity)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_PRESS_DURATION,
                  curve: AnimConfig.BUTTON_PRESS_CURVE,
                }, () => {
                  this.returnBtnScale = AnimConfig.BUTTON_PRESS_SCALE;
                  this.returnBtnOpacity = AnimConfig.BUTTON_PRESS_OPACITY;
                });
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.getUIContext()?.animateTo({
                  duration: AnimConfig.BUTTON_RELEASE_DURATION,
                  curve: AnimConfig.BUTTON_RELEASE_CURVE,
                }, () => {
                  this.returnBtnScale = 1.0;
                  this.returnBtnOpacity = 1.0;
                });
              }
            })
            .onClick(() => {
              this.pathStack.pop();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 统计概览
            CommonCard({ marginTop: Spacing.MD }) {
              Row() {
                this.tierStat('冲刺', this.plan.rushCount, RUSH_COLOR)
                this.tierStat('稳妥', this.plan.stableCount, STABLE_COLOR)
                this.tierStat('保底', this.plan.safeCount, SAFE_COLOR)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceEvenly)
            }

            // 冲刺组
            if (this.rushList.length > 0) {
              this.tierHeader('冲刺', this.rushList.length, RUSH_COLOR)
              ForEach(this.rushList, (college: RecommendCollege, idx: number) => {
                RecommendCardItem({
                  college: college,
                  tierColor: RUSH_COLOR,
                  visible: this.isCardVisible(idx),
                  onTap: (c: RecommendCollege) => {
                    c.isSelected = !c.isSelected;
                  }
                })
              }, (c: RecommendCollege, idx: number) => `rush_${idx}`)
            }

            // 稳妥组
            if (this.stableList.length > 0) {
              this.tierHeader('稳妥', this.stableList.length, STABLE_COLOR)
              ForEach(this.stableList, (college: RecommendCollege, idx: number) => {
                RecommendCardItem({
                  college: college,
                  tierColor: STABLE_COLOR,
                  visible: this.isCardVisible(this.rushList.length + idx),
                  onTap: (c: RecommendCollege) => {
                    c.isSelected = !c.isSelected;
                  }
                })
              }, (c: RecommendCollege, idx: number) => `stable_${idx}`)
            }

            // 保底组
            if (this.safeList.length > 0) {
              this.tierHeader('保底', this.safeList.length, SAFE_COLOR)
              ForEach(this.safeList, (college: RecommendCollege, idx: number) => {
                RecommendCardItem({
                  college: college,
                  tierColor: SAFE_COLOR,
                  visible: this.isCardVisible(this.rushList.length + this.stableList.length + idx),
                  onTap: (c: RecommendCollege) => {
                    c.isSelected = !c.isSelected;
                  }
                })
              }, (c: RecommendCollege, idx: number) => `safe_${idx}`)
            }
          }
          .width('100%')
          .padding({ left: Spacing.LG, right: Spacing.LG, bottom: Spacing.XL })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .title('志愿推荐结果')
  }

  @Builder
  tierStat(label: string, count: number, color: string) {
    Column() {
      Text(`${count}`)
        .fontSize(FontSize.DISPLAY)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(`${label}院校`)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: Spacing.XS })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tierHeader(label: string, count: number, color: string) {
    Row() {
      // 左侧 3vp 宽色块竖线指示器
      Column()
        .width(3)
        .height(22)
        .borderRadius(1.5)
        .backgroundColor(color)

      Text(`${label}院校`)
        .fontSize(FontSize.HEADLINE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ left: Spacing.SM })
      Text(`${count}所`)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ left: Spacing.XS })
    }
    .width('100%')
    .padding({ left: Spacing.MD, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.SM })
    .margin({ top: Spacing.MD })
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.SM)
  }

  // 推荐院校卡片已提取为 RecommendCardItem 组件（液态玻璃 + 按压边框加深）
}
