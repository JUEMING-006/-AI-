import { AppColors } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { CollegeInfo, ScoreLine } from '../../models/CollegeModel';
import { collegeService } from '../../services/CollegeService';
import { LoadingView } from '../../components/LoadingView';

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
  @Local favBtnScale: number = 1.0;
  @Local favBtnOpacity: number = 1.0;
  @Local targetBtnScale: number = 1.0;
  @Local targetBtnOpacity: number = 1.0;

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
    });
  }

  private animateBars(): void {
    const chartHeight: number = 120;
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
      if (this.isLoading) {
        LoadingView({ message: '加载院校详情...' })
      } else if (this.college !== null) {
        Scroll() {
          Column() {
            // 院校基本信息卡片
            this.infoSection()
            // 历年分数线
            this.scoreSection()
            // 分数线柱状图
            if (this.scoreLines.length > 0) {
              this.scoreChartSection()
            }
            // 底部操作按钮
            this.actionSection()
          }
          .width('100%')
          .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD, bottom: Spacing.XL })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .title('院校详情')
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

  // 基本信息区域
  @Builder
  infoSection() {
    Column() {
      // 院校名称 + 类型标签
      Row() {
        Text(this.college!.name)
          .fontSize(FontSize.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
        Text(this.college!.type)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.PRIMARY_COLOR)
          .backgroundColor('#E8EDFB')
          .borderRadius(6)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      }
      .width('100%')

      // 信息行
      this.infoRow('层次', this.college!.level)
      this.infoRow('地址', this.college!.address)
      this.infoRow('电话', this.college!.phone)
      this.infoRow('官网', this.college!.website)
    }
    .width('100%')
    .padding(Spacing.LG)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width(50)
      Text(value)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: Spacing.SM })
  }

  // 分数线表格区域（保留原有表格）
  @Builder
  scoreSection() {
    Column() {
      Text('历年分数线')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ top: Spacing.XL, bottom: Spacing.MD })
        .alignSelf(ItemAlign.Start)

      // 表头
      Row() {
        Text('年份').fontSize(FontSize.CAPTION).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY).width(50)
        Text('专业').fontSize(FontSize.CAPTION).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY).layoutWeight(1)
        Text('最低分').fontSize(FontSize.CAPTION).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY).width(55).textAlign(TextAlign.Center)
        Text('平均分').fontSize(FontSize.CAPTION).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY).width(55).textAlign(TextAlign.Center)
        Text('最高分').fontSize(FontSize.CAPTION).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY).width(55).textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: Spacing.SM, right: Spacing.SM, top: Spacing.SM, bottom: Spacing.SM })
      .backgroundColor(AppColors.BACKGROUND_COLOR)
      .borderRadius(Radius.SM)

      // 数据行
      ForEach(this.scoreLines, (line: ScoreLine) => {
        Row() {
          Text(line.year.toString()).fontSize(FontSize.BODY).fontColor(AppColors.TEXT_PRIMARY).width(50)
          Text(line.major).fontSize(FontSize.BODY).fontColor(AppColors.TEXT_PRIMARY).layoutWeight(1)
          Text(line.minScore.toString()).fontSize(FontSize.BODY).fontColor(AppColors.ERROR_COLOR).width(55).textAlign(TextAlign.Center)
          Text(line.avgScore.toString()).fontSize(FontSize.BODY).fontColor(AppColors.WARNING_COLOR).width(55).textAlign(TextAlign.Center)
          Text(line.maxScore.toString()).fontSize(FontSize.BODY).fontColor(AppColors.SUCCESS_COLOR).width(55).textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ left: Spacing.SM, right: Spacing.SM, top: 10, bottom: 10 })
      }, (line: ScoreLine, index: number) => `${line.year}_${line.major}_${index}`)
    }
    .width('100%')
    .padding(Spacing.LG)
    .margin({ top: Spacing.MD })
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
  }

  // 分数线柱状图可视化
  @Builder
  scoreChartSection() {
    Column() {
      Text('分数线趋势')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: Spacing.MD })

      // 柱状图：展示前3条数据的最低分
      Row() {
        ForEach(this.scoreLines.slice(0, 3), (line: ScoreLine, index: number) => {
          Column() {
            Text(`${line.minScore}`)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.PRIMARY_COLOR)
              .fontWeight(FontWeight.Medium)
            Column()
              .width(32)
              .height(this.barHeights[index] !== undefined ? this.barHeights[index] : 0)
              .backgroundColor(index === 0 ? '#0056CC' : AppColors.PRIMARY_COLOR)
              .borderRadius({ topLeft: 4, topRight: 4 })
              .animation({ duration: 600, curve: Curve.EaseOut })
            Text(`${line.year}`)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ top: Spacing.XS })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
        }, (line: ScoreLine, index: number) => `bar_${line.year}_${index}`)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .height(160)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(Spacing.LG)
    .margin({ top: Spacing.MD })
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
  }

  // 操作按钮区域
  @Builder
  actionSection() {
    Row() {
      // 收藏按钮
      Button(this.college?.isFavorite ? '已收藏' : '收藏')
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.PRIMARY_COLOR)
        .backgroundColor(AppColors.BACKGROUND_COLOR)
        .borderRadius(20)
        .layoutWeight(1)
        .margin({ right: Spacing.SM })
        .scale({ x: this.favBtnScale, y: this.favBtnScale })
        .opacity(this.favBtnOpacity)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_PRESS_DURATION,
              curve: AnimConfig.BUTTON_PRESS_CURVE,
            }, () => {
              this.favBtnScale = AnimConfig.BUTTON_PRESS_SCALE;
              this.favBtnOpacity = AnimConfig.BUTTON_PRESS_OPACITY;
            });
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_RELEASE_DURATION,
              curve: AnimConfig.BUTTON_RELEASE_CURVE,
            }, () => {
              this.favBtnScale = 1.0;
              this.favBtnOpacity = 1.0;
            });
          }
        })
        .onClick(() => {
          this.onToggleFavorite();
        })

      // 设为目标按钮
      Button('设为目标院校')
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.CARD_COLOR)
        .linearGradient({
          angle: 135,
          colors: [[AppColors.PRIMARY_COLOR, 0], [AppColors.PRIMARY_GRADIENT_END, 1]]
        })
        .borderRadius(20)
        .layoutWeight(1)
        .margin({ left: Spacing.SM })
        .scale({ x: this.targetBtnScale, y: this.targetBtnScale })
        .opacity(this.targetBtnOpacity)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_PRESS_DURATION,
              curve: AnimConfig.BUTTON_PRESS_CURVE,
            }, () => {
              this.targetBtnScale = AnimConfig.BUTTON_PRESS_SCALE;
              this.targetBtnOpacity = AnimConfig.BUTTON_PRESS_OPACITY;
            });
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.getUIContext()?.animateTo({
              duration: AnimConfig.BUTTON_RELEASE_DURATION,
              curve: AnimConfig.BUTTON_RELEASE_CURVE,
            }, () => {
              this.targetBtnScale = 1.0;
              this.targetBtnOpacity = 1.0;
            });
          }
        })
    }
    .width('100%')
    .margin({ top: Spacing.XL })
    .height(40)
  }
}
