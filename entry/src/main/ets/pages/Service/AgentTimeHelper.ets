import { dateToString, number2characterInWeek, timeToString } from '../../Utils/ViewUtils';

export class AgentTimeBlock {
  startMinute: number = 0;
  endMinute: number = 0;
  label: string = '';
}

export class AgentTimeHelper {
  public static formatDate(date: Date): string {
    return dateToString(date.getFullYear(), date.getMonth() + 1, date.getDate());
  }

  public static formatTime(date: Date): string {
    return timeToString(date.getHours(), date.getMinutes());
  }

  public static formatWeekday(date: Date): string {
    return '周' + number2characterInWeek[date.getDay()];
  }

  public static formatDateTime(date: Date): string {
    const secondText: string = date.getSeconds().toString().padStart(2, '0');
    return AgentTimeHelper.formatDate(date) + ' ' + AgentTimeHelper.formatTime(date) + ':' + secondText;
  }

  public static formatIsoOffset(date: Date): string {
    const offsetMinute: number = -date.getTimezoneOffset();
    const sign: string = offsetMinute >= 0 ? '+' : '-';
    const absoluteMinute: number = Math.abs(offsetMinute);
    const offsetHourText: string = Math.floor(absoluteMinute / 60).toString().padStart(2, '0');
    const offsetMinuteText: string = (absoluteMinute % 60).toString().padStart(2, '0');
    return AgentTimeHelper.formatDate(date) + 'T' + AgentTimeHelper.formatTime(date) + ':' +
      date.getSeconds().toString().padStart(2, '0') + sign + offsetHourText + ':' + offsetMinuteText;
  }

  public static cloneDateOnly(date: Date): Date {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  public static parseDateText(dateText: string): Date | null {
    const parts: Array<string> = dateText.split('-');
    if (parts.length !== 3) {
      return null;
    }
    const year: number = Number(parts[0]);
    const month: number = Number(parts[1]);
    const day: number = Number(parts[2]);
    if (!AgentTimeHelper.isFiniteNumber(year) || !AgentTimeHelper.isFiniteNumber(month) || !AgentTimeHelper.isFiniteNumber(day)) {
      return null;
    }
    const date: Date = new Date(year, month - 1, day);
    if (date.getFullYear() !== year || date.getMonth() + 1 !== month || date.getDate() !== day) {
      return null;
    }
    return date;
  }

  public static parseTimeText(timeText: string): AgentTimeBlock | null {
    const parts: Array<string> = timeText.split(':');
    if (parts.length !== 2) {
      return null;
    }
    const hour: number = Number(parts[0]);
    const minute: number = Number(parts[1]);
    if (!AgentTimeHelper.isFiniteNumber(hour) || !AgentTimeHelper.isFiniteNumber(minute)) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    const block: AgentTimeBlock = new AgentTimeBlock();
    block.startMinute = hour * 60 + minute;
    block.endMinute = block.startMinute;
    block.label = timeToString(hour, minute);
    return block;
  }

  public static minuteToText(totalMinute: number): string {
    const hour: number = Math.floor(totalMinute / 60);
    const minute: number = totalMinute % 60;
    return timeToString(hour, minute);
  }

  public static isSameDate(first: Date, second: Date): boolean {
    return first.getFullYear() === second.getFullYear() && first.getMonth() === second.getMonth() &&
      first.getDate() === second.getDate();
  }

  public static daysBetween(start: Date, end: Date): number {
    const startDate: Date = AgentTimeHelper.cloneDateOnly(start);
    const endDate: Date = AgentTimeHelper.cloneDateOnly(end);
    const diff: number = endDate.getTime() - startDate.getTime();
    return Math.round(diff / (24 * 60 * 60 * 1000));
  }

  public static mondayOf(date: Date): Date {
    const result: Date = AgentTimeHelper.cloneDateOnly(date);
    const day: number = result.getDay();
    const offset: number = day === 0 ? -6 : 1 - day;
    result.setDate(result.getDate() + offset);
    return result;
  }

  public static monthOffset(fromDate: Date, targetDate: Date): number {
    return (targetDate.getFullYear() - fromDate.getFullYear()) * 12 + targetDate.getMonth() - fromDate.getMonth();
  }

  public static mergeBlocks(blocks: Array<AgentTimeBlock>): Array<AgentTimeBlock> {
    if (blocks.length === 0) {
      return [];
    }
    const sorted: Array<AgentTimeBlock> = blocks.slice().sort((first: AgentTimeBlock, second: AgentTimeBlock) => {
      return first.startMinute - second.startMinute;
    });
    const result: Array<AgentTimeBlock> = [];
    let current: AgentTimeBlock = new AgentTimeBlock();
    current.startMinute = sorted[0].startMinute;
    current.endMinute = sorted[0].endMinute;
    current.label = sorted[0].label;
    for (let index: number = 1; index < sorted.length; index++) {
      const nextBlock: AgentTimeBlock = sorted[index];
      if (nextBlock.startMinute <= current.endMinute) {
        current.endMinute = Math.max(current.endMinute, nextBlock.endMinute);
        if (current.label.length > 0 && nextBlock.label.length > 0) {
          current.label += '、' + nextBlock.label;
        }
      } else {
        result.push(current);
        current = new AgentTimeBlock();
        current.startMinute = nextBlock.startMinute;
        current.endMinute = nextBlock.endMinute;
        current.label = nextBlock.label;
      }
    }
    result.push(current);
    return result;
  }

  private static isFiniteNumber(value: number): boolean {
    return !Number.isNaN(value) && Number.isFinite(value);
  }
}
