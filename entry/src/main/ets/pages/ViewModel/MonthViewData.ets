import {DailyInfo} from '../Model/DailyInfo'
import { DailyInfoBase } from '../Model/DailyInfoBase';
import { PerMonthInfoInYearView } from '../Model/PerMonthInfoInYearView';
import { fetchDailyInfoInYearView, fetchDayDateInfo } from './DayDateInfo';

export const lunarDayMap = [
  '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
  '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
  '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
]

export function fetchMonthData(year : number,month : number) : Array<DailyInfo> {
  let MonthInfo : Array<DailyInfo> = [];
  const firstDayDate : Date = new Date(year,month - 1,1);//这个月的第一天
  const lastDayDate : Date = new Date(year,month,0);//这个月的最后一天
  const weekOfFirstDayInCurrentMonth = firstDayDate.getDay();
  const weekOfLastDayInCurrentMonth = lastDayDate.getDay();
  const lastDayOfLastMonth : Date = new Date(year,month - 1,0);
  for(let week : number = 0,offset : number = weekOfFirstDayInCurrentMonth - 1;week < weekOfFirstDayInCurrentMonth;++week,--offset){
    const year = lastDayOfLastMonth.getFullYear();
    const month_ = lastDayOfLastMonth.getMonth() + 1;//真正的月份
    const date = lastDayOfLastMonth.getDate() - offset;
    const dayDateInfo : DailyInfo = fetchDayDateInfo(year,month_,date,false,true);
    MonthInfo.push(dayDateInfo);
  }
  for(let day : number = firstDayDate.getDate();day <= lastDayDate.getDate();++day){
    const dayDateInfo : DailyInfo = fetchDayDateInfo(year,month,day,true,true);
    MonthInfo.push(dayDateInfo);
  }
  for(let week = weekOfLastDayInCurrentMonth + 1,offset = 1;week <= 6;++week,++offset){
    const date = offset;
    let  dayDateInfo : DailyInfo = new DailyInfo();
    if(month == 12){
      dayDateInfo = fetchDayDateInfo(year + 1,month % 12 + 1,date,false,true);
    } else {
      dayDateInfo = fetchDayDateInfo(year,month % 12 + 1,date,false,true);
    }
    MonthInfo.push(dayDateInfo);
  }
  return MonthInfo;
}

export function fetchMonthDataInYearView(year : number,month : number) : Array<DailyInfoBase>{
  let perMonthInfo : Array<DailyInfoBase> = [];
  const firstDayDate : Date = new Date(year,month - 1,1);//这个月的第一天
  const lastDayDate : Date = new Date(year,month,0);//这个月的最后一天
  const weekOfFirstDayInCurrentMonth = firstDayDate.getDay();
  const weekOfLastDayInCurrentMonth = lastDayDate.getDay();
  const lastDayOfLastMonth : Date = new Date(year,month - 1,0);

  for(let week : number = 0,offset : number = weekOfFirstDayInCurrentMonth - 1;week < weekOfFirstDayInCurrentMonth;++week,--offset){
    const year = lastDayOfLastMonth.getFullYear();
    const month_ = lastDayOfLastMonth.getMonth() + 1;
    const date = lastDayOfLastMonth.getDate() - offset;
    const dayDateInfo : DailyInfoBase = fetchDailyInfoInYearView(year,month_,date,false);
    perMonthInfo.push(dayDateInfo);
  }

  for(let day : number = firstDayDate.getDate();day <= lastDayDate.getDate();++day){
    const dayDateInfo : DailyInfoBase = fetchDailyInfoInYearView(year,month,day,true);
    perMonthInfo.push(dayDateInfo);
  }

  for(let week = weekOfLastDayInCurrentMonth + 1,offset = 1;week <= 6;++week,++offset){
    const date = offset;
    const dayDateInfo : DailyInfoBase = fetchDailyInfoInYearView(year,month % 12 + 1,date,false);
    perMonthInfo.push(dayDateInfo);
  }
  return perMonthInfo;
}