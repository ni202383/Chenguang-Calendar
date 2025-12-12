import { BasicConstant } from '../../../Constants/BasicConstant'
import { Task } from '../../Model/DailyTask'
import {RealDailyScheduleWithoutScroll} from './RealDailyScheduleWithoutScroll'

@Component
export struct RealDailySchedule{
  @State ensureUpdateDailyTask : boolean = false;
  @State isDeleteThisTask : boolean = false;
  @State returnEnsureSave : boolean = false;

  build() {
    Column(){
      Scroll(){
        RealDailyScheduleWithoutScroll({
          newDailySchedule : new Task(),
          isNewDailyTask : true,
          isUpdateDailyTask : false,
          ensureUpdateDailyTask : this.ensureUpdateDailyTask,
          newDailySchedule_ : new Task(),
          isDeleteThisTask : this.isDeleteThisTask,
          returnEnsureSave : this.returnEnsureSave
        })
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
    }
  }
}