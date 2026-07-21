import { AppColors, RouteNames } from '../../common/Constants';
import { NavHeader } from '../../components/NavHeader';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { Duration, AnimConfig } from '../../common/AnimationHelper';
import { CollegeInfo, CollegeFilter } from '../../models/CollegeModel';
import { collegeService } from '../../services/CollegeService';
import { SearchBar } from '../../components/SearchBar';
import { TagSelector } from '../../components/TagSelector';
import { LoadingView } from '../../components/LoadingView';
import { EmptyView } from '../../components/EmptyView';

// LazyForEach 数据源
class CollegeDataSource implements IDataSource {
  private dataList: CollegeInfo[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.dataList.length;
  }

  getData(index: number): CollegeInfo {
    return this.dataList[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx: number = this.listeners.indexOf(listener);
    if (idx >= 0) {
      this.listeners.splice(idx, 1);
    }
  }

  setData(data: CollegeInfo[]): void {
    this.dataList = data;
    this.notifyReload();
  }

  private notifyReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataReloaded());
  }
}

// 路由参数
interface CollegePageRouteParam {
  id: string;
}

// 院校类型快捷筛选标签
const TYPE_TAGS: string[] = ['全部', '公办', '民办', '职业本科'];

// 院校卡片组件（独立状态管理按压/收藏动画）
@ComponentV2
struct CollegeCard {
  @Param college: CollegeInfo = new CollegeInfo();
  @Param onTap: (id: string) => void = () => {};
  @Param onToggleFavorite: (college: CollegeInfo) => void = () => {};
  @Local cardScale: number = 1.0;
  @Local cardOpacity: number = 1.0;
  @Local favScale: number = 1.0;

  private handleFavBounce(): void {
    const ctx: UIContext = this.getUIContext();
    ctx?.animateTo({ duration: Duration.FAST, curve: Curve.EaseOut }, () => {
      this.favScale = 1.3;
    });
    setTimeout(() => {
      ctx?.animateTo({ duration: Duration.FAST, curve: Curve.EaseOut }, () => {
        this.favScale = 1.0;
      });
    }, Duration.FAST);
  }

  build() {
    Row() {
      Column() {
        // 院校名称 + 类型标签
        Row() {
          Text(this.college.name)
            .fontSize(FontSize.SUBTITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .layoutWeight(1)
          Text(this.college.type)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.PRIMARY_COLOR)
            .backgroundColor('#E8EDFB')
            .borderRadius(4)
            .padding({ left: Spacing.SM, right: Spacing.SM, top: 2, bottom: 2 })
        }
        .width('100%')

        // 省份城市
        Text(`${this.college.province} · ${this.college.city}`)
          .fontSize(FontSize.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ top: Spacing.SM })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 收藏按钮
      Image(this.college.isFavorite ? $r('sys.symbol.checkmark') : $r('sys.symbol.star'))
        .width(24)
        .height(24)
        .fillColor(this.college.isFavorite ? AppColors.WARNING_COLOR : AppColors.TEXT_HINT)
        .scale({ x: this.favScale, y: this.favScale })
        .animation({ duration: Duration.FAST, curve: Curve.EaseOut })
        .onClick(() => {
          this.handleFavBounce();
          this.onToggleFavorite(this.college);
        })
    }
    .width('100%')
    .padding(Spacing.LG)
    .margin({ top: Spacing.MD })
    .backgroundColor(AppColors.GLASS_LIGHT)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
    .borderRadius(Radius.MD)
    .shadow(Shadows.GLASS)
    .scale({ x: this.cardScale, y: this.cardScale })
    .opacity(this.cardOpacity)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_PRESS_DURATION,
          curve: AnimConfig.LIQUID_PRESS_CURVE,
        }, () => {
          this.cardScale = AnimConfig.PRESS_SCALE;
          this.cardOpacity = AnimConfig.PRESS_OPACITY;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_RELEASE_DURATION,
          curve: AnimConfig.LIQUID_RELEASE_CURVE,
        }, () => {
          this.cardScale = 1.0;
          this.cardOpacity = 1.0;
        });
      }
    })
    .onClick(() => {
      this.onTap(this.college.id);
    })
  }
}

@ComponentV2
export struct CollegePage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local dataSource: CollegeDataSource = new CollegeDataSource();
  @Local isLoading: boolean = true;
  @Local isEmpty: boolean = false;
  @Local selectedType: string = '全部';
  @Local searchKeyword: string = '';

  aboutToAppear(): void {
    this.loadColleges();
  }

  private loadColleges(): void {
    this.isLoading = true;
    this.isEmpty = false;
    const filter: CollegeFilter = {
      province: '',
      type: this.selectedType === '全部' ? '' : this.selectedType,
      keyword: this.searchKeyword,
    };
    collegeService.getColleges(filter).then((data: CollegeInfo[]) => {
      this.dataSource.setData(data);
      this.isLoading = false;
      this.isEmpty = data.length === 0;
    });
  }

  private onSearch(keyword: string): void {
    this.searchKeyword = keyword;
    this.loadColleges();
  }

  private onTypeSelect(tag: string): void {
    this.selectedType = tag;
    this.loadColleges();
  }

  private goToDetail(id: string): void {
    const param: CollegePageRouteParam = { id: id };
    this.pathStack.pushPath({ name: RouteNames.COLLEGE_DETAIL, param: param });
  }

  private onToggleFavorite(college: CollegeInfo): void {
    const newValue: boolean = !college.isFavorite;
    collegeService.toggleFavorite(college.id, newValue).then(() => {
      college.isFavorite = newValue;
    });
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '院校库' })

        // 搜索栏
        SearchBar({
        placeholder: '搜索院校名称...',
        onSearch: (keyword: string) => {
          this.onSearch(keyword);
        }
      })
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.XS })

      // 类型快捷筛选
      TagSelector({
        tags: TYPE_TAGS,
        selectedTags: [this.selectedType],
        onTagSelect: (tag: string) => {
          this.onTypeSelect(tag);
        }
      })
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM })

      // 内容区域
      if (this.isLoading) {
        LoadingView({ message: '加载院校数据...' })
      } else if (this.isEmpty) {
        EmptyView({ message: '未找到匹配的院校' })
      } else {
        List() {
          LazyForEach(this.dataSource, (college: CollegeInfo) => {
            ListItem() {
              CollegeCard({
                college: college,
                onTap: (id: string) => {
                  this.goToDetail(id);
                },
                onToggleFavorite: (c: CollegeInfo) => {
                  this.onToggleFavorite(c);
                }
              })
            }
          }, (college: CollegeInfo) => college.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.XL, bottom: Spacing.MD })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND_COLOR)
  }
  .hideTitleBar(true)
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
