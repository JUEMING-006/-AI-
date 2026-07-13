import { RouteNames } from '../common/Constants';
import { CollegeDetailPage } from '../views/college/CollegeDetailPage';
import { CollegeFilterPage } from '../views/college/CollegeFilterPage';
import { CollegeComparePage } from '../views/college/CollegeComparePage';
import { DailyTaskPage } from '../views/study/DailyTaskPage';
import { ProgressPage } from '../views/study/ProgressPage';
import { VolunteerResultPage } from '../views/volunteer/VolunteerResultPage';
import { PolicyDetailPage } from '../views/home/PolicyDetailPage';
import { QualificationCheckPage } from '../views/home/QualificationCheckPage';
import { ScoreInputPage } from '../views/volunteer/ScoreInputPage';

// 学习计划占位组件（Tab 页已有完整实现，此处供快捷入口路由使用）
@ComponentV2
struct StudyPlanPlaceholder {
  build() {
    Column() {
      Text('学习计划').fontSize(20).fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

// 路由映射 @Builder 函数，供 Navigation.navDestination 使用
// 注意：CollegeDetailPage/CollegeFilterPage/CollegeComparePage/DailyTaskPage/ProgressPage/VolunteerResultPage
// 已自带 NavDestination，无需再次包裹
// PolicyDetailPage/QualificationCheckPage/ScoreInputPage 无自带 NavDestination，由此处包裹
@Builder
export function routerMap(name: string) {
  if (name === RouteNames.POLICY_DETAIL) {
    NavDestination() {
      PolicyDetailPage()
    }
    .title('政策详情')
  }
  if (name === RouteNames.QUALIFICATION_CHECK) {
    NavDestination() {
      QualificationCheckPage()
    }
    .title('报考资格检查')
  }
  if (name === RouteNames.COLLEGE_DETAIL) {
    CollegeDetailPage()
  }
  if (name === RouteNames.COLLEGE_FILTER) {
    CollegeFilterPage()
  }
  if (name === RouteNames.COLLEGE_COMPARE) {
    CollegeComparePage()
  }
  if (name === RouteNames.STUDY_PLAN) {
    NavDestination() {
      StudyPlanPlaceholder()
    }
    .title('学习计划')
  }
  if (name === RouteNames.DAILY_TASK) {
    DailyTaskPage()
  }
  if (name === RouteNames.PROGRESS) {
    ProgressPage()
  }
  if (name === RouteNames.SCORE_INPUT) {
    NavDestination() {
      ScoreInputPage()
    }
    .title('成绩录入')
  }
  if (name === RouteNames.VOLUNTEER_RESULT) {
    VolunteerResultPage()
  }
}
