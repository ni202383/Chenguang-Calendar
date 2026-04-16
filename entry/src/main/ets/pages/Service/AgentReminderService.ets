import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Task } from '../Model/DailyTask';
import { RemindTime } from '../Model/RemindTimeBase';
import { AgentLogger } from './AgentLogger';
import { updateScheduleReminders } from '../../Utils/ReminderNotification';

export class AgentReminderService {
  private static readonly SCOPE: string = 'AgentReminderService';

  public static buildReminderListFromMinutes(minutesList: Array<number>): Array<RemindTime> {
    const result: Array<RemindTime> = [];
    const sortedMinutes: Array<number> = minutesList.slice().sort((first: number, second: number) => first - second);
    for (let index: number = 0; index < sortedMinutes.length; index++) {
      const value: number = sortedMinutes[index];
      if (value < 0) {
        continue;
      }
      const item: RemindTime = AgentReminderService.createRemindTime(value);
      result.push(item);
    }
    return result;
  }

  public static cloneReminderList(source: Array<RemindTime>): Array<RemindTime> {
    const result: Array<RemindTime> = [];
    for (let index: number = 0; index < source.length; index++) {
      const item: RemindTime = new RemindTime();
      item.setRemindTimeID(source[index].getRemindTimeID());
      item.setRemindTime(source[index].getRemindTime());
      item.setUnit(source[index].getUnit());
      item.setIsSelect(source[index].getIsSelect());
      result.push(item);
    }
    return result;
  }

  public static async applyTaskReminders(task: Task): Promise<void> {
    const reminders: Array<RemindTime> = task.getRemindTime();
    if (reminders.length === 0) {
      AgentLogger.info(AgentReminderService.SCOPE, 'skip apply reminders, empty list');
      return;
    }
    const date: Date = task.getSelectedDate();
    await updateScheduleReminders(date.getFullYear(), date.getMonth() + 1, date.getDate(), task.getBeginHour(),
      task.getBeginMinute(), task.getTitle(), reminders);
    AgentLogger.info(AgentReminderService.SCOPE, 'applyTaskReminders success taskId=' + task.getId());
  }

  public static async cancelReminders(reminders: Array<RemindTime>): Promise<void> {
    for (let index: number = 0; index < reminders.length; index++) {
      const item: RemindTime = reminders[index];
      const reminderId: number = item.getRemindTimeID();
      if (reminderId <= 0) {
        continue;
      }
      try {
        await reminderAgentManager.cancelReminder(reminderId);
        item.setRemindTimeID(-1);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        if (err.code !== 1700003) {
          AgentLogger.error(AgentReminderService.SCOPE, 'cancel reminder failed code=' + err.code.toString() +
            ' message=' + err.message);
        }
      }
    }
  }

  private static createRemindTime(totalMinutes: number): RemindTime {
    const item: RemindTime = new RemindTime();
    item.setRemindTimeID(-1);
    item.setIsSelect(true);
    if (totalMinutes === 0) {
      item.setUnit('分钟');
      item.setRemindTime(0);
      return item;
    }
    if (totalMinutes % (24 * 60) === 0) {
      item.setUnit('天');
      item.setRemindTime(Math.floor(totalMinutes / (24 * 60)));
      return item;
    }
    if (totalMinutes % 60 === 0) {
      item.setUnit('小时');
      item.setRemindTime(Math.floor(totalMinutes / 60));
      return item;
    }
    item.setUnit('分钟');
    item.setRemindTime(totalMinutes);
    return item;
  }
}
