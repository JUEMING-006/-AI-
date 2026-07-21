import { AppColors } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect, LiquidGlass } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { CollegeInfo, ScoreLine } from '../../models/CollegeModel';
import { collegeService } from '../../services/CollegeService';
import { LoadingView } from '../../components/LoadingView';
import { NavHeader } from '../../components/NavHeader';

// 路由参数接口
interface CollegeDetailParam {
  id: string;
}

@ComponentV2
export struct CollegeDetailPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local college: CollegeInfo | null = null;
  @Local scoreLines: ScoreLine[] = [];
  @Local isLoading: boolean = true;
  @Local collegeId: string = '';
  @Local barHeights: number[] = [0, 0, 0];
  @Local favScale: number = 1.0;
  @Local favOpacity: number = 1.0;
  @Local targetScale: number = 1.0;
  @Local targetOpacity: number = 1.0;

  private loadData(): void {
    this.isLoading = true;
    Promise.all([
      collegeService.getCollegeDetail(this.collegeId),
      collegeService.getScoreLines(this.collegeId),
    ]).then((results: [CollegeInfo, ScoreLine[]]) => {
      this.college = results[0];
      this.scoreLines = results[1];
      this.isLoading = false;
      this.animateBars();
    }).catch(() => {
      this.isLoading = false;
    });
  }

  private animateBars(): void {
    const chartHeight: number = 100;
    const maxScore: number = Math.max(...this.scoreLines.map((l: ScoreLine) => l.minScore), 1);
    const targetHeights: number[] = this.scoreLines.slice(0, 3).map(
      (l: ScoreLine) => Math.round((l.minScore / maxScore) * chartHeight)
    );
    setTimeout(() => {
      const ctx: UIContext = this.getUIContext();
      ctx?.animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
        this.barHeights = targetHeights;
      });
    }, 300);
  }

  private onToggleFavorite(): void {
    if (this.college === null) {
      return;
    }
    const newVal: boolean = !this.college.isFavorite;
    collegeService.toggleFavorite(this.college.id, newVal).then(() => {
      if (this.college !== null) {
        this.college.isFavorite = newVal;
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '院校详情' })

        if (this.isLoading) {
          LoadingView({ message: '加载院校详情...' })
        } else if (this.college !== null) {
          Scroll() {
            Column() {
              // 蓝色渐变头部卡片
              this.headerCard()
              // 核心数据四格
              this.dataGrid()
              // 院校简介
              this.descriptionCard()
              // 招生专业
              this.majorsCard()
              // 历年分数线 + 柱状图
              this.scoreCard()
              // 底部留白（为固定按钮栏留空间）
              Blank().height(80)
            }
            .width('100%')
            .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)

          // 底部固定操作栏
          this.bottomActionBar()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.BACKGROUND_COLOR)
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .onReady((context: NavDestinationContext) => {
      const param: Record<string, Object> | undefined = context.pathInfo.param as Record<string, Object> | undefined;
      if (param !== null && param !== undefined) {
        const detailParam: CollegeDetailParam = { id: param['id'] as string };
        if (detailParam.id !== '') {
          this.collegeId = detailParam.id;
          this.loadData();
        }
      }
    })
  }

  // === 蓝色渐变头部卡片 ===
  @Builder
  headerCard() {
    Column() {
      // 院校名称
      Text(this.college!.name)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width('100%')

      // 类型 + 省份城市 标签行
      Row({ space: 8 }) {
        Text(this.college!.type)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#30FFFFFF')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        Text(`${this.college!.province} · ${this.college!.city}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#30FFFFFF')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        Text(this.college!.category)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#30FFFFFF')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      }
      .margin({ top: 12 })

      // 特殊标签（双一流/211等）
      if (this.college!.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(this.college!.tags, (tag: string) => {
            Text(tag)
              .fontSize(11)
              .fontColor(tag === '双一流' || tag === '211' ? '#FFD700' : '#B0FFFFFF')
              .backgroundColor(tag === '双一流' || tag === '211' ? '#30FFD700' : '#20FFFFFF')
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .margin({ right: 6, top: 6 })
          }, (tag: string) => tag)
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 28, bottom: 28 })
    .borderRadius(20)
    .linearGradient({
      angle: 135,
      colors: [['#0066FF', 0.0], ['#003D99', 1.0]]
    })
    .shadow({ radius: 16, color: '#300066FF', offsetY: 6 })
    .alignItems(HorizontalAlign.Center)
  }

  // === 核心数据四格（2×2网格） ===
  @Builder
  dataGrid() {
    Column() {
      // 第一行
      Row() {
        // 招生人数
        Column() {
          Text(`${this.college!.enrollCount}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.SUCCESS_COLOR)
          Text('招生人数')
            .fontSize(11)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .height(76)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .backgroundColor(AppColors.GLASS_LIGHT)
        .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
        .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .margin({ right: 6 })

        // 最低分
        Column() {
          Text(`${this.college!.minScore}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.PRIMARY_COLOR)
          Text('最低录取分')
            .fontSize(11)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .height(76)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .backgroundColor(AppColors.GLASS_LIGHT)
        .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
        .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .margin({ left: 6 })
      }
      .width('100%')
      .margin({ top: 12 })

      // 第二行
      Row() {
        // 层次
        Column() {
          Text(this.college!.level)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.WARNING_COLOR)
          Text('办学层次')
            .fontSize(11)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .height(76)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .backgroundColor(AppColors.GLASS_LIGHT)
        .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
        .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .margin({ right: 6, top: 8 })

        // 类别
        Column() {
          Text(this.college!.category)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#AF52DE')
          Text('院校类别')
            .fontSize(11)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .height(76)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .backgroundColor(AppColors.GLASS_LIGHT)
        .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
        .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .margin({ left: 6, top: 8 })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: 12 })
  }

  // === 院校简介卡片 ===
  @Builder
  descriptionCard() {
    if (this.college!.description.length > 0) {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.doc'))
            .fontSize(18)
            .fontColor([AppColors.PRIMARY_COLOR])
          Text('院校简介')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: 6 })
        }
        .width('100%')

        Text(this.college!.description)
          .fontSize(14)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: 10 })
          .lineHeight(22)
      }
      .width('100%')
      .padding(16)
      .margin({ top: 12 })
      .borderRadius(16)
      .backgroundColor(AppColors.GLASS_LIGHT)
      .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
      .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
      .shadow(LiquidGlass.SHADOW_CONTAINER)
      .alignItems(HorizontalAlign.Start)
    }
  }

  // === 招生专业卡片 ===
  @Builder
  majorsCard() {
    if (this.college!.majors.length > 0) {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.bookmark'))
            .fontSize(18)
            .fontColor(['#34C759'])
          Text('招生专业')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: 6 })
          Text(`${this.college!.majors.length}个`)
            .fontSize(12)
            .fontColor(AppColors.TEXT_HINT)
            .margin({ left: 8 })
        }
        .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.college!.majors, (major: string) => {
            Text(major)
              .fontSize(13)
              .fontColor(AppColors.TEXT_PRIMARY)
              .backgroundColor(AppColors.BACKGROUND_COLOR)
              .borderRadius(8)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8, top: 8 })
          }, (major: string) => major)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .margin({ top: 12 })
      .borderRadius(16)
      .backgroundColor(AppColors.GLASS_LIGHT)
      .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
      .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
      .shadow(LiquidGlass.SHADOW_CONTAINER)
      .alignItems(HorizontalAlign.Start)
    }
  }

  // === 底部固定操作栏 ===
  @Builder
  bottomActionBar() {
    Row({ space: 12 }) {
      // 收藏按钮
      Button() {
        Row({ space: 6 }) {
          SymbolGlyph(this.college!.isFavorite ? $r('sys.symbol.checkmark') : $r('sys.symbol.star'))
            .fontSize(18)
            .fontColor([this.college!.isFavorite ? AppColors.WARNING_COLOR : AppColors.TEXT_SECONDARY])
          Text(this.college!.isFavorite ? '已收藏' : '收藏')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.college!.isFavorite ? AppColors.WARNING_COLOR : AppColors.TEXT_PRIMARY)
        }
      }
      .type(ButtonType.Capsule)
      .height(48)
      .layoutWeight(1)
      .backgroundColor(AppColors.GLASS_LIGHT)
      .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
      .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
      .shadow(LiquidGlass.SHADOW_CONTAINER)
      .scale({ x: this.favScale, y: this.favScale })
      .opacity(this.favOpacity)
      .animation({ duration: 200, curve: Curve.EaseOut })
      .onClick(() => {
        this.onToggleFavorite();
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.favScale = 0.92;
          this.favOpacity = 0.7;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.favScale = 1.0;
          this.favOpacity = 1.0;
        }
      })

      // 设为目标院校按钮（渐变背景）
      Button() {
        Row({ space: 6 }) {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize(18)
            .fontColor(['#FFFFFF'])
          Text('设为目标院校')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
      }
      .type(ButtonType.Capsule)
      .height(48)
      .layoutWeight(1)
      .linearGradient({
        angle: 135,
        colors: [['#0066FF', 0.0], ['#003D99', 1.0]]
      })
      .shadow({ radius: 12, color: '#300066FF', offsetY: 4 })
      .scale({ x: this.targetScale, y: this.targetScale })
      .opacity(this.targetOpacity)
      .animation({ duration: 200, curve: Curve.EaseOut })
      .onClick(() => {
        this.pathStack.pop();
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.targetScale = 0.92;
          this.targetOpacity = 0.7;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.targetScale = 1.0;
          this.targetOpacity = 1.0;
        }
      })
    }
    .width('100%')
    .padding({ left: Spacing.LG, right: Spacing.LG, top: 12, bottom: 12 })
    .backgroundColor(AppColors.GLASS_XLIGHT)
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
  }

  // === 历年分数线 + 柱状图 ===
  @Builder
  scoreCard() {
    if (this.scoreLines.length > 0) {
      Column() {
        // 标题行
        Row() {
          SymbolGlyph($r('sys.symbol.calendar'))
            .fontSize(18)
            .fontColor(['#FF9500'])
          Text('历年分数线')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: 6 })
        }
        .width('100%')

        // 柱状图趋势
        Row() {
          ForEach(this.scoreLines.slice(0, 3), (line: ScoreLine, index: number) => {
            Column() {
              Text(`${line.minScore}`)
                .fontSize(13)
                .fontColor(AppColors.PRIMARY_COLOR)
                .fontWeight(FontWeight.Medium)
              Column()
                .width(36)
                .height(this.barHeights[index] !== undefined ? this.barHeights[index] : 0)
                .linearGradient({
                  angle: 180,
                  colors: index === 0
                    ? [['#0056CC', 0.0], ['#0066FF', 1.0]]
                    : [['#0066FF', 0.0], ['#3399FF', 1.0]]
                })
                .borderRadius({ topLeft: 6, topRight: 6 })
                .animation({ duration: 600, curve: Curve.EaseOut })
              Text(`${line.year}`)
                .fontSize(11)
                .fontColor(AppColors.TEXT_SECONDARY)
                .margin({ top: 6 })
              Text(line.major.length > 4 ? line.major.substring(0, 4) + '..' : line.major)
                .fontSize(9)
                .fontColor(AppColors.TEXT_HINT)
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.End)
            .layoutWeight(1)
          }, (line: ScoreLine, index: number) => `bar_${line.year}_${index}`)
        }
        .width('100%')
        .height(140)
        .margin({ top: 12 })
        .alignItems(VerticalAlign.Bottom)

        // 分割线
        Divider()
          .color(AppColors.GLASS_BORDER)
          .margin({ top: 12, bottom: 12 })

        // 分数线表格
        // 表头
        Row() {
          Text('年份')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width(45)
          Text('专业')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .layoutWeight(1)
          Text('最低')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width(40)
            .textAlign(TextAlign.Center)
          Text('平均')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width(40)
            .textAlign(TextAlign.Center)
          Text('最高')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width(40)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(AppColors.BACKGROUND_COLOR)
        .borderRadius(8)

        // 数据行
        ForEach(this.scoreLines, (line: ScoreLine, index: number) => {
          Row() {
            Text(line.year.toString())
              .fontSize(13)
              .fontColor(AppColors.TEXT_PRIMARY)
              .width(45)
            Text(line.major)
              .fontSize(13)
              .fontColor(AppColors.TEXT_PRIMARY)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(line.minScore.toString())
              .fontSize(13)
              .fontColor(AppColors.ERROR_COLOR)
              .fontWeight(FontWeight.Medium)
              .width(40)
              .textAlign(TextAlign.Center)
            Text(line.avgScore.toString())
              .fontSize(13)
              .fontColor(AppColors.WARNING_COLOR)
              .width(40)
              .textAlign(TextAlign.Center)
            Text(line.maxScore.toString())
              .fontSize(13)
              .fontColor(AppColors.SUCCESS_COLOR)
              .width(40)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 10, bottom: 10 })
        }, (line: ScoreLine, idx: number) => `${line.year}_${line.major}_${idx}`)
      }
      .width('100%')
      .padding(16)
      .margin({ top: 12 })
      .borderRadius(16)
      .backgroundColor(AppColors.GLASS_LIGHT)
      .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
      .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
      .shadow(LiquidGlass.SHADOW_CONTAINER)
      .alignItems(HorizontalAlign.Start)
    }
  }
}
