import { AppColors, PROVINCE_LIST } from '../../common/Constants';
import { AnimConfig } from '../../common/AnimationHelper';
import { QualificationResult, QualificationCheckData } from '../../models/PolicyModel';
import { policyService } from '../../services/PolicyService';

// 资格检测表单页内容组件（NavDestination 由 RouterMap 提供）
@ComponentV2
export struct QualificationCheckPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local selectedProvince: string = '';
  @Local specialty: string = '';
  @Local selectedGrade: string = '大一';
  @Local household: string = '';
  @Local isChecking: boolean = false;
  @Local result: QualificationResult | null = null;
  @Local showProvinceSelect: boolean = false;
  @Local showGradeSelect: boolean = false;
  @Local specialtyFocused: boolean = false;
  @Local householdFocused: boolean = false;
  @Local isSubmitPressed: boolean = false;

  private gradeOptions: string[] = ['大一', '大二', '大三'];

  private buildCheckData(): QualificationCheckData {
    return {
      province: this.selectedProvince,
      specialty: this.specialty,
      grade: this.selectedGrade,
      household: this.household
    };
  }

  private async submitCheck(): Promise<void> {
    if (this.selectedProvince === '') {
      return;
    }
    if (this.specialty === '') {
      return;
    }
    this.isChecking = true;
    this.result = null;
    try {
      const data: QualificationCheckData = this.buildCheckData();
      this.result = await policyService.checkQualification(data);
    } catch (_e) {
      const errResult: QualificationResult = new QualificationResult();
      errResult.isQualified = false;
      errResult.message = '检测请求失败，请稍后重试。';
      errResult.suggestions = [];
      this.result = errResult;
    }
    this.isChecking = false;
  }

  // 表单项标签
  @Builder
  formLabel(text: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(AppColors.TEXT_PRIMARY)
      .margin({ bottom: 8 })
  }

  // 省份选择器
  @Builder
  provinceSelector() {
    Column() {
      this.formLabel('所在省份')
      Row() {
        Text(this.selectedProvince === '' ? '请选择省份' : this.selectedProvince)
          .fontSize(15)
          .fontColor(this.selectedProvince === '' ? AppColors.TEXT_HINT : AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
        Image($r('sys.symbol.chevron_right'))
          .width(18)
          .height(18)
          .fillColor(AppColors.TEXT_HINT)
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .backgroundColor(AppColors.BACKGROUND_COLOR)
      .borderRadius(8)
      .onClick(() => {
        this.showProvinceSelect = true;
      })

      if (this.showProvinceSelect) {
        Select(PROVINCE_LIST.map((p: string) => ({ value: p } as SelectOption)))
          .selected(0)
          .value(this.selectedProvince === '' ? '请选择省份' : this.selectedProvince)
          .font({ size: 15 })
          .onSelect((index: number) => {
            this.selectedProvince = PROVINCE_LIST[index];
            this.showProvinceSelect = false;
          })
          .width('100%')
          .margin({ top: 4 })
      }
    }
    .width('100%')
  }

  // 年级选择器
  @Builder
  gradeSelector() {
    Column() {
      this.formLabel('当前年级')
      Row() {
        Text(this.selectedGrade)
          .fontSize(15)
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
        Image($r('sys.symbol.chevron_right'))
          .width(18)
          .height(18)
          .fillColor(AppColors.TEXT_HINT)
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .backgroundColor(AppColors.BACKGROUND_COLOR)
      .borderRadius(8)
      .onClick(() => {
        this.showGradeSelect = true;
      })

      if (this.showGradeSelect) {
        Select(this.gradeOptions.map((g: string) => ({ value: g } as SelectOption)))
          .selected(this.gradeOptions.indexOf(this.selectedGrade))
          .value(this.selectedGrade)
          .font({ size: 15 })
          .onSelect((index: number) => {
            this.selectedGrade = this.gradeOptions[index];
            this.showGradeSelect = false;
          })
          .width('100%')
          .margin({ top: 4 })
      }
    }
    .width('100%')
  }

  // 结果显示区
  @Builder
  resultSection() {
    if (this.result !== null) {
      Column() {
        // 结果标识
        Row({ space: 8 }) {
          Image($r(this.result.isQualified ? 'sys.symbol.checkmark' : 'sys.symbol.xmark'))
            .width(24)
            .height(24)
            .fillColor(this.result.isQualified ? AppColors.SUCCESS_COLOR : AppColors.ERROR_COLOR)
          Text(this.result.isQualified ? '符合条件' : '不符合条件')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.result.isQualified ? AppColors.SUCCESS_COLOR : AppColors.ERROR_COLOR)
        }
        .width('100%')

        // 详细信息
        Text(this.result.message)
          .fontSize(14)
          .fontColor(AppColors.TEXT_SECONDARY)
          .lineHeight(22)
          .width('100%')
          .margin({ top: 12 })

        // 建议列表
        if (this.result.suggestions.length > 0) {
          Column() {
            Text('建议事项')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)
              .margin({ bottom: 8 })
            ForEach(this.result.suggestions, (suggestion: string, index: number) => {
              Row() {
                Text(`${index + 1}.`)
                  .fontSize(14)
                  .fontColor(AppColors.PRIMARY_COLOR)
                  .width(24)
                Text(suggestion)
                  .fontSize(14)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ top: 6 })
            })
          }
          .width('100%')
          .margin({ top: 16 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.CARD_COLOR)
      .borderRadius(12)
      .margin({ top: 16 })
    }
  }

  build() {
    Scroll() {
      Column() {
        // 页面说明
        Text('填写以下信息，检测您是否符合专升本报考条件')
          .fontSize(14)
          .fontColor(AppColors.TEXT_SECONDARY)
          .width('100%')
          .margin({ bottom: 20 })

        // 表单区域
        Column({ space: 16 }) {
          // 省份选择
          this.provinceSelector()

          // 专科专业
          Column() {
            this.formLabel('专科专业')
            TextInput({ text: this.specialty, placeholder: '请输入您的专科专业名称' })
              .fontSize(15)
              .placeholderColor(AppColors.TEXT_HINT)
              .height(44)
              .backgroundColor(AppColors.BACKGROUND_COLOR)
              .borderRadius(8)
              .border({ width: { bottom: 2 }, color: this.specialtyFocused ? AppColors.PRIMARY_COLOR : Color.Transparent })
              .onChange((value: string) => {
                this.specialty = value;
              })
              .onFocus(() => {
                this.getUIContext()?.animateTo({ duration: AnimConfig.FOCUS_ANIM_DURATION }, () => {
                  this.specialtyFocused = true;
                });
              })
              .onBlur(() => {
                this.getUIContext()?.animateTo({ duration: AnimConfig.FOCUS_ANIM_DURATION }, () => {
                  this.specialtyFocused = false;
                });
              })
          }
          .width('100%')

          // 年级选择
          this.gradeSelector()

          // 户籍所在地
          Column() {
            this.formLabel('户籍所在地')
            TextInput({ text: this.household, placeholder: '请输入户籍所在地（如：广东省广州市）' })
              .fontSize(15)
              .placeholderColor(AppColors.TEXT_HINT)
              .height(44)
              .backgroundColor(AppColors.BACKGROUND_COLOR)
              .borderRadius(8)
              .border({ width: { bottom: 2 }, color: this.householdFocused ? AppColors.PRIMARY_COLOR : Color.Transparent })
              .onChange((value: string) => {
                this.household = value;
              })
              .onFocus(() => {
                this.getUIContext()?.animateTo({ duration: AnimConfig.FOCUS_ANIM_DURATION }, () => {
                  this.householdFocused = true;
                });
              })
              .onBlur(() => {
                this.getUIContext()?.animateTo({ duration: AnimConfig.FOCUS_ANIM_DURATION }, () => {
                  this.householdFocused = false;
                });
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(AppColors.CARD_COLOR)
        .borderRadius(12)

        // 提交按钮
        Button(this.isChecking ? '检测中...' : '开始检测')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor(AppColors.PRIMARY_COLOR)
          .borderRadius(12)
          .margin({ top: 24 })
          .enabled(!this.isChecking)
          .opacity(this.isChecking ? 0.6 : (this.isSubmitPressed ? AnimConfig.BUTTON_PRESS_OPACITY : 1.0))
          .scale({ x: this.isSubmitPressed ? AnimConfig.BUTTON_PRESS_SCALE : 1.0, y: this.isSubmitPressed ? AnimConfig.BUTTON_PRESS_SCALE : 1.0 })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.getUIContext()?.animateTo({ duration: AnimConfig.BUTTON_PRESS_DURATION, curve: AnimConfig.BUTTON_PRESS_CURVE }, () => {
                this.isSubmitPressed = true;
              });
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.getUIContext()?.animateTo({ duration: AnimConfig.BUTTON_RELEASE_DURATION, curve: AnimConfig.BUTTON_RELEASE_CURVE }, () => {
                this.isSubmitPressed = false;
              });
            }
          })
          .onClick(() => {
            this.submitCheck();
          })

        // 检测结果
        this.resultSection()
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
