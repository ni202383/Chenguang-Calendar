import { PerMonthInfoInYearView } from "../Model/PerMonthInfoInYearView";
import { PerYearInfo } from "../Model/PerYearInfo";
import { fetchMonthDataInYearView } from "./MonthViewData";

export function fetchYearData(year : number) : PerYearInfo{
  let perYearInfo : Array<PerMonthInfoInYearView> = [];
  for(let month : number = 1;month <= 12;++month){
    perYearInfo.push(new PerMonthInfoInYearView(month,fetchMonthDataInYearView(year,month)));
  }
  return new PerYearInfo(year,perYearInfo);
}