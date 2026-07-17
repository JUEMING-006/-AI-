import { AppColors, RouteNames, ButtonStyles } from '../../common/Constants';
import { FontSize, FontWeightTokens, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { Duration, getStaggerDelay, AnimConfig } from '../../common/AnimationHelper';
import { StudyPhase, GapAnalysis } from '../../models/StudyPlanModel';
import { studyService } from '../../services/StudyService';
import { CommonCard } from '../../components/CommonCard';
import { LoadingView } from '../../components/LoadingView';

const RING_SIZE: number = 64;
const RING_STROKE: number = 7;
const PHASE_COLORS: string[] = [AppColors.PRIMARY_COLOR, AppColors.SUCCESS_COLOR, AppColors.ACCENT_COLOR];

@ComponentV2
export struct StudyPlanPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local phases: StudyPhase[] = [];
  @Local gapAnalysis: GapAnalysis = new GapAnalysis();
  @Local isLoading: boolean = true;
  @Local animatedProgress: number[] = [0, 0, 0];
  @Local gapCardScale: number = 1.0;
  @Local gapCardOpacity: number = 1.0;
  @Local btn1Scale: number = 1.0;
  @Local btn1Opacity: number = 1.0;
  @Local btn2Scale: number = 1.0;
  @Local btn2Opacity: number = 1.0;

  async aboutToAppear(): Promise<void> {
    await this.loadData();
    this.animatePhaseProgress();
  }

  animatePhaseProgress(): void {
    this.phases.forEach((phase: StudyPhase, index: number) => {
      setTimeout(() => {
        this.getUIContext()?.animateTo({ duration: Duration.SLOW, curve: Curve.EaseOut }, () => {
          const newArr: number[] = [...this.animatedProgress];
          newArr[index] = phase.progress;
          this.animatedProgress = newArr;
        });
      }, getStaggerDelay(index));
    });
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      this.phases = await studyService.generatePlan('');
      this.gapAnalysis = await studyService.getGapAnalysis();
    } catch (e) {
      // 错误静默处理，保留默认值
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 状态栏安全区避让
      Blank().height(AppStorage.get<number>('safeAreaTop') ?? 0)

      if (this.isLoading) {
        LoadingView({ message: '正在生成学习规划...' })
      } else {
        Scroll() {
          Column() {
            this.gapCard()
            this.phaseSection()
            this.actionButtons()
          }
          .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.XL, bottom: Spacing.XL })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND_COLOR)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  gapCard() {
    Column() {
      Text(this.gapAnalysis.targetCollegeName)
        .fontSize(FontSize.SUBTITLE + 2)
        .fontWeight(FontWeightTokens.BOLD)
        .fontColor(AppColors.TEXT_PRIMARY)

      Row() {
        this.gapStatItem('目标分数', `${this.gapAnalysis.targetScore}`)
        this.gapStatItem('预估分数', `${this.gapAnalysis.currentEstimate}`)
        this.gapStatItem('差距', `-${this.gapAnalysis.gap}`)
        this.gapStatItem('剩余天数', `${this.gapAnalysis.daysRemaining}`)
      }
      .width('100%')
      .margin({ top: Spacing.LG })
    }
    .width('100%')
    .padding(Spacing.LG)
    .margin({ top: Spacing.MD })
    .borderRadius(Radius.CARD_LG)
    .backgroundColor(AppColors.GLASS_LIGHT)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
    .shadow(Shadows.GLASS)
    .scale({ x: this.gapCardScale, y: this.gapCardScale })
    .opacity(this.gapCardOpacity)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_PRESS_DURATION,
          curve: AnimConfig.LIQUID_PRESS_CURVE,
        }, () => {
          this.gapCardScale = AnimConfig.PRESS_SCALE;
          this.gapCardOpacity = AnimConfig.PRESS_OPACITY;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_RELEASE_DURATION,
          curve: AnimConfig.LIQUID_RELEASE_CURVE,
        }, () => {
          this.gapCardScale = 1.0;
          this.gapCardOpacity = 1.0;
        });
      }
    })
  }

  @Builder
  gapStatItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
      Text(value)
        .fontSize(FontSize.TITLE)
        .fontWeight(FontWeight.Lighter)
        .fontColor(AppColors.PRIMARY_COLOR)
        .margin({ top: Spacing.XS })
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  phaseSection() {
    CommonCard({ marginTop: Spacing.MD, radius: Radius.CARD_SM }) {
      Column() {
        Text('学习阶段进度')
          .fontSize(FontSize.SUBTITLE)
          .fontWeight(FontWeightTokens.MEDIUM)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ bottom: Spacing.LG })

        ForEach(this.phases, (phase: StudyPhase, index: number) => {
          this.phaseItem(phase, index)
        })
      }
    }
  }

  @Builder
  phaseItem(phase: StudyPhase, index: number) {
    Row() {
      Stack() {
        Progress({
          value: this.animatedProgress.length > index ? this.animatedProgress[index] : 0,
          total: 100,
          type: ProgressType.Ring
        })
          .width(RING_SIZE)
          .height(RING_SIZE)
          .style({ strokeWidth: RING_STROKE })
          .color(PHASE_COLORS[index % PHASE_COLORS.length])
          .backgroundColor('#E8EAF6')

        Text(`${phase.progress}%`)
          .fontSize(FontSize.CAPTION)
          .fontWeight(FontWeightTokens.BOLD)
          .fontColor(PHASE_COLORS[index % PHASE_COLORS.length])
      }

      Column() {
        Text(phase.name)
          .fontSize(FontSize.HEADLINE)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeightTokens.MEDIUM)

        Text(`${phase.startDate} ~ ${phase.endDate}`)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_HINT)
          .margin({ top: 2 })

        Text(phase.description)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: Spacing.XS })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: Spacing.MD })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .margin({ bottom: Spacing.LG })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  actionButtons() {
    Row() {
      Button('今日任务')
        .fontSize(FontSize.BODY + 1)
        .fontColor(ButtonStyles.PRIMARY_BTN_TEXT)
        .height(44)
        .layoutWeight(1)
        .borderRadius(Radius.BUTTON)
        .backgroundColor(ButtonStyles.PRIMARY_BTN_BG)
        .scale({ x: this.btn1Scale, y: this.btn1Scale })
        .opacity(this.btn1Opacity)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_PRESS_DURATION,
              curve: AnimConfig.BUTTON_PRESS_CURVE,
            }, () => {
              this.btn1Scale = AnimConfig.BUTTON_PRESS_SCALE;
              this.btn1Opacity = AnimConfig.BUTTON_PRESS_OPACITY;
            });
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_RELEASE_DURATION,
              curve: AnimConfig.BUTTON_RELEASE_CURVE,
            }, () => {
              this.btn1Scale = 1.0;
              this.btn1Opacity = 1.0;
            });
          }
        })
        .onClick(() => {
          this.pathStack.pushPath({ name: RouteNames.DAILY_TASK });
        })

      Button('学习进度')
        .fontSize(FontSize.BODY + 1)
        .fontColor(ButtonStyles.SECONDARY_BTN_TEXT)
        .backgroundColor(ButtonStyles.SECONDARY_BTN_BG)
        .height(44)
        .layoutWeight(1)
        .borderRadius(Radius.BUTTON)
        .border({ width: 1, color: ButtonStyles.SECONDARY_BTN_BORDER })
        .margin({ left: Spacing.MD })
        .scale({ x: this.btn2Scale, y: this.btn2Scale })
        .opacity(this.btn2Opacity)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_PRESS_DURATION,
              curve: AnimConfig.BUTTON_PRESS_CURVE,
            }, () => {
              this.btn2Scale = AnimConfig.BUTTON_PRESS_SCALE;
              this.btn2Opacity = AnimConfig.BUTTON_PRESS_OPACITY;
            });
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_RELEASE_DURATION,
              curve: AnimConfig.BUTTON_RELEASE_CURVE,
            }, () => {
              this.btn2Scale = 1.0;
              this.btn2Opacity = 1.0;
            });
          }
        })
        .onClick(() => {
          this.pathStack.pushPath({ name: RouteNames.PROGRESS });
        })
    }
    .width('100%')
    .margin({ top: Spacing.LG })
  }
}
