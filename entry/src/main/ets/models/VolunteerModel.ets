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
}

@ObservedV2
export class VolunteerPlan {
  @Trace recommendations: RecommendCollege[] = [];
  @Trace rushCount: number = 0;
  @Trace stableCount: number = 0;
  @Trace safeCount: number = 0;
}
