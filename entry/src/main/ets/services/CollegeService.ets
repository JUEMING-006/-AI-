// [BACKEND] 后端调用已注释，当前使用前端 mock 数据
import { CollegeInfo, ScoreLine, MajorMatch, CollegeFilter } from '../models/CollegeModel';
// [BACKEND] import { httpClient } from './HttpClient';
// [BACKEND] import type { AxiosResponse } from '@ohos/axios';
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
    hilog.info(DOMAIN, TAG, '[MOCK] getColleges: province=%{public}s type=%{public}s keyword=%{public}s',
      filter.province, filter.type, filter.keyword);
    // [BACKEND] const response: AxiosResponse<Record<string, Object>[]> = await httpClient.get('/colleges', { params });
    // [BACKEND] return rawData.map(d => toCollegeInfo(d));
    return getMockColleges(filter);
  }

  /** GET /colleges/{id} — 获取院校详情 */
  async getCollegeDetail(id: string): Promise<CollegeInfo> {
    hilog.info(DOMAIN, TAG, '[MOCK] getCollegeDetail: id=%{public}s', id);
    // [BACKEND] const response: AxiosResponse<Record<string, Object>> = await httpClient.get(`/colleges/${id}`);
    // [BACKEND] return toCollegeInfo(response.data);
    const list: CollegeInfo[] = getMockColleges({ province: '', type: '', keyword: '' });
    for (const c of list) {
      if (c.id === id) {
        return c;
      }
    }
    return list[0];
  }

  /** GET /colleges/{id}/score-lines — 获取历年分数线 */
  async getScoreLines(collegeId: string): Promise<ScoreLine[]> {
    hilog.info(DOMAIN, TAG, '[MOCK] getScoreLines: collegeId=%{public}s', collegeId);
    // [BACKEND] const response = await httpClient.get(`/colleges/${collegeId}/score-lines`);
    return getMockScoreLines();
  }

  /** GET /majors/match — 专业匹配 */
  async matchMajors(specialty: string): Promise<MajorMatch> {
    hilog.info(DOMAIN, TAG, '[MOCK] matchMajors: specialty=%{public}s', specialty);
    // [BACKEND] const response = await httpClient.get('/majors/match', { params: { specialty } });
    // [BACKEND] return toMajorMatch(response.data);
    const m = new MajorMatch();
    m.specialtyName = specialty;
    m.matchedMajors = ['计算机科学与技术', '软件工程', '网络工程', '信息安全', '数据科学与大数据技术'];
    return m;
  }

  /** POST/DELETE /user/favorites — 切换收藏状态 */
  async toggleFavorite(collegeId: string, isFavorite: boolean): Promise<void> {
    hilog.info(DOMAIN, TAG, '[MOCK] toggleFavorite: collegeId=%{public}s isFavorite=%{public}s',
      collegeId, `${isFavorite}`);
    // [BACKEND] const requestBody: FavoriteRequest = { collegeId };
    // [BACKEND] if (isFavorite) { await httpClient.post('/user/favorites', requestBody); }
    // [BACKEND] else { await httpClient.delete('/user/favorites', { data: requestBody }); }
    // mock：不做任何事
  }
}

// ── mock 数据 ──

function getMockColleges(filter: CollegeFilter): CollegeInfo[] {
  const all: CollegeInfo[] = [];
  const data: Array<[string, string, string, string, string, string]> = [
    ['college_001', '华南师范大学', '广东', '广州', '公办', '一本'],
    ['college_002', '广东技术师范大学', '广东', '广州', '公办', '一本'],
    ['college_003', '岭南师范学院', '广东', '湛江', '公办', '二本'],
    ['college_004', '韩山师范学院', '广东', '潮州', '公办', '二本'],
    ['college_005', '广东石油化工学院', '广东', '茂名', '公办', '二本'],
    ['college_006', '深圳技术大学', '广东', '深圳', '公办', '一本'],
    ['college_007', '广州软件学院', '广东', '广州', '民办', '二本'],
    ['college_008', '广东理工学院', '广东', '肇庆', '民办', '二本'],
  ];
  for (const item of data) {
    const c = new CollegeInfo();
    c.id = item[0];
    c.name = item[1];
    c.province = item[2];
    c.city = item[3];
    c.type = item[4];
    c.level = item[5];
    c.address = item[3] + '市' + item[1] + '校区';
    c.phone = '020-12345678';
    c.website = 'https://www.example.edu.cn';
    c.isFavorite = false;
    c.logoUrl = '';
    all.push(c);
  }
  // 筛选
  let result: CollegeInfo[] = all;
  if (filter.province !== '') {
    result = result.filter((c: CollegeInfo) => c.province === filter.province);
  }
  if (filter.type !== '') {
    result = result.filter((c: CollegeInfo) => c.type === filter.type);
  }
  if (filter.keyword !== '') {
    result = result.filter((c: CollegeInfo) => c.name.includes(filter.keyword));
  }
  return result;
}

function getMockScoreLines(): ScoreLine[] {
  const lines: ScoreLine[] = [];
  const years: number[] = [2023, 2024, 2025];
  const majors: string[] = ['计算机科学与技术', '软件工程', '网络工程'];
  for (const year of years) {
    for (const major of majors) {
      const s = new ScoreLine();
      s.year = year;
      s.major = major;
      s.minScore = 180 + Math.floor(Math.random() * 30);
      s.avgScore = s.minScore + 15;
      s.maxScore = s.minScore + 40;
      s.enrollCount = 50 + Math.floor(Math.random() * 50);
      lines.push(s);
    }
  }
  return lines;
}

export const collegeService: CollegeService = CollegeService.getInstance();
