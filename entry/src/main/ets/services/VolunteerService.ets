import { ScoreInput, RecommendCollege, VolunteerPlan, SubjectScore } from '../models/VolunteerModel';
import { httpClient } from './HttpClient';
import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'VolunteerService';

// ── JSON → Model 映射 ──

function toRecommendCollege(d: Record<string, Object>): RecommendCollege {
  const c = new RecommendCollege();
  c.id = d['id'] as string;
  c.name = d['name'] as string;
  c.type = d['type'] as string;
  c.tier = d['tier'] as string;
  c.probability = d['probability'] as number;
  c.lastYearMinScore = d['lastYearMinScore'] as number;
  c.enrollCount = d['enrollCount'] as number;
  c.isSelected = d['isSelected'] as boolean;
  c.tuition = (d['tuition'] as number) ?? 0;
  c.major = (d['major'] as string) ?? '';
  c.city = (d['city'] as string) ?? '';
  return c;
}

function toVolunteerPlan(d: Record<string, Object>): VolunteerPlan {
  const plan = new VolunteerPlan();
  const recs = d['recommendations'] as Record<string, Object>[];
  plan.recommendations = recs.map((r: Record<string, Object>) => toRecommendCollege(r));
  plan.rushCount = d['rushCount'] as number;
  plan.stableCount = d['stableCount'] as number;
  plan.safeCount = d['safeCount'] as number;
  return plan;
}

// 将 ScoreInput 实例转为纯 JSON 对象（避免 @Trace 序列化问题）
function scoreInputToBody(scoreInput: ScoreInput): Record<string, Object> {
  const subjects: Record<string, Object>[] = scoreInput.subjects.map((s: SubjectScore) => {
    const obj: Record<string, Object> = {};
    obj['subject'] = s.subject;
    obj['score'] = s.score;
    obj['fullScore'] = s.fullScore;
    return obj;
  });
  const body: Record<string, Object> = {};
  body['subjects'] = subjects;
  body['totalScore'] = scoreInput.totalScore;
  body['province'] = scoreInput.province;
  return body;
}

@ObservedV2
export class VolunteerService {
  @Trace currentPlan: VolunteerPlan = new VolunteerPlan();
  @Trace currentScore: ScoreInput = new ScoreInput();
  @Trace isLoading: boolean = false;
  @Trace hasScore: boolean = false;

  /** POST /volunteer/match — 志愿匹配 */
  async matchVolunteer(scoreInput: ScoreInput): Promise<VolunteerPlan> {
    this.isLoading = true;
    hilog.info(DOMAIN, TAG, 'matchVolunteer: totalScore=%{public}d, province=%{public}s',
      scoreInput.totalScore, scoreInput.province);
    try {
      const body = scoreInputToBody(scoreInput);
      const response: AxiosResponse<Record<string, Object>> = await httpClient.post('/volunteer/match', body);
      const plan = toVolunteerPlan(response.data);
      this.currentPlan = plan;
      this.currentScore = scoreInput;
      this.hasScore = true;
      return plan;
    } finally {
      this.isLoading = false;
    }
  }

  /** GET /volunteer/recommend — 获取推荐列表 */
  async getRecommendations(totalScore: number, province: string): Promise<RecommendCollege[]> {
    hilog.info(DOMAIN, TAG, 'getRecommendations: totalScore=%{public}d, province=%{public}s',
      totalScore, province);
    const response: AxiosResponse<Record<string, Object>[]> = await httpClient.get('/volunteer/recommend', {
      params: { totalScore: totalScore, province: province }
    });
    const rawData: Record<string, Object>[] = response.data;
    return rawData.map((d: Record<string, Object>) => toRecommendCollege(d));
  }

  resetScore(): void {
    this.currentScore = new ScoreInput();
    this.currentPlan = new VolunteerPlan();
    this.hasScore = false;
  }
}

export const volunteerService: VolunteerService = new VolunteerService();
