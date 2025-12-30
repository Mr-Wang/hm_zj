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
  ZJ_EXPERT_LEAVE_RESPONSE_HTTP,
  ZJ_REWARD_APPLY_HTTP,
  ZJ_REWARD_CODE_HTTP} from "../../api/UrlConfigure";
import { systemShare } from "@kit.ShareKit";
import { common } from "@kit.AbilityKit";
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { DialogHelper } from "@pura/harmony-dialog";

@Builder
export function ApplyForBonusPointsPageBuilder(name: string, param: Object) {
  // console.log("aa");
  ApplyForBonusPointsPage()
}

@ComponentV2
export struct ApplyForBonusPointsPage {
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local currentTabIndex: number = 0;
  // 新增：帖子标题和内容状态
  @Local postTitle: string = "";
  @Local postContent: string = "";
  @Local selectedImages: string[] = []; // 存储选中的图片路径
  @Local selectedImages1: string[] = []; // 存储选中的图片路径
  @Local selectedVideos: string[] = []; // 存储选中的图片路径
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local nsComId: string = "";
  @Local isEdit: string = "";
  @Local isVideo: string= "";
  @Local pixelMap?: image.PixelMap = undefined;
  @Local mWY_ExpertModel?: generalModel = undefined;

  @Local sxlxArray:generalModel[] = [];
  @Local mendwhysArray: string[] =[];
  @Local selMendwhys: string = "";
  @Local selMendwhysIndex: number = 0;

  aboutToAppear(): void {

  }

  loadTabsData() {
    this.pageLoading = true;

    easyDataRequest(ZJ_REWARD_CODE_HTTP,{},"POSTFORM").then((res) => {
      this.sxlxArray = res?.["data"]|| [];
      if (this.sxlxArray.length > 0) {
        this.mendwhysArray = this.sxlxArray.map(item => item.name??"");
      } else {
        this.mendwhysArray = [];
      }
      LogUtil.info("loadTabsData success: " + JSON.stringify(res));
      this.pageLoading = false;
      this.refreshIndex++;
    })
      .catch((err:string) => {
        LogUtil.error("loadTabsData error: " + err);
      })
      .finally(() => {
        this.pageLoading = false;
        this.refreshIndex++;
      });
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
      CoreUtils.toast("请输入具体内容");
      return;
    }

    if (this.selMendwhys == "") {
      DialogHelper.showToast("请选择事项类型");
      return;
    }
    //拼装提交参数paramModel
    let paramModel: generalModel = {
      rewardContent: this.postContent,
      rewardTerms: this.selMendwhys,
      rewardTermsCode: this.sxlxArray[this.selMendwhysIndex].code,
      scoreStandard:  this.sxlxArray[this.selMendwhysIndex].scoreStandard,
    }

    paramModel.sysAttachList = [];
    for (let i = 0; i < this.selectedImages.length; i++) {
      let fileItem :generalModel =  {
        sysAttachcol:"1",
        url: this.selectedImages[i]
      }
      paramModel.sysAttachList?.push(fileItem);
    }
    for (let i = 0; i < this.selectedImages1.length; i++) {
      let fileItem :generalModel =  {
        sysAttachcol:"2",
        url: this.selectedImages[i]
      }
      paramModel.sysAttachList?.push(fileItem);
    }

    this.pageLoading = true;
    easyDataRequest(ZJ_REWARD_APPLY_HTTP, paramModel,"POST").then((res) => {
      if (res['code'] == 0) {
        // 验证通过，进行下一步操作
        CoreUtils.alert("提交成功");
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
  handleAddImage(type:number = 0) {

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
      if (type == 1) {
        if (this.selectedImages1.length >= 1) {
          CoreUtils.toast('最多选择1张图片');
          return
        }
      }else {
        if (this.selectedImages.length >= 3) {
          CoreUtils.toast('最多选择3张图片');
          return
        }
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

          if (type == 1) {
            if (this.selectedImages1.length >= 1) {
              CoreUtils.toast('最多选择1张图片');
              return
            }
          }else {
            if (this.selectedImages.length + uris.length > 3) {
              CoreUtils.toast('最多选择3张图片');
              return
            }
          }



          this.pageLoading = true;
          let arrayBuffer :ArrayBuffer[] = await this.selectImages(uris);
          let param : generalModel = {
            arrImagesUint8 : arrayBuffer,
            num : "1"
          };

          easyUploadRequest(E_UPLOAD_FILE_HTTP,param)
            .then((res) => {
              if (type == 1) {
                this.selectedImages1 = this.selectedImages1.concat(res["data"]);
              } else {
                this.selectedImages = this.selectedImages.concat(res["data"]);
              }

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
  handleDeleteImage(index: number,type: number = 0) {
    if (this.isVideo == "1") {
      console.log("删除视频:", index);
      this.selectedVideos.splice(index, 1);
      this.selectedVideos = [...this.selectedVideos]; // 触发UI更新
    } else {
      console.log("删除图片:", index);
      if (type == 1) {
        this.selectedImages1.splice(index, 1);
        this.selectedImages1 = [...this.selectedImages1]; // 触发UI更新
      } else {
        this.selectedImages.splice(index, 1);
        this.selectedImages = [...this.selectedImages]; // 触发UI更新
      }

    }

  }

  @Builder
  cellTitle(content?: string | Resource, status?: string | Resource, onMoreClick?: () => void) {
    Stack() {
      // Image($r("app.media.0814_Group4Copy7"))
      //   .width("100%")

      Row() {
        // 竖杠
        Image($r("app.media.1127_shutiao"))
          .width(4)
          .height(20)
          .margin({ right: 10 })

        Text(content) // 请添加对应的资源字符串
          .fontSize(16)
          .fontColor($r("app.color.black"))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        // Image($r("app.media.0219xtzscell"))
        //   .width(61)
        //   .height(15)
        //   .margin({ right: 10 })
        // 状态文本
        // Text(status) // 请添加对应的资源字符串
        //   .fontSize(12)
        //   .fontColor($r("app.color.black"))

        if (onMoreClick) {
          Text(status) // 请添加对应的资源字符串
            .fontSize(14)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .fontColor($r("app.color.white"))
            .backgroundColor($r("app.color.main_color"))
            .borderRadius(5)
            .onClick(() => {
              onMoreClick();
            })
        }
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
          Text($r("app.string.apply_for_bonus_points")) // 请添加对应的资源字符串
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



            this.cellTitle("事项类型：")

            Row() {
              Row(){
                Text() {
                  Span(this.selMendwhys.length>0 && this.selMendwhys !== "无"  ?this.selMendwhys: "请选择事项类型")
                    .fontColor(this.selMendwhys.length>0 && this.selMendwhys !== "无"?$r("app.color.black"):$r("app.color.gl_666"));
                }
                .fontSize(14)
                .textAlign(TextAlign.Start)
                .layoutWeight(1)

                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontColor([$r('app.color.gl_888')])
                  .fontSize(24)
                  .margin({ left: 10 })
              }
              .padding({top:8, bottom: 8, left: 16, right: 16})
              .border({width: 1, color: $r("app.color.color_line"),radius: 5})
              .layoutWeight(1)
            }
            .onClick(() => {
              // let array: string[] = (this.generalModelPageData?.hair?.["xvalue"] ?? "").split(",");
              console.log("点击了事项类型选择");
              console.log("---"+this.mendwhysArray.length);
              if (this.mendwhysArray.length > 0) {
                DialogHelper.showActionSheetDialog({
                  title: "请选择事项类型",
                  cancelFontColor: Color.Red,
                  cancelFontWeight: FontWeight.Normal,
                  backCancel:true,
                  sheets: this.mendwhysArray,
                  onAction: (index) => {
                    console.log("点击了："+this.mendwhysArray[index]);
                    this.selMendwhys = this.mendwhysArray[index];
                    this.selMendwhysIndex = index;
                  }
                })
              } else {
                this.loadTabsData();
              }

            })
            .justifyContent(FlexAlign.Start)
            .padding({top:5, bottom: 5, left: 16, right: 16})
            .width("100%")
            .border({ width: { bottom: 1 }, color: $r("app.color.color_line") })


            Divider().strokeWidth(1).color('#EEEEEE')

            this.cellTitle("具体内容：")

            TextArea({ placeholder: "请输入具体内容", text: this.postContent })
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

              this.cellTitle("请上传证明材料（最多3张）：")
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

              Divider().strokeWidth(1).color('#EEEEEE')

              this.cellTitle("请上传辽宁省综合评标专家库评标专家奖励加分申请表（最多1张）：","下载模板",()=> {
                  //   https://www.capass.cn/Avatar/expert_award_apply.pdf
                let shareUrl :string = "https://www.capass.cn/Avatar/expert_award_apply.pdf";
                console.log("分享链接:"+shareUrl);
                let data: systemShare.SharedData = new systemShare.SharedData({
                  utd: utd.UniformDataType.HTML,
                  content: shareUrl//'Hello HarmonyOS'
                });
                let controller: systemShare.ShareController = new systemShare.ShareController(data);
                // 获取UIAbility上下文对象
                let uiContext: UIContext = this.getUIContext();
                let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
                controller.show(context, {
                  previewMode: systemShare.SharePreviewMode.DETAIL,
                  selectionMode: systemShare.SelectionMode.SINGLE
                });
              });
              Row() {
                // 已选图片展示和上传按钮容器
                Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                  // 已选图片
                  ForEach(this.selectedImages1, (image: string, index: number) => {
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
                          this.handleDeleteImage(index,1);
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
                      this.handleAddImage(1);
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
        this.mWY_ExpertModel = this.navPathStack.getParamByName('ApplyForBonusPointsPage')[0] as generalModel;
        this.isVideo = "0";
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }


}