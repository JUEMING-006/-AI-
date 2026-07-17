import { AppColors, RouteNames, ButtonStyles } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { volunteerService } from '../../services/VolunteerService';
import { CommonCard } from '../../components/CommonCard';
import { promptAction } from '@kit.ArkUI';
import { NavHeader } from '../../components/NavHeader';

// 三梯度颜色
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

// 志愿表项数据
interface VolunteerItem {
  order: number;
  collegeName: string;
  collegeType: string;
  tier: string;
  lastYearMinScore: number;
  probability: number;
}

// 梯度统计数据
interface TierStats {
  rush: number;
  stable: number;
  safe: number;
}

// 风险分析数据
interface RiskAnalysis {
  rushPercent: number;
  stablePercent: number;
  safePercent: number;
}

@ComponentV2
export struct VolunteerFormPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local volunteerList: VolunteerItem[] = [];
  @Local pressScale: number = 1.0;
  @Local pressOpacity: number = 1.0;
  @Local draggingIndex: number = -1;

  aboutToAppear(): void {
    this.loadVolunteerList();
  }

  private loadVolunteerList(): void {
    this.volunteerList = [
      { order: 1, collegeName: '深圳技术大学', collegeType: '公办', tier: '冲刺', lastYearMinScore: 320, probability: 65 },
      { order: 2, collegeName: '广州理工学院', collegeType: '民办', tier: '稳妥', lastYearMinScore: 305, probability: 80 },
      { order: 3, collegeName: '东莞理工学院', collegeType: '公办', tier: '稳妥', lastYearMinScore: 298, probability: 85 },
      { order: 4, collegeName: '佛山科学技术学院', collegeType: '公办', tier: '保底', lastYearMinScore: 290, probability: 95 }
    ];
  }

  private getTierColor(tier: string): string {
    if (tier === '冲刺') return RUSH_COLOR;
    if (tier === '稳妥') return STABLE_COLOR;
    return SAFE_COLOR;
  }

  private getTierStats(): TierStats {
    let rush = 0;
    let stable = 0;
    let safe = 0;
    for (const item of this.volunteerList) {
      if (item.tier === '冲刺') rush++;
      else if (item.tier === '稳妥') stable++;
      else safe++;
    }
    const result: TierStats = { rush: rush, stable: stable, safe: safe };
    return result;
  }

  private deleteItem(index: number): void {
    this.volunteerList.splice(index, 1);
    this.volunteerList.forEach((item: VolunteerItem, idx: number) => {
      item.order = idx + 1;
    });
  }

  private deleteWithConfirm(index: number): void {
    promptAction.showDialog({
      title: '删除确认',
      message: `确定删除「${this.volunteerList[index].collegeName}」吗？`,
      buttons: [
        { text: '取消', color: AppColors.TEXT_SECONDARY },
        { text: '删除', color: AppColors.ERROR_COLOR }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.deleteItem(index);
      }
    });
  }

  private moveUp(index: number): void {
    if (index <= 0) return;
    const list: VolunteerItem[] = [...this.volunteerList];
    const temp: VolunteerItem = list[index - 1];
    list[index - 1] = list[index];
    list[index] = temp;
    list.forEach((item: VolunteerItem, idx: number) => {
      item.order = idx + 1;
    });
    this.volunteerList = list;
  }

  private moveDown(index: number): void {
    if (index >= this.volunteerList.length - 1) return;
    const list: VolunteerItem[] = [...this.volunteerList];
    const temp: VolunteerItem = list[index + 1];
    list[index + 1] = list[index];
    list[index] = temp;
    list.forEach((item: VolunteerItem, idx: number) => {
      item.order = idx + 1;
    });
    this.volunteerList = list;
  }

  private reorderItem(from: number, to: number): void {
    if (from < 0 || to < 0 || from >= this.volunteerList.length || to >= this.volunteerList.length) return;
    const list: VolunteerItem[] = [...this.volunteerList];
    const item: VolunteerItem = list.splice(from, 1)[0];
    list.splice(to, 0, item);
    list.forEach((it: VolunteerItem, idx: number) => {
      it.order = idx + 1;
    });
    this.volunteerList = list;
  }

  private getDynamicRiskText(): string {
    const stats = this.getTierStats();
    const total = stats.rush + stats.stable + stats.safe;
    if (total === 0) return '暂无志愿数据';
    if (stats.safe === 0) return '风险较高，建议添加保底院校';
    if (stats.rush === 0 && stats.stable === 0) return '过于保守，建议尝试冲刺院校';
    if (stats.rush > stats.stable + stats.safe) return '冲刺过多，建议增加稳妥院校';
    if (stats.safe > stats.rush + stats.stable) return '保底过多，建议适当增加冲刺';
    return '梯度分布合理，方案较为稳健';
  }

  private getRiskGrade(): string {
    const stats = this.getTierStats();
    const total = stats.rush + stats.stable + stats.safe;
    if (total === 0) return '暂无';
    if (stats.safe === 0) return 'C- 风险较高';
    if (stats.rush === 0 && stats.stable === 0) return 'B- 偏保守';
    if (stats.rush > stats.stable + stats.safe) return 'B+ 偏激进';
    return 'A- 方案稳健';
  }

  private getRiskAnalysis(): RiskAnalysis {
    const stats = this.getTierStats();
    const total = stats.rush + stats.stable + stats.safe;
    if (total === 0) {
      const defaultResult: RiskAnalysis = { rushPercent: 33, stablePercent: 33, safePercent: 34 };
      return defaultResult;
    }
    const result: RiskAnalysis = {
      rushPercent: (stats.rush / total) * 100,
      stablePercent: (stats.stable / total) * 100,
      safePercent: (stats.safe / total) * 100
    };
    return result;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '我的志愿表' })

        // 顶部标题栏
        Row() {
          Text(`我的志愿表（${this.volunteerList.length}/5）`)
            .fontSize(FontSize.SUBTITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)

          Blank()

          Button('诊断')
            .height(32)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.PRIMARY_COLOR)
            .backgroundColor('#10007AFF')
            .borderRadius(Radius.BUTTON)
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_DIAGNOSE });
            })

          Button('清空')
            .height(32)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.ERROR_COLOR)
            .backgroundColor('#10FF3B30')
            .borderRadius(Radius.BUTTON)
            .margin({ left: Spacing.SM })
            .onClick(() => {
              this.volunteerList = [];
            })
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD, bottom: Spacing.MD })

        // 排序提示
        Row() {
          SymbolGlyph($r('sys.symbol.info_circle'))
            .fontSize(16)
            .fontColor([AppColors.TEXT_SECONDARY])

          Text('拖动调整志愿顺序，第1志愿优先录取')
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ left: Spacing.XS })
        }
        .width('100%')
        .padding(Spacing.SM)
        .backgroundColor('#10007AFF')
        .margin({ left: Spacing.LG, right: Spacing.LG, bottom: Spacing.MD })
        .borderRadius(Radius.SM)

        // 志愿列表
        if (this.volunteerList.length === 0) {
          this.emptyState()
        } else {
          List({ space: Spacing.SM }) {
            ForEach(this.volunteerList, (item: VolunteerItem, index: number) => {
              ListItem() {
                this.volunteerItem(item, index)
              }
              .swipeAction({
                end: {
                  builder: () => {
                    this.deleteSwipeButton(index)
                  }
                }
              })
            }, (item: VolunteerItem) => `volunteer_${item.order}`)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .padding({ left: Spacing.LG, right: Spacing.LG })
          .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
            this.draggingIndex = itemIndex;
          })
          .onItemDrop((event: ItemDragInfo, insertIndex: number) => {
            this.reorderItem(this.draggingIndex, insertIndex);
            this.draggingIndex = -1;
          })

          // 风险分析卡片
          this.riskAnalysis()

          // 底部操作按钮
          this.bottomButtons()
        }
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
  emptyState() {
    Column() {
      Stack() {
        Column()
          .width(100)
          .height(100)
          .borderRadius(50)
          .backgroundColor('#10007AFF')

        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(48)
          .fontColor([AppColors.PRIMARY_COLOR])
      }
      .width(100)
      .height(100)

      Text('还没有添加志愿')
        .fontSize(FontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ top: Spacing.LG })

      Text('去智能选志愿添加你心仪的院校')
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_HINT)
        .margin({ top: Spacing.SM })

      Button('去添加')
        .width(160)
        .height(44)
        .fontSize(FontSize.BODY)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
        })
        .borderRadius(Radius.BUTTON)
        .margin({ top: Spacing.XL })
        .onClick(() => {
          this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_RESULT });
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  deleteSwipeButton(index: number) {
    Column() {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontSize(20)
        .fontColor([Color.White])
      Text('删除')
        .fontSize(10)
        .fontColor(Color.White)
        .margin({ top: Spacing.XS })
    }
    .width(72)
    .height('100%')
    .backgroundColor(AppColors.ERROR_COLOR)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.deleteWithConfirm(index);
    })
  }

  @Builder
  volunteerItem(item: VolunteerItem, index: number) {
    Row() {
      Column() {
        Text(`${item.order}`)
          .fontSize(FontSize.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .width(32)
      .height(32)
      .borderRadius(16)
      .backgroundColor(this.getTierColor(item.tier))
      .justifyContent(FlexAlign.Center)

      Column()
        .width(4)
        .height(40)
        .backgroundColor(this.getTierColor(item.tier))
        .borderRadius(2)
        .margin({ left: Spacing.SM })

      Column() {
        Text(item.collegeName)
          .fontSize(FontSize.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)

        Row() {
          Text(item.collegeType)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)

          Text(`去年${item.lastYearMinScore}分`)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ left: Spacing.SM })

          Text(`${item.probability}%`)
            .fontSize(FontSize.CAPTION)
            .fontColor(this.getTierColor(item.tier))
            .margin({ left: Spacing.SM })
        }
        .margin({ top: Spacing.XS })

        Text(item.tier)
          .fontSize(FontSize.CAPTION)
          .fontColor(Color.White)
          .backgroundColor(this.getTierColor(item.tier))
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .margin({ top: Spacing.XS })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.SM })

      // 拖拽手柄 + 上下移动
      Column() {
        SymbolGlyph($r('sys.symbol.ellipsis_circle'))
          .fontSize(16)
          .fontColor([AppColors.TEXT_HINT])

        Row({ space: Spacing.XS }) {
          Text('▲')
            .fontSize(12)
            .fontColor(AppColors.TEXT_SECONDARY)
            .onClick(() => {
              this.moveUp(index);
            })

          Text('▼')
            .fontSize(12)
            .fontColor(AppColors.TEXT_SECONDARY)
            .onClick(() => {
              this.moveDown(index);
            })
        }
        .margin({ top: Spacing.SM })
      }
      .opacity(this.draggingIndex === index ? 0.5 : 1)
    }
    .width('100%')
    .padding(Spacing.MD)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
  }

  @Builder
  riskAnalysis() {
    Column() {
      CommonCard() {
        Column() {
          Row() {
            Text('梯度分布')
              .fontSize(FontSize.BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)

            Blank()

            Text(this.getRiskGrade())
              .fontSize(FontSize.CAPTION)
              .fontColor(STABLE_COLOR)
          }
          .width('100%')

          Row() {
            Row()
              .width(`${this.getRiskAnalysis().rushPercent}%`)
              .height(8)
              .backgroundColor(RUSH_COLOR)
              .borderRadius({ topLeft: 4, bottomLeft: 4 })

            Row()
              .width(`${this.getRiskAnalysis().stablePercent}%`)
              .height(8)
              .backgroundColor(STABLE_COLOR)

            Row()
              .width(`${this.getRiskAnalysis().safePercent}%`)
              .height(8)
              .backgroundColor(SAFE_COLOR)
              .borderRadius({ topRight: 4, bottomRight: 4 })
          }
          .width('100%')
          .margin({ top: Spacing.MD })

          Text(this.getDynamicRiskText())
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ top: Spacing.SM })
        }
        .width('100%')
      }
    }
    .margin({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD })
  }

  @Builder
  bottomButtons() {
    Row() {
      Button('志愿诊断')
        .layoutWeight(1)
        .height(48)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.PRIMARY_COLOR)
        .backgroundColor(Color.Transparent)
        .border({ width: 1.5, color: AppColors.PRIMARY_COLOR })
        .borderRadius(Radius.BUTTON)
        .onClick(() => {
          this.pathStack.pushPath({ name: RouteNames.VOLUNTEER_DIAGNOSE });
        })

      Button('确认提交')
        .layoutWeight(1)
        .height(48)
        .fontSize(FontSize.BODY)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
        })
        .borderRadius(Radius.BUTTON)
        .margin({ left: Spacing.MD })
        .enabled(this.volunteerList.length > 0)
        .onClick(() => {
          // TODO: 提交志愿表
        })
    }
    .width('100%')
    .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD, bottom: Spacing.LG })
    .backgroundColor(AppColors.CARD_COLOR)
  }
}
