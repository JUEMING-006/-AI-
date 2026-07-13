// 政策信息数据模型
@ObservedV2
export class PolicyInfo {
  @Trace id: string = '';
  @Trace title: string = '';
  @Trace summary: string = '';
  @Trace province: string = '';
  @Trace category: string = ''; // 'notice' | 'policy' | 'outline'
  @Trace publishDate: string = '';
  @Trace content: string = '';
  @Trace source: string = '';
}

// 资格检测结果模型
@ObservedV2
export class QualificationResult {
  @Trace isQualified: boolean = false;
  @Trace message: string = '';
  @Trace suggestions: string[] = [];
}

// 资格检测请求数据接口
export interface QualificationCheckData {
  province: string;
  specialty: string;
  grade: string;
  household: string;
}
