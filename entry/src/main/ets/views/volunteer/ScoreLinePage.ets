import { AppColors, ButtonStyles, RouteNames, CollegeNavParam } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { volunteerService } from '../../services/VolunteerService';
import { CommonCard } from '../../components/CommonCard';
import { NavHeader } from '../../components/NavHeader';

// 分数数据接口
interface ScoreData {
  year: number;
  score: number;
}

// 专业分数线
interface MajorScoreLine {
  majorName: string;
  scores: ScoreData[];
  enrollCount: number;
}

// 分数线条目数据
interface ScoreLineItem {
  collegeName: string;
  collegeType: string;
  scores: ScoreData[];
  enrollCount: number;
  trend: string;
  majors: MajorScoreLine[];
}

@ComponentV2
export struct ScoreLinePage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local searchText: string = '';
  @Local displaySearchText: string = '';
  @Local debounceTimer: number = -1;
  @Local selectedYear: number = 2024;
  @Local selectedType: string = '全部';
  @Local scoreLines: ScoreLineItem[] = [];
  @Local expandedIndex: number = -1;
  private yearOptions: number[] = [2024, 2023, 2022];

  aboutToAppear(): void {
    this.loadScoreLines();
  }

  private loadScoreLines(): void {
    this.scoreLines = [
      {
        collegeName: '深圳技术大学', collegeType: '公办',
        scores: [{ year: 2024, score: 320 }, { year: 2023, score: 315 }, { year: 2022, score: 308 }],
        enrollCount: 120, trend: 'up',
        majors: [
          { majorName: '计算机科学与技术', scores: [{ year: 2024, score: 325 }, { year: 2023, score: 320 }, { year: 2022, score: 312 }], enrollCount: 60 },
          { majorName: '软件工程', scores: [{ year: 2024, score: 318 }, { year: 2023, score: 314 }, { year: 2022, score: 308 }], enrollCount: 40 },
          { majorName: '数据科学', scores: [{ year: 2024, score: 322 }, { year: 2023, score: 316 }, { year: 2022, score: 310 }], enrollCount: 20 }
        ]
      },
      {
        collegeName: '广州理工学院', collegeType: '民办',
        scores: [{ year: 2024, score: 305 }, { year: 2023, score: 302 }, { year: 2022, score: 298 }],
        enrollCount: 80, trend: 'up',
        majors: [
          { majorName: '软件工程', scores: [{ year: 2024, score: 310 }, { year: 2023, score: 306 }, { year: 2022, score: 300 }], enrollCount: 30 },
          { majorName: '网络工程', scores: [{ year: 2024, score: 300 }, { year: 2023, score: 298 }, { year: 2022, score: 295 }], enrollCount: 50 }
        ]
      },
      {
        collegeName: '东莞理工学院', collegeType: '公办',
        scores: [{ year: 2024, score: 298 }, { year: 2023, score: 300 }, { year: 2022, score: 295 }],
        enrollCount: 100, trend: 'down',
        majors: [
          { majorName: '计算机科学与技术', scores: [{ year: 2024, score: 302 }, { year: 2023, score: 305 }, { year: 2022, score: 298 }], enrollCount: 50 },
          { majorName: '电子信息工程', scores: [{ year: 2024, score: 295 }, { year: 2023, score: 297 }, { year: 2022, score: 292 }], enrollCount: 50 }
        ]
      },
      {
        collegeName: '佛山科学技术学院', collegeType: '公办',
        scores: [{ year: 2024, score: 290 }, { year: 2023, score: 290 }, { year: 2022, score: 288 }],
        enrollCount: 90, trend: 'flat',
        majors: [
          { majorName: '数据科学', scores: [{ year: 2024, score: 292 }, { year: 2023, score: 290 }, { year: 2022, score: 288 }], enrollCount: 45 },
          { majorName: '机械工程', scores: [{ year: 2024, score: 288 }, { year: 2023, score: 289 }, { year: 2022, score: 287 }], enrollCount: 45 }
        ]
      },
      {
        collegeName: '广东石油化工学院', collegeType: '公办',
        scores: [{ year: 2024, score: 280 }, { year: 2023, score: 275 }, { year: 2022, score: 270 }],
        enrollCount: 70, trend: 'up',
        majors: [
          { majorName: '化学工程', scores: [{ year: 2024, score: 282 }, { year: 2023, score: 277 }, { year: 2022, score: 272 }], enrollCount: 40 },
          { majorName: '机械设计制造', scores: [{ year: 2024, score: 278 }, { year: 2023, score: 273 }, { year: 2022, score: 268 }], enrollCount: 30 }
        ]
      },
      {
        collegeName: '珠海科技学院', collegeType: '民办',
        scores: [{ year: 2024, score: 275 }, { year: 2023, score: 272 }, { year: 2022, score: 268 }],
        enrollCount: 60, trend: 'up',
        majors: [
          { majorName: '网络工程', scores: [{ year: 2024, score: 278 }, { year: 2023, score: 274 }, { year: 2022, score: 270 }], enrollCount: 35 },
          { majorName: '市场营销', scores: [{ year: 2024, score: 272 }, { year: 2023, score: 270 }, { year: 2022, score: 266 }], enrollCount: 25 }
        ]
      },
      {
        collegeName: '中山火炬职业技术学院', collegeType: '公办',
        scores: [{ year: 2024, score: 265 }, { year: 2023, score: 262 }, { year: 2022, score: 258 }],
        enrollCount: 50, trend: 'up',
        majors: [
          { majorName: '物联网工程', scores: [{ year: 2024, score: 268 }, { year: 2023, score: 264 }, { year: 2022, score: 260 }], enrollCount: 30 },
          { majorName: '软件技术', scores: [{ year: 2024, score: 262 }, { year: 2023, score: 260 }, { year: 2022, score: 256 }], enrollCount: 20 }
        ]
      },
      {
        collegeName: '广东东软学院', collegeType: '民办',
        scores: [{ year: 2024, score: 258 }, { year: 2023, score: 255 }, { year: 2022, score: 250 }],
        enrollCount: 55, trend: 'up',
        majors: [
          { majorName: '软件工程', scores: [{ year: 2024, score: 262 }, { year: 2023, score: 258 }, { year: 2022, score: 253 }], enrollCount: 30 },
          { majorName: '数字媒体技术', scores: [{ year: 2024, score: 254 }, { year: 2023, score: 252 }, { year: 2022, score: 248 }], enrollCount: 25 }
        ]
      }
    ];
  }

  private getMyScoreDiff(score: number): number {
    if (!volunteerService.hasScore) return 0;
    return volunteerService.currentScore.totalScore - score;
  }

  private getDiffColor(diff: number): string {
    if (diff >= 10) return AppColors.SUCCESS_COLOR;
    if (diff >= 0) return '#FF9500';
    return AppColors.ERROR_COLOR;
  }

  private getTrendIcon(trend: string): string {
    if (trend === 'up') return '↑';
    if (trend === 'down') return '↓';
    return '→';
  }

  private getTrendColor(trend: string): string {
    if (trend === 'up') return AppColors.ERROR_COLOR;
    if (trend === 'down') return AppColors.SUCCESS_COLOR;
    return AppColors.TEXT_HINT;
  }

  private showYearPicker(): void {
    const yearStrings: string[] = this.yearOptions.map((y: number) => `${y}年`);
    TextPickerDialog.show({
      range: yearStrings,
      selected: this.yearOptions.indexOf(this.selectedYear),
      onAccept: (value: TextPickerResult) => {
        const idx: number = value.index as number;
        this.selectedYear = this.yearOptions[idx];
      }
    });
  }

  private getFilteredData(): ScoreLineItem[] {
    let result = this.scoreLines;
    if (this.searchText) {
      result = result.filter((item: ScoreLineItem) =>
        item.collegeName.includes(this.searchText)
      );
    }
    if (this.selectedType !== '全部') {
      result = result.filter((item: ScoreLineItem) =>
        item.collegeType === this.selectedType
      );
    }
    return result;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '分数线查询' })

        // 搜索栏
        Row() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(20)
            .fontColor([AppColors.TEXT_HINT])

          TextInput({ placeholder: '搜索院校名称', text: this.displaySearchText })
            .layoutWeight(1)
            .fontSize(FontSize.BODY)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.displaySearchText = value;
              if (this.debounceTimer !== -1) {
                clearTimeout(this.debounceTimer);
              }
              this.debounceTimer = setTimeout(() => {
                this.searchText = this.displaySearchText;
                this.debounceTimer = -1;
              }, 300);
            })
        }
        .width('100%')
        .height(44)
        .padding({ left: Spacing.MD, right: Spacing.MD })
        .backgroundColor(AppColors.CARD_COLOR)
        .borderRadius(Radius.LG)
        .margin({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD })

        // 筛选条件
        Row() {
          Row() {
            Text(`${this.selectedYear}年`)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_PRIMARY)

            Text('▼')
              .fontSize(10)
              .fontColor(AppColors.TEXT_HINT)
              .margin({ left: Spacing.XS })
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(AppColors.BACKGROUND_COLOR)
          .borderRadius(Radius.SM)
          .onClick(() => {
            this.showYearPicker();
          })

          Row({ space: Spacing.XS }) {
            this.typeChip('全部')
            this.typeChip('公办')
            this.typeChip('民办')
          }
          .margin({ left: Spacing.MD })
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.SM })

        // 我的分数参考线
        if (volunteerService.hasScore) {
          this.myScoreCard()
        }

        // 分数线列表
        Scroll() {
          Column() {
            ForEach(this.getFilteredData(), (item: ScoreLineItem, index: number) => {
              this.scoreLineItem(item, index)
            }, (item: ScoreLineItem) => item.collegeName)
          }
          .width('100%')
          .padding({ left: Spacing.LG, right: Spacing.LG, bottom: Spacing.XL })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 底部说明
        this.footerNote()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.BACKGROUND_COLOR)
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(AppColors.BACKGROUND_COLOR)
  }

  @Builder
  typeChip(type: string) {
    Text(type)
      .fontSize(FontSize.CAPTION)
      .fontColor(this.selectedType === type ? Color.White : AppColors.TEXT_SECONDARY)
      .backgroundColor(this.selectedType === type ? AppColors.PRIMARY_COLOR : AppColors.BACKGROUND_COLOR)
      .borderRadius(12)
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .onClick(() => {
        this.selectedType = type;
      })
  }

  @Builder
  myScoreCard() {
    Column() {
      CommonCard() {
        Row() {
          Column() {
            Text('我的总分')
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)

            Text(`${volunteerService.currentScore.totalScore}`)
              .fontSize(FontSize.DISPLAY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.PRIMARY_COLOR)
              .margin({ top: Spacing.XS })

            Text('分')
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Column() {
            Text('参考线')
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)

            Text('---')
              .fontSize(FontSize.BODY)
              .fontColor(AppColors.TEXT_HINT)
              .margin({ top: Spacing.SM })
          }
        }
        .width('100%')
      }
    }
    .margin({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.SM })
  }

  @Builder
  scoreLineItem(item: ScoreLineItem, index: number) {
    Column() {
      Row() {
        Text(item.collegeName)
          .fontSize(FontSize.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)

        Text(item.collegeType)
          .fontSize(FontSize.CAPTION)
          .fontColor(Color.White)
          .backgroundColor(item.collegeType === '公办' ? '#007AFF' : '#FF9500')
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: Spacing.SM })

        if (this.expandedIndex === index) {
          Text('▲')
            .fontSize(12)
            .fontColor(AppColors.TEXT_HINT)
            .margin({ left: Spacing.SM })
        } else {
          Text('▼')
            .fontSize(12)
            .fontColor(AppColors.TEXT_HINT)
            .margin({ left: Spacing.SM })
        }
      }
      .width('100%')
      .onClick(() => {
        this.expandedIndex = this.expandedIndex === index ? -1 : index;
      })

      Row() {
        ForEach(item.scores, (scoreItem: ScoreData) => {
          Column() {
            Text(`${scoreItem.year}年`)
              .fontSize(10)
              .fontColor(AppColors.TEXT_HINT)

            Text(`${scoreItem.score}`)
              .fontSize(FontSize.BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)
          }
          .layoutWeight(1)
        }, (scoreItem: ScoreData) => `${scoreItem.year}`)

        Column() {
          Text('趋势')
            .fontSize(10)
            .fontColor(AppColors.TEXT_HINT)

          Text(this.getTrendIcon(item.trend))
            .fontSize(FontSize.BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTrendColor(item.trend))
        }
        .width(40)
      }
      .width('100%')
      .margin({ top: Spacing.SM })

      Row() {
        Text(`招生${item.enrollCount}人`)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)

        Blank()

        if (volunteerService.hasScore) {
          Text(`${this.getMyScoreDiff(item.scores[0].score) >= 0 ? '+' : ''}${this.getMyScoreDiff(item.scores[0].score)}分`)
            .fontSize(FontSize.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getDiffColor(this.getMyScoreDiff(item.scores[0].score)))
        }

        Text('查看详情')
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.PRIMARY_COLOR)
          .margin({ left: Spacing.MD })
          .onClick(() => {
            const param: CollegeNavParam = { collegeName: item.collegeName };
            this.pathStack.pushPath({ name: RouteNames.COLLEGE_VOLUNTEER, param: param });
          })
      }
      .width('100%')
      .margin({ top: Spacing.SM })

      // 展开区域：专业分数线
      if (this.expandedIndex === index) {
        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.doc'))
              .fontSize(16)
              .fontColor([AppColors.PRIMARY_COLOR])

            Text('专业分数线')
              .fontSize(FontSize.CAPTION)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)
              .margin({ left: Spacing.XS })
          }
          .width('100%')
          .margin({ bottom: Spacing.SM })

          ForEach(item.majors, (major: MajorScoreLine, mIdx: number) => {
            Row() {
              Column() {
                Text(major.majorName)
                  .fontSize(FontSize.CAPTION)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppColors.TEXT_PRIMARY)

                Text(`计划${major.enrollCount}人`)
                  .fontSize(10)
                  .fontColor(AppColors.TEXT_HINT)
                  .margin({ top: Spacing.XS })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Row() {
                ForEach(major.scores, (ms: ScoreData) => {
                  Column() {
                    Text(`${ms.year}`)
                      .fontSize(9)
                      .fontColor(AppColors.TEXT_HINT)
                    Text(`${ms.score}`)
                      .fontSize(FontSize.CAPTION)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(AppColors.TEXT_PRIMARY)
                  }
                  .margin({ left: Spacing.SM })
                }, (ms: ScoreData) => `${ms.year}`)
              }
            }
            .width('100%')
            .padding({ top: Spacing.SM, bottom: Spacing.SM })
            .border({ width: 0.5, color: AppColors.DIVIDER_COLOR })
          }, (major: MajorScoreLine) => major.majorName)
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
  footerNote() {
    Column() {
      Text('数据来源：各省教育考试院官方数据')
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_HINT)

      Text('仅供参考，请以官方公布为准')
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_HINT)
        .margin({ top: Spacing.XS })
    }
    .width('100%')
    .padding(Spacing.MD)
    .backgroundColor(AppColors.CARD_COLOR)
  }
}
