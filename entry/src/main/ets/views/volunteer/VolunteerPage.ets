import { AppColors, RouteNames, ButtonStyles, CollegeNavParam } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { volunteerService } from '../../services/VolunteerService';
import { CommonCard } from '../../components/CommonCard';
import { getDaysCountdown } from '../../common/Utils';

// 三梯度颜色
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

// 四宫格入口数据接口
interface QuickEntry {
  icon: Resource;
  title: string;
  subtitle: string;
  route: string;
  color: string;
}

// 热门院校数据结构
interface HotCollege {
  name: string;
  lastYearScore: number;
  enrollCount: number;
  type: string;
}

@ComponentV2
export struct VolunteerPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local btnScale: number = 1.0;
  @Local btnOpacity: number = 1.0;
  @Local entryScale: number[] = [1.0, 1.0, 1.0, 1.0];
  @Local entryOpacity: number[] = [1.0, 1.0, 1.0, 1.0];

  // 四宫格入口配置
  private quickEntries: QuickEntry[] = [
    { icon: $r('sys.symbol.star'), title: '智能选志愿', subtitle: '冲稳保方案', route: RouteNames.VOLUNTEER_RESULT, color: '#007AFF' },
    { icon: $r('sys.symbol.doc'), title: '我的志愿表', subtitle: '已选0所', route: RouteNames.VOLUNTEER_FORM, color: '#10B981' },
    { icon: $r('sys.symbol.clock'), title: '分数线查询', subtitle: '历年数据', route: RouteNames.SCORE_LINE, color: '#FF9500' },
    { icon: $r('sys.symbol.checkmark'), title: '志愿诊断', subtitle: '风险评估', route: RouteNames.VOLUNTEER_DIAGNOSE, color: '#FF6B6B' }
  ];

  // 动态获取入口副标题
  private getEntrySubtitle(route: string): string {
    if (route === RouteNames.VOLUNTEER_FORM) {
      const total: number = volunteerService.currentPlan.rushCount + volunteerService.currentPlan.stableCount + volunteerService.currentPlan.safeCount;
      return `已选${total}所`;
    }
    const entry: QuickEntry | undefined = this.quickEntries.find((e: QuickEntry) => e.route === route);
    return entry ? entry.subtitle : '';
  }

  // 动态倒计时天数
  private getDeadlineDays(): number {
    return getDaysCountdown('2026-08-15');
  }

  private getHotColleges(): HotCollege[] {
    return [
      { name: '深圳技术大学', lastYearScore: 320, enrollCount: 120, type: '公办' },
      { name: '广州理工学院', lastYearScore: 305, enrollCount: 80, type: '民办' },
      { name: '东莞理工学院', lastYearScore: 298, enrollCount: 100, type: '公办' },
      { name: '佛山科学技术学院', lastYearScore: 290, enrollCount: 90, type: '公办' }
    ];
  }

  private getTierPercent(tier: string): number {
    const total = volunteerService.currentPlan.rushCount + volunteerService.currentPlan.stableCount + volunteerService.currentPlan.safeCount;
    if (total === 0) return 33;
    if (tier === 'rush') return (volunteerService.currentPlan.rushCount / total) * 100;
    if (tier === 'stable') return (volunteerService.currentPlan.stableCount / total) * 100;
    return (volunteerService.currentPlan.safeCount / total) * 100;
  }

  build() {
    Column() {
      // 状态栏安全区避让
      Blank().height(AppStorage.get<number>('safeAreaTop') ?? 0)

      Scroll() {
        Column() {
          // ========== 顶部Banner：成绩摘要卡片 ==========
          this.scoreBanner()

          // ========== 核心功能区：四宫格快捷入口 ==========
          this.quickEntryGrid()

          // ========== 推荐概览：冲稳保方案预览 ==========
          if (volunteerService.hasScore) {
            this.tierOverview()
          }

          // ========== 热门院校：水平滚动列表 ==========
          this.hotColleges()

          // ========== 政策提醒：填报时间线 ==========
          this.timelineCard()
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.XL })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  // 成绩摘要卡片
  @Builder
  scoreBanner() {
    Column() {
      if (!volunteerService.hasScore) {
        // 未录入状态
        Row() {
          Column() {
            Text('快速录入成绩')
              .fontSize(FontSize.SUBTITLE)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
            Text('开启智能志愿推荐')
              .fontSize(FontSize.CAPTION)
              .fontColor('#80FFFFFF')
              .margin({ top: Spacing.XS })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(32)
            .fontColor([Color.White])
        }
        .width('100%')
        .padding(Spacing.LG)
        .onClick(() => {
          this.pathStack.pushPath({ name: RouteNames.SCORE_INPUT });
        })
      } else {
        // 已录入状态
        Row() {
          Column() {
            Text('我的成绩')
              .fontSize(FontSize.CAPTION)
              .fontColor('#80FFFFFF')
            Text(`${volunteerService.currentScore.totalScore}`)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: Spacing.XS })
            Text(`${volunteerService.currentScore.province} · 专升本`)
              .fontSize(FontSize.CAPTION)
              .fontColor('#80FFFFFF')
              .margin({ top: Spacing.XS })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          // 录取概率环形图
          Stack() {
            Progress({ value: 75, total: 100, type: ProgressType.Ring })
              .width(60)
              .height(60)
              .color(Color.White)
              .backgroundColor('#20FFFFFF')
              .style({ strokeWidth: 6 })
            Column() {
              Text('75%')
                .fontSize(FontSize.CAPTION)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
              Text('录取率')
                .fontSize(10)
                .fontColor('#80FFFFFF')
            }
          }
        }
        .width('100%')
        .padding(Spacing.LG)

        // 操作栏
        Row() {
          Button('修改成绩')
            .layoutWeight(1)
            .height(36)
            .fontSize(FontSize.CAPTION)
            .fontColor(Color.White)
            .backgroundColor('#20FFFFFF')
            .borderRadius(Radius.BUTTON)
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteNames.SCORE_INPUT });
            })

          Button('查看推荐')
            .layoutWeight(1)
            .height(36)
            .fontSize(FontSize.CAPTION)
            .fontColor('#007AFF')
            .backgroundColor(Color.White)
            .borderRadius(Radius.BUTTON)
            .margin({ left: Spacing.MD })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_RESULT });
            })
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, bottom: Spacing.LG })
      }
    }
    .width('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
    })
    .borderRadius(Radius.LG)
    .margin({ bottom: Spacing.LG })
  }

  // 四宫格快捷入口
  @Builder
  quickEntryGrid() {
    Column() {
      Text('功能中心')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: Spacing.MD })

      Grid() {
        ForEach(this.quickEntries, (entry: QuickEntry, index: number) => {
          GridItem() {
            this.entryItem(entry, index)
          }
        }, (entry: QuickEntry) => entry.title)
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(Spacing.MD)
      .rowsGap(Spacing.MD)
      .width('100%')
      .height(200)
    }
    .width('100%')
    .margin({ bottom: Spacing.LG })
  }

  @Builder
  entryItem(entry: QuickEntry, index: number) {
    Column() {
      SymbolGlyph(entry.icon)
        .fontSize(28)
        .fontColor([entry.color])

      Text(entry.title)
        .fontSize(FontSize.BODY)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ top: Spacing.SM })

      Text(this.getEntrySubtitle(entry.route))
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: Spacing.XS })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.LG)
    .shadow(Shadows.GLASS)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
    .scale({ x: this.entryScale[index], y: this.entryScale[index] })
    .opacity(this.entryOpacity[index])
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_PRESS_DURATION,
          curve: AnimConfig.LIQUID_PRESS_CURVE,
        }, () => {
          const newScale: number[] = [...this.entryScale];
          newScale[index] = AnimConfig.PRESS_SCALE;
          this.entryScale = newScale;
          const newOpacity: number[] = [...this.entryOpacity];
          newOpacity[index] = AnimConfig.PRESS_OPACITY;
          this.entryOpacity = newOpacity;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_RELEASE_DURATION,
          curve: AnimConfig.LIQUID_RELEASE_CURVE,
        }, () => {
          const newScale: number[] = [...this.entryScale];
          newScale[index] = 1.0;
          this.entryScale = newScale;
          const newOpacity: number[] = [...this.entryOpacity];
          newOpacity[index] = 1.0;
          this.entryOpacity = newOpacity;
        });
      }
    })
    .onClick(() => {
      this.pathStack.pushPath({ name: entry.route });
    })
  }

  // 冲稳保方案预览
  @Builder
  tierOverview() {
    Column() {
      CommonCard() {
        Column() {
          Row() {
            Text('推荐概览')
              .fontSize(FontSize.SUBTITLE)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)

            Blank()

            Text('查看完整方案 →')
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.PRIMARY_COLOR)
              .onClick(() => {
                this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_RESULT });
              })
          }
          .width('100%')

          // 三色进度条
          Row() {
            Row()
              .width(`${this.getTierPercent('rush')}%`)
              .height(8)
              .backgroundColor(RUSH_COLOR)
              .borderRadius({ topLeft: 4, bottomLeft: 4 })

            Row()
              .width(`${this.getTierPercent('stable')}%`)
              .height(8)
              .backgroundColor(STABLE_COLOR)

            Row()
              .width(`${this.getTierPercent('safe')}%`)
              .height(8)
              .backgroundColor(SAFE_COLOR)
              .borderRadius({ topRight: 4, bottomRight: 4 })
          }
          .width('100%')
          .margin({ top: Spacing.MD })

          // 梯度详情
          Row() {
            this.tierBadge('冲刺', volunteerService.currentPlan.rushCount, RUSH_COLOR)
            this.tierBadge('稳妥', volunteerService.currentPlan.stableCount, STABLE_COLOR)
            this.tierBadge('保底', volunteerService.currentPlan.safeCount, SAFE_COLOR)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: Spacing.MD })
        }
        .width('100%')
      }
    }
    .margin({ bottom: Spacing.LG })
  }

  @Builder
  tierBadge(label: string, count: number, color: string) {
    Row() {
      Column()
        .width(4)
        .height(16)
        .backgroundColor(color)
        .borderRadius(2)

      Text(`${label} ${count}所`)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ left: Spacing.XS })
    }
  }

  // 热门院校
  @Builder
  hotColleges() {
    Column() {
      Row() {
        Text('热门院校')
          .fontSize(FontSize.SUBTITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)

        Blank()

        Text('更多 >')
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .margin({ bottom: Spacing.MD })

      Scroll() {
        Row({ space: Spacing.MD }) {
          ForEach(this.getHotColleges(), (college: HotCollege) => {
            this.collegeCard(college)
          }, (college: HotCollege) => college.name)
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .margin({ bottom: Spacing.LG })
  }

  @Builder
  collegeCard(college: HotCollege) {
    Column() {
      Text(college.name)
        .fontSize(FontSize.BODY)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(`${college.type} · ${college.lastYearScore}分`)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: Spacing.XS })

      Text(`招生${college.enrollCount}人`)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_HINT)
        .margin({ top: Spacing.XS })
    }
    .width(140)
    .padding(Spacing.MD)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
    .onClick(() => {
      const param: CollegeNavParam = { collegeName: college.name };
      this.pathStack.pushPath({ name: RouteNames.COLLEGE_VOLUNTEER, param: param });
    })
  }

  // 填报时间线
  @Builder
  timelineCard() {
    CommonCard() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.clock'))
            .fontSize(20)
            .fontColor([AppColors.WARNING_COLOR])

          Text('志愿填报时间线')
            .fontSize(FontSize.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: Spacing.SM })
        }

        Row() {
          Text('距离志愿填报截止还有')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)

          Text(` ${this.getDeadlineDays()} `)
            .fontSize(FontSize.SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.WARNING_COLOR)

          Text('天')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .margin({ top: Spacing.SM })

        // 时间节点
        Row() {
          this.timelineNode('报名', '已完成', true)
          this.timelineLine(true)
          this.timelineNode('填报', '进行中', true)
          this.timelineLine(false)
          this.timelineNode('录取', '待开始', false)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: Spacing.MD })
      }
      .width('100%')
    }
  }

  @Builder
  timelineNode(title: string, status: string, isActive: boolean) {
    Column() {
      Column()
        .width(12)
        .height(12)
        .borderRadius(6)
        .backgroundColor(isActive ? AppColors.PRIMARY_COLOR : AppColors.TEXT_HINT)

      Text(title)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ top: Spacing.XS })

      Text(status)
        .fontSize(10)
        .fontColor(isActive ? AppColors.PRIMARY_COLOR : AppColors.TEXT_HINT)
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  timelineLine(isActive: boolean) {
    Row()
      .width(40)
      .height(2)
      .backgroundColor(isActive ? AppColors.PRIMARY_COLOR : AppColors.DIVIDER_COLOR)
  }
}
