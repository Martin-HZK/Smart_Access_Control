import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import FaceUtils from '../utils/FaceUtils'
export default class EntryAbility extends UIAbility {
  faceutils:FaceUtils = new FaceUtils();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // let ctx = getContext(this) as common.UIAbilityContext
    // let rootDir = ctx.filesDir
    let ctx = this.context
    let rootDir = ctx.filesDir
    // console.log("the seetatest number is:" + seetaTest())
    console.log("this is the context root dir: " + rootDir)

    PersistentStorage.persistProp('modelLoaded', false)


  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    let ctx = this.context
    let rootDir = ctx.filesDir
    try {
      this.faceutils.saveFaceDB(rootDir)
      console.log("[SUCCESS] Face database saved successfully")
    } catch (err) {
      console.log("Fail to save the face FDB: " + err)
    }
    PersistentStorage.persistProp('modelLoaded', false)
    console.log("The modelLoad status in js is set to [" + AppStorage.get<number>('modelLoaded') + "] after quit")
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
