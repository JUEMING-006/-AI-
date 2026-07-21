import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class AppStore {
  @Trace isLoading: boolean = false;
  @Trace isLoggedIn: boolean = false;
  @Trace token: string = '';
  @Trace userId: string = '';
  @Trace phone: string = '';
  @Trace nickname: string = '';
  @Trace avatar: string = '';  // 用户头像URI（空则显示默认Logo）
}

// 连接 AppStorageV2，全局共享应用状态
export const appStore: AppStore = AppStorageV2.connect(AppStore, 'appStore', () => new AppStore())!;
