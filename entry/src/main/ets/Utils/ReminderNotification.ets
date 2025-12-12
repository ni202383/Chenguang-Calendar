import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RemindTime } from '../pages/Model/RemindTimeBase';
import { notificationManager } from '@kit.NotificationKit';


function pad(n: number): string {
  return n.toString().padStart(2, '0');
}

/**
 * 新增 / 修改某一天某个开始时间的所有提醒
 * - RemindTime.toMinutes() 决定提前多久
 * - notificationId = 提前的分钟数
 * - reminderId 只用于 cancelReminder，来自 publishReminder 的返回值
 */
export async function updateScheduleReminders(
  year: number,
  month: number,
  day: number,
  beginHour: number,
  beginMinute: number,
  title : string,
  remindTimeArray: Array<RemindTime>
): Promise<void> {
  const beginDate = new Date(year, month - 1, day, beginHour, beginMinute, 0, 0);
  const now = new Date();

  for (const rt of remindTimeArray) {
    // 尝试取消旧提醒（如果有系统ID）
    const oldId = rt.getRemindTimeID();
    if (oldId > 0) {
      try {
        await reminderAgentManager.cancelReminder(oldId);
        console.info(`[updateScheduleReminders] 取消旧提醒成功 id=${oldId}`);
      } catch (e) {
        const err = e as BusinessError;
        if (err.code === 1700003) {
          // 提醒本来就不存在了，可以当成功处理
          console.info(
            `[updateScheduleReminders] 旧提醒已不存在 id=${oldId}，忽略`
          );
        } else {
          console.error(
            `[updateScheduleReminders] 取消旧提醒失败 id=${oldId}, code=${err.code}, msg=${err.message}`
          );
        }
      }
    }

    const minutesBefore = rt.toMinutes();
    if (minutesBefore < 0) {
      rt.setRemindTimeID(-1);
      continue;
    }

    // 提醒触发时间 = 开始时间 - 提前分钟数
    const triggerTime = new Date(beginDate.getTime() - minutesBefore * 60 * 1000);

    // 提醒时间已经在当前时间之前了，就不用创建
    if (triggerTime <= now) {
      rt.setRemindTimeID(-1);
      continue;
    }

    const reminderReq: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      dateTime: {
        year: triggerTime.getFullYear(),
        month: triggerTime.getMonth() + 1,
        day: triggerTime.getDate(),
        hour: triggerTime.getHours(),
        minute: triggerTime.getMinutes(),
        second: triggerTime.getSeconds()
      },
      repeatMonths: [],
      repeatDays: [],
      daysOfWeek: [],

      title: '你的日程快开始啦~',
      content: rt.getRemindTime() == 0 ? `您的日程 ${title} 将在${pad(beginHour)}:${pad(beginMinute
      )}开始，已经开始啦，快去行动吧~` : `您的日程 ${title} 将在${pad(beginHour)}:${pad(beginMinute
      )}开始，还有${rt.getRemindTime()}${rt.getUnit()}啦~`,

      notificationId: minutesBefore,
      slotType : notificationManager.SlotType.CONTENT_INFORMATION,
      actionButton: [
        {
          title: '关闭',
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        }
      ],
      wantAgent: {
        pkgName: 'com.example.calendar',
        abilityName: 'com.example.calendar.EntryAbility'
      }
    };

    try {
      const reminderId = await reminderAgentManager.publishReminder(reminderReq);
      // 系统返回的 ID 在这里拿到，并写回 RemindTime
      rt.setRemindTimeID(reminderId);

      console.info(
        `[updateScheduleReminders] 创建提醒成功: offset=${rt.toString()}, reminderId=${reminderId}`
      );
    } catch (e) {
      const err = e as BusinessError;
      console.error(
        `[updateScheduleReminders] 创建提醒失败 offset=${rt.toString()}, code=${err.code}, msg=${err.message}`
      );
      rt.setRemindTimeID(-1);
    }
  }
}
