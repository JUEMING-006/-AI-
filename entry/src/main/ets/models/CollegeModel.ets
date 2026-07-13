@ObservedV2
export class CollegeInfo {
  @Trace id: string = '';
  @Trace name: string = '';
  @Trace province: string = '';
  @Trace city: string = '';
  @Trace type: string = '';       // '公办' | '民办' | '职业本科'
  @Trace level: string = '';      // '一本' | '二本'
  @Trace address: string = '';
  @Trace phone: string = '';
  @Trace website: string = '';
  @Trace isFavorite: boolean = false;
  @Trace logoUrl: string = '';
}

@ObservedV2
export class ScoreLine {
  @Trace year: number = 0;
  @Trace major: string = '';
  @Trace minScore: number = 0;
  @Trace avgScore: number = 0;
  @Trace maxScore: number = 0;
  @Trace enrollCount: number = 0;
}

@ObservedV2
export class MajorMatch {
  @Trace specialtyName: string = '';   // 专科专业名
  @Trace matchedMajors: string[] = []; // 可报本科专业列表
}

// 筛选条件
export interface CollegeFilter {
  province: string;
  type: string;
  keyword: string;
}
