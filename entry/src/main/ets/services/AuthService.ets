import { httpClient } from './HttpClient';
import type { AxiosResponse } from '@ohos/axios';
import { appStore } from '../stores/AppStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'AuthService';

// ── 请求/响应接口定义 ──

interface SendCodeRequest {
  phone: string;
}

interface VerifyCodeRequest {
  phone: string;
  code: string;
}

interface SendCodeResponse {
  success: boolean;
  code: string;
}

interface UserInfo {
  userId: string;
  phone: string;
  nickname: string;
  avatar: string;
  province: string;
  specialty: string;
  targetCollegeId: string;
  targetCollegeName: string;
  examDate: string;
}

interface AuthResponse {
  token: string;
  user: UserInfo;
}

class AuthService {
  /** POST /auth/send-code — 发送验证码，返回验证码明文（开发阶段） */
  async sendCode(phone: string): Promise<string> {
    hilog.info(DOMAIN, TAG, 'sendCode: phone=%{public}s', phone);
    const body: SendCodeRequest = { phone: phone };
    const response: AxiosResponse<SendCodeResponse> = await httpClient.post('/auth/send-code', body);
    return response.data.code;
  }

  /** POST /auth/verify-code — 验证码登录，成功后写入 appStore */
  async verifyCode(phone: string, code: string): Promise<void> {
    hilog.info(DOMAIN, TAG, 'verifyCode: phone=%{public}s', phone);
    const body: VerifyCodeRequest = { phone: phone, code: code };
    const response: AxiosResponse<AuthResponse> = await httpClient.post('/auth/verify-code', body);
    const data: AuthResponse = response.data;
    appStore.token = data.token;
    appStore.isLoggedIn = true;
    appStore.userId = data.user.userId;
    appStore.phone = data.user.phone;
    appStore.nickname = data.user.nickname;
    hilog.info(DOMAIN, TAG, 'verifyCode success: userId=%{public}s', data.user.userId);
  }

  /** 退出登录 — 清空 appStore 中的用户状态 */
  logout(): void {
    hilog.info(DOMAIN, TAG, 'logout');
    appStore.token = '';
    appStore.isLoggedIn = false;
    appStore.userId = '';
    appStore.phone = '';
    appStore.nickname = '';
  }
}

export const authService = new AuthService();
