import { CollegeInfo, ScoreLine, MajorMatch, CollegeFilter } from '../models/CollegeModel';

// Mock 院校数据
const MOCK_COLLEGES: CollegeInfo[] = [
  buildCollege('c001', '广东技术师范大学', '广东', '广州', '公办', '二本',
    '广州市天河区中山大道西293号', '020-38256888', 'https://www.gpnu.edu.cn'),
  buildCollege('c002', '广州大学', '广东', '广州', '公办', '一本',
    '广州市番禺区大学城外环西路230号', '020-39366068', 'https://www.gzhu.edu.cn'),
  buildCollege('c003', '深圳技术大学', '广东', '深圳', '公办', '二本',
    '深圳市坪山区兰田路3002号', '0755-23598888', 'https://www.sztu.edu.cn'),
  buildCollege('c004', '广东白云学院', '广东', '广州', '民办', '二本',
    '广州市白云区江高镇学苑路1号', '020-36095240', 'https://www.baiyunu.edu.cn'),
  buildCollege('c005', '广州城市理工学院', '广东', '广州', '民办', '二本',
    '广州市花都区赤坭镇学府路1号', '020-86719888', 'https://www.gcu.edu.cn'),
  buildCollege('c006', '深圳职业技术大学', '广东', '深圳', '职业本科', '二本',
    '深圳市南山区留仙大道7098号', '0755-26731717', 'https://www.szpt.edu.cn'),
  buildCollege('c007', '广东轻工职业技术大学', '广东', '广州', '职业本科', '二本',
    '广州市海珠区新港西路152号', '020-61230888', 'https://www.gdqy.edu.cn'),
  buildCollege('c008', '仲恺农业工程学院', '广东', '广州', '公办', '二本',
    '广州市海珠区纺织路东沙街24号', '020-89003030', 'https://www.zhku.edu.cn'),
  buildCollege('c009', '五邑大学', '广东', '江门', '公办', '二本',
    '江门市蓬江区迎宾大道中99号', '0750-3296888', 'https://www.wyu.edu.cn'),
  buildCollege('c010', '广州南方学院', '广东', '广州', '民办', '二本',
    '广州市从化区温泉镇南学院路1号', '020-61787333', 'https://www.nfu.edu.cn'),
];

// Mock 分数线数据
const MOCK_SCORE_LINES: Map<string, ScoreLine[]> = new Map<string, ScoreLine[]>([
  ['c001', [
    buildScoreLine(2025, '计算机科学与技术', 385, 402, 438, 120),
    buildScoreLine(2025, '软件工程', 378, 395, 425, 90),
    buildScoreLine(2024, '计算机科学与技术', 372, 390, 420, 110),
    buildScoreLine(2024, '软件工程', 365, 382, 415, 85),
    buildScoreLine(2023, '计算机科学与技术', 360, 378, 410, 100),
  ]],
  ['c002', [
    buildScoreLine(2025, '计算机科学与技术', 420, 445, 478, 150),
    buildScoreLine(2025, '电子信息工程', 410, 432, 465, 130),
    buildScoreLine(2024, '计算机科学与技术', 408, 430, 462, 140),
    buildScoreLine(2024, '电子信息工程', 398, 420, 450, 120),
    buildScoreLine(2023, '计算机科学与技术', 395, 418, 448, 135),
  ]],
  ['c003', [
    buildScoreLine(2025, '物联网工程', 400, 418, 450, 80),
    buildScoreLine(2025, '智能制造工程', 392, 410, 440, 70),
    buildScoreLine(2024, '物联网工程', 388, 405, 435, 75),
    buildScoreLine(2024, '智能制造工程', 380, 398, 428, 65),
    buildScoreLine(2023, '物联网工程', 375, 392, 420, 60),
  ]],
]);

// 默认分数线（为没有专属数据的院校使用）
const DEFAULT_SCORE_LINES: ScoreLine[] = [
  buildScoreLine(2025, '统招专升本', 330, 355, 400, 200),
  buildScoreLine(2024, '统招专升本', 320, 345, 390, 180),
  buildScoreLine(2023, '统招专升本', 310, 335, 380, 170),
];

function buildCollege(
  id: string, name: string, province: string, city: string,
  type: string, level: string, address: string, phone: string, website: string
): CollegeInfo {
  const c = new CollegeInfo();
  c.id = id;
  c.name = name;
  c.province = province;
  c.city = city;
  c.type = type;
  c.level = level;
  c.address = address;
  c.phone = phone;
  c.website = website;
  c.isFavorite = false;
  c.logoUrl = '';
  return c;
}

function buildScoreLine(
  year: number, major: string, minScore: number,
  avgScore: number, maxScore: number, enrollCount: number
): ScoreLine {
  const s = new ScoreLine();
  s.year = year;
  s.major = major;
  s.minScore = minScore;
  s.avgScore = avgScore;
  s.maxScore = maxScore;
  s.enrollCount = enrollCount;
  return s;
}

/**
 * 院校库服务 — 预留 FastAPI 接口，暂返回 Mock 数据
 */
export class CollegeService {
  private static instance: CollegeService;

  static getInstance(): CollegeService {
    if (!CollegeService.instance) {
      CollegeService.instance = new CollegeService();
    }
    return CollegeService.instance;
  }

  /** GET /api/v1/colleges — 获取院校列表（支持筛选） */
  getColleges(filter: CollegeFilter): Promise<CollegeInfo[]> {
    let result: CollegeInfo[] = MOCK_COLLEGES.slice();
    if (filter.province !== '') {
      result = result.filter((c: CollegeInfo) => c.province === filter.province);
    }
    if (filter.type !== '') {
      result = result.filter((c: CollegeInfo) => c.type === filter.type);
    }
    if (filter.keyword !== '') {
      const kw: string = filter.keyword.toLowerCase();
      result = result.filter((c: CollegeInfo) => c.name.toLowerCase().includes(kw));
    }
    return Promise.resolve(result);
  }

  /** GET /api/v1/colleges/{id} — 获取院校详情 */
  getCollegeDetail(id: string): Promise<CollegeInfo> {
    const found: CollegeInfo | undefined = MOCK_COLLEGES.find((c: CollegeInfo) => c.id === id);
    if (found) {
      return Promise.resolve(found);
    }
    return Promise.reject(new Error(`院校 ${id} 不存在`));
  }

  /** GET /api/v1/colleges/{id}/score-lines — 获取历年分数线 */
  getScoreLines(collegeId: string): Promise<ScoreLine[]> {
    const lines: ScoreLine[] | undefined = MOCK_SCORE_LINES.get(collegeId);
    return Promise.resolve(lines ?? DEFAULT_SCORE_LINES);
  }

  /** GET /api/v1/majors/match — 专业匹配 */
  matchMajors(specialty: string): Promise<MajorMatch> {
    const match = new MajorMatch();
    match.specialtyName = specialty;
    match.matchedMajors = ['计算机科学与技术', '软件工程', '信息管理与信息系统', '数据科学与大数据技术'];
    return Promise.resolve(match);
  }

  /** POST/DELETE /api/v1/user/favorites — 切换收藏状态 */
  toggleFavorite(collegeId: string, isFavorite: boolean): Promise<void> {
    const found: CollegeInfo | undefined = MOCK_COLLEGES.find((c: CollegeInfo) => c.id === collegeId);
    if (found) {
      found.isFavorite = isFavorite;
    }
    return Promise.resolve();
  }
}

export const collegeService: CollegeService = CollegeService.getInstance();
