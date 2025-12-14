import { BasicConstant } from '../Constants/BasicConstant';
import { BreakpointConstant } from '../Constants/BreakpointConstant';
import { ColorPickDialog } from 'color-picker';
import {FormIdStore} from '../Utils/FormIdStore';
import { formBindingData, formProvider } from '@kit.FormKit';
import { ViewArkUIConstant } from '../Constants/ArkUIConstant';

@Entry
@Component
struct Settings {
  @StorageProp('topStatusBarHeight') topStatusBarHeight : number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  @StorageLink('isSubscribe') @Watch('onDataChange') isSubscribe : boolean = true;
  @StorageLink('themeColor') themeColor : string = '';
  @StorageLink('isSetChangingNewTaskButton') isSetChangingNewTaskButton : boolean = true;
  @StorageLink('changingNewTaskButtonHandingStatus') changingNewTaskButtonHandingStatus : boolean = true;

  /*
  *设置主题色，是否显示黄历。
   */

  onDataChange(){
    console.info(`[App] 状态变更为: ${this.isSubscribe}，准备同步所有组件`);
    this.updateWidgets();
  }

  async updateWidgets(){
    const context = getContext(this);
    const formIds = await FormIdStore.getAllFormIds(context);

    if (formIds.length === 0) {
      console.info('[App] 没有发现活跃的小组件，跳过更新');
      return;
    }

    // 1. 创建更新数据包 (放在循环外创建一次即可)
    let dataObj = new Map<string, boolean>();
    dataObj.set('isSubscribe', this.isSubscribe);
    let formData = formBindingData.createFormBindingData(dataObj);

    console.info(`[App] 准备更新 ${formIds.length} 个小组件...`);

    // 2. 🌟 关键修正：使用 for...of 循环和 await 确保顺序执行
    for (const formId of formIds) {
      try {
        // 等待上一个小组件更新成功后，再执行下一个
        await formProvider.updateForm(formId, formData);
        console.info(`[App] 小组件 ${formId} 更新成功`);
      } catch (error) {
        console.error(`[App] 小组件 ${formId} 更新失败: ${error.message}, 错误码: ${error.code}`);

        // 错误处理：如果 ID 无效，则从 Preferences 中移除
        // 错误码 16501001 通常表示 Form 不存在
        if (error.code === 16501001) {
          await FormIdStore.removeFormId(context, formId);
          console.warn(`[App] 已移除无效的 formId: ${formId}`);
        }
      }
    }
  }

  colorPickerDialogController : CustomDialogController = new CustomDialogController({
    builder : ColorPickDialog({
      color : this.themeColor
    }),
    alignment: DialogAlignment.Center,
    width: ViewArkUIConstant.COLOR_PICKER_DIALOG_WIDTH_PERCENTAGE,
    cornerRadius: ViewArkUIConstant.COLOR_PICKER_DIALOG_CORNER_RADIUS,
    backgroundColor : Color.White
  })

  @Builder settingItem(text : string,initStatus : boolean,things : (isOn : boolean) => void){
    Row(){
      Text(text)
        .fontSize(ViewArkUIConstant.SETTING_IS_ALMANAC_FONT_SIZE)
        .fontColor(Color.Black)

      Toggle({type : ToggleType.Switch,isOn : initStatus})
        .selectedColor(this.themeColor)
        .switchPointColor(Color.White)
        .onChange((isOn) => {
          things(isOn);
        })
    }
    .width(BasicConstant.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(ViewArkUIConstant.SETTING_IS_ALMANAC_ROW_PADDING)
    .height(ViewArkUIConstant.SETTING_IS_ALMANAC_ROW_HEIGHT)
    .backgroundColor(Color.White)
    .borderRadius(ViewArkUIConstant.SETTING_IS_ALMANAC_ROW_BORDER_RADIUS)
  }

  build() {
    Column() {
      Column({ space: ViewArkUIConstant.SETTING_COLUMN_GAP_SPACE }) {
        Button() {
          Image($r('app.media.return'))
            .width(ViewArkUIConstant.SETTING_RETURN_IMAGE_WIDTH_HEIGHT)
            .height(ViewArkUIConstant.SETTING_RETURN_IMAGE_WIDTH_HEIGHT)
        }
        .width(ViewArkUIConstant.SETTING_RETURN_BUTTON_WIDTH_HEIGHT)
        .height(ViewArkUIConstant.SETTING_RETURN_BUTTON_WIDTH_HEIGHT)
        .type(ButtonType.Circle)
        .backgroundColor($r('app.color.background_gray'))
        .onClick((event: ClickEvent) => {
          this.getUIContext().getRouter().back();
        })

        Text('设置')
          .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? ViewArkUIConstant.SETTING_FONT_SIZE_LG :
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.SETTING_FONT_SIZE_MD :
              ViewArkUIConstant.SETTING_FONT_SIZE_SM)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)

        List({ space: ViewArkUIConstant.SETTING_LIST_SPACE }) {
          ListItem() {
            this.settingItem('是否显示黄历',this.isSubscribe,async (isOn: boolean) => {
              this.isSubscribe = isOn;
            })
          }

          ListItem(){
            this.settingItem('是否开启底部添加日程按钮',this.isSetChangingNewTaskButton,(isOn : boolean) => {
              this.isSetChangingNewTaskButton = isOn;
            })
          }

          if(this.isSetChangingNewTaskButton){
            this.settingItem('质感握姿',this.changingNewTaskButtonHandingStatus,(isOn : boolean) => {
              this.getUIContext().animateTo({
                duration :300,
                curve : Curve.EaseInOut
              },() => {
                this.changingNewTaskButtonHandingStatus = isOn;
              })
            })
          }

          ListItem(){
            Button('点击选择主题颜色~').onClick((event: ClickEvent) => {
              this.colorPickerDialogController.open();
            })
              .width(BasicConstant.FULL_WIDTH)
              .height(ViewArkUIConstant.SETTING_SELECT_THEME_COLOR_BUTTON_HEIGHT)
              .backgroundColor(this.themeColor)
              .fontColor(Color.White)
              .fontSize(ViewArkUIConstant.SETTING_SELECT_THEME_COLOR_BUTTON_FONT_SIZE)
          }
        }
      }
      .width(ViewArkUIConstant.SETTING_WHOLE_WIDTH_PERCENTAGE)
      .height(BasicConstant.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: this.getUIContext().px2vp(this.topStatusBarHeight)
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .backgroundColor($r('app.color.backgroundcolor'))
    .alignItems(HorizontalAlign.Center)
  }
}