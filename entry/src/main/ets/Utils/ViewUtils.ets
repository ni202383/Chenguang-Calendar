import {i18n} from '@kit.LocalizationKit'

export const number2CharacterInLunarMonth : Record<number,string> = {
  // -12 : '闰腊',-11 : '闰冬',-10 : '闰十',-9 : '闰九',-8 : '闰八',-7 : '闰七',-6 : '闰六',-5 : '闰五',-4 : '闰四',-3 : '闰三',-2 : '闰二',-1 : '闰正',
  0 : '0',1 : '正',2 : '二',3 : '三',4 : '四',5 : '五',6 : '六',7 : '七',8 : '八',9 : '九',10 : '十',11 : '冬',12 : '腊',
}

export const number2characterInWeek : Record<number,string> = {
  0 : '日',1 : '一',2 : '二',3 : '三',4 : '四',5 : '五',6 : '六'
}

export function daysDiff(date1 : Date,date2 : Date) : number{
  let calendar = i18n.getCalendar('zh-Hans','gregory');
  calendar.setTimeZone('Asia/Shanghai');
  calendar.setTime(date1);
  return calendar.compareDays(date2);
}

export function currentDateDiff(currentDate : Date) : string{
  const dayDiff = daysDiff(currentDate,new Date(new Date().getFullYear(),new Date().getMonth(),new Date().getDate()));
  let response : string = '';
  switch (dayDiff){
    case 0:
      response = '今天';
      break;
    case -1:
      response = '明天';
      break;
    case 1:
      response = '昨天';
      break;
    case -2:
      response = '后天';
      break;
    case 2:
      response = '前天';
      break;
    default:
      if(dayDiff < 0){
        response = `${Math.abs(dayDiff)}天后`;
      } else {
        response = `${Math.abs(dayDiff)}天前`;
      }
      break;
  }
  return response;
}

export function hexToRgb(hexColor : string) : [number,number,number]{
  return [parseInt(hexColor.slice(1,3),16),parseInt(hexColor.slice(3,5),16),parseInt(hexColor.slice(5,7),16)];
}

export function addTransparency(RGBcolor: [number,number,number],transparency: number) : string{
  return `rgba(${RGBcolor[0]},${RGBcolor[1]},${RGBcolor[2]},${transparency})`;
}

export function find<T>(list : Array<T>,target : T,cmp : (first : T,second : T) => number) : number{
  let left : number = 0;
  let right : number = list.length - 1;
  while(left <= right){
    let mid = (left + right) >> 1;
    let result : number = cmp(target,list[mid]);
    if(result == 0){
      return mid;
    } else if(result == 1){
      left = mid + 1;
    } else {
      right = mid - 1
    }
  }
  return -1;
}

export function upper_bound<T>(list : Array<T>,target : T,cmp : (first : T,second : T) => number) : number{
  let left : number = 0;
  let right : number = list.length;
  while(left < right){
    let mid : number = (left + right) >>> 1;
    let result = cmp(list[mid],target);
    if (result <= 0) {
      left = mid + 1;
    } else {
      right = mid;
    }
  }
  return left;
}

export function monthDiff(
  startYear: number,
  startMonth: number,
  endYear: number,
  endMonth: number
) : number{
  const startTotalMonth = startYear * 12 + startMonth;
  const endTotalMonth = endYear * 12 + endMonth;
  return startTotalMonth - endTotalMonth;
}

export function isNormalTimeSchedule(startHour : number,startMinute : number,endHour : number,endMinute : number) : boolean {//判断日程的开始时间是否小于等于结束时间
  const startTotalMinutes = startHour * 60 + startMinute;
  const endTotalMinutes = endHour * 60 + endMinute;
  if(startTotalMinutes <= endTotalMinutes)return true;
  else return false;
}