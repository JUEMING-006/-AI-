import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class AppStore {
  @Trace isLoading: boolean = false;
  @Trace isLoggedIn: boolean = false;
  @Trace token: string = '';
}

// 连接 AppStorageV2，全局共享应用状态
export const appStore: AppStore = AppStorageV2.connect(AppStore, 'appStore', () => new AppStore())!;
