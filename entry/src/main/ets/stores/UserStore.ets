import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class UserStore {
  @Trace province: string = '';         // 用户所在省份
  @Trace specialty: string = '';        // 专科专业
  @Trace targetCollegeId: string = '';  // 目标院校ID
  @Trace targetCollegeName: string = ''; // 目标院校名称
  @Trace examDate: string = '';         // 考试日期 'YYYY-MM-DD'
  @Trace signature: string = '热爱学习，追求卓越'; // 用户签名
}

// 连接 AppStorageV2，全局共享用户状态
export const userStore: UserStore = AppStorageV2.connect(UserStore, 'userStore', () => new UserStore())!;
