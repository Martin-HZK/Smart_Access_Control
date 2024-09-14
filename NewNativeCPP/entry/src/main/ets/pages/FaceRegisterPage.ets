import FileUtils from '../utils/FileUtils'
import FaceUtils from '../utils/FaceUtils'
import promptAction from '@ohos.promptAction'
import { BusinessError } from '@ohos.base'
import FaceNAPI from 'libentry.so'
import taskpool from '@ohos.taskpool';
@Concurrent
function loadFDBModel():boolean {
  return FaceNAPI.LoadModelCallBack();
}

async function asyncLoad():Promise<void> {
  let task:taskpool.Task = new taskpool.Task(loadFDBModel)
  let res:boolean = await taskpool.execute(task) as boolean

  console.info("taskpool:task res is: " + res)
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
        Button("Register")
          .type(ButtonType.Normal)
          .onClick(async()=>{
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


            let storagePaths : string[] = this.fileUtils.getTmpFilesInDirectory(getContext(this).filesDir)
            if(storagePaths.length == 0) {
                console.log("NULL path")
             } else {
              let imgPath:string = getContext(this).filesDir +"/" + storagePaths[0]
              console.log("This is the storage path: "+imgPath)
              await this.faceUtils.openCVTest(imgPath);

              // call face register function
              // try {
              //   let retNum = await this.faceUtils.faceRegister(imgPath)
              //   console.log("The return number of face register is: " + retNum)
              // } catch (err) {
              //   console.log("Error registering faces: " + err)
              // }


              this.fileUtils.deleteTmpFile(imgPath)
              console.log("Register finished")
            }
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