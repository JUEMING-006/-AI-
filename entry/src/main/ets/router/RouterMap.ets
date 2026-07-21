import { RouteNames } from '../common/Constants';
import { CollegePage } from '../views/college/CollegePage';
import { CollegeDetailPage } from '../views/college/CollegeDetailPage';
import { CollegeFilterPage } from '../views/college/CollegeFilterPage';
import { CollegeComparePage } from '../views/college/CollegeComparePage';
import { StudyPlanPage } from '../views/study/StudyPlanPage';
import { DailyTaskPage } from '../views/study/DailyTaskPage';
import { ProgressPage } from '../views/study/ProgressPage';
import { VolunteerPage } from '../views/volunteer/VolunteerPage';
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
import { SettingPage } from '../views/setting/SettingPage';

// 路由映射 @Builder 函数，供 Navigation.navDestination 使用
// 所有页面组件均已自带 NavDestination，此处直接调用即可
@Builder
export function routerMap(name: string) {
  if (name === RouteNames.POLICY_DETAIL) {
    PolicyDetailPage()
  } else if (name === RouteNames.QUALIFICATION_CHECK) {
    QualificationCheckPage()
  } else if (name === RouteNames.COLLEGE_LIST) {
    CollegePage()
  } else if (name === RouteNames.COLLEGE_DETAIL) {
    CollegeDetailPage()
  } else if (name === RouteNames.COLLEGE_FILTER) {
    CollegeFilterPage()
  } else if (name === RouteNames.COLLEGE_COMPARE) {
    CollegeComparePage()
  } else if (name === RouteNames.STUDY_PLAN) {
    StudyPlanPage()
  } else if (name === RouteNames.DAILY_TASK) {
    DailyTaskPage()
  } else if (name === RouteNames.PROGRESS) {
    ProgressPage()
  } else if (name === RouteNames.SCORE_INPUT) {
    ScoreInputPage()
  } else if (name === RouteNames.VOLUNTEER_MAIN) {
    VolunteerPage()
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
  } else if (name === RouteNames.SETTING) {
    SettingPage()
  }
}
