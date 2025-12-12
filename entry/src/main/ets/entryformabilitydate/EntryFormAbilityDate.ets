import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import {FormIdStore} from '../Utils/FormIdStore'

export default class EntryFormAbilityDate extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    const formId = want.parameters!['ohos.extra.param.key.form_identity'] as string;

    FormIdStore.addFormId(this.context, formId);
    let dataObj = new Map<string, boolean>();
    dataObj.set('isSubscribe', false);

    const formData = formBindingData.createFormBindingData(dataObj);
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    FormIdStore.removeFormId(this.context, formId);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}