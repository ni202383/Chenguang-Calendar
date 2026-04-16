import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { taskStore } from '../pages/Model/TaskStore';
import {countDownStore} from '../pages/Model/CountDownStore';
import { courseStore } from '../pages/Model/CourseStore'; // [课程导入] 初始化课程仓库。
import { examStore } from '../pages/Model/ExamStore'; // [考试导入] 初始化考试仓库。

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // [启动恢复] 提前注入课程仓库 context，避免首页首次渲染时课程区拿不到 termStartDate。
    courseStore.bindContext(this.context);
    examStore.bindContext(this.context); // [考试导入] 提前注入考试仓库 context。

    (async () => {
      await taskStore.init(this.context);
      await countDownStore.init(this.context);
      await courseStore.init(this.context);
      await examStore.init(this.context);
      AppStorage.setOrCreate('isExportCourseSchedule', courseStore.hasImportedCourse()); // [课程导入] 启动时恢复课表导入状态。
      AppStorage.setOrCreate('isExportExamSchedule', examStore.hasImportedExam()); // [考试导入] 启动时恢复考试导入状态。
      console.info('TaskStore countDownStore courseStore examStore init 完成，磁盘数据已恢复');
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
        w.setWindowSystemBarProperties({
          statusBarColor : '#00000000'
        })
        let topStatusBarHeight = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
        let bottomStatusBarHeight = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).bottomRect.height;
        let leftGap = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).leftRect.width
        let rightGap = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).rightRect.width
        AppStorage.setOrCreate('topStatusBarHeight', topStatusBarHeight);
        AppStorage.setOrCreate('bottomStatusBarHeight', bottomStatusBarHeight);
        AppStorage.setOrCreate('windowLeftGap',leftGap);
        AppStorage.setOrCreate('windowRightGap',rightGap);
      AppStorage.setOrCreate('agentRootTabIndex', 2);
      AppStorage.setOrCreate('agentRootTabVersion', 0);
      AppStorage.setOrCreate('agentCalendarJumpDate', '');
      AppStorage.setOrCreate('agentCalendarJumpViewType', 'day');
      AppStorage.setOrCreate('agentCalendarJumpVersion', 0);
      AppStorage.setOrCreate('agentFocusTaskId', '');
      AppStorage.setOrCreate('agentFocusTaskVersion', 0);
      AppStorage.setOrCreate('agentFocusCountDownId', '');
      AppStorage.setOrCreate('agentFocusCountDownVersion', 0);
      })

      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      PersistentStorage.PersistProps([
        { key: 'themeColor',  defaultValue: '#EA5C2E' },
        { key: 'isSubscribe', defaultValue: true },
        { key: 'isSetChangingNewTaskButton', defaultValue: true},
        { key: 'changingNewTaskButtonHandingStatus', defaultValue: true},
        { key: 'isExportCourseSchedule', defaultValue: false }, // [课程导入] 课表导入状态持久化。
        { key: 'isExportExamSchedule', defaultValue: false } // [考试导入] 考试导入状态持久化。
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