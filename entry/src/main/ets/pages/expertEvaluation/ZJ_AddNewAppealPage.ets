import { CoreUtils, FullLoading, PageTitleBuilder } from "jbase";
import { PhotoHelper, PickerUtil } from '@pura/picker_utils';
import { BusinessError } from "@kit.BasicServicesKit";
import { ImageUtil, KeyboardUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { fileUri } from "@kit.CoreFileKit";
import fs from '@ohos.file.fs'
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { image } from "@kit.ImageKit";
import { IMAGE_COMPRESSION_SIZE } from "../../config/Index";
import { generalModel } from "../../model/ZJ_Model";
import { easyDataRequest, easyUploadRequest } from "../../api/EasyRequest";
import { E_UPLOAD_FILE_HTTP,
  ZJ_APPEAL_EXPERT_EVALUATE_HTTP,
  ZJ_EXPERT_LEAVE_RESPONSE_HTTP } from "../../api/UrlConfigure";

@Builder
export function AddNewAppealPageBuilder(name: string, param: Object) {
  // console.log("aa");
  AddNewAppealPage()
}

@ComponentV2
export struct AddNewAppealPage {
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local currentTabIndex: number = 0;
  // 新增：帖子标题和内容状态
  @Local postTitle: string = "";
  @Local postContent: string = "";
  @Local selectedImages: string[] = []; // 存储选中的图片路径
  @Local selectedVideos: string[] = []; // 存储选中的图片路径
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local nsComId: string = "";
  @Local isEdit: string = "";
  @Local isVideo: string= "";
  @Local pixelMap?: image.PixelMap = undefined;
  @Local mWY_ExpertModel?: generalModel = undefined;

  aboutToAppear(): void {

  }

  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop(true);
  }

  // 处理提交按钮点击
  async handleSubmit() {

    console.log("提交请假，内容:", this.postContent);
    // 这里实现提交逻辑，调用API等
    // 关闭键盘
    KeyboardUtil.hide();

    if (this.postContent.length <= 0) {
      CoreUtils.toast($r("app.string.input_leave_content_placeholder"));
      return;
    }

    //拼装提交参数paramModel
    let paramModel: generalModel = {
      id: this.mWY_ExpertModel?.id,
      appeal: this.postContent,
      appealAppendix: this.selectedImages.join(",")
    }
    this.pageLoading = true;
    easyDataRequest(ZJ_APPEAL_EXPERT_EVALUATE_HTTP, paramModel,"POSTFORM").then((res) => {
      if (res['code'] == 0) {
        // 验证通过，进行下一步操作
        this.navPathStack.pop(true);
      }
    })
      .catch((err:object) => {
        CoreUtils.toast(err['msg'])
      }).finally(() => {
      this.pageLoading = false;
    });


  }

  // 添加图片
  handleAddImage() {

    // 关闭键盘
    KeyboardUtil.hide();

    if (this.isVideo == "1") {
      console.log("添加视频");
      if (this.selectedVideos.length >= 1) {
        CoreUtils.toast('只能添加1个视频');
        return
      }
      PhotoHelper.selectEasy({
        maxSelectNumber:1,
        MIMEType:photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE //可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
      }).then((result) => {
        if(result.length <= 0){
          return;
        }
        let uris = result;
        // pixelMap
        PhotoHelper.getPhotoAsset(uris[0]).then((photoAsset) => {
          try {
            let name = photoAsset?.get(photoAccessHelper.PhotoKeys.DISPLAY_NAME);
            let duration = photoAsset?.get(photoAccessHelper.PhotoKeys.DURATION);
            let type = photoAsset?.get(photoAccessHelper.PhotoKeys.PHOTO_TYPE);
            let title = photoAsset?.get(photoAccessHelper.PhotoKeys.TITLE.toString());
            let size = photoAsset?.get(photoAccessHelper.PhotoKeys.SIZE.toString());
            let with1 = photoAsset?.get(photoAccessHelper.PhotoKeys.WIDTH.toString());
            let height = photoAsset?.get(photoAccessHelper.PhotoKeys.HEIGHT.toString());
            let date = photoAsset?.get(photoAccessHelper.PhotoKeys.DATE_TAKEN.toString());
            let orientation = photoAsset?.get(photoAccessHelper.PhotoKeys.ORIENTATION.toString());
            console.log(`图片信息：\n文件名：${name}\n文件类型：${type}\n文件大小：${size}\n图片宽度：${with1}\n图片高度：${height}\n拍摄日期：${date}\n文件标题：${title}\n图片文件的方向：${orientation}\n视频的时长：${duration}`)


            // 检查视频时长是否在5-30秒之间
            if (duration !== undefined && duration !== null) {
              // 将毫秒转换为秒
              let durationInSeconds = Math.abs(duration as number)  / 1000;

              if (durationInSeconds < 5 || durationInSeconds > 30) {

                CoreUtils.toast("请选择时长在5-30秒的视频");
                return;
              }
            } else {
              // 如果无法获取时长信息，也提示用户
              CoreUtils.toast("无法获取视频时长信息，请选择其他视频");
              return;
            }

            this.selectedVideos = this.selectedVideos.concat(uris);

          } catch (err) {
            LogUtil.error("读取图片信息失败：" + JSON.stringify(err));
          }
          photoAsset?.getThumbnail((err, pixelMap) => {
            if (err) {
              LogUtil.error("缩略图-异常：" + JSON.stringify(err));
              return;
            }
            this.pixelMap = pixelMap;
          })
        }).catch((err: BusinessError) => {
          console.log(`读取图片，异常：\n${JSON.stringify(err)}`);
        });
      }).catch((err: BusinessError) => {
        console.log(`调用相册，异常：\n${JSON.stringify(err)}`);
      });

    } else {
      // 这里实现图片选择逻辑
      console.log("添加图片");
      if (this.selectedImages.length >= 3) {
        CoreUtils.toast('最多选择3张图片');
        return
      }
      PhotoHelper.selectEasy({
        maxSelectNumber:1,
        MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE //可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
      })
        .then(async (result) => {
          if(result.length <= 0){
            return;
          }
        let uris = result;
          if (this.selectedImages.length + uris.length > 3) {
            CoreUtils.toast('最多选择3张图片');
            return
          }

          this.pageLoading = true;
          let arrayBuffer :ArrayBuffer[] = await this.selectImages(uris);
          let param : generalModel = {
            arrImagesUint8 : arrayBuffer,
            num : "1"
          };

          easyUploadRequest(E_UPLOAD_FILE_HTTP,param)
            .then((res) => {
              this.selectedImages = this.selectedImages.concat(res["data"]);
            })
            .catch((error: Error) => {
              console.error("失败:" + error);
              CoreUtils.alert(error.toString()??"");
            }).finally(() => {
            this.pageLoading = false;
          });

      }).catch((err: BusinessError) => {
        console.log(`调用相册，异常：\n${JSON.stringify(err)}`);
      });
    }


  }
  //此方法把图片、视频集合的uri转成ArrayBuffer,上传的时候需要用 ArrayBuffer
  async selectImages(result: string[]): Promise<ArrayBuffer[]> {
    let bufferImgs: ArrayBuffer[] = [];
    // //判断是否成功
    if (result && result.length > 0) {
      for (let index = 0; index < result.length; index++) {
        let item = result[index];
        if (this.isVideo == "1") {
          //视频不压缩
          item = result[index];
        } else {
          //图片压缩
          // 给图片压缩了
          let filePath = await ImageUtil.compressPhoto(result[index], IMAGE_COMPRESSION_SIZE).catch((err: BusinessError) => {
            LogUtil.error("图片压缩异常：" + err.message);
            return "";
          });
          if (filePath == "") {
            return [];
          }
          item = filePath!; //result[index];
        }

        //创建文件信息
        let fileUriObject = new fileUri.FileUri(item);
        //获取文件名
        let name = fileUriObject.name;
        //打开文件
        let file = fs.openSync(item, fs.OpenMode.READ_ONLY);
        //读取文件大小
        let info = fs.statSync(file.fd);
        //缓存照片数据
        let bufferImg: ArrayBuffer = new ArrayBuffer(info.size);
        //写入缓存
        fs.readSync(file.fd, bufferImg);
        //关闭文件流
        fs.closeSync(file);
        bufferImgs.push(bufferImg);
      }
      return bufferImgs;
    }
    return [];
  }

  // 删除图片、视频
  handleDeleteImage(index: number) {
    if (this.isVideo == "1") {
      console.log("删除视频:", index);
      this.selectedVideos.splice(index, 1);
      this.selectedVideos = [...this.selectedVideos]; // 触发UI更新
    } else {
      console.log("删除图片:", index);
      this.selectedImages.splice(index, 1);
      this.selectedImages = [...this.selectedImages]; // 触发UI更新
    }

  }

  @Builder
  cellTitle(content?: string | Resource) {
    Stack() {
      Image($r("app.media.0814_Group4Copy7"))
        .width("100%")

      Row() {
        // 竖杠
        Column()
          .width(4)
          .height(20)
          .backgroundColor($r("app.color.main_color"))
          .margin({ right: 10 })

        Text(content) // 请添加对应的资源字符串
          .fontSize(16)
          .width(80)
      }
      .padding(10)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .width("100%")
    }
    .width("100%")
    .margin({ top: 14 })
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航条 - 修改版
        Row() {
          // 返回按钮
          Button() {
            Image($r("app.media.BFH")) // 请替换为实际的返回图标资源
              .objectFit(ImageFit.Contain)
              .width(24)
              .height(24)
          }
          .width(44)
          .height(44)
          .onClick(() => {
            this.handleBack();
          })
           // 标题
          Text($r("app.string.publish_an_appeal")) // 请添加对应的资源字符串
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor($r("app.color.white"))

          // 提交按钮
          Text($r("app.string.submit")) // 请添加对应的资源字符串
            .fontSize(16)
            .onClick(() => {
              this.handleSubmit();
            })
            .width(60)
            .height(30)
            .fontColor($r("app.color.white"))
            .textAlign(TextAlign.End)
            .padding({ right: 10, top: 5 })
        }
        .width("100%")
        .padding(10)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.main_color"))

        // 页面内容
        Scroll() {
          Column() {
            // 请假原因
            this.cellTitle($r("app.string.reasons_for_appeal"))

            TextArea({ placeholder: $r("app.string.input_appeal_content_placeholder"), text: this.postContent })
              .height(150)
              .margin(14)
              .onChange((value: string) => {
                this.postContent = value;
              })
              .padding(10)

            Divider().strokeWidth(1).color('#EEEEEE')

            if (this.isVideo == "1") {
              this.cellTitle("添加视频")
              Row() {
                // 已选图片展示和上传按钮容器
                Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                  // 已选图片
                  ForEach(this.selectedVideos, (image: string, index: number) => {
                    Stack() {
                      Image(this.pixelMap)
                        .width(90)
                        .height(90)
                        .objectFit(ImageFit.Fill)
                        .borderWidth(1)
                        .borderRadius(10)
                        .borderColor(Color.Gray)

                      // 删除按钮
                      Image($r("app.media.0615_del"))
                        .width(24)
                        .height(24)
                        .objectFit(ImageFit.Fill)
                        .position({ x: 75, y: -10 })
                        .backgroundColor(Color.Blue)
                        .borderRadius(12)
                        .onClick(() => {
                          this.handleDeleteImage(index);
                        })
                    }
                    .width(90)
                    .height(90)
                    .margin(10)
                  })

                  // 上传图片按钮 - 始终在最后一个位置
                  Image($r("app.media.photo_btn01"))
                    .width(90)
                    .height(90)
                    .objectFit(ImageFit.Contain)
                    .borderWidth(1)
                    .borderRadius(10)
                    .borderColor(Color.Gray)
                    .margin(10)
                    .onClick(() => {
                      this.handleAddImage();
                    })
                }
                .width("100%")
                .alignSelf(ItemAlign.Start)
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width("100%")
              .padding(14)
            }
            else {
              this.cellTitle("其他材料")
              Row() {
                // 已选图片展示和上传按钮容器
                Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                  // 已选图片
                  ForEach(this.selectedImages, (image: string, index: number) => {
                    Stack() {
                      Image(image)
                        .width(90)
                        .height(90)
                        .objectFit(ImageFit.Fill)
                        .borderWidth(1)
                        .borderRadius(10)
                        .borderColor(Color.Gray)

                      // 删除按钮
                      Image($r("app.media.0615_del"))
                        .width(24)
                        .height(24)
                        .objectFit(ImageFit.Fill)
                        .position({ x: 75, y: -10 })
                        .backgroundColor(Color.Blue)
                        .borderRadius(12)
                        .onClick(() => {
                          this.handleDeleteImage(index);
                        })
                    }
                    .width(90)
                    .height(90)
                    .margin(10)
                  })

                  // 上传图片按钮 - 始终在最后一个位置
                  Image($r("app.media.photo_btn01"))
                    .width(90)
                    .height(90)
                    .objectFit(ImageFit.Contain)
                    .borderWidth(1)
                    .borderRadius(10)
                    .borderColor(Color.Gray)
                    .margin(10)
                    .onClick(() => {
                      this.handleAddImage();
                    })
                }
                .width("100%")
                .alignSelf(ItemAlign.Start)
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width("100%")
              .padding(14)
            }

          }.width("100%")
        }.width("100%").padding({bottom:50})

        FullLoading({ loading: this.pageLoading })
      }
      .height("100%")
      .backgroundColor($r("app.color.white"))
    }
    .hideTitleBar(true)
    // .backButtonIcon($r("app.media.arrow_left_b_n"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack

      try {
        this.mWY_ExpertModel = this.navPathStack.getParamByName('AddNewAppealPage')[0] as generalModel;
        this.isVideo = "0";
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }
}