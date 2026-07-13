@ObservedV2
export class StudyPhase {
  @Trace name: string = '';
  @Trace startDate: string = '';
  @Trace endDate: string = '';
  @Trace progress: number = 0;
  @Trace description: string = '';
}

@ObservedV2
export class DailyTask {
  @Trace id: string = '';
  @Trace title: string = '';
  @Trace subject: string = '';
  @Trace estimatedMinutes: number = 0;
  @Trace isCompleted: boolean = false;
  @Trace completedAt: string = '';
}

@ObservedV2
export class StudyProgress {
  @Trace weeklyCompletionRates: number[] = [];
  @Trace totalTasks: number = 0;
  @Trace completedTasks: number = 0;
  @Trace currentStreak: number = 0;
  @Trace weekDates: string[] = [];
}

@ObservedV2
export class GapAnalysis {
  @Trace targetScore: number = 0;
  @Trace currentEstimate: number = 0;
  @Trace gap: number = 0;
  @Trace targetCollegeName: string = '';
  @Trace daysRemaining: number = 0;
}
