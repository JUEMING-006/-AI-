import { AppColors } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows } from '../../common/DesignTokens';
import { CollegeInfo, ScoreLine } from '../../models/CollegeModel';
import { collegeService } from '../../services/CollegeService';
import { LoadingView } from '../../components/LoadingView';
import { NavHeader } from '../../components/NavHeader';

// 数值对比行标签（用于判断是否高亮）
const NUMERIC_ROW_LABELS: string[] = ['最低分', '平均分', '最高分', '招生总人数'];

// 对比数据项
@ObservedV2
class CompareItem {
  @Trace college: CollegeInfo = new CollegeInfo();
  @Trace minScore: number = 0;
  @Trace avgScore: number = 0;
  @Trace maxScore: number = 0;
  @Trace totalEnroll: number = 0;
}

@ComponentV2
export struct CollegeComparePage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local compareItems: CompareItem[] = [];
  @Local isLoading: boolean = true;
  // 记录每个数值行中差异最大的院校索引（-1 表示无需高亮）
  @Local highlightIndices: Record<string, number> = {};

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '院校对比' })

        if (this.isLoading) {
          LoadingView({ message: '加载对比数据...' })
        } else if (this.compareItems.length > 0) {
          Scroll() {
          Column() {
            // 对比表格
            this.compareTable()
          }
          .width('100%')
          .padding(Spacing.LG)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .onReady((context: NavDestinationContext) => {
      const param: Record<string, Object> | undefined = context.pathInfo.param as Record<string, Object> | undefined;
      if (param !== null && param !== undefined) {
        const ids: string[] = param['ids'] as string[];
        if (ids !== undefined && ids !== null && ids.length > 0) {
          this.loadCompareData(ids);
        }
      }
    })
  }

  private loadCompareData(ids: string[]): void {
    this.isLoading = true;
    const promises: Promise<CompareItem>[] = ids.map((id: string): Promise<CompareItem> => {
      return Promise.all([
        collegeService.getCollegeDetail(id),
        collegeService.getScoreLines(id),
      ]).then((results: [CollegeInfo, ScoreLine[]]) => {
        const item = new CompareItem();
        item.college = results[0];
        const lines: ScoreLine[] = results[1];
        if (lines.length > 0) {
          item.minScore = lines[0].minScore;
          item.avgScore = lines[0].avgScore;
          item.maxScore = lines[0].maxScore;
          item.totalEnroll = lines.reduce((sum: number, l: ScoreLine) => sum + l.enrollCount, 0);
        }
        return item;
      });
    });

    Promise.all(promises).then((items: CompareItem[]) => {
      this.compareItems = items;
      this.computeHighlights();
      this.isLoading = false;
    });
  }

  // 计算每个数值行中差异最大的院校索引
  private computeHighlights(): void {
    if (this.compareItems.length < 2) {
      this.highlightIndices = {};
      return;
    }
    const result: Record<string, number> = {};
    // 最低分
    result['最低分'] = this.findMaxIndex(this.compareItems.map((item: CompareItem) => item.minScore));
    // 平均分
    result['平均分'] = this.findMaxIndex(this.compareItems.map((item: CompareItem) => item.avgScore));
    // 最高分
    result['最高分'] = this.findMaxIndex(this.compareItems.map((item: CompareItem) => item.maxScore));
    // 招生总人数
    result['招生总人数'] = this.findMaxIndex(this.compareItems.map((item: CompareItem) => item.totalEnroll));
    this.highlightIndices = result;
  }

  // 找差值最大的：max - min > 0 时返回 max 的索引，否则返回 -1
  private findMaxIndex(values: number[]): number {
    if (values.length < 2) {
      return -1;
    }
    let maxVal: number = values[0];
    let maxIdx: number = 0;
    let minVal: number = values[0];
    for (let i: number = 1; i < values.length; i++) {
      if (values[i] > maxVal) {
        maxVal = values[i];
        maxIdx = i;
      }
      if (values[i] < minVal) {
        minVal = values[i];
      }
    }
    return (maxVal - minVal > 0) ? maxIdx : -1;
  }

  private isHighlightRow(label: string): boolean {
    return NUMERIC_ROW_LABELS.indexOf(label) >= 0;
  }

  // 对比表格
  @Builder
  compareTable() {
    Column() {
      // 表头行：浅灰底 + 深色文字
      Row() {
        Text('对比项')
          .fontSize(FontSize.CAPTION)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .width(70)
        ForEach(this.compareItems, (item: CompareItem) => {
          Text(item.college.name)
            .fontSize(FontSize.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }, (item: CompareItem, index: number) => `header_${index}`)
      }
      .width('100%')
      .padding({ left: Spacing.SM, right: Spacing.SM, top: Spacing.MD, bottom: Spacing.MD })
      .backgroundColor(AppColors.BACKGROUND_COLOR)
      .borderRadius({ topLeft: Radius.MD, topRight: Radius.MD })

      // 对比行（传入行索引实现交替底色）
      this.compareRow('院校类型', this.compareItems.map((item: CompareItem) => item.college.type), 0)
      this.compareRow('层次', this.compareItems.map((item: CompareItem) => item.college.level), 1)
      this.compareRow('省份', this.compareItems.map((item: CompareItem) => item.college.province), 2)
      this.compareRow('最低分', this.compareItems.map((item: CompareItem) => item.minScore.toString()), 3)
      this.compareRow('平均分', this.compareItems.map((item: CompareItem) => item.avgScore.toString()), 4)
      this.compareRow('最高分', this.compareItems.map((item: CompareItem) => item.maxScore.toString()), 5)
      this.compareRow('招生总人数', this.compareItems.map((item: CompareItem) => item.totalEnroll.toString()), 6)
      this.compareRow('地址', this.compareItems.map((item: CompareItem) => item.college.city), 7)
      this.compareRow('联系电话', this.compareItems.map((item: CompareItem) => item.college.phone), 8)
    }
    .width('100%')
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.MD)
    .shadow(Shadows.CARD)
    .clip(true)
  }

  @Builder
  compareRow(label: string, values: string[], rowIndex: number) {
    Row() {
      Text(label)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width(70)
      ForEach(values, (value: string, index: number) => {
        Text(value)
          .fontSize(FontSize.BODY)
          .fontColor(this.isHighlightRow(label) && this.highlightIndices[label] === index
            ? AppColors.PRIMARY_COLOR
            : AppColors.TEXT_PRIMARY)
          .fontWeight(this.isHighlightRow(label) && this.highlightIndices[label] === index
            ? FontWeight.Medium
            : FontWeight.Normal)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }, (value: string, index: number) => `row_${label}_${index}`)
    }
    .width('100%')
    .padding({ left: Spacing.SM, right: Spacing.SM, top: 10, bottom: 10 })
    .backgroundColor(rowIndex % 2 === 0 ? '#F8F9FE' : '#FFFFFF')
    .border({ width: { top: 0.5 }, color: AppColors.DIVIDER_COLOR })
  }
}
