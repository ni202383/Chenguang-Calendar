import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { taskStore } from '../pages/Model/TaskStore';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    (async () => {
      await taskStore.init(this.context);
      console.info('TaskStore init 完成，磁盘数据已恢复');
    })();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Start', (err) => {

      windowStage.getMainWindow().then(w => {
        w.setWindowLayoutFullScreen(true)
        let topStatusBarHeight = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
        let bottomStatusBarHeight = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).bottomRect.height;
        let leftGap = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).leftRect.width
        let rightGap = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).rightRect.width
        AppStorage.setOrCreate('topStatusBarHeight', topStatusBarHeight);
        AppStorage.setOrCreate('bottomStatusBarHeight', bottomStatusBarHeight);
        AppStorage.setOrCreate('windowLeftGap',leftGap);
        AppStorage.setOrCreate('windowRightGap',rightGap);
      })

      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      PersistentStorage.PersistProps([
        { key: 'themeColor',  defaultValue: '#EA5C2E' }, // 你的默认主题色
        { key: 'isSubscribe', defaultValue: true }      // 默认未订阅
      ]);

      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      let requestEnableNotificationCallback = (err: BusinessError): void => {
        if (err) {
          hilog.error(0x0000, 'testTag', `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
        } else {
          hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
        }
      };
      notificationManager.requestEnableNotification(this.context, requestEnableNotificationCallback);
    });
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