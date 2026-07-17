import { PolicyInfo, QualificationResult, QualificationCheckData } from '../models/PolicyModel';
import { httpClient } from './HttpClient';
import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'PolicyService';

// ── JSON → Model 映射 ──

function toPolicyInfo(d: Record<string, Object>): PolicyInfo {
  const p = new PolicyInfo();
  p.id = d['id'] as string;
  p.title = d['title'] as string;
  p.summary = d['summary'] as string;
  p.province = d['province'] as string;
  p.category = d['category'] as string;
  p.publishDate = d['publishDate'] as string;
  p.content = d['content'] as string;
  p.source = d['source'] as string;
  return p;
}

function toQualificationResult(d: Record<string, Object>): QualificationResult {
  const r = new QualificationResult();
  r.isQualified = d['isQualified'] as boolean;
  r.message = d['message'] as string;
  r.suggestions = d['suggestions'] as string[];
  return r;
}

/**
 * 政策服务 — 调用 FastAPI 后端
 */
export class PolicyService {

  /** GET /policies?province= — 获取政策列表 */
  async getPolicies(province: string): Promise<PolicyInfo[]> {
    hilog.info(DOMAIN, TAG, 'getPolicies: province=%{public}s', province);
    const response: AxiosResponse<Record<string, Object>[]> = await httpClient.get('/policies', { params: { province: province } });
    const rawData: Record<string, Object>[] = response.data;
    return rawData.map((d: Record<string, Object>) => toPolicyInfo(d));
  }

  /** GET /policies/{id} — 获取政策详情 */
  async getPolicyDetail(id: string): Promise<PolicyInfo> {
    hilog.info(DOMAIN, TAG, 'getPolicyDetail: id=%{public}s', id);
    const response: AxiosResponse<Record<string, Object>> = await httpClient.get(`/policies/${id}`);
    return toPolicyInfo(response.data);
  }

  /** POST /qualification/check — 报考资格检测 */
  async checkQualification(data: QualificationCheckData): Promise<QualificationResult> {
    hilog.info(DOMAIN, TAG, 'checkQualification: province=%{public}s specialty=%{public}s',
      data.province, data.specialty);
    const response: AxiosResponse<Record<string, Object>> = await httpClient.post('/qualification/check', data);
    return toQualificationResult(response.data);
  }
}

// 导出单例
export const policyService: PolicyService = new PolicyService();
