import { EventCountDown } from '../Model/EventCountDown';
import { countDownStore } from '../Model/CountDownStore';
import {
  AgentCountDownOperationResult,
  AgentCreateCountDownArgs,
  AgentDeleteCountDownArgs
} from '../Model/AgentModels';
import { AgentLogger } from './AgentLogger';

export class CountDownOperationService {
  private static readonly SCOPE: string = 'CountDownOperationService';

  public static async createCountDown(args: AgentCreateCountDownArgs): Promise<AgentCountDownOperationResult> {
    const result: AgentCountDownOperationResult = new AgentCountDownOperationResult();
    const title: string = args.title.trim();
    if (title.length === 0) {
      result.userText = '创建失败，缺少倒计时标题。';
      return result;
    }
    const targetDate: Date | null = CountDownOperationService.parseTargetDate(args.targetDate);
    if (targetDate === null) {
      result.userText = '创建失败，倒计时日期格式不正确。';
      return result;
    }
    if (targetDate.getTime() <= new Date().getTime()) {
      result.userText = '创建失败，倒计时时间需要晚于当前时间。';
      return result;
    }
    const countDown: EventCountDown = new EventCountDown();
    countDown.eventName = title;
    countDown.eventDetail = args.detail.trim();
    countDown.targetDate = targetDate;
    countDown.hourMinuteSecondIsUsed = CountDownOperationService.hasTimePart(args.targetDate);
    countDown.imageIndex = 0;
    const id: string = await countDownStore.addCountDownAndFlush(countDown);
    result.success = true;
    result.countDownId = id;
    result.userText = '创建成功，已打开倒计时列表。';
    AgentLogger.info(CountDownOperationService.SCOPE, 'createCountDown success id=' + id);
    return result;
  }

  public static deleteCountDown(args: AgentDeleteCountDownArgs): AgentCountDownOperationResult {
    const result: AgentCountDownOperationResult = new AgentCountDownOperationResult();
    const id: string = CountDownOperationService.findTargetId(args.title);
    if (id.length === 0) {
      result.userText = '未找到要删除的倒计时。';
      return result;
    }
    const success: boolean = countDownStore.deleteCountDownById(id);
    if (!success) {
      result.userText = '删除失败，请稍后再试。';
      return result;
    }
    result.success = true;
    result.userText = '删除成功，已更新倒计时列表。';
    return result;
  }

  public static describeDeleteTarget(args: AgentDeleteCountDownArgs): string {
    const title: string = args.title.trim();
    return title.length > 0 ? '“' + title + '”' : '该倒计时';
  }

  private static parseTargetDate(dateText: string): Date | null {
    const value: string = dateText.trim();
    if (value.length === 10) {
      const parts: Array<string> = value.split('-');
      if (parts.length !== 3) {
        return null;
      }
      const year: number = Number(parts[0]);
      const month: number = Number(parts[1]);
      const day: number = Number(parts[2]);
      if (Number.isNaN(year) || Number.isNaN(month) || Number.isNaN(day)) {
        return null;
      }
      return new Date(year, month - 1, day, 23, 59, 59);
    }
    if (value.length === 19 && value.indexOf('T') > 0) {
      const date: Date = new Date(value);
      if (Number.isNaN(date.getTime())) {
        return null;
      }
      return date;
    }
    return null;
  }

  private static hasTimePart(dateText: string): boolean {
    return dateText.trim().length > 10;
  }

  private static findTargetId(titleText: string): string {
    const normalizedTitle: string = titleText.trim();
    const list: Array<EventCountDown> = countDownStore.getAll();
    let fuzzyMatchId: string = '';
    for (let index: number = 0; index < list.length; index++) {
      const item: EventCountDown = list[index];
      if (item.eventName === normalizedTitle) {
        return item.getId();
      }
      if (normalizedTitle.length > 0 && item.eventName.indexOf(normalizedTitle) >= 0) {
        if (fuzzyMatchId.length === 0) {
          fuzzyMatchId = item.getId();
        } else {
          return '';
        }
      }
    }
    return fuzzyMatchId;
  }
}
