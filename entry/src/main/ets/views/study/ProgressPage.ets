import { AppColors } from '../../common/Constants';
import { FontSize, FontWeightTokens, Spacing, Radius } from '../../common/DesignTokens';
import { Duration, getStaggerDelay } from '../../common/AnimationHelper';
import { StudyProgress } from '../../models/StudyPlanModel';
import { studyService } from '../../services/StudyService';
import { CommonCard } from '../../components/CommonCard';
import { LoadingView } from '../../components/LoadingView';
import { NavHeader } from '../../components/NavHeader';

const BAR_MAX_HEIGHT: number = 120;

@ComponentV2
export struct ProgressPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local progress: StudyProgress = new StudyProgress();
  @Local isLoading: boolean = true;
  @Local barHeights: number[] = [];

  async aboutToAppear(): Promise<void> {
    await this.loadProgress();
  }

  async loadProgress(): Promise<void> {
    this.isLoading = true;
    try {
      this.progress = await studyService.getProgress();
      // 初始化为0
      this.barHeights = this.progress.weeklyCompletionRates.map((): number => 4);
      // 逐个延迟生长动画
      this.progress.weeklyCompletionRates.forEach((rate: number, index: number) => {
        setTimeout(() => {
          this.getUIContext()?.animateTo({ duration: Duration.SLOW, curve: Curve.EaseOut }, () => {
            const newHeights: number[] = [...this.barHeights];
            newHeights[index] = this.targetBarHeight(rate);
            this.barHeights = newHeights;
          });
        }, getStaggerDelay(index) + Duration.NORMAL);
      });
    } catch (e) {
      // 静默处理
    } finally {
      this.isLoading = false;
    }
  }

  targetBarHeight(rate: number): number {
    if (rate <= 0) {
      return 4;
    }
    return Math.round((rate / 100) * BAR_MAX_HEIGHT);
  }

  get completionRate(): number {
    if (this.progress.totalTasks === 0) {
      return 0;
    }
    return Math.round((this.progress.completedTasks / this.progress.totalTasks) * 100);
  }

  isCurrentDay(index: number): boolean {
    const today: number = new Date().getDay();
    // getDay: 0=Sunday, weekDates likely Mon-Sun; adjust: if today is 0 treat as 6
    const adjustedToday: number = today === 0 ? 6 : today - 1;
    return index === adjustedToday;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '学习进度' })

        if (this.isLoading) {
          LoadingView({ message: '正在加载学习进度...' })
        } else {
          Scroll() {
            Column() {
              this.summaryHeader()
              this.chartSection()
              this.statsCard()
            }
            .padding({ left: Spacing.LG, right: Spacing.LG, bottom: Spacing.XL })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.BACKGROUND_COLOR)
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  summaryHeader() {
    CommonCard({ marginTop: Spacing.MD }) {
      Row() {
        Column() {
          Text('连续学习')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_HINT)
          Text(`${this.progress.currentStreak} 天`)
            .fontSize(FontSize.DISPLAY)
            .fontWeight(FontWeight.Lighter)
            .fontColor(AppColors.PRIMARY_COLOR)
            .margin({ top: Spacing.XS })
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)

        Column()
          .width(1)
          .height(50)
          .backgroundColor(AppColors.DIVIDER_COLOR)

        Column() {
          Text('总完成率')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_HINT)
          Text(`${this.completionRate}%`)
            .fontSize(FontSize.DISPLAY)
            .fontWeight(FontWeight.Lighter)
            .fontColor(AppColors.PRIMARY_COLOR)
            .margin({ top: Spacing.XS })
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }
      .width('100%')
    }
  }

  @Builder
  chartSection() {
    CommonCard({ marginTop: Spacing.MD }) {
      Column() {
        Text('本周任务完成率趋势')
          .fontSize(FontSize.BODY + 1)
          .fontWeight(FontWeightTokens.MEDIUM)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ bottom: Spacing.LG })
          .alignSelf(ItemAlign.Start)

        Row() {
          ForEach(this.progress.weeklyCompletionRates, (rate: number, index: number) => {
            Column() {
              Text(`${rate}%`)
                .fontSize(10)
                .fontColor(this.isCurrentDay(index) ? '#0056CC' : AppColors.TEXT_HINT)
                .fontWeight(this.isCurrentDay(index) ? FontWeightTokens.MEDIUM : FontWeightTokens.NORMAL)

              Column()
                .width(24)
                .height(this.barHeights.length > index ? this.barHeights[index] : 4)
                .borderRadius(Radius.XS)
                .backgroundColor(this.isCurrentDay(index) ? '#0056CC' : AppColors.PRIMARY_COLOR)
                .margin({ top: 6, bottom: 6 })

              Text(this.progress.weekDates[index])
                .fontSize(10)
                .fontColor(this.isCurrentDay(index) ? '#0056CC' : AppColors.TEXT_HINT)
                .fontWeight(this.isCurrentDay(index) ? FontWeightTokens.MEDIUM : FontWeightTokens.NORMAL)
            }
            .alignItems(HorizontalAlign.Center)
          })
        }
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        .height(180)
        .alignItems(VerticalAlign.Bottom)
      }
    }
  }

  @Builder
  statsCard() {
    CommonCard({ marginTop: Spacing.MD }) {
      Column() {
        Text('本周统计')
          .fontSize(FontSize.BODY + 1)
          .fontWeight(FontWeightTokens.MEDIUM)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ bottom: Spacing.MD })
          .alignSelf(ItemAlign.Start)

        Row() {
          this.statItem('总任务数', `${this.progress.totalTasks}`, AppColors.TEXT_PRIMARY)
          this.statItem('已完成', `${this.progress.completedTasks}`, AppColors.SUCCESS_COLOR)
          this.statItem('完成率', `${this.completionRate}%`, AppColors.PRIMARY_COLOR)
        }
        .width('100%')
      }
    }
  }

  @Builder
  statItem(label: string, value: string, valueColor: ResourceColor) {
    Column() {
      Text(label)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_HINT)
      Text(value)
        .fontSize(FontSize.TITLE)
        .fontWeight(FontWeight.Lighter)
        .fontColor(valueColor)
        .margin({ top: Spacing.XS })
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }
}
