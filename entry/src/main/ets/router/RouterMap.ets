import { RouteNames } from '../common/Constants';
import { NavHeader } from '../components/NavHeader';
import { CollegeDetailPage } from '../views/college/CollegeDetailPage';
import { CollegeFilterPage } from '../views/college/CollegeFilterPage';
import { CollegeComparePage } from '../views/college/CollegeComparePage';
import { DailyTaskPage } from '../views/study/DailyTaskPage';
import { ProgressPage } from '../views/study/ProgressPage';
import { VolunteerResultPage } from '../views/volunteer/VolunteerResultPage';
import { PolicyDetailPage } from '../views/home/PolicyDetailPage';
import { QualificationCheckPage } from '../views/home/QualificationCheckPage';
import { ScoreInputPage } from '../views/volunteer/ScoreInputPage';
import { LoginPage } from '../views/auth/LoginPage';
import { VolunteerFormPage } from '../views/volunteer/VolunteerFormPage';
import { ScoreLinePage } from '../views/volunteer/ScoreLinePage';
import { VolunteerDiagnosePage } from '../views/volunteer/VolunteerDiagnosePage';
import { MajorDetailPage } from '../views/volunteer/MajorDetailPage';
import { CollegeVolunteerPage } from '../views/volunteer/CollegeVolunteerPage';

// 学习计划占位组件（Tab 页已有完整实现，此处供快捷入口路由使用）
@ComponentV2
struct StudyPlanPlaceholder {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '学习计划' })

        // 占位文字在剩余内容区居中
        Column() {
          Text('学习计划').fontSize(20).fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}

// 路由映射 @Builder 函数，供 Navigation.navDestination 使用
// 所有页面组件均已自带 NavDestination，此处直接调用即可
@Builder
export function routerMap(name: string) {
  if (name === RouteNames.POLICY_DETAIL) {
    PolicyDetailPage()
  } else if (name === RouteNames.QUALIFICATION_CHECK) {
    QualificationCheckPage()
  } else if (name === RouteNames.COLLEGE_DETAIL) {
    CollegeDetailPage()
  } else if (name === RouteNames.COLLEGE_FILTER) {
    CollegeFilterPage()
  } else if (name === RouteNames.COLLEGE_COMPARE) {
    CollegeComparePage()
  } else if (name === RouteNames.STUDY_PLAN) {
    StudyPlanPlaceholder()
  } else if (name === RouteNames.DAILY_TASK) {
    DailyTaskPage()
  } else if (name === RouteNames.PROGRESS) {
    ProgressPage()
  } else if (name === RouteNames.SCORE_INPUT) {
    ScoreInputPage()
  } else if (name === RouteNames.VOLUNTEER_RESULT) {
    VolunteerResultPage()
  } else if (name === RouteNames.LOGIN) {
    LoginPage()
  } else if (name === RouteNames.VOLUNTEER_FORM) {
    VolunteerFormPage()
  } else if (name === RouteNames.SCORE_LINE) {
    ScoreLinePage()
  } else if (name === RouteNames.VOLUNTEER_DIAGNOSE) {
    VolunteerDiagnosePage()
  } else if (name === RouteNames.MAJOR_DETAIL) {
    MajorDetailPage()
  } else if (name === RouteNames.COLLEGE_VOLUNTEER) {
    CollegeVolunteerPage()
  }
}
