/**
 * 本地开发环境 API 配置
 * 
 * 此文件不会提交到 Git，可安全配置本地开发参数
 */

export class ApiConfigEnv {
  // 本地后端服务地址
  static readonly BASE_URL: string = 'http://localhost:8000';
  
  // API 路径前缀
  static readonly API_PREFIX: string = '/api/v1';
  
  // 请求超时时间（毫秒）
  static readonly TIMEOUT: number = 10000;
  
  // 本地开发启用调试模式
  static readonly DEBUG_MODE: boolean = true;
  
  // 后端未完成时使用 Mock 数据
  static readonly USE_MOCK_DATA: boolean = true;
  
  // 本地开发 API 密钥
  static readonly API_KEY: string = '';
}
