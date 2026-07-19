import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, KeyboardAvoidMode } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      
      // 🌟 配置沉浸式窗口
      this.setupImmersiveWindow(windowStage);
    });
  }
  
  /**
   * 🌟 沉浸式窗口配置
   * - 全屏布局：内容延伸到状态栏和导航栏区域
   * - 系统栏透明：与背景无缝融合
   * - 安全区适配：获取并存储安全区高度
   */
  private async setupImmersiveWindow(windowStage: window.WindowStage): Promise<void> {
    try {
      const mainWindow = windowStage.getMainWindowSync();
      
      // 1. 设置全屏布局 - 内容延伸到系统栏区域
      await mainWindow.setWindowLayoutFullScreen(true);
      
      // 1.1 设置键盘避让模式为 RESIZE - 键盘弹出时只压缩页面高度，不整体上推
      // 避免顶部导航栏跟着键盘一起上升
      mainWindow.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
      
      // 2. 设置系统栏透明
      const systemBarProps: window.SystemBarProperties = {
        statusBarColor: '#00000000',        // 透明状态栏
        statusBarContentColor: '#1D1D1F',   // 深色状态栏图标（适配浅色背景）
        navigationBarColor: '#00000000',    // 透明导航栏
        navigationBarContentColor: '#1D1D1F'
      };
      await mainWindow.setWindowSystemBarProperties(systemBarProps);
      
      // 3. 获取并存储安全区域高度
      const systemAvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topHeight = mainWindow.getUIContext().px2vp(systemAvoidArea.topRect.height);
      AppStorage.setOrCreate('safeAreaTop', topHeight);
      
      const navAvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const bottomHeight = mainWindow.getUIContext().px2vp(navAvoidArea.bottomRect.height);
      AppStorage.setOrCreate('safeAreaBottom', bottomHeight);
      
      hilog.info(DOMAIN, 'testTag', 
        'Immersive window setup completed. SafeArea: top=%{public}d, bottom=%{public}d', 
        topHeight, bottomHeight);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to setup immersive window: %{public}s', JSON.stringify(err));
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}