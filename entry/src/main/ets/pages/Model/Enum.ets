export enum TaskType{
  Work = '工作',
  Entertainment = '娱乐',
  life = '生活',
  Self_discipline = '自律'
}

export const taskTypeMap : Array<string> = ['工作','生活','娱乐','自律']

export enum CountDownTimeType{
  LongTime = 1,//只显示年月日
  MediumTime = 2,//显示日时分
  ShortTime = 3//显示时分秒
}