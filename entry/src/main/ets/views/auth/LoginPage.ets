import { AppColors } from '../../common/Constants';
import { FontSize, Spacing, Radius } from '../../common/DesignTokens';
import { authService } from '../../services/AuthService';
import { NavHeader } from '../../components/NavHeader';

@ComponentV2
export struct LoginPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();

  @Local phone: string = '';
  @Local code: string = '';
  @Local errorMessage: string = '';
  @Local isSendingCode: boolean = false;
  @Local isLoggingIn: boolean = false;
  @Local countdown: number = 0;

  private timerId: number = -1;

  aboutToAppear(): void {
    console.info('[LoginPage] 页面开始渲染');
  }

  aboutToDisappear(): void {
    console.info('[LoginPage] 页面销毁');
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  private isValidPhone(phone: string): boolean {
    return phone.length === 11 && phone.startsWith('1');
  }

  private canSendCode(): boolean {
    return this.isValidPhone(this.phone) && this.countdown === 0 && !this.isSendingCode;
  }

  private canLogin(): boolean {
    return this.isValidPhone(this.phone) && this.code.length === 6 && !this.isLoggingIn;
  }

  private startCountdown(): void {
    this.countdown = 60;
    this.timerId = setTimeout(() => {
      this.tickCountdown();
    }, 1000);
  }

  private tickCountdown(): void {
    this.countdown--;
    if (this.countdown > 0) {
      this.timerId = setTimeout(() => {
        this.tickCountdown();
      }, 1000);
    } else {
      this.timerId = -1;
    }
  }

  private async onSendCode(): Promise<void> {
    if (!this.isValidPhone(this.phone)) {
      this.errorMessage = '请输入正确的手机号';
      return;
    }
    this.errorMessage = '';
    this.isSendingCode = true;
    try {
      const devCode: string = await authService.sendCode(this.phone);
      if (devCode !== '') {
        this.code = devCode;
      }
      this.startCountdown();
    } catch (e) {
      this.errorMessage = '验证码发送失败，请稍后重试';
    } finally {
      this.isSendingCode = false;
    }
  }

  private async onLogin(): Promise<void> {
    if (!this.canLogin()) {
      return;
    }
    this.errorMessage = '';
    this.isLoggingIn = true;
    try {
      await authService.verifyCode(this.phone, this.code);
      this.pathStack.pop();
    } catch (e) {
      this.errorMessage = '验证码错误或已过期';
    } finally {
      this.isLoggingIn = false;
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '登录' })

        Scroll() {
          Column() {
          // ========== 顶部渐变区域 ==========
          Column() {
            // 图标
            Text('🎓')
              .fontSize(60)
              .margin({ top: 60 })

            // 标题
            Text('鸿蒙AI指导者')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 20 })

            // 副标题
            Text('您的智能升本助手')
              .fontSize(16)
              .fontColor('#80FFFFFF')
              .margin({ top: 10 })
          }
          .width('100%')
          .height(220)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
          })

          // ========== 表单区域 ==========
          Column({ space: 20 }) {
            // 手机号输入框
            Column() {
              Row({ space: 10 }) {
                Text('📱')
                  .fontSize(20)

                TextInput({ placeholder: '请输入手机号', text: this.phone })
                  .type(InputType.PhoneNumber)
                  .maxLength(11)
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .onChange((value: string) => {
                    this.phone = value;
                    this.errorMessage = '';
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .border({ width: 1, color: '#E5E5EA' })

            // 验证码输入框
            Row({ space: 10 }) {
              TextInput({ placeholder: '验证码', text: this.code })
                .type(InputType.Number)
                .maxLength(6)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.code = value;
                  this.errorMessage = '';
                })

              Text(this.countdown > 0 ? `${this.countdown}s` : (this.isSendingCode ? '发送中...' : '获取验证码'))
                .fontSize(14)
                .fontColor(this.canSendCode() ? '#007AFF' : '#AEAEB2')
                .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                .onClick(() => {
                  if (this.canSendCode()) {
                    this.onSendCode();
                  }
                })
            }
            .width('100%')
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .border({ width: 1, color: '#E5E5EA' })
            .alignItems(VerticalAlign.Center)

            // 错误信息
            if (this.errorMessage !== '') {
              Text(this.errorMessage)
                .fontSize(14)
                .fontColor('#FF3B30')
                .width('100%')
                .textAlign(TextAlign.Start)
            }

            // 登录按钮
            Button(this.isLoggingIn ? '登录中...' : '登 录')
              .width('100%')
              .height(50)
              .fontSize(18)
              .fontColor(Color.White)
              .backgroundColor(this.canLogin() ? '#007AFF' : '#AEAEB2')
              .borderRadius(25)
              .enabled(this.canLogin())
              .onClick(() => {
                this.onLogin();
              })

            // 底部提示
            Text('登录即代表同意用户协议和隐私政策')
              .fontSize(12)
              .fontColor('#AEAEB2')
              .margin({ top: 20 })
          }
          .width('100%')
          .padding({ left: 30, right: 30, top: 30, bottom: 30 })
          .backgroundColor('#F5F5F7')
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor('#F5F5F7')
  }
}
