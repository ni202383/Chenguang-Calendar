import { Solar, Lunar } from '@buyansky/lunar'
import {
  almanacOfDay,
  almanacOfTime,
  JiShengPosition,
  ordinaryAlmanacOfDay,
  TaiSuiPosition
} from '../Model/LunarCalendar';

export function fetchAlmanac(year: number, month: number, day: number,): almanacOfDay {
  const solar = Solar.fromYmd(year, month, day);
  const lunarYear = solar.getLunar().getYear();
  const lunarMonth = solar.getLunar().getMonth();
  const lunarDay = solar.getLunar().getDay();
  const almanac = Lunar.fromYmd(lunarYear, lunarMonth, lunarDay);
  const XiPosition = almanac.getDayPositionXiDesc();
  const YangGuiPosition = almanac.getDayPositionYangGuiDesc();
  const YinGuiPosition = almanac.getDayPositionYinGuiDesc();
  const FuPosition = almanac.getDayPositionFuDesc();
  const CaiPosition = almanac.getDayPositionCaiDesc();
  const jiShengPosition = new JiShengPosition(XiPosition, YangGuiPosition, YinGuiPosition, FuPosition, CaiPosition);
  const dayTaiPosition = almanac.getDayPositionTai();
  const yearTaiSuiPosition = almanac.getYearPositionTaiSuiDesc();
  const monthTaiSuiPosition = almanac.getMonthPositionTaiSuiDesc();
  const dayTaiSuiPosition = almanac.getDayPositionTaiSuiDesc();
  const taisuiPosition = new TaiSuiPosition(yearTaiSuiPosition, monthTaiSuiPosition, dayTaiSuiPosition);
  const Chong = almanac.getDayChongDesc();
  const Sha = almanac.getDaySha();
  const dayJiSheng = almanac.getDayJiShen();
  const dayXiongSha = almanac.getDayXiongSha();
  let dayJiShengString = '';
  for(let i = 0;i < dayJiSheng.length;++i){
    if(i == dayJiSheng.length - 1)dayJiShengString += dayJiSheng[i];
    else dayJiShengString += `${dayJiSheng[i]} `;
  }
  let dayXiongShaString = '';
  for(let i = 0;i < dayXiongSha.length;++i){
    if(i == dayXiongSha.length - 1)dayXiongShaString += dayXiongSha[i];
    else dayXiongShaString += `${dayXiongSha[i]} `;
  }
  const twelveZhiXing = almanac.getZhiXing();
  const PengZuGan = almanac.getPengZuGan();
  const PengZuZhi = almanac.getPengZuZhi();
  let timeOfCurrentDay: Array<almanacOfTime> = [];
  const times = almanac.getTimes();
  let startHour = 23;
  for (let i = 0; i < 12; ++i) {
    const t = times[i];
    const time = t.getGanZhi();
    let endHour = (startHour + 1) % 24;
    let startHourstring = startHour < 10 ? '0' + `${startHour}` : `${startHour}`;
    let endHourstring = endHour < 10 ? '0' + `${endHour}` : `${endHour}`;
    let beginTime = new Date();
    if(i == 0){
      beginTime = new Date(year,month - 1,day - 1,startHour,0);
    } else {
      beginTime = new Date(year,month - 1,day,startHour,0);
    }
    const endTime = new Date(year,month - 1,day ,endHour,59);
    const beginTimeString = `${startHourstring}:00`;
    const endTimeString = `${endHourstring}:59`;
    const currentTime = new Date(year, month - 1, day, endHour, 0);
    const lunarInCurrentTime = Lunar.fromDate(currentTime);
    const timeInGanZhi = lunarInCurrentTime.getTimeInGanZhi();
    const Chong = lunarInCurrentTime.getTimeChongDesc();
    const Sha = lunarInCurrentTime.getTimeSha();
    const XiPosition = lunarInCurrentTime.getTimePositionXiDesc();
    const YangGuiPosition = lunarInCurrentTime.getTimePositionYangGuiDesc();
    const YinGuiPosition = lunarInCurrentTime.getTimePositionYinGuiDesc();
    const FuPosition = lunarInCurrentTime.getTimePositionFuDesc();
    const CaiPosition = lunarInCurrentTime.getTimePositionCaiDesc();
    const jiShengPosition = new JiShengPosition(XiPosition, YangGuiPosition, YinGuiPosition, FuPosition, CaiPosition);
    const Yi = lunarInCurrentTime.getTimeYi();
    const Ji = lunarInCurrentTime.getTimeJi();
    let yiString = '';
    let jiString = '';
    for(let i = 0;i < Yi.length;++i){
      if(i == Yi.length - 1){
        yiString += Yi[i];
      } else {
        yiString += `${Yi[i]} `;
      }
    }
    for(let i = 0;i < Ji.length;++i){
      if(i == Ji.length - 1){
        jiString += Ji[i];
      } else {
        jiString += `${Ji[i]} `;
      }
    }
    const JiOrXiong = lunarInCurrentTime.getTimeTianShenLuck();
    let lunarOfTime: almanacOfTime =
      new almanacOfTime(time, beginTime, endTime, beginTimeString, endTimeString, timeInGanZhi, Chong, Sha, jiShengPosition, yiString, jiString, JiOrXiong);
    timeOfCurrentDay.push(lunarOfTime);
    startHour = (endHour + 1) % 24;
  }
  return new almanacOfDay(jiShengPosition, dayTaiPosition, taisuiPosition, Chong, Sha, dayJiShengString,
    dayXiongShaString, twelveZhiXing, timeOfCurrentDay, PengZuGan, PengZuZhi);
}