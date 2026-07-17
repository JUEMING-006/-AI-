import { AppColors } from '../../common/Constants';
import { FontSize, FontWeightTokens, Spacing, Radius } from '../../common/DesignTokens';
import { Duration, getStaggerDelay } from '../../common/AnimationHelper';
import { DailyTask } from '../../models/StudyPlanModel';
import { studyService } from '../../services/StudyService';
import { CommonCard } from '../../components/CommonCard';
import { LoadingView } from '../../components/LoadingView';
import { NavHeader } from '../../components/NavHeader';

@ComponentV2
export struct DailyTaskPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local tasks: DailyTask[] = [];
  @Local isLoading: boolean = true;
  @Local todayDate: string = '';
  @Local taskScales: number[] = [];
  @Local animatedPercent: number = 0;
  @Local taskVisible: boolean[] = [];

  async aboutToAppear(): Promise<void> {
    const now: Date = new Date();
    const month: string = (now.getMonth() + 1).toString().padStart(2, '0');
    const day: string = now.getDate().toString().padStart(2, '0');
    this.todayDate = `${now.getFullYear()}-${month}-${day}`;
    await this.loadTasks();
  }

  async loadTasks(): Promise<void> {
    this.isLoading = true;
    try {
      this.tasks = await studyService.getDailyTasks(this.todayDate);
      this.taskScales = this.tasks.map((): number => 1.0);
      this.taskVisible = this.tasks.map((): boolean => false);
      // 逐个任务入场动画
      this.tasks.forEach((_t: DailyTask, index: number) => {
        setTimeout(() => {
          const newArr: boolean[] = [...this.taskVisible];
          newArr[index] = true;
          this.taskVisible = newArr;
        }, getStaggerDelay(index));
      });
      // 进度条动画
      setTimeout(() => {
        this.getUIContext()?.animateTo({ duration: Duration.SLOW, curve: Curve.EaseOut }, () => {
          this.animatedPercent = this.completionPercent;
        });
      }, Duration.NORMAL);
    } catch (e) {
      // 静默处理
    } finally {
      this.isLoading = false;
    }
  }

  get completedCount(): number {
    let count: number = 0;
    for (const task of this.tasks) {
      if (task.isCompleted) {
        count++;
      }
    }
    return count;
  }

  get remainingMinutes(): number {
    let minutes: number = 0;
    for (const task of this.tasks) {
      if (!task.isCompleted) {
        minutes += task.estimatedMinutes;
      }
    }
    return minutes;
  }

  get completionPercent(): number {
    if (this.tasks.length === 0) {
      return 0;
    }
    return Math.round((this.completedCount / this.tasks.length) * 100);
  }

  onTaskComplete(_task: DailyTask, index: number): void {
    // 弹跳动画
    const scales: number[] = [...this.taskScales];
    scales[index] = 1.05;
    this.taskScales = scales;
    setTimeout(() => {
      const resetScales: number[] = [...this.taskScales];
      resetScales[index] = 1.0;
      this.taskScales = resetScales;
    }, Duration.FAST);
    // 进度条平滑更新
    setTimeout(() => {
      this.getUIContext()?.animateTo({ duration: Duration.NORMAL, curve: Curve.EaseOut }, () => {
        this.animatedPercent = this.completionPercent;
      });
    }, 0);
  }

  async handleToggle(task: DailyTask, index: number): Promise<void> {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      const now: Date = new Date();
      const h: string = now.getHours().toString().padStart(2, '0');
      const m: string = now.getMinutes().toString().padStart(2, '0');
      task.completedAt = `${this.todayDate} ${h}:${m}`;
    } else {
      task.completedAt = '';
    }
    this.onTaskComplete(task, index);
    try {
      await studyService.completeTask(task.id);
    } catch (e) {
      // 回滚
      task.isCompleted = !task.isCompleted;
      this.onTaskComplete(task, index);
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: `今日任务 · ${this.todayDate}` })

        if (this.isLoading) {
          LoadingView({ message: '正在加载今日任务...' })
        } else {
          this.contentSection()
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
  contentSection() {
    Column() {
      this.progressHeader()
      Scroll() {
        Column() {
          ForEach(this.tasks, (task: DailyTask, index: number) => {
            Column() {
              if (this.taskVisible.length > index && this.taskVisible[index]) {
                this.taskItem(task, index)
              }
            }
            .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 20 })))
          })
        }
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM })
      }
      .layoutWeight(1)
      this.bottomStats()
    }
  }

  @Builder
  progressHeader() {
    CommonCard({ marginTop: Spacing.MD }) {
      Column() {
        Row() {
          Text('今日完成进度')
            .fontSize(FontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
          Blank()
          Text(`${this.completedCount}/${this.tasks.length}`)
            .fontSize(FontSize.TITLE)
            .fontWeight(FontWeight.Lighter)
            .fontColor(AppColors.PRIMARY_COLOR)
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          // 底层轨道
          Column()
            .width('100%')
            .height(10)
            .borderRadius(Radius.FULL)
            .backgroundColor('#E8EAF6')

          // 渐变进度
          Column()
            .width(`${this.animatedPercent}%`)
            .height(10)
            .borderRadius(Radius.FULL)
            .backgroundColor(AppColors.PRIMARY_COLOR)
        }
        .width('100%')
        .margin({ top: 10 })
      }
    }
  }

  @Builder
  taskItem(task: DailyTask, index: number) {
    Column() {
      CommonCard({ marginTop: Spacing.SM, cardPadding: Spacing.MD }) {
        Row() {
          Checkbox()
            .select(task.isCompleted)
            .selectedColor(AppColors.PRIMARY_COLOR)
            .width(22)
            .height(22)
            .onChange((_checked: boolean) => {
              this.handleToggle(task, index);
            })

          Column() {
            Text(task.title)
              .fontSize(FontSize.BODY)
              .fontWeight(FontWeightTokens.MEDIUM)
              .fontColor(task.isCompleted ? AppColors.TEXT_HINT : AppColors.TEXT_PRIMARY)
              .decoration({
                type: task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None,
                color: task.isCompleted ? AppColors.TEXT_HINT : AppColors.TEXT_PRIMARY
              })
            Row() {
              Text(task.subject)
                .fontSize(FontSize.CAPTION)
                .fontColor(Color.White)
                .backgroundColor(AppColors.PRIMARY_COLOR)
                .borderRadius(Radius.XS)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              Text(`${task.estimatedMinutes} 分钟`)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_HINT)
                .margin({ left: Spacing.SM })
            }
            .margin({ top: 6 })
          }
          .layoutWeight(1)
          .margin({ left: 10 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
    }
    .width('100%')
    .scale({
      x: this.taskScales.length > index ? this.taskScales[index] : 1.0,
      y: this.taskScales.length > index ? this.taskScales[index] : 1.0
    })
  }

  @Builder
  bottomStats() {
    Row() {
      Text(`已完成 ${this.completedCount}/${this.tasks.length} 项`)
        .fontSize(FontSize.CAPTION + 1)
        .fontColor(AppColors.TEXT_SECONDARY)
      Blank()
      Text(`预计还需 ${this.remainingMinutes} 分钟`)
        .fontSize(FontSize.CAPTION + 1)
        .fontColor(AppColors.WARNING_COLOR)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: Spacing.MD, bottom: Spacing.MD })
    .backgroundColor(AppColors.CARD_COLOR)
  }
}
