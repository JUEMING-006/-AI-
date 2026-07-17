import { AppColors, RouteNames, CollegeNavParam } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { CommonCard } from '../../components/CommonCard';
import { MajorDetail, MajorBrief, ScoreHistoryItem } from '../../models/VolunteerModel';
import { NavHeader } from '../../components/NavHeader';

// 院校简要信息（开设该专业的院校行）
interface CollegeRow {
  name: string;
  lastYearScore: number;
  enrollCount: number;
}

@ComponentV2
export struct MajorDetailPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local majorName: string = '计算机科学与技术';
  @Local detail: MajorDetail = new MajorDetail();
  @Local colleges: CollegeRow[] = [];

  // 硬编码专业详情数据
  private getMajorDetail(name: string): MajorDetail {
    const detail = new MajorDetail();
    detail.name = name;
    detail.category = '工学';
    detail.duration = '2年';
    detail.heat = 5;
    detail.requirements = ['计算机应用技术', '软件技术', '计算机网络技术', '大数据技术', '人工智能技术应用'];
    detail.jobs = ['后端开发工程师', '前端开发工程师', '全栈工程师', '算法工程师', '产品经理', '测试工程师', '运维工程师', '数据分析师'];
    detail.salaryRange = '6k-15k';
    detail.colleges = [];
    const t1 = new ScoreHistoryItem();
    t1.year = 2022; t1.score = 0;
    const t2 = new ScoreHistoryItem();
    t2.year = 2023; t2.score = 0;
    const t3 = new ScoreHistoryItem();
    t3.year = 2024; t3.score = 0;
    detail.enrollTrend = [t1, t2, t3];
    return detail;
  }

  private getColleges(): CollegeRow[] {
    return [
      { name: '深圳技术大学', lastYearScore: 320, enrollCount: 60 },
      { name: '广州理工学院', lastYearScore: 305, enrollCount: 40 },
      { name: '东莞理工学院', lastYearScore: 298, enrollCount: 50 },
      { name: '佛山科学技术学院', lastYearScore: 290, enrollCount: 45 }
    ];
  }

  private getEnrollNumbers(): number[] {
    return [320, 380, 450];
  }

  aboutToAppear(): void {
    this.detail = this.getMajorDetail(this.majorName);
    this.colleges = this.getColleges();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '专业详情' })

        Scroll() {
          Column() {
          // 专业头部卡片
          this.headerCard()

          // 报考要求卡片
          this.requirementCard()

          // 开设院校卡片
          this.collegeListCard()

          // 就业方向卡片
          this.careerCard()

          // 历年数据卡片
          this.trendCard()
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD, bottom: Spacing.XL })
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
    .onReady((context: NavDestinationContext) => {
      const param: Record<string, Object> | undefined = context.pathInfo.param as Record<string, Object> | undefined;
      if (param !== null && param !== undefined) {
        const name: string = param['majorName'] as string;
        if (name !== '') {
          this.majorName = name;
          this.detail = this.getMajorDetail(name);
          this.colleges = this.getColleges();
        }
      }
    })
  }

  // 专业头部卡片
  @Builder
  headerCard() {
    CommonCard() {
      Column() {
        Text(this.detail.name)
          .fontSize(FontSize.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)

        // 标签行
        Row({ space: Spacing.SM }) {
          Text(this.detail.category)
            .fontSize(FontSize.CAPTION)
            .fontColor(Color.White)
            .backgroundColor(AppColors.PRIMARY_COLOR)
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })

          Text(this.detail.duration)
            .fontSize(FontSize.CAPTION)
            .fontColor(Color.White)
            .backgroundColor(AppColors.ACCENT_COLOR)
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
        .margin({ top: Spacing.SM })

        // 热度指示器
        Row() {
          Text('报考热度')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)

          Row({ space: 2 }) {
            ForEach([0, 1, 2, 3, 4], (_: number, idx: number) => {
              SymbolGlyph($r('sys.symbol.star'))
                .fontSize(16)
                .fontColor([idx < this.detail.heat ? AppColors.WARNING_COLOR : AppColors.DIVIDER_COLOR])
            })
          }
          .margin({ left: Spacing.SM })
        }
        .margin({ top: Spacing.MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 报考要求卡片
  @Builder
  requirementCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize(20)
            .fontColor([AppColors.PRIMARY_COLOR])

          Text('报考要求')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        Text('可报考的专科专业')
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: Spacing.MD })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.detail.requirements, (req: string, idx: number) => {
            Text(req)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.PRIMARY_COLOR)
              .backgroundColor(AppColors.PRIMARY_LIGHT)
              .borderRadius(12)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .margin({ right: Spacing.SM, top: Spacing.SM })
          }, (req: string) => req)
        }
        .margin({ top: Spacing.XS })

        Text('其他要求：身体健康，无色盲色弱')
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: Spacing.MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 开设院校卡片
  @Builder
  collegeListCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.building'))
            .fontSize(20)
            .fontColor([AppColors.PRIMARY_COLOR])

          Text('开设该专业的院校')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        ForEach(this.colleges, (college: CollegeRow, idx: number) => {
          Row() {
            Column() {
              Text(college.name)
                .fontSize(FontSize.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppColors.TEXT_PRIMARY)

              Row({ space: Spacing.MD }) {
                Text(`去年${college.lastYearScore}分`)
                  .fontSize(FontSize.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)

                Text(`招生${college.enrollCount}人`)
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
            const param: CollegeNavParam = { collegeName: college.name };
            this.pathStack.pushPath({ name: RouteNames.COLLEGE_VOLUNTEER, param: param });
          })
        }, (college: CollegeRow) => college.name)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 就业方向卡片
  @Builder
  careerCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.building'))
            .fontSize(20)
            .fontColor([AppColors.SUCCESS_COLOR])

          Text('就业前景')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.detail.jobs, (job: string, idx: number) => {
            Text(job)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_PRIMARY)
              .backgroundColor(AppColors.BACKGROUND_COLOR)
              .borderRadius(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: Spacing.SM, top: Spacing.SM })
          }, (job: string) => job)
        }
        .margin({ top: Spacing.MD })

        Row() {
          Text('参考薪资')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)

          Text(this.detail.salaryRange)
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.SUCCESS_COLOR)
            .margin({ left: Spacing.SM })
        }
        .margin({ top: Spacing.MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  // 历年数据卡片
  @Builder
  trendCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.calendar'))
            .fontSize(20)
            .fontColor([AppColors.ACCENT_COLOR])

          Text('招生趋势')
            .fontSize(FontSize.HEADLINE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        Row() {
          ForEach(this.getEnrollNumbers(), (num: number, idx: number) => {
            Column() {
              Text(`${2022 + idx}`)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)

              Text(`${num}`)
                .fontSize(FontSize.HEADLINE)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.PRIMARY_COLOR)
                .margin({ top: Spacing.XS })

              Text('人')
                .fontSize(10)
                .fontColor(AppColors.TEXT_HINT)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (num: number, idx: number) => `${idx}`)
        }
        .width('100%')
        .margin({ top: Spacing.MD })

        Row() {
          Text('↑')
            .fontSize(14)
            .fontColor(AppColors.SUCCESS_COLOR)

          Text('招生人数逐年增长，就业前景广阔')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ left: Spacing.XS })
        }
        .margin({ top: Spacing.MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
