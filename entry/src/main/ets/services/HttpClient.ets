import axios from '@ohos/axios';
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { ApiConfig } from '../common/ApiConfig';
import { appStore } from '../stores/AppStore';
import { authService } from './AuthService';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'HttpClient';

// axios 错误结构
interface AxiosErrorResponse {
  status: number;
}

interface AxiosErrorData {
  response?: AxiosErrorResponse;
  config?: InternalAxiosRequestConfig;
  message: string;
}

// 创建 axios 实例
const instance: AxiosInstance = axios.create({
  baseURL: `${ApiConfig.BASE_URL}${ApiConfig.API_PREFIX}`,
  timeout: ApiConfig.TIMEOUT
});

// token 刷新状态（防止并发刷新）
let isRefreshing: boolean = false;

// 请求拦截器：自动添加 token header
instance.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token: string = appStore.token;
    if (token !== '') {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    hilog.info(DOMAIN, TAG, 'Request: %{public}s %{public}s', config.method ?? 'GET', config.url ?? '');
    return config;
  },
  (error: Error) => {
    hilog.error(DOMAIN, TAG, 'Request error: %{public}s', error.message);
    return Promise.reject(error);
  }
);

// 响应拦截器：统一错误处理 + 401 自动刷新 token
instance.interceptors.response.use(
  (response: AxiosResponse) => {
    hilog.info(DOMAIN, TAG, 'Response status: %{public}d', response.status);
    return response;
  },
  async (error: Object) => {
    const err: AxiosErrorData = error as AxiosErrorData;
    const status: number = err.response?.status ?? 0;
    const originalConfig: InternalAxiosRequestConfig | undefined = err.config;

    hilog.error(DOMAIN, TAG, 'Response error: status=%{public}d url=%{public}s',
      status, originalConfig?.url ?? '');

    // 401 且非 refresh 请求本身 → 尝试刷新 token 并重试
    if (status === 401 && originalConfig && !originalConfig.url?.includes('/auth/refresh') && !isRefreshing) {
      isRefreshing = true;
      try {
        const ok: boolean = await authService.refreshToken();
        isRefreshing = false;
        if (ok) {
          // 更新 header 后重发原请求
          originalConfig.headers['Authorization'] = `Bearer ${appStore.token}`;
          hilog.info(DOMAIN, TAG, 'Token refreshed, retrying: %{public}s', originalConfig.url ?? '');
          return instance.request(originalConfig);
        }
      } catch (e) {
        isRefreshing = false;
        hilog.error(DOMAIN, TAG, 'Token refresh failed: %{public}s', (e as Error).message);
      }
      // 刷新失败 → 清除登录状态
      appStore.token = '';
      appStore.isLoggedIn = false;
    }

    return Promise.reject(error);
  }
);

// 导出单例 httpClient
export const httpClient: AxiosInstance = instance;
