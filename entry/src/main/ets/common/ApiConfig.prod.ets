/**
 * 生产环境 API 配置
 * 
 * 此文件不会提交到 Git，包含生产环境真实配置
 * 部署时需要手动配置此文件
 */

export class ApiConfigEnv {
  // 生产环境 API 地址（请替换为真实地址）
  static readonly BASE_URL: string = 'https://api.yourdomain.com';
  
  // API 路径前缀
  static readonly API_PREFIX: string = '/api/v1';
  
  // 请求超时时间（毫秒）
  static readonly TIMEOUT: number = 10000;
  
  // 生产环境关闭调试模式
  static readonly DEBUG_MODE: boolean = false;
  
  // 生产环境使用真实后端数据
  static readonly USE_MOCK_DATA: boolean = false;
  
  // 生产环境 API 密钥（请替换为真实密钥）
  static readonly API_KEY: string = 'your-production-api-key';
}
