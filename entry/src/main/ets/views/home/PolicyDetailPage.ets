import { AppColors } from '../../common/Constants';
import { PolicyInfo } from '../../models/PolicyModel';
import { policyService } from '../../services/PolicyService';

// 政策详情页内容组件（NavDestination 由 RouterMap 提供）
@ComponentV2
export struct PolicyDetailPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Param policyId: string = '';
  @Local policy: PolicyInfo = new PolicyInfo();
  @Local isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadDetail();
  }

  private async loadDetail(): Promise<void> {
    this.isLoading = true;
    try {
      this.policy = await policyService.getPolicyDetail(this.policyId);
    } catch (_e) {
      this.policy.title = '加载失败';
      this.policy.content = '无法获取政策详情，请检查网络后重试。';
    }
    this.isLoading = false;
  }

  private getCategoryLabel(category: string): string {
    if (category === 'notice') {
      return '通知';
    } else if (category === 'policy') {
      return '政策';
    }
    return '大纲';
  }

  private getCategoryColor(category: string): string {
    if (category === 'notice') {
      return AppColors.PRIMARY_COLOR;
    } else if (category === 'policy') {
      return AppColors.SUCCESS_COLOR;
    }
    return AppColors.WARNING_COLOR;
  }

  build() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(48)
          .height(48)
          .color(AppColors.PRIMARY_COLOR)
        Text('加载中...')
          .fontSize(14)
          .fontColor(AppColors.TEXT_HINT)
          .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      Scroll() {
        Column() {
          // 标题区
          Column({ space: 8 }) {
            Row() {
              Text(this.getCategoryLabel(this.policy.category))
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor(this.getCategoryColor(this.policy.category))
                .borderRadius(4)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            }

            Text(this.policy.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY)
              .width('100%')

            Row({ space: 16 }) {
              Text(`发布时间：${this.policy.publishDate}`)
                .fontSize(13)
                .fontColor(AppColors.TEXT_HINT)
              Text(`来源：${this.policy.source}`)
                .fontSize(13)
                .fontColor(AppColors.TEXT_HINT)
            }
            .width('100%')
            .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.CARD_COLOR)
          .borderRadius(12)

          // 分割线
          Divider()
            .color(AppColors.DIVIDER_COLOR)
            .margin({ top: 12, bottom: 12, left: 16, right: 16 })

          // 正文内容
          Column() {
            Text(this.policy.content)
              .fontSize(15)
              .fontColor(AppColors.TEXT_PRIMARY)
              .lineHeight(26)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.CARD_COLOR)
          .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(AppColors.BACKGROUND_COLOR)
    }
  }
}
