// 设置页面 — 用户信息 + 个人设置 + 通用设置 + 关于
import { AppColors, RouteNames } from '../../common/Constants';
import { KimiGradient } from '../../common/DesignTokens';
import { NavHeader } from '../../components/NavHeader';
import { userStore } from '../../stores/UserStore';

interface SettingItem {
  icon: Resource;
  label: string;
  value: string;
  route: string;
}

@ComponentV2
export struct SettingPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local safeAreaTop: number = 0;
  @Local isEditingSignature: boolean = false;
  @Local signatureInput: string = '';

  aboutToAppear(): void {
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
  }

  private getPersonalItems(): SettingItem[] {
    return [
      { icon: $r('sys.symbol.doc'), label: '专科专业', value: userStore.specialty || '未设置', route: '' },
      { icon: $r('sys.symbol.building'), label: '目标院校', value: userStore.targetCollegeName || '未设置', route: '' },
      { icon: $r('sys.symbol.calendar'), label: '考试日期', value: userStore.examDate || '未设置', route: '' },
    ];
  }

  private getAboutItems(): SettingItem[] {
    return [
      { icon: $r('sys.symbol.checkmark'), label: '关于我们', value: '', route: '' },
      { icon: $r('sys.symbol.star'), label: '隐私政策', value: '', route: '' },
      { icon: $r('sys.symbol.doc'), label: '用户协议', value: '', route: '' },
    ];
  }

  build() {
    NavDestination() {
      Column() {
        // 导航栏
        NavHeader({ title: '设置' })

        // 内容区
        Scroll() {
          Column() {
            // === 用户信息卡片 ===
            Row({ space: 16 }) {
              // 头像
              Column() {
                Text('JM')
                  .fontSize(20)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
              }
              .width(64)
              .height(64)
              .borderRadius(32)
              .linearGradient({
                angle: KimiGradient.ANGLE,
                colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
              })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              // 名称 + VIP
              Column({ space: 6 }) {
                Row({ space: 8 }) {
                  Text('觉明同学')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.moon_text_primary'))

                  Text('VIP')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(8)
                    .linearGradient({
                      angle: KimiGradient.ANGLE,
                      colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
                    })
                }

                Text(userStore.signature || '点击设置签名')
                  .fontSize(13)
                  .fontColor($r('app.color.moon_text_secondary'))
                  .onClick(() => {
                    this.signatureInput = userStore.signature;
                    this.isEditingSignature = true;
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 右箭头
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(16)
                .fontColor([$r('app.color.moon_text_hint')])
            }
            .width('100%')
            .padding(20)
            .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
            .backgroundEffect({
              radius: 30,
              saturation: 2.0,
              brightness: 1.05,
              color: '#30FFFFFF'
            })
            .borderRadius(16)
            .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 3 })
            .margin({ left: 16, right: 16, top: 12 })
            .alignItems(VerticalAlign.Center)

            // === 签名编辑区域（点击签名后展开） ===
            if (this.isEditingSignature) {
              Row({ space: 8 }) {
                TextInput({ text: this.signatureInput, placeholder: '输入你的个性签名' })
                  .fontSize(14)
                  .layoutWeight(1)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(12)
                  .padding({ left: 12, right: 12 })
                  .onChange((value: string) => {
                    this.signatureInput = value;
                  })

                Button('保存')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#0066FF')
                  .borderRadius(12)
                  .height(40)
                  .padding({ left: 16, right: 16 })
                  .onClick(() => {
                    userStore.signature = this.signatureInput;
                    this.isEditingSignature = false;
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
              .backgroundEffect({
                radius: 30,
                saturation: 2.0,
                brightness: 1.05,
                color: '#30FFFFFF'
              })
              .borderRadius(16)
              .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 3 })
              .margin({ left: 16, right: 16, top: 8 })
              .alignItems(VerticalAlign.Center)
            }

            // === 个人信息 ===
            this.settingGroup('个人信息', this.getPersonalItems())

            // === 关于 ===
            this.settingGroup('关于', this.getAboutItems())

            // === 退出登录 ===
            Row() {
              Text('退出登录')
                .fontSize(16)
                .fontColor('#FF3B30')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(52)
            .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
            .backgroundEffect({
              radius: 30,
              saturation: 2.0,
              brightness: 1.05,
              color: '#30FFFFFF'
            })
            .borderRadius(16)
            .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 3 })
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .margin({ left: 16, right: 16, top: 24, bottom: 32 })
            .onClick(() => {
              this.pathStack.pop();
            })

            Blank().height(32)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.moon_bg_page'))
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  settingGroup(title: string, items: SettingItem[]) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor($r('app.color.moon_text_hint'))
        .margin({ left: 4, bottom: 8 })

      Column() {
        ForEach(items, (item: SettingItem, index: number) => {
          Row({ space: 12 }) {
            SymbolGlyph(item.icon)
              .fontSize(18)
              .fontColor([$r('app.color.moon_text_secondary')])

            Text(item.label)
              .fontSize(15)
              .fontColor($r('app.color.moon_text_primary'))
              .layoutWeight(1)

            if (item.value.length > 0) {
              Text(item.value)
                .fontSize(14)
                .fontColor($r('app.color.moon_text_hint'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .constraintSize({ maxWidth: 120 })
            }

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(14)
              .fontColor([$r('app.color.moon_text_hint')])
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            // 后续可扩展跳转
          })

          if (index < items.length - 1) {
            Divider()
              .color($r('app.color.moon_divider'))
              .strokeWidth(0.5)
              .margin({ left: 16 })
          }
        }, (item: SettingItem) => item.label)
      }
      .width('100%')
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .backgroundEffect({
        radius: 30,
        saturation: 2.0,
        brightness: 1.05,
        color: '#30FFFFFF'
      })
      .borderRadius(16)
      .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 3 })
      .clip(true)
    }
    .width('100%')
    .margin({ left: 16, right: 16, top: 24 })
  }
}
