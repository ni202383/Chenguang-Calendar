import { DailyInfo } from "../Model/DailyInfo";
import { fetchDayDateInfo } from "./DayDateInfo";

export function fetchWeekData(year : number,month : number,day : number) : Array<DailyInfo>{
  const currentWeek = new Date(year,month - 1,day).getDay();
  const firstDayInCurrentMonth = new Date(year,month - 1,1);
  const lastDayInCurrentMonth = new Date(year,month,0);
  let offsetStart = currentWeek;
  let offset = 1;
  let weekInfo : Array<DailyInfo> = [];
  for(let week = 0;week <= currentWeek;++week,--offsetStart){
    const dayDate = new Date(year,month - 1,day - offsetStart);
    if(dayDate >= firstDayInCurrentMonth){
      weekInfo.push(fetchDayDateInfo(dayDate.getFullYear(),dayDate.getMonth() + 1,dayDate.getDate(),true,true));
    } else {
      weekInfo.push(fetchDayDateInfo(dayDate.getFullYear(),dayDate.getMonth() + 1,dayDate.getDate(),false,true));
    }
  }
  for(let week = currentWeek + 1;week <= 6;++week,++offset){
    const dayDate = new Date(year,month - 1,day + offset);
    if(dayDate <= lastDayInCurrentMonth){
      weekInfo.push(fetchDayDateInfo(dayDate.getFullYear(),dayDate.getMonth() + 1,dayDate.getDate(),true,true));
    } else {
      weekInfo.push(fetchDayDateInfo(dayDate.getFullYear(),dayDate.getMonth() + 1,dayDate.getDate(),false,true));
    }
  }
  return weekInfo;
}