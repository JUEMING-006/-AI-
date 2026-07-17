import { AppColors, RouteNames, MajorNavParam } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { CommonCard } from '../../components/CommonCard';
import { CollegeVolunteerDetail, MajorBrief, ScoreHistoryItem } from '../../models/VolunteerModel';
import { volunteerService } from '../../services/VolunteerService';
import { NavHeader } from '../../components/NavHeader';

// 三梯度颜色
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

@ComponentV2
export struct CollegeVolunteerPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local collegeName: string = '深圳技术大学';
  @Local detail: CollegeVolunteerDetail = new CollegeVolunteerDetail();
  @Local btnScale: number = 1.0;
  @Local btnOpacity: number = 1.0;

  // 硬编码院校详情数据
  private getCollegeDetail(name: string): CollegeVolunteerDetail {
    const detail = new CollegeVolunteerDetail();
    detail.name = name;
    detail.type = '公办';
    detail.city = '深圳';
    detail.description = '广东省属公办本科院校，以应用型人才培养为特色';
    detail.lastYearScore = 320;
    detail.enrollCount = 120;
    detail.tuition = 5500;
    detail.ratio = '3:1';
    const m1 = new MajorBrief();
    m1.name = '计算机科学与技术'; m1.enrollCount = 60; m1.lastYearScore = 320;
    const m2 = new MajorBrief();
    m2.name = '软件工程'; m2.enrollCount = 40; m2.lastYearScore = 315;
    const m3 = new MajorBrief();
    m3.name = '数据科学与大数据技术'; m3.enrollCount = 20; m3.lastYearScore = 318;
    detail.majors = [m1, m2, m3];
    const s1 = new ScoreHistoryItem();
    s1.year = 2022; s1.score = 308;
    const s2 = new ScoreHistoryItem();
    s2.year = 2023; s2.score = 315;
    const s3 = new ScoreHistoryItem();
    s3.year = 2024; s3.score = 320;
    detail.scoreHistory = [s1, s2, s3];
    detail.probability = 65;
    detail.tier = '冲刺';
    return detail;
  }

  aboutToAppear(): void {
    this.detail = this.getCollegeDetail(this.collegeName);
  }

  private getTierColor(tier: string): string {
    if (tier === '冲刺') return RUSH_COLOR;
    if (tier === '稳妥') return STABLE_COLOR;
    return SAFE_COLOR;
  }

  private getScoreDiff(): number {
    if (!volunteerService.hasScore) return 0;
    return volunteerService.currentScore.totalScore - this.detail.lastYearScore;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '院校详情' })

        Scroll() {
          Column() {
            // 院校头部渐变卡片
            this.headerCard()

            // 核心数据四格
            this.dataGrid()

            // 招生专业列表
            this.majorListCard()

            // 历年分数线
            this.scoreHistoryCard()

            // 录取概率（仅已录入成绩显示）
            if (volunteerService.hasScore) {
              this.probabilityCard()
            }
          }
          .width('100%')
          .padding({ left: Spacing.LG, right: Spacing.LG, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        // 底部固定按钮
        this.bottomButton()
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(AppColors.BACKGROUND_COLOR)
    .onReady((context: NavDestinationContext) => {
      const param: Record<string, Object> | undefined = context.pathInfo.param as Record<string, Object> | undefined;
      if (param !== null && param !== undefined) {
        const name: string = param['collegeName'] as string;
        if (name !== '') {
          this.collegeName = name;
          this.detail = this.getCollegeDetail(name);
        }
      }
    })
  }

  // 院校头部渐变卡片
  @Builder
  headerCard() {
    Column() {
      Column() {
        Text(this.detail.name)
          .fontSize(FontSize.DISPLAY)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Row({ space: Spacing.SM }) {
          Text(this.detail.type)
            .fontSize(FontSize.CAPTION)
            .fontColor(Color.White)
            .backgroundColor('#30FFFFFF')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })

          Text(this.detail.city)
            .fontSize(FontSize.CAPTION)
            .fontColor(Color.White)
            .backgroundColor('#30FFFFFF')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
        .margin({ top: Spacing.SM })

        Text(this.detail.description)
          .fontSize(FontSize.CAPTION)
          .fontColor('#B0FFFFFF')
          .margin({ top: Spacing.SM })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding(Spacing.XL)
    }
    .width('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
    })
    .borderRadius(Radius.LG)
    .margin({ top: Spacing.MD, bottom: Spacing.MD })
  }

  // 核心数据四格（2x2）
  @Builder
  dataGrid() {
    Grid() {
      GridItem() {
        this.dataCell('去年最低分', `${this.detail.lastYearScore}`, AppColors.PRIMARY_COLOR)
      }
      GridItem() {
        this.dataCell('招生人数', `${this.detail.enrollCount}`, AppColors.SUCCESS_COLOR)
      }
      GridItem() {
        this.dataCell('学费/年', `${this.detail.tuition}`, AppColors.ACCENT_COLOR)
      }
      GridItem() {
        this.dataCell('报录比', this.detail.ratio, RUSH_COLOR)
      }
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(Spacing.MD)
    .rowsGap(Spacing.MD)
    .width('100%')
    .height(160)
    .margin({ bottom: Spacing.MD })
  }

  @Builder
  dataCell(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(FontSize.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: Spacing.XS })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
  }

  // 招生专业列表
  @Builder
  majorListCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.doc'))
            .fontSize(20)
            .fontColor([AppColors.PRIMARY_COLOR])

          Text('专升本招生专业')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        ForEach(this.detail.majors, (major: MajorBrief, idx: number) => {
          Row() {
            Column() {
              Text(major.name)
                .fontSize(FontSize.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppColors.TEXT_PRIMARY)

              Row({ space: Spacing.MD }) {
                Text(`计划${major.enrollCount}人`)
                  .fontSize(FontSize.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)

                Text(`去年${major.lastYearScore}分`)
                  .fontSize(FontSize.CAPTION)
                  .fontColor(AppColors.TEXT_HINT)
              }
              .margin({ top: Spacing.XS })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            SymbolGlyph($r('sys.symbol.arrow_right'))
              .fontSize(16)
              .fontColor([AppColors.TEXT_HINT])
          }
          .width('100%')
          .padding({ top: Spacing.MD, bottom: Spacing.MD })
          .border({ width: 0.5, color: AppColors.DIVIDER_COLOR })
          .onClick(() => {
            const param: MajorNavParam = { majorName: major.name };
            this.pathStack.pushPath({ name: RouteNames.MAJOR_DETAIL, param: param });
          })
        }, (major: MajorBrief) => major.name)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 历年分数线
  @Builder
  scoreHistoryCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.calendar'))
            .fontSize(20)
            .fontColor([AppColors.ACCENT_COLOR])

          Text('近三年分数线')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        Row() {
          ForEach(this.detail.scoreHistory, (item: ScoreHistoryItem, idx: number) => {
            Column() {
              Text(`${item.year}`)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)

              Text(`${item.score}`)
                .fontSize(FontSize.HEADLINE)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT_PRIMARY)
                .margin({ top: Spacing.XS })

              // 趋势箭头
              if (idx > 0) {
                Row() {
                  if (item.score > this.detail.scoreHistory[idx - 1].score) {
                    Text('↑')
                      .fontSize(12)
                      .fontColor(AppColors.ERROR_COLOR)
                  } else {
                    Text('↓')
                      .fontSize(12)
                      .fontColor(AppColors.SUCCESS_COLOR)
                  }
                }
                .margin({ top: Spacing.XS })
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (item: ScoreHistoryItem) => `${item.year}`)
        }
        .width('100%')
        .margin({ top: Spacing.MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 录取概率卡片
  @Builder
  probabilityCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.clock'))
            .fontSize(20)
            .fontColor([this.getTierColor(this.detail.tier)])

          Text('录取概率')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        Row() {
          // 环形进度图
          Stack() {
            Progress({ value: this.detail.probability, total: 100, type: ProgressType.Ring })
              .width(100)
              .height(100)
              .color(this.getTierColor(this.detail.tier))
              .backgroundColor('#F5F5F7')
              .style({ strokeWidth: 8 })

            Column() {
              Text(`${this.detail.probability}%`)
                .fontSize(FontSize.HEADLINE)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getTierColor(this.detail.tier))

              Text(this.detail.tier)
                .fontSize(FontSize.CAPTION)
                .fontColor(this.getTierColor(this.detail.tier))
            }
          }

          // 分数对比
          Column() {
            Text('我的分数')
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)

            Text(`${volunteerService.currentScore.totalScore}`)
              .fontSize(FontSize.TITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY)
              .margin({ top: Spacing.XS })

            Text(`去年最低分 ${this.detail.lastYearScore}`)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ top: Spacing.SM })

            Row() {
              Text(`${this.getScoreDiff() >= 0 ? '+' : ''}${this.getScoreDiff()}`)
                .fontSize(FontSize.HEADLINE)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getScoreDiff() >= 0 ? AppColors.SUCCESS_COLOR : AppColors.ERROR_COLOR)

              Text('分')
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .margin({ top: Spacing.SM })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .margin({ top: Spacing.MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 底部固定按钮
  @Builder
  bottomButton() {
    Row() {
      Button('加入志愿表')
        .width('100%')
        .height(50)
        .fontSize(FontSize.HEADLINE)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
        })
        .borderRadius(Radius.BUTTON)
        .scale({ x: this.btnScale, y: this.btnScale })
        .opacity(this.btnOpacity)
        .onClick(() => {
          this.pathStack.pop();
        })
    }
    .width('100%')
    .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD, bottom: Spacing.LG })
    .backgroundColor(AppColors.CARD_COLOR)
    .shadow({ radius: 10, color: '#10000000', offsetY: -2 })
  }
}
