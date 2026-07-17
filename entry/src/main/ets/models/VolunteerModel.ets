@ObservedV2
export class SubjectScore {
  @Trace subject: string = '';
  @Trace score: number = 0;
  @Trace fullScore: number = 150;
}

@ObservedV2
export class ScoreInput {
  @Trace subjects: SubjectScore[] = [];
  @Trace totalScore: number = 0;
  @Trace province: string = '';
}

@ObservedV2
export class RecommendCollege {
  @Trace id: string = '';
  @Trace name: string = '';
  @Trace type: string = '';
  @Trace tier: string = '';
  @Trace probability: number = 0;
  @Trace lastYearMinScore: number = 0;
  @Trace enrollCount: number = 0;
  @Trace isSelected: boolean = false;
  @Trace tuition: number = 0;
  @Trace major: string = '';
  @Trace city: string = '';
}

@ObservedV2
export class VolunteerPlan {
  @Trace recommendations: RecommendCollege[] = [];
  @Trace rushCount: number = 0;
  @Trace stableCount: number = 0;
  @Trace safeCount: number = 0;
}

// 专业简要信息（院校招生专业列表用）
@ObservedV2
export class MajorBrief {
  @Trace name: string = '';
  @Trace enrollCount: number = 0;
  @Trace lastYearScore: number = 0;
}

// 历年分数线项
@ObservedV2
export class ScoreHistoryItem {
  @Trace year: number = 0;
  @Trace score: number = 0;
}

// 专业详情数据
@ObservedV2
export class MajorDetail {
  @Trace name: string = '';
  @Trace category: string = '';
  @Trace duration: string = '2年';
  @Trace heat: number = 3;
  @Trace requirements: string[] = [];
  @Trace colleges: MajorBrief[] = [];
  @Trace jobs: string[] = [];
  @Trace salaryRange: string = '';
  @Trace enrollTrend: ScoreHistoryItem[] = [];
}

// 院校志愿详情数据
@ObservedV2
export class CollegeVolunteerDetail {
  @Trace name: string = '';
  @Trace type: string = '';
  @Trace city: string = '';
  @Trace description: string = '';
  @Trace lastYearScore: number = 0;
  @Trace enrollCount: number = 0;
  @Trace tuition: number = 0;
  @Trace ratio: string = '';
  @Trace majors: MajorBrief[] = [];
  @Trace scoreHistory: ScoreHistoryItem[] = [];
  @Trace probability: number = 0;
  @Trace tier: string = '';
}
