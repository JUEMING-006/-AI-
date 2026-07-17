import { AppColors, RouteNames, ButtonStyles } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { volunteerService } from '../../services/VolunteerService';
import { CommonCard } from '../../components/CommonCard';
import { NavHeader } from '../../components/NavHeader';

// 三梯度颜色
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

// 诊断维度
interface DiagnoseDimension {
  title: string;
  score: number;
  maxScore: number;
  status: string;
  description: string;
}

// 诊断建议
interface DiagnoseSuggestion {
  icon: Resource;
  text: string;
  priority: string;
  action: string;
}

@ComponentV2
export struct VolunteerDiagnosePage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local overallScore: number = 0;
  @Local displayScore: number = 0;
  @Local expandedDimension: number = -1;
  @Local confirmedSuggestions: boolean[] = [false, false, false];

  // 诊断维度数据
  private dimensions: DiagnoseDimension[] = [
    { title: '梯度合理性', score: 85, maxScore: 100, status: 'good', description: '冲稳保比例合理，梯度分布均匀' },
    { title: '分数匹配度', score: 72, maxScore: 100, status: 'warning', description: '部分志愿与分数匹配度较低' },
    { title: '志愿梯度', score: 90, maxScore: 100, status: 'good', description: '相邻志愿分差合理，梯度适中' },
    { title: '滑档风险', score: 60, maxScore: 100, status: 'danger', description: '保底院校较少，存在滑档风险' }
  ];

  // 诊断建议
  private suggestions: DiagnoseSuggestion[] = [
    { icon: $r('sys.symbol.xmark'), text: '第2志愿与第3志愿分差仅2分，建议拉开梯度', priority: 'high', action: '去调整' },
    { icon: $r('sys.symbol.plus'), text: '建议增加1所保底院校，降低滑档风险', priority: 'medium', action: '去添加' },
    { icon: $r('sys.symbol.checkmark'), text: '冲刺院校选择合理，保持当前配置', priority: 'low', action: '确认' }
  ];

  aboutToAppear(): void {
    this.overallScore = 78;
    this.animateScore();
  }

  private animateScore(): void {
    let current = 0;
    const timer = setInterval(() => {
      current += 1;
      if (current >= this.overallScore) {
        current = this.overallScore;
        clearInterval(timer);
      }
      this.displayScore = current;
    }, 20);
  }

  private confirmSuggestion(index: number): void {
    const updated: boolean[] = [...this.confirmedSuggestions];
    updated[index] = true;
    this.confirmedSuggestions = updated;
  }

  private onSuggestionAction(action: string, index: number): void {
    if (action === '去调整') {
      this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_FORM });
    } else if (action === '去添加') {
      this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_RESULT });
    } else {
      this.confirmSuggestion(index);
    }
  }

  private getDimensionDetail(dimension: DiagnoseDimension): string {
    if (dimension.title === '梯度合理性') {
      return '冲刺 2 所 · 稳妥 2 所 · 保底 2 所\n比例 1:1:1，梯度分布均匀';
    }
    if (dimension.title === '分数匹配度') {
      return '第1志愿：+15分（偏高）\n第2志愿：+5分（适中）\n第3志愿：-5分（偏低）';
    }
    if (dimension.title === '志愿梯度') {
      return '第1→2志愿分差：15分\n第2→3志愿分差：2分 ← 偏小\n第3→4志愿分差：10分';
    }
    return '保底院校：2 所\n最低分差：+10分\n滑档概率：约 5%';
  }

  private getGrade(score: number): string {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'E';
  }

  private getStatusColor(status: string): string {
    if (status === 'good') return AppColors.SUCCESS_COLOR;
    if (status === 'warning') return AppColors.WARNING_COLOR;
    return AppColors.ERROR_COLOR;
  }

  private getPriorityColor(priority: string): string {
    if (priority === 'high') return AppColors.ERROR_COLOR;
    if (priority === 'medium') return AppColors.WARNING_COLOR;
    return AppColors.SUCCESS_COLOR;
  }

  private getOverallStatus(): string {
    if (this.overallScore >= 80) return 'good';
    if (this.overallScore >= 60) return 'warning';
    return 'danger';
  }

  private getOverallComment(): string {
    if (this.overallScore >= 90) return '方案优秀，录取概率很高';
    if (this.overallScore >= 80) return '方案良好，建议微调';
    if (this.overallScore >= 70) return '方案一般，存在风险';
    if (this.overallScore >= 60) return '方案较差，建议重新规划';
    return '方案风险较大，请重新评估';
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '志愿诊断' })

        Scroll() {
          Column() {
          // 综合评分卡片
          this.scoreCard()

          // 维度分析
          this.dimensionAnalysis()

          // 具体建议
          this.suggestionsList()

          // 底部按钮
          Button('返回调整志愿')
            .width('100%')
            .height(50)
            .fontSize(FontSize.SUBTITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
            })
            .borderRadius(Radius.BUTTON)
            .margin({ left: Spacing.LG, right: Spacing.LG, top: Spacing.XL, bottom: Spacing.XL })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_FORM });
            })
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(AppColors.BACKGROUND_COLOR)
  }

  @Builder
  scoreCard() {
    Column() {
      CommonCard() {
        Column() {
          Stack() {
            Progress({ value: this.displayScore, total: 100, type: ProgressType.Ring })
              .width(140)
              .height(140)
              .color(this.getStatusColor(this.getOverallStatus()))
              .backgroundColor('#F5F5F7')
              .style({ strokeWidth: 12 })

            Column() {
              Text(`${this.displayScore}`)
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT_PRIMARY)

              Text('分')
                .fontSize(FontSize.BODY)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
          }

          Text(this.getGrade(this.overallScore))
            .fontSize(FontSize.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor(this.getStatusColor(this.getOverallStatus()))
            .borderRadius(12)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .margin({ top: Spacing.MD })

          Text(this.getOverallComment())
            .fontSize(FontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: Spacing.SM })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding(Spacing.XL)
      }
    }
    .margin({ bottom: Spacing.LG })
  }

  @Builder
  dimensionAnalysis() {
    Column() {
      Text('维度分析')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: Spacing.MD })

      ForEach(this.dimensions, (dimension: DiagnoseDimension, index: number) => {
        this.dimensionCard(dimension, index)
      }, (dimension: DiagnoseDimension) => dimension.title)
    }
    .width('100%')
    .margin({ bottom: Spacing.LG })
  }

  @Builder
  dimensionCard(dimension: DiagnoseDimension, index: number) {
    Column() {
      Row() {
        Column() {
          Text(dimension.title)
            .fontSize(FontSize.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)

          Text(dimension.description)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: Spacing.XS })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Stack() {
          Progress({ value: dimension.score, total: dimension.maxScore, type: ProgressType.Ring })
            .width(48)
            .height(48)
            .color(this.getStatusColor(dimension.status))
            .backgroundColor('#F5F5F7')
            .style({ strokeWidth: 4 })

          Text(`${dimension.score}`)
            .fontSize(FontSize.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getStatusColor(dimension.status))
        }

        if (this.expandedDimension === index) {
          Text('▲')
            .fontSize(14)
            .fontColor(AppColors.TEXT_HINT)
            .margin({ left: Spacing.SM })
        } else {
          Text('▼')
            .fontSize(14)
            .fontColor(AppColors.TEXT_HINT)
            .margin({ left: Spacing.SM })
        }
      }
      .width('100%')
      .onClick(() => {
        this.expandedDimension = this.expandedDimension === index ? -1 : index;
      })

      Row() {
        Row()
          .width(`${dimension.score}%`)
          .height(6)
          .backgroundColor(this.getStatusColor(dimension.status))
          .borderRadius(3)

        Row()
          .width(`${100 - dimension.score}%`)
          .height(6)
          .backgroundColor(AppColors.DIVIDER_COLOR)
          .borderRadius(3)
      }
      .width('100%')
      .margin({ top: Spacing.SM })

      // 展开区域
      if (this.expandedDimension === index) {
        Column() {
          Text('详细分析')
            .fontSize(FontSize.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ bottom: Spacing.XS })

          Text(this.getDimensionDetail(dimension))
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_PRIMARY)
            .lineHeight(22)
        }
        .width('100%')
        .padding(Spacing.MD)
        .margin({ top: Spacing.SM })
        .backgroundColor(AppColors.BACKGROUND_COLOR)
        .borderRadius(Radius.SM)
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 10 })))
      }
    }
    .width('100%')
    .padding(Spacing.MD)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .margin({ top: Spacing.SM })
    .shadow(Shadows.CARD)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
  }

  @Builder
  suggestionsList() {
    Column() {
      Text('优化建议')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: Spacing.MD })

      ForEach(this.suggestions, (suggestion: DiagnoseSuggestion, index: number) => {
        this.suggestionItem(suggestion, index)
      }, (suggestion: DiagnoseSuggestion) => suggestion.text)
    }
    .width('100%')
  }

  @Builder
  suggestionItem(suggestion: DiagnoseSuggestion, index: number) {
    Row() {
      SymbolGlyph(suggestion.icon)
        .fontSize(20)
        .fontColor([
          this.confirmedSuggestions[index]
            ? AppColors.TEXT_HINT
            : this.getPriorityColor(suggestion.priority)
        ])

      Column() {
        Text(suggestion.text)
          .fontSize(FontSize.BODY)
          .fontColor(
            this.confirmedSuggestions[index]
              ? AppColors.TEXT_SECONDARY
              : AppColors.TEXT_PRIMARY
          )
      }
      .layoutWeight(1)
      .margin({ left: Spacing.SM })

      Button(
        this.confirmedSuggestions[index] && suggestion.action === '确认'
          ? '已确认'
          : suggestion.action
      )
        .height(32)
        .fontSize(FontSize.CAPTION)
        .fontColor(
          this.confirmedSuggestions[index] && suggestion.action === '确认'
            ? AppColors.TEXT_HINT
            : this.getPriorityColor(suggestion.priority)
        )
        .backgroundColor(Color.Transparent)
        .border({
          width: 1,
          color: this.confirmedSuggestions[index] && suggestion.action === '确认'
            ? AppColors.DIVIDER_COLOR
            : this.getPriorityColor(suggestion.priority)
        })
        .borderRadius(Radius.BUTTON)
        .enabled(!this.confirmedSuggestions[index])
        .onClick(() => {
          this.onSuggestionAction(suggestion.action, index);
        })
    }
    .width('100%')
    .padding(Spacing.MD)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .margin({ top: Spacing.SM })
    .shadow(Shadows.CARD)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
  }
}
