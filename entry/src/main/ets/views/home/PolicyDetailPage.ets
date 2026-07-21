import { AppColors } from '../../common/Constants';
import { PolicyInfo } from '../../models/PolicyModel';
import { policyService } from '../../services/PolicyService';
import { NavHeader } from '../../components/NavHeader';

// 政策页面 — 无参数时展示列表，有参数时展示详情
@ComponentV2
export struct PolicyDetailPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local policyId: string = '';
  @Local policy: PolicyInfo = new PolicyInfo();
  @Local policies: PolicyInfo[] = [];
  @Local isLoading: boolean = true;
  @Local isListMode: boolean = true;

  private async loadList(): Promise<void> {
    this.isLoading = true;
    try {
      this.policies = await policyService.getPolicies('');
    } catch (_e) {
      this.policies = [];
    }
    this.isLoading = false;
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
    NavDestination() {
      Column() {
        NavHeader({ title: this.isListMode ? '政策资讯' : '政策详情' })

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
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else if (this.isListMode) {
          // 政策列表模式
          Scroll() {
            Column({ space: 12 }) {
              ForEach(this.policies, (item: PolicyInfo) => {
                Column({ space: 8 }) {
                  Row() {
                    Text(this.getCategoryLabel(item.category))
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getCategoryColor(item.category))
                      .borderRadius(4)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    Blank()
                    Text(item.publishDate)
                      .fontSize(12)
                      .fontColor(AppColors.TEXT_HINT)
                  }
                  .width('100%')

                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(AppColors.TEXT_PRIMARY)
                    .width('100%')

                  Text(item.summary)
                    .fontSize(13)
                    .fontColor(AppColors.TEXT_SECONDARY)
                    .width('100%')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(AppColors.CARD_COLOR)
                .borderRadius(12)
                .onClick(() => {
                  this.pathStack.pushPath({ name: 'PolicyDetail', param: item.id });
                })
              }, (item: PolicyInfo) => item.id)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 24 })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .backgroundColor(AppColors.BACKGROUND_COLOR)
        } else {
          // 政策详情模式
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
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor(AppColors.BACKGROUND_COLOR)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.BACKGROUND_COLOR)
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .onReady((context: NavDestinationContext) => {
      const param = context.pathInfo.param as string | undefined;
      if (param !== null && param !== undefined && param !== '') {
        this.policyId = param;
        this.isListMode = false;
        this.loadDetail();
      } else {
        this.isListMode = true;
        this.loadList();
      }
    })
  }
}
