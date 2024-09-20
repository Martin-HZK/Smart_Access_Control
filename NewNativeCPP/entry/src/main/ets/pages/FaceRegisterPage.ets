import FileUtils from '../utils/FileUtils'
import FaceUtils from '../utils/FaceUtils'
import promptAction from '@ohos.promptAction'
import { BusinessError } from '@ohos.base'
import FaceNAPI from 'libentry.so'
import taskpool from '@ohos.taskpool';
import common from '@ohos.app.ability.common';

@Concurrent
function loadFDBModel():boolean {
  return FaceNAPI.LoadModelCallBack();
}

async function asyncLoad():Promise<void> {
  let task:taskpool.Task = new taskpool.Task(loadFDBModel)
  let res:boolean = await taskpool.execute(task) as boolean
  if (res == true) {
    PersistentStorage.persistProp('modelLoaded', true) // when successfully loaded, we need to change the number to true to avoid loading another time in register stage
  }
  console.info("taskpool:task res is: " + res)
}


@Concurrent
function registerFace(path:string):boolean {
  return FaceNAPI.FaceRegister(path);
}

async function asyncRegister(path:string):Promise<void> {
  let task:taskpool.Task = new taskpool.Task(registerFace, path)
  let res:boolean = await taskpool.execute(task) as boolean

  console.log("The register functionality return: " + res)
}

@Entry
@Component
struct FaceRegisterPage {
  @State message: string = 'Hello Reg';
  @State fileUtils: FileUtils = new FileUtils();
  @State faceUtils: FaceUtils = new FaceUtils();

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(async()=> {
            console.log("The persistent storage is: " + AppStorage.get<boolean>('isRawNewDB'))
          })
        Button("Register")
          .type(ButtonType.Normal)
          .onClick(async()=>{
            if (!AppStorage.get<boolean>('modelLoaded')) {
              asyncLoad();
              let pollInterval = 500; // 轮询间隔时间(ms)

              const checkModelLoaded = () => {
                return new Promise<boolean>((resolve, reject) => {
                  let intervalId = setInterval(async () => {
                    try {
                      // 假设这是你导出的 NAPI 接口
                      let isLoaded:boolean = await this.faceUtils.checkModelLoadStatus();

                      if (isLoaded) {
                        clearInterval(intervalId); // 模型加载完成，清除定时器
                        resolve(true); // 返回成功状态
                      } else {
                        console.log("Model not loaded yet, retrying...");
                      }
                    } catch (err) {
                      clearInterval(intervalId);
                      reject(err); // 处理错误
                    }
                  }, pollInterval);
                });
              };

              await checkModelLoaded();

              console.log("Successfully load the models!")

              this.faceUtils.setFDBLoadStatusToDefault();

              console.log("The loadStatus is changed to: " + this.faceUtils.checkModelLoadStatus())
            }

            // Load the FDB
            let ctx = getContext(this) as common.UIAbilityContext
            let rootDir = ctx.filesDir
            this.faceUtils.loadFaceDB(rootDir)


            let storagePaths : string[] = this.fileUtils.getTmpFilesInDirectory(getContext(this).filesDir)
            if(storagePaths.length == 0) {
                console.log("NULL path")
             } else {
              let imgPath: string = getContext(this).filesDir + "/" + storagePaths[0]
              console.log("This is the storage path: " + imgPath)
              asyncRegister(imgPath)
            }


            //
            //
            //   // call face register function
            //   // try {
            //   //   let retNum = await this.faceUtils.faceRegister(imgPath)
            //   //   console.log("The return number of face register is: " + retNum)
            //   // } catch (err) {
            //   //   console.log("Error registering faces: " + err)
            //   // }
            //
            //
            //   this.fileUtils.deleteTmpFile(imgPath)
            //   console.log("Register finished")
            // }
            // try {
            //   promptAction.showToast({
            //     message: 'Register Successfully',
            //     duration: 2000
            //   });
            // } catch (error) {
            //   let message = (error as BusinessError).message
            //   let code = (error as BusinessError).code
            //   console.error(`showToast args error code is ${code}, message is ${message}`);
            // };
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}