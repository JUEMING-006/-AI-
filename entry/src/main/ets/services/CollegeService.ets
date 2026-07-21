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
    try {
      return getMockColleges(filter);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'getColleges error: %{public}s', (error as Error).message);
      return [];
    }
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

function createMockCollege(
  id: string, name: string, province: string, city: string,
  type: string, level: string, category: string,
  description: string, enrollCount: number, minScore: number,
  tags: string[], majors: string[]
): CollegeInfo {
  const c = new CollegeInfo();
  c.id = id;
  c.name = name;
  c.province = province;
  c.city = city;
  c.type = type;
  c.level = level;
  c.category = category;
  c.description = description;
  c.enrollCount = enrollCount;
  c.minScore = minScore;
  c.tags = tags;
  c.majors = majors;
  c.address = city + '市' + name + '校区';
  c.phone = '020-12345678';
  c.website = 'https://www.example.edu.cn';
  c.isFavorite = false;
  c.logoUrl = '';
  return c;
}

function getMockColleges(filter: CollegeFilter): CollegeInfo[] {
  const all: CollegeInfo[] = [];
  // ── 广东院校 ──
  all.push(createMockCollege('college_001', '华南师范大学', '广东', '广州', '公办', '一本', '师范',
    '华南师范大学是广东省人民政府和教育部共建高校，广东省属重点大学，国家“双一流”建设高校。',
    800, 220, ['师范类', '公办', '一本', '双一流'],
    ['计算机科学与技术', '软件工程', '英语', '汉语言文学', '教育学', '心理学', '数学与应用数学']));
  all.push(createMockCollege('college_002', '广东技术师范大学', '广东', '广州', '公办', '一本', '师范',
    '广东技术师范大学是广东省属普通高等院校，全国独立设置的职业技术师范院校。',
    600, 195, ['师范类', '公办', '一本'],
    ['计算机科学与技术', '电子信息工程', '机械设计制造及其自动化', '英语', '会计学']));
  all.push(createMockCollege('college_003', '岭南师范学院', '广东', '湛江', '公办', '二本', '师范',
    '岭南师范学院是一所具有百年师范教育历史的广东省属普通本科院校。',
    400, 175, ['师范类', '公办', '二本'],
    ['汉语言文学', '英语', '数学与应用数学', '小学教育', '学前教育']));
  all.push(createMockCollege('college_004', '韩山师范学院', '广东', '潮州', '公办', '二本', '师范',
    '韩山师范学院是广东省属本科师范院校，坐落于国家历史文化名城潮州市。',
    350, 170, ['师范类', '公办', '二本'],
    ['汉语言文学', '英语', '历史学', '数学与应用数学', '化学']));
  all.push(createMockCollege('college_005', '深圳技术大学', '广东', '深圳', '公办', '一本', '理工',
    '深圳技术大学是广东省深圳市的一所公立应用型本科院校，依托深圳产业优势。',
    500, 210, ['理工类', '公办', '一本', '新设'],
    ['计算机科学与技术', '软件工程', '电子信息工程', '机械设计制造及其自动化', '物联网工程']));
  all.push(createMockCollege('college_006', '广东石油化工学院', '广东', '茂名', '公办', '二本', '理工',
    '广东石油化工学院是华南地区唯一以石油化工为特色的公办本科院校。',
    300, 165, ['理工类', '公办', '二本', '特色'],
    ['化学工程与工艺', '机械设计制造及其自动化', '计算机科学与技术', '环境工程']));
  all.push(createMockCollege('college_007', '广州软件学院', '广东', '广州', '民办', '二本', '理工',
    '广州软件学院是经教育部批准设立的民办全日制普通本科院校。',
    250, 155, ['理工类', '民办', '二本'],
    ['软件工程', '计算机科学与技术', '网络工程', '数字媒体技术']));
  all.push(createMockCollege('college_008', '广东理工学院', '广东', '肇庆', '民办', '二本', '理工',
    '广东理工学院是经教育部批准的民办全日制普通本科院校。',
    200, 150, ['理工类', '民办', '二本'],
    ['机械设计制造及其自动化', '电气工程及其自动化', '计算机科学与技术']));
  // ── 湖南院校 ──
  all.push(createMockCollege('college_009', '湖南师范大学', '湖南', '长沙', '公办', '一本', '师范',
    '湖南师范大学是教育部与湖南省重点共建“双一流”建设高校。',
    700, 215, ['师范类', '公办', '一本', '双一流', '211'],
    ['计算机科学与技术', '英语', '汉语言文学', '教育学', '法学', '新闻学']));
  all.push(createMockCollege('college_010', '湖南科技大学', '湖南', '湘潭', '公办', '一本', '综合',
    '湖南科技大学是湖南省人民政府与教育部共建高校。',
    550, 190, ['综合类', '公办', '一本'],
    ['计算机科学与技术', '软件工程', '机械设计制造及其自动化', '土木工程']));
  all.push(createMockCollege('college_011', '湖南理工学院', '湖南', '岳阳', '公办', '二本', '理工',
    '湖南理工学院是湖南省属普通本科院校。',
    350, 168, ['理工类', '公办', '二本'],
    ['计算机科学与技术', '电子信息工程', '化学工程与工艺']));
  // ── 湖北院校 ──
  all.push(createMockCollege('college_012', '湖北师范大学', '湖北', '黄石', '公办', '一本', '师范',
    '湖北师范大学是湖北省属重点本科师范院校。',
    450, 185, ['师范类', '公办', '一本'],
    ['汉语言文学', '英语', '数学与应用数学', '物理学', '化学']));
  all.push(createMockCollege('college_013', '湖北工程学院', '湖北', '孝感', '公办', '二本', '综合',
    '湖北工程学院是湖北省属普通本科院校。',
    300, 160, ['综合类', '公办', '二本'],
    ['计算机科学与技术', '土木工程', '电子信息工程']));
  // ── 河南院校 ──
  all.push(createMockCollege('college_014', '河南师范大学', '河南', '新乡', '公办', '一本', '师范',
    '河南师范大学是河南省属重点大学，中西部高校基础能力建设工程高校。',
    600, 180, ['师范类', '公办', '一本'],
    ['计算机科学与技术', '英语', '数学与应用数学', '化学', '物理学']));
  all.push(createMockCollege('college_015', '河南科技大学', '河南', '洛阳', '公办', '一本', '综合',
    '河南科技大学是河南省重点建设的综合性大学。',
    500, 178, ['综合类', '公办', '一本'],
    ['机械设计制造及其自动化', '计算机科学与技术', '材料成型及控制工程']));
  // ── 山东院校 ──
  all.push(createMockCollege('college_016', '曲阜师范大学', '山东', '曲阜', '公办', '一本', '师范',
    '曲阜师范大学是山东省属重点大学，位于孔孟之乡。',
    550, 182, ['师范类', '公办', '一本'],
    ['汉语言文学', '数学与应用数学', '英语', '物理学', '历史学']));
  all.push(createMockCollege('college_017', '山东交通学院', '山东', '济南', '公办', '二本', '理工',
    '山东交通学院是山东省属普通本科院校，以交通为特色。',
    350, 162, ['理工类', '公办', '二本'],
    ['交通运输', '土木工程', '汽车服务工程', '计算机科学与技术']));
  // ── 其他省份 ──
  all.push(createMockCollege('college_018', '浙江师范大学', '浙江', '金华', '公办', '一本', '师范',
    '浙江师范大学是浙江省属重点大学，以教师教育为主。',
    500, 188, ['师范类', '公办', '一本'],
    ['计算机科学与技术', '英语', '汉语言文学', '数学与应用数学', '教育学']));
  all.push(createMockCollege('college_019', '江苏师范大学', '江苏', '徐州', '公办', '一本', '师范',
    '江苏师范大学是江苏省人民政府和教育部共建高校。',
    450, 186, ['师范类', '公办', '一本'],
    ['汉语言文学', '英语', '数学与应用数学', '历史学', '地理科学']));
  all.push(createMockCollege('college_020', '江西师范大学', '江西', '南昌', '公办', '一本', '师范',
    '江西师范大学是江西省属重点大学。',
    400, 176, ['师范类', '公办', '一本'],
    ['计算机科学与技术', '英语', '汉语言文学', '心理学', '教育学']));
  all.push(createMockCollege('college_021', '福州大学', '福建', '福州', '公办', '一本', '综合',
    '福州大学是国家“双一流”建设高校，福建省重点大学。',
    600, 205, ['综合类', '公办', '一本', '双一流', '211'],
    ['计算机科学与技术', '软件工程', '土木工程', '化学工程与工艺']));
  all.push(createMockCollege('college_022', '广西师范大学', '广西', '桂林', '公办', '一本', '师范',
    '广西师范大学是广西壮族自治区属重点大学。',
    400, 172, ['师范类', '公办', '一本'],
    ['汉语言文学', '英语', '数学与应用数学', '物理学', '化学']));
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
