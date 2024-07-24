import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import camera from '@ohos.multimedia.camera';
import image from '@ohos.multimedia.image'
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import fs from '@ohos.file.fs';
import {hilog} from '@kit.PerformanceAnalysisKit'
import {BusinessError} from '@ohos.base';

const TAG: string= '[TakePicAbility]';
const DOMAIN_NUMBER: number = 0xFF00;


export default class CameraAbility extends UIAbility {
  windowStage: window.WindowStage | undefined = undefined

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.windowStage = windowStage
    windowStage.loadContent('pages/TakePicPage', (err, data) => {
      console.log("Error: ${err.code}")
    })
  }

  onWindowStageDestroy(): void {
    try {
      if (this.windowStage) {
        this.windowStage.off('windowStageEvent')
      }
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      hilog.error(DOMAIN_NUMBER, TAG, 'Failed to destroy, the code is ${code} and the message is ${message}')
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let context = this.context
  }
}