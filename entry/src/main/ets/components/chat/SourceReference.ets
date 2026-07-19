// 引用来源展示 — 左侧品牌蓝色条 + 标题和描述
// 遵循Kimi设计规范：左侧强调色条，浅色背景
import { SourceRef } from '../../models/ChatModel';
import { ChatFontSize, Spacing } from '../../common/DesignTokens';

@ComponentV2
export struct SourceReference {
  @Param sources: SourceRef[] = [];

  build() {
    if (this.sources.length > 0) {
      Column({ space: 8 }) {
        ForEach(this.sources, (source: SourceRef, index: number) => {
          Row() {
            // 左侧品牌蓝色条
            Column()
              .width(3)
              .height('100%')
              .backgroundColor($r('app.color.brand_primary'))

            // 内容区
            Column() {
              Text(source.title)
                .fontSize(ChatFontSize.SOURCE)
                .fontColor($r('app.color.brand_primary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(source.description)
                .fontSize(ChatFontSize.SOURCE_DESC)
                .fontColor($r('app.color.moon_text_secondary'))
                .margin({ top: 3 })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .padding({ left: Spacing.MD })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10, left: 10, right: 14 })
          .borderRadius(8)
          .backgroundColor($r('app.color.moon_source_bg'))
          .clip(true)
        }, (source: SourceRef, index: number) => `${index}_${source.title}`)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
    }
  }
}
