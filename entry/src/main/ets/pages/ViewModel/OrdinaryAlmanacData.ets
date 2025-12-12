import { Lunar, Solar } from "@buyansky/lunar";
import { ordinaryAlmanacOfDay } from "../Model/LunarCalendar";

export function fetchOrdinaryAlmanacData(year : number,month : number,day : number) : ordinaryAlmanacOfDay{
  const date : Date = new Date(year,month - 1,day);
  const almanac = Lunar.fromDate(date);
  const lunar = Solar.fromYmd(year,month,day);
  const lunarYear = lunar.getLunar().getYear();
  const lunarMonth = lunar.getLunar().getMonth();
  const lunarDay = lunar.getLunar().getDay();
  const YiArray = almanac.getDayYi();
  const JiArray = almanac.getDayJi();
  let Yi = '';
  let Ji = '';
  for (let i = 0; i < YiArray.length; ++i) {
    Yi += `${YiArray[i]} `;
  }
  for (let i = 0; i < JiArray.length; ++i) {
    Ji += `${JiArray[i]} `;
  }
  const yearInGanZhi = almanac.getYearInGanZhi();
  const monthInGanZhi = almanac.getMonthInGanZhi();
  const dayInGanZhi = almanac.getDayInGanZhi();
  const yearInShengXiao = almanac.getYearShengXiao();
  const ordinaryAlmanac =
    new ordinaryAlmanacOfDay(lunarYear, lunarMonth, lunarDay, Yi, Ji, yearInGanZhi, monthInGanZhi, dayInGanZhi,
      yearInShengXiao);
  return ordinaryAlmanac;
}