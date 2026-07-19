// 底部输入区 — 快捷功能坞 + 胶囊输入容器 + 附件/发送按钮 + AI生成提示
// 极简轻量化设计：微投影悬浮胶囊，无生硬边框
import { ChatFontSize, KimiGradient } from '../../common/DesignTokens';
import { AppColors, RouteNames } from '../../common/Constants';

interface QuickAction {
  label: string;
  icon: Resource;
  route: string;
  color: string;
}

const QUICK_ACTIONS: QuickAction[] = [
  { label: '院校库', icon: $r('sys.symbol.building'), route: RouteNames.COLLEGE_DETAIL, color: '#FF9500' },
  { label: '志愿填报', icon: $r('sys.symbol.bookmark'), route: RouteNames.VOLUNTEER_RESULT, color: '#34C759' },
  { label: '学习计划', icon: $r('sys.symbol.calendar'), route: RouteNames.STUDY_PLAN, color: '#007AFF' },
  { label: '政策资讯', icon: $r('sys.symbol.doc'), route: RouteNames.POLICY_DETAIL, color: '#AF52DE' },
];

@ComponentV2
export struct ChatInputBar {
  @Param onSend: (content: string) => void = (_c: string) => {};
  @Param onPlusClick: () => void = () => {};
  @Param onNavigate: (route: string) => void = (_r: string) => {};
  @Param disabled: boolean = false;
  @Local inputValue: string = '';

  build() {
    Column() {
      // 快捷功能坞 — 横向滑动胶囊按钮
      Scroll() {
        Row({ space: 8 }) {
          ForEach(QUICK_ACTIONS, (item: QuickAction) => {
            Button() {
              Row({ space: 4 }) {
                SymbolGlyph(item.icon)
                  .fontSize(14)
                  .fontColor([item.color])
                Text(item.label)
                  .fontSize(13)
                  .fontColor($r('app.color.moon_text_primary'))
              }
            }
            .type(ButtonType.Normal)
            .height(32)
            .padding({ left: 12, right: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 4, color: '#15000000', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              this.onNavigate(item.route);
            })
          }, (item: QuickAction) => item.route)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 8 })

      // 输入容器 — 集成式布局，附件按钮+输入框+发送按钮在同一行
      Row() {
        // 附件按钮 — 点击触发回调
        Button() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(18)
            .fontColor([$r('app.color.moon_text_secondary')])
        }
        .type(ButtonType.Circle)
        .width(32)
        .height(32)
        .backgroundColor('#E8E8E8')
        .shadow({ radius: 4, color: '#15000000', offsetX: 0, offsetY: 2 })
        .borderRadius(16)
        .margin({ right: 8 })
        .onClick(() => {
          this.onPlusClick();
        })

        // 输入框
        TextArea({ text: this.inputValue, placeholder: '有问题尽管问我...' })
          .fontSize(ChatFontSize.BODY)
          .fontColor($r('app.color.moon_text_primary'))
          .placeholderColor($r('app.color.moon_text_hint'))
          .placeholderFont({ size: ChatFontSize.BODY })
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding({ left: 0, right: 0, top: 8, bottom: 8 })
          .constraintSize({ minHeight: 36, maxHeight: 100 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.inputValue = value;
          })

        // 发送按钮（有内容时）或语音按钮（无内容时）
        if (this.inputValue.trim().length > 0 && !this.disabled) {
          Button() {
            SymbolGlyph($r('sys.symbol.arrow_up'))
              .fontSize(16)
              .fontColor(['#FFFFFF'])
          }
          .type(ButtonType.Circle)
          .width(30)
          .height(30)
          .linearGradient({
            angle: KimiGradient.ANGLE,
            colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
          })
          .shadow({ radius: 4, color: '#20000000', offsetX: 0, offsetY: 2 })
          .margin({ left: 8 })
          .onClick(() => {
            const content: string = this.inputValue.trim();
            if (content.length > 0 && !this.disabled) {
              this.onSend(content);
              this.inputValue = '';
            }
          })
        } else {
          // 语音按钮
          Button() {
            SymbolGlyph($r('sys.symbol.mic'))
              .fontSize(16)
              .fontColor([$r('app.color.moon_text_hint')])
          }
          .type(ButtonType.Circle)
          .width(30)
          .height(30)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 4, color: '#15000000', offsetX: 0, offsetY: 2 })
          .borderRadius(15)
          .margin({ left: 8 })
        }
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .backgroundEffect({
        radius: 30,
        saturation: 2.0,
        brightness: 1.05,
        color: '#30FFFFFF'
      })
      .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 3 })
      .borderRadius(20)
      .margin({ left: 16, right: 16 })

      // AI生成提示文字
      Text('内容由AI生成')
        .fontSize(11)
        .fontColor($r('app.color.moon_text_hint'))
        .margin({ top: 6 })
    }
    .width('100%')
    .padding({ top: 6, bottom: 8 })
    .backgroundColor(Color.Transparent)
  }
}
