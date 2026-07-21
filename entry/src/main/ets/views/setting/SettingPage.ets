// 设置页面 — 用户信息 + 个人设置 + 通用设置 + 关于
import { AppColors, RouteNames } from '../../common/Constants';
import { KimiGradient, LiquidGlass } from '../../common/DesignTokens';
import { NavHeader } from '../../components/NavHeader';
import { userStore } from '../../stores/UserStore';
import { appStore } from '../../stores/AppStore';
import { userService } from '../../services/UserService';
import { authService } from '../../services/AuthService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'SettingPage';

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
  @Local isEditingName: boolean = false;
  @Local nameInput: string = '';
  @Local isEditingSignature: boolean = false;
  @Local signatureInput: string = '';
  @Local isSaving: boolean = false;
  @Local isLoggingOut: boolean = false;
  @Local isPickingAvatar: boolean = false;

  aboutToAppear(): void {
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
    // 从后端拉取最新用户资料
    this.loadProfile();
  }

  private async loadProfile(): Promise<void> {
    if (!appStore.isLoggedIn) {
      return;
    }
    try {
      await userService.fetchProfile();
    } catch (e) {
      console.warn('[SettingPage] 加载用户资料失败: ' + (e as Error).message);
    }
  }

  private async onSaveSignature(): Promise<void> {
    userStore.signature = this.signatureInput;
    this.isSaving = true;
    try {
      await userService.updateProfile();
      this.isEditingSignature = false;
    } catch (e) {
      console.warn('[SettingPage] 保存资料失败: ' + (e as Error).message);
    } finally {
      this.isSaving = false;
    }
  }

  private async onSaveName(): Promise<void> {
    const trimmed: string = this.nameInput.trim();
    if (trimmed.length === 0) {
      return;
    }
    appStore.nickname = trimmed;
    this.isSaving = true;
    try {
      await userService.updateProfile();
      this.isEditingName = false;
    } catch (e) {
      console.warn('[SettingPage] 保存昵称失败: ' + (e as Error).message);
    } finally {
      this.isSaving = false;
    }
  }

  private async onPickAvatar(): Promise<void> {
    if (this.isPickingAvatar) {
      return;
    }
    this.isPickingAvatar = true;
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const result: photoAccessHelper.PhotoSelectResult = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      const uris: Array<string> = result.photoUris;
      if (uris.length > 0) {
        appStore.avatar = uris[0];
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, '头像选择失败: %{public}s', (e as Error).message);
    } finally {
      this.isPickingAvatar = false;
    }
  }

  private async onLogout(): Promise<void> {
    if (this.isLoggingOut) {
      return;
    }
    this.isLoggingOut = true;
    authService.logout();
    this.isLoggingOut = false;
    this.pathStack.pop();
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
              // 头像 — 可点击更换
              Stack({ alignContent: Alignment.BottomEnd }) {
                if (appStore.avatar.length > 0) {
                  Image(appStore.avatar)
                    .width(64)
                    .height(64)
                    .borderRadius(32)
                    .objectFit(ImageFit.Cover)
                } else {
                  Column() {
                    Text(appStore.nickname.length > 0 ? appStore.nickname.substring(0, 1).toUpperCase() : 'JM')
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
                }
                // 相机图标 — 换头像入口
                Column() {
                  SymbolGlyph($r('sys.symbol.plus'))
                    .fontSize(12)
                    .fontColor([$r('app.color.moon_text_primary')])
                }
                .width(22)
                .height(22)
                .borderRadius(11)
                .backgroundColor($r('app.color.moon_card_bg'))
                .border({ width: 1.5, color: $r('app.color.moon_card_border') })
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width(72)
              .height(72)
              .onClick(() => {
                this.onPickAvatar();
              })

              // 名称 + 签名
              Column({ space: 6 }) {
                Text(appStore.nickname || '觉明同学')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.moon_text_primary'))
                  .onClick(() => {
                    this.nameInput = appStore.nickname;
                    this.isEditingName = true;
                  })

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
            }
            .width('100%')
            .padding(20)
            .backgroundBlurStyle(LiquidGlass.CONTAINER_BLUR)
            .backgroundEffect({
              radius: LiquidGlass.CONTAINER_RADIUS,
              saturation: LiquidGlass.CONTAINER_SATURATION,
              brightness: LiquidGlass.CONTAINER_BRIGHTNESS,
              color: LiquidGlass.CONTAINER_COLOR
            })
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .borderRadius(16)
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .margin({ left: 16, right: 16, top: 12 })
            .alignItems(VerticalAlign.Center)

            // === 昵称编辑区域（点击昵称后展开） ===
            if (this.isEditingName) {
              Row({ space: 8 }) {
                TextInput({ text: this.nameInput, placeholder: '输入你的昵称' })
                  .fontSize(14)
                  .layoutWeight(1)
                  .backgroundColor($r('app.color.moon_input_bg'))
                  .borderRadius(12)
                  .padding({ left: 12, right: 12 })
                  .maxLength(20)
                  .onChange((value: string) => {
                    this.nameInput = value;
                  })

                Button(this.isSaving ? '保存中...' : '保存')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor($r('app.color.brand_primary'))
                  .borderRadius(12)
                  .height(40)
                  .padding({ left: 16, right: 16 })
                  .enabled(!this.isSaving)
                  .onClick(() => {
                    this.onSaveName();
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundBlurStyle(LiquidGlass.CONTAINER_BLUR)
              .backgroundEffect({
                radius: LiquidGlass.CONTAINER_RADIUS,
                saturation: LiquidGlass.CONTAINER_SATURATION,
                brightness: LiquidGlass.CONTAINER_BRIGHTNESS,
                color: LiquidGlass.CONTAINER_COLOR
              })
              .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
              .borderRadius(16)
              .shadow(LiquidGlass.SHADOW_CONTAINER)
              .margin({ left: 16, right: 16, top: 8 })
              .alignItems(VerticalAlign.Center)
            }

            // === 签名编辑区域（点击签名后展开） ===
            if (this.isEditingSignature) {
              Row({ space: 8 }) {
                TextInput({ text: this.signatureInput, placeholder: '输入你的个性签名' })
                  .fontSize(14)
                  .layoutWeight(1)
                  .backgroundColor($r('app.color.moon_input_bg'))
                  .borderRadius(12)
                  .padding({ left: 12, right: 12 })
                  .onChange((value: string) => {
                    this.signatureInput = value;
                  })

                Button(this.isSaving ? '保存中...' : '保存')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor($r('app.color.brand_primary'))
                  .borderRadius(12)
                  .height(40)
                  .padding({ left: 16, right: 16 })
                  .enabled(!this.isSaving)
                  .onClick(() => {
                    this.onSaveSignature();
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundBlurStyle(LiquidGlass.CONTAINER_BLUR)
              .backgroundEffect({
                radius: LiquidGlass.CONTAINER_RADIUS,
                saturation: LiquidGlass.CONTAINER_SATURATION,
                brightness: LiquidGlass.CONTAINER_BRIGHTNESS,
                color: LiquidGlass.CONTAINER_COLOR
              })
              .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
              .borderRadius(16)
              .shadow(LiquidGlass.SHADOW_CONTAINER)
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
            .backgroundBlurStyle(LiquidGlass.CONTAINER_BLUR)
            .backgroundEffect({
              radius: LiquidGlass.CONTAINER_RADIUS,
              saturation: LiquidGlass.CONTAINER_SATURATION,
              brightness: LiquidGlass.CONTAINER_BRIGHTNESS,
              color: LiquidGlass.CONTAINER_COLOR
            })
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .borderRadius(16)
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .margin({ left: 16, right: 16, top: 24, bottom: 32 })
            .onClick(() => {
              this.onLogout();
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
              .strokeWidth(1)
              .margin({ left: 16 })
          }
        }, (item: SettingItem) => item.label)
      }
      .width('100%')
      .backgroundBlurStyle(LiquidGlass.CONTAINER_BLUR)
      .backgroundEffect({
        radius: LiquidGlass.CONTAINER_RADIUS,
        saturation: LiquidGlass.CONTAINER_SATURATION,
        brightness: LiquidGlass.CONTAINER_BRIGHTNESS,
        color: LiquidGlass.CONTAINER_COLOR
      })
      .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
      .borderRadius(16)
      .shadow(LiquidGlass.SHADOW_CONTAINER)
      .clip(true)
    }
    .width('100%')
    .margin({ left: 16, right: 16, top: 24 })
  }
}
