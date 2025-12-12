import { Solar, Lunar } from '@buyansky/lunar'
import { cardAlmanacData } from '../model/cardAlmanacData';
import { cardDataClass } from '../model/cardDataClass';

export const lunarDayMap = [
  '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
  '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
  '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
]

export const number2CharacterInLunarMonth : Record<number,string> = {
  // -12 : '闰腊',-11 : '闰冬',-10 : '闰十',-9 : '闰九',-8 : '闰八',-7 : '闰七',-6 : '闰六',-5 : '闰五',-4 : '闰四',-3 : '闰三',-2 : '闰二',-1 : '闰正',
  0 : '0',1 : '正',2 : '二',3 : '三',4 : '四',5 : '五',6 : '六',7 : '七',8 : '八',9 : '九',10 : '十',11 : '冬',12 : '腊',
}

export const number2characterInWeek : Record<number,string> = {
  0 : '日',1 : '一',2 : '二',3 : '三',4 : '四',5 : '五',6 : '六'
}

export function fetchAlmanacData(year: number, month: number, day: number) : cardDataClass {
  const lunar = Solar.fromYmd(year,month,day).getLunar();
  const lunarYear = lunar.getYear();
  const lunarMonth = lunar.getMonth();
  const lunarDay = lunar.getDay();
  const lunarDateText = lunarDayMap[lunarDay - 1];
  const solar = Solar.fromYmd(year, month, day);
  const festivalSolar: Array<string> = solar.getFestivals();
  const otherFestivalSolar: Array<string> = solar.getOtherFestivals();
  const festivalLunar : Array<string> = lunar.getFestivals();
  const otherFestivalLunar : Array<string> = lunar.getOtherFestivals();
  const solarTerm: string = lunar.getJieQi();
  const festival: Array<string> = [];
  const otherFestival: Array<string> = [];
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
  const almanac = Lunar.fromDate(new Date(year,month - 1,day));
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
  const XiPosition = almanac.getDayPositionXiDesc();
  const YangGuiPosition = almanac.getDayPositionYangGuiDesc();
  const FuPosition = almanac.getDayPositionFuDesc();
  const CaiPosition = almanac.getDayPositionCaiDesc();
  const almanacData = new cardAlmanacData(Yi,Ji,CaiPosition,XiPosition,FuPosition,YangGuiPosition);
  return new cardDataClass(year,month,day,lunarYear,lunarMonth,lunarDay,lunarDateText,festival,otherFestival,almanacData,yearInGanZhi,monthInGanZhi,dayInGanZhi,yearInShengXiao);
}