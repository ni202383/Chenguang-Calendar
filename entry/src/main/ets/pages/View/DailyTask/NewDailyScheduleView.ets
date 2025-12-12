import { ViewArkUIConstant } from '../../../Constants/ArkUIConstant';
import { BasicConstant } from '../../../Constants/BasicConstant'
import { Task } from '../../Model/DailyTask'
import { RealDailySchedule } from './RealDailySchedule'


@Component
export struct DailySchedule {
  @State ensureUpdateDailyTask : boolean = false;
  @State isDeleteThisTask : boolean = false;

  build() {
    Column({space : ViewArkUIConstant.NEW_DAILY_SCHEDULE_WHOLE_COLUMN_GAP_SPACE}) {
      Text('新建日程')
        .fontSize(ViewArkUIConstant.NEW_DAILY_SCHEDULE_FONT_SIZE)
        .fontWeight(FontWeight.Bold)

      RealDailySchedule()
      //新建任务界面
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .padding(ViewArkUIConstant.NEW_DAILY_SCHEDULE_WHOLE_COLUMN_PADDING)
    .alignItems(HorizontalAlign.Start)
  }
}