import { ordinaryAlmanacOfDay } from '../Model/LunarCalendar';
import { lunarDayMap } from './MonthViewData'
import { Solar, Lunar } from '@buyansky/lunar'
import { DailyInfo } from '../Model/DailyInfo'
import { fetchOrdinaryAlmanacData } from './OrdinaryAlmanacData';
import { DailyInfoBase } from '../Model/DailyInfoBase';

export function fetchDayDateInfo(year: number, month: number, day: number, isCurrentMonth: boolean,
  almanacSubscribe: boolean = true): DailyInfo {
  const solar_ = Solar.fromDate(new Date(year, month - 1, day));
  const lunarYear = solar_.getLunar().getYear();
  const lunarMonth = solar_.getLunar().getMonth();
  const lunarDay = solar_.getLunar().getDay();
  const lunarDateText = lunarDayMap[lunarDay - 1];
  const solar = Solar.fromYmd(year, month, day);
  const festivalSolar: Array<string> = solar.getFestivals();
  const otherFestivalSolar: Array<string> = solar.getOtherFestivals();
  const lunar = Lunar.fromYmd(lunarYear, lunarMonth, lunarDay);
  const festivalLunar: Array<string> = lunar.getFestivals();
  const otherFestivalLunar: Array<string> = lunar.getOtherFestivals();
  const solarTerm: string = lunar.getJieQi();
  const festival: Array<string> = [];
  const otherFestival: Array<string> = [];
  const todayDate: Date = new Date();
  let isSelected: boolean = false;
  let isSelectedAndAddThemeBackgroundColor: boolean = false;
  if (year !== todayDate.getFullYear() || month !== todayDate.getMonth() + 1) {
    if (day === 1) isSelected = true;
  } else {
    if (day === todayDate.getDate()) {
      isSelected = true;
      isSelectedAndAddThemeBackgroundColor = true;
    }
  }
  for (let index = 0; index < festivalLunar.length; ++index) {
    festival.push(festivalLunar[index]);
  }
  for (let index = 0; index < festivalSolar.length; ++index) {
    festival.push(festivalSolar[index]);
  }
  for (let index = 0; index < otherFestivalLunar.length; ++index) {
    otherFestival.push(otherFestivalLunar[index]);
  }
  for (let index = 0; index < otherFestivalSolar.length; ++index) {
    otherFestival.push(otherFestivalSolar[index]);
  }
  if (!almanacSubscribe) {
    return new DailyInfo(year, month, day, new Date(year, month - 1, day).getDay(), isCurrentMonth,
      isSelected, isSelectedAndAddThemeBackgroundColor, lunarMonth, new ordinaryAlmanacOfDay(), lunarDateText, festival,
      otherFestival, solarTerm);
  }
  const ordinaryAlmanac = fetchOrdinaryAlmanacData(year,month,day);
  return new DailyInfo(year, month, day, new Date(year, month - 1, day).getDay(), isCurrentMonth, isSelected,
    isSelectedAndAddThemeBackgroundColor, lunarMonth, ordinaryAlmanac, lunarDateText, festival, otherFestival,
      solarTerm);
}

export function fetchDailyInfoInYearView(year: number, month: number, day: number, isCurrentMonth: boolean) : DailyInfoBase{
  const solar_ = Solar.fromDate(new Date(year, month - 1, day));
  const lunarDay = solar_.getLunar().getDay();
  const lunarDateText = lunarDayMap[lunarDay - 1];
  return new DailyInfoBase(day,new Date(year,month - 1,day).getDay(),isCurrentMonth,lunarDateText);
}