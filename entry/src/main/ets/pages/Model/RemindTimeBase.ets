@Observed
export class RemindTime{
  private remindTimeID : number = -1;
  private unit : string;
  private remindTime : number;
  private isSelected : boolean

  constructor();
  constructor(remindTime : number,unit : string,isSelected : boolean);
  constructor(remindTime ?: number,unit ?: string,isSelected ?: boolean) {
    this.unit = unit ?? '';
    this.remindTime = remindTime ?? 0;
    this.isSelected = isSelected ?? false;
  }

  public toMinutes(): number {
    switch (this.unit) {
      case '分钟':
        return this.remindTime;
      case '小时':
        return this.remindTime * 60;
      case '天':
        return this.remindTime * 60 * 24;
      default:
        return this.remindTime;
    }
  }

  public setRemindTimeID(remindTimeID : number){
    this.remindTimeID = remindTimeID
  }

  public getRemindTimeID(){
    return this.remindTimeID;
  }

  public setUnit(unit : string){
    this.unit = unit;
  }

  public getUnit(){
    return this.unit;
  }

  public setRemindTime(remindTime : number){
    this.remindTime = remindTime;
  }

  public getRemindTime(){
    return this.remindTime;
  }

  public setIsSelect(isSelected : boolean){
    this.isSelected = isSelected;
  }

  public getIsSelect(){
    return this.isSelected;
  }

  public toString(){
    return this.remindTime + this.unit;
  }

  public toPlainObject(): RemindTimePlain {
    return {
      remindTimeID : this.remindTimeID,
      unit: this.unit,
      remindTime: this.remindTime,
      isSelected: this.isSelected
    };
  }

  public static fromPlainObject(obj: RemindTimePlain): RemindTime {
    return new RemindTime(obj.remindTime, obj.unit, obj.isSelected);
  }

}

export interface RemindTimePlain {
  remindTimeID : number,
  unit: string;
  remindTime: number;
  isSelected: boolean;
}

export function sortRemindTimeList(list: Array<RemindTime>): Array<RemindTime> {
  return list.sort((a: RemindTime, b: RemindTime) => {
    const aMinutes = a.toMinutes();
    const bMinutes = b.toMinutes();

    if (aMinutes < bMinutes) {
      return -1;   // a 在前
    } else if (aMinutes > bMinutes) {
      return 1;    // b 在前
    } else {
      return 0;    // 一样长
    }
  });
}



const RemindTimeListUnit : Array<string> = [
  '无单位','分钟','分钟','分钟','分钟','分钟','小时','小时','天','天','周'
]

const RemindTimeListNumber : Array<number> = [-1,0,5,10,15,30,1,2,1,2,1]

export function generateRemindTimeListInfo() : Array<RemindTime>{
  let DialogSelectRemindTimeList : Array<RemindTime> = [];
  for(let i = 0;i < RemindTimeListUnit.length;++i){
    DialogSelectRemindTimeList.push(new RemindTime(
      RemindTimeListNumber[i],
      RemindTimeListUnit[i],
      false
    ))
  }
  DialogSelectRemindTimeList[0].setIsSelect(true);
  return DialogSelectRemindTimeList;
}

function generateNumbers(unit : string) : Array<TextCascadePickerRangeContent>{
  let res : Array<TextCascadePickerRangeContent> = [];
  switch (unit){
    case 'minute' :
      for(let i = 1;i <= 59;++i){
        res.push({
          text : i.toString()
        })
      }
      break;
    case 'hour':
      for(let i = 1;i <= 23;++i){
        res.push({
          text : i.toString()
        })
      }
      break;
    case 'day':
      for(let i = 1;i <= 30;++i){
        res.push({
          text : i.toString()
        })
      }
      break;
  }
  return res;
}

export const CustomDialogSelectedRemindTime : Array<TextCascadePickerRangeContent> = [
  {
    text : '分钟',
    children : generateNumbers('minute')
  },
  {
    text : '小时',
    children : generateNumbers('hour')
  },
  {
    text : '天',
    children : generateNumbers('day')
  }
]