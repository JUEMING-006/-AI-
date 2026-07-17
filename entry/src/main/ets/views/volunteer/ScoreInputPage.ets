import { AppColors, PROVINCE_LIST } from '../../common/Constants';
import { FontSize, Spacing, Radius } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { SubjectScore, ScoreInput } from '../../models/VolunteerModel';
import { volunteerService } from '../../services/VolunteerService';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NavHeader } from '../../components/NavHeader';

const MAX_SCORE: number = 150;
const MIN_SCORE: number = 0;

@ComponentV2
export struct ScoreInputPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local province: string = '广东';
  @Local subjects: SubjectScore[] = ScoreInputPage.createDefaultSubjects();
  @Local totalScore: number = 0;
  @Local isSubmitting: boolean = false;
  @Local selectedProvinceIndex: number = 7; // 广东在列表中索引
  @Local focusedSubjectIndex: number = -1;
  @Local isSubmitPressed: boolean = false;

  static createDefaultSubjects(): SubjectScore[] {
    const english: SubjectScore = new SubjectScore();
    english.subject = '英语';
    english.fullScore = MAX_SCORE;

    const math: SubjectScore = new SubjectScore();
    math.subject = '高数';
    math.fullScore = MAX_SCORE;

    const major: SubjectScore = new SubjectScore();
    major.subject = '专业课';
    major.fullScore = MAX_SCORE;

    return [english, math, major];
  }

  private calcTotal(): void {
    let total: number = 0;
    for (const s of this.subjects) {
      total += s.score;
    }
    this.totalScore = total;
  }

  private validateScore(value: string, index: number): void {
    const num: number = parseInt(value) || 0;
    const clamped: number = Math.max(MIN_SCORE, Math.min(MAX_SCORE, num));
    this.subjects[index].score = clamped;
    this.calcTotal();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '成绩录入' })

        Scroll() {
          Column() {
          // 省份选择
          Text('选择省份')
            .fontSize(FontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: Spacing.XL, bottom: Spacing.SM })
          Select(PROVINCE_LIST.map((p: string) => ({ value: p } as SelectOption)))
            .selected(this.selectedProvinceIndex)
            .value(this.province)
            .fontColor(AppColors.TEXT_PRIMARY)
            .font({ size: FontSize.BODY })
            .height(44)
            .backgroundColor(AppColors.CARD_COLOR)
            .borderRadius(Radius.SM)
            .onSelect((index: number, value: string) => {
              this.selectedProvinceIndex = index;
              this.province = value;
            })

          // 科目分数列表
          Text('科目成绩')
            .fontSize(FontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: Spacing.XL, bottom: Spacing.SM })

          // 科目输入卡片容器
          Column() {
            ForEach(this.subjects, (item: SubjectScore, index: number) => {
              this.subjectRow(item, index)
            }, (_item: SubjectScore, index: number) => `subject_${index}`)
          }
          .width('100%')
          .backgroundColor(AppColors.CARD_COLOR)
          .borderRadius(Radius.MD)
          .padding({ left: Spacing.MD, right: Spacing.MD })

          // 总分显示
          Column() {
            Text('总分')
              .fontSize(FontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
            Text(`${this.totalScore}`)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.PRIMARY_COLOR)
              .margin({ top: Spacing.XS })
          }
          .width('100%')
          .padding(Spacing.LG)
          .margin({ top: Spacing.XL })
          .backgroundColor(AppColors.CARD_COLOR)
          .borderRadius(Radius.MD)
          .alignItems(HorizontalAlign.Center)

          // 提交按钮
          Button(this.isSubmitting ? '匹配中...' : '确认提交')
            .width('100%')
            .height(48)
            .fontSize(FontSize.SUBTITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .linearGradient({ angle: 90, colors: [[AppColors.PRIMARY_COLOR, 0], [AppColors.PRIMARY_GRADIENT_END, 1]] })
            .borderRadius(Radius.LG)
            .margin({ top: Spacing.XXL })
            .enabled(!this.isSubmitting && this.totalScore > 0)
            .opacity(this.isSubmitting ? 0.6 : (this.isSubmitPressed ? AnimConfig.BUTTON_PRESS_OPACITY : 1.0))
            .scale({ x: this.isSubmitPressed ? AnimConfig.BUTTON_PRESS_SCALE : 1.0, y: this.isSubmitPressed ? AnimConfig.BUTTON_PRESS_SCALE : 1.0 })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.getUIContext()?.animateTo({ duration: AnimConfig.BUTTON_PRESS_DURATION, curve: AnimConfig.BUTTON_PRESS_CURVE }, () => {
                  this.isSubmitPressed = true;
                });
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.getUIContext()?.animateTo({ duration: AnimConfig.BUTTON_RELEASE_DURATION, curve: AnimConfig.BUTTON_RELEASE_CURVE }, () => {
                  this.isSubmitPressed = false;
                });
              }
            })
            .onClick(() => {
              this.handleSubmit();
            })
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, bottom: Spacing.XXL })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  subjectRow(item: SubjectScore, index: number) {
    Row() {
      Text(item.subject)
        .fontSize(FontSize.SUBTITLE - 1)
        .fontColor(AppColors.TEXT_PRIMARY)
        .width(80)
      TextInput({ text: item.score > 0 ? `${item.score}` : '', placeholder: '请输入分数' })
        .type(InputType.Number)
        .layoutWeight(1)
        .height(44)
        .fontSize(FontSize.SUBTITLE)
        .backgroundColor(AppColors.BACKGROUND_COLOR)
        .borderRadius(Radius.SM)
        .border({ width: { bottom: 2 }, color: this.focusedSubjectIndex === index ? AppColors.PRIMARY_COLOR : Color.Transparent })
        .onChange((value: string) => {
          this.validateScore(value, index);
        })
        .onFocus(() => {
          this.getUIContext()?.animateTo({ duration: AnimConfig.FOCUS_ANIM_DURATION }, () => {
            this.focusedSubjectIndex = index;
          });
        })
        .onBlur(() => {
          this.getUIContext()?.animateTo({ duration: AnimConfig.FOCUS_ANIM_DURATION }, () => {
            if (this.focusedSubjectIndex === index) {
              this.focusedSubjectIndex = -1;
            }
          });
        })
      Text(`/ ${item.fullScore}`)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_HINT)
        .margin({ left: Spacing.SM })
        .width(50)
    }
    .width('100%')
    .padding({ top: Spacing.SM, bottom: Spacing.SM })
    .alignItems(VerticalAlign.Center)
  }

  private async handleSubmit(): Promise<void> {
    this.isSubmitting = true;
    const input: ScoreInput = new ScoreInput();
    input.subjects = this.subjects;
    input.totalScore = this.totalScore;
    input.province = this.province;

    try {
      await volunteerService.matchVolunteer(input);
      this.pathStack.pop();
    } catch (err) {
      const errMsg: string = (err instanceof Error) ? err.message : String(err);
      hilog.error(0x0001, 'ScoreInput', 'Submit error: %{public}s', errMsg);
    } finally {
      this.isSubmitting = false;
    }
  }
}
