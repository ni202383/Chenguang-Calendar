import {FestivalDetailData} from '../../data/FestivalDetailData'
import {SolarTermsDetailData} from '../../data/SolarTermsDetailData'
import { FestivalDetailInfo } from '../Model/FestivalDetailInfo';
import { SolarTermsDetailInfo } from '../Model/SolarTermsDetailInfo';

export function fetchFestivalDetailInfo(festival : string) : FestivalDetailInfo{
    let festivalInfo : FestivalDetailInfo | undefined = FestivalDetailData[festival];
    if(festivalInfo === undefined){
      console.log('未找到节日信息');
      return new FestivalDetailInfo();
    }
    return festivalInfo;
}

export function fetchSolarTermsDetailInfo(solarTerms : string) : SolarTermsDetailInfo{
    let solarTermsInfo : SolarTermsDetailInfo | undefined = SolarTermsDetailData[solarTerms];
    if(solarTermsInfo === undefined){
      console.log('未找到节气信息');
      return new SolarTermsDetailInfo();
    }
    return solarTermsInfo;
}