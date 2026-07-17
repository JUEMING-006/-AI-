import { CollegeInfo, ScoreLine, MajorMatch, CollegeFilter } from '../models/CollegeModel';
import { httpClient } from './HttpClient';
import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'CollegeService';

// ── 请求接口定义 ──
interface FavoriteRequest {
  collegeId: string;
}

// ── JSON → Model 映射（确保返回 @ObservedV2 实例，@Trace 响应式生效）──

function toCollegeInfo(d: Record<string, Object>): CollegeInfo {
  const c = new CollegeInfo();
  c.id = d['id'] as string;
  c.name = d['name'] as string;
  c.province = d['province'] as string;
  c.city = d['city'] as string;
  c.type = d['type'] as string;
  c.level = d['level'] as string;
  c.address = d['address'] as string;
  c.phone = d['phone'] as string;
  c.website = d['website'] as string;
  c.isFavorite = d['isFavorite'] as boolean;
  c.logoUrl = d['logoUrl'] as string;
  return c;
}

function toScoreLine(d: Record<string, Object>): ScoreLine {
  const s = new ScoreLine();
  s.year = d['year'] as number;
  s.major = d['major'] as string;
  s.minScore = d['minScore'] as number;
  s.avgScore = d['avgScore'] as number;
  s.maxScore = d['maxScore'] as number;
  s.enrollCount = d['enrollCount'] as number;
  return s;
}

function toMajorMatch(d: Record<string, Object>): MajorMatch {
  const m = new MajorMatch();
  m.specialtyName = d['specialtyName'] as string;
  m.matchedMajors = d['matchedMajors'] as string[];
  return m;
}

/**
 * 院校库服务 — 调用 FastAPI 后端
 */
export class CollegeService {
  private static instance: CollegeService;

  static getInstance(): CollegeService {
    if (!CollegeService.instance) {
      CollegeService.instance = new CollegeService();
    }
    return CollegeService.instance;
  }

  /** GET /colleges — 获取院校列表（支持筛选） */
  async getColleges(filter: CollegeFilter): Promise<CollegeInfo[]> {
    const params: Record<string, string> = {};
    if (filter.province !== '') {
      params['province'] = filter.province;
    }
    if (filter.type !== '') {
      params['type'] = filter.type;
    }
    if (filter.keyword !== '') {
      params['keyword'] = filter.keyword;
    }
    hilog.info(DOMAIN, TAG, 'getColleges: province=%{public}s type=%{public}s keyword=%{public}s',
      filter.province, filter.type, filter.keyword);
    const response: AxiosResponse<Record<string, Object>[]> = await httpClient.get('/colleges', { params: params });
    const rawData: Record<string, Object>[] = response.data;
    return rawData.map((d: Record<string, Object>) => toCollegeInfo(d));
  }

  /** GET /colleges/{id} — 获取院校详情 */
  async getCollegeDetail(id: string): Promise<CollegeInfo> {
    hilog.info(DOMAIN, TAG, 'getCollegeDetail: id=%{public}s', id);
    const response: AxiosResponse<Record<string, Object>> = await httpClient.get(`/colleges/${id}`);
    return toCollegeInfo(response.data);
  }

  /** GET /colleges/{id}/score-lines — 获取历年分数线 */
  async getScoreLines(collegeId: string): Promise<ScoreLine[]> {
    hilog.info(DOMAIN, TAG, 'getScoreLines: collegeId=%{public}s', collegeId);
    const response: AxiosResponse<Record<string, Object>[]> = await httpClient.get(`/colleges/${collegeId}/score-lines`);
    const rawData: Record<string, Object>[] = response.data;
    return rawData.map((d: Record<string, Object>) => toScoreLine(d));
  }

  /** GET /majors/match — 专业匹配 */
  async matchMajors(specialty: string): Promise<MajorMatch> {
    hilog.info(DOMAIN, TAG, 'matchMajors: specialty=%{public}s', specialty);
    const response: AxiosResponse<Record<string, Object>> = await httpClient.get('/majors/match', { params: { specialty: specialty } });
    return toMajorMatch(response.data);
  }

  /** POST/DELETE /user/favorites — 切换收藏状态 */
  async toggleFavorite(collegeId: string, isFavorite: boolean): Promise<void> {
    hilog.info(DOMAIN, TAG, 'toggleFavorite: collegeId=%{public}s isFavorite=%{public}s',
      collegeId, `${isFavorite}`);
    const requestBody: FavoriteRequest = { collegeId: collegeId };
    if (isFavorite) {
      await httpClient.post('/user/favorites', requestBody);
    } else {
      await httpClient.delete('/user/favorites', { data: requestBody });
    }
  }
}

export const collegeService: CollegeService = CollegeService.getInstance();
