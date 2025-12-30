import { ContextUtils, CoreUtils, FullLoading, PageTitleBuilder, UserInfo } from "jbase";
import { PhotoHelper, PickerUtil } from '@pura/picker_utils';
import { BusinessError } from "@kit.BasicServicesKit";
import { ImageUtil, KeyboardUtil, LogUtil, RegexUtil, StrUtil, ToastUtil } from "@pura/harmony-utils";
import { fileUri } from "@kit.CoreFileKit";
import fs from '@ohos.file.fs'
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { image } from "@kit.ImageKit";
import { APP_ID_WX, IMAGE_COMPRESSION_SIZE } from "../../config/Index";
import { generalModel, justifyTextModel } from "../../model/ZJ_Model";
import { easyDataRequest, easyUploadRequest } from "../../api/EasyRequest";
import { E_UPLOAD_FILE_HTTP,
  UPDATE_USER_INFO_HTTP,
  ZJ_CREATE_DD_HTTP,
  ZJ_EXPERT_LEAVE_RESPONSE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP,
  ZJ_HANDLE_CLOUD_SIGNATURE_HTTP,
  ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP,
  ZJ_SYS_GET_INFO_HTTP} from "../../api/UrlConfigure";
import { CFCASCAP,CFCASCAPConstants } from "scap";
import { DialogHelper } from "@pura/harmony-dialog";
import { Previewer } from "@humor/lg-image-previewer";
import { ShareWxSdk } from "@zyl/wxcommonlibhar";
import { BaseResp, LaunchMiniProgramReq, PayReq, PayResp, SendReqResultWrap } from "@tencent/wechat_open_sdk";
import { call } from "@kit.TelephonyKit";

@Builder
export function UKeyCAHandlePayPageBuilder(name: string, param: Object) {
  // console.log("aa");
  UKeyCAHandlePayPage()
}

@ComponentV2
export struct UKeyCAHandlePayPage {
  @Local isInvoice: string = "0"; //1是开具发票，0不是
  @Local isLqType: string = "1"; //收货方式1领取、2邮寄
  @Local selCity: string = "1"; //领取、收货城市 1 沈阳 ，2 大连

  @Local payType: string = "wx";

  @Local caAgree: boolean = false;
  // 申请人姓名
  @Local txtName: string = "";
  //身份证号
  @Local txtIdCardNo: string = "";
  //手机号码
  @Local txtPhone: string = "";
  //单位名称
  @Local txtCompanyName: string = "";
  //邮箱
  @Local txtEmail: string = "";
  // 签名图片路径
  @Local signImgUrl: string = "";


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
  @Local dicSignUpSuccess?: generalModel = undefined;

  @Local selAddress?: generalModel = undefined;


  private userinfoModel?:UserInfo = undefined;

  aboutToAppear(): void {
    easyDataRequest(ZJ_SYS_GET_INFO_HTTP,{},"GET").then((res) => {
      ContextUtils.setUserInfo(res["data"]);

      this.userinfoModel = res["data"] ?? {};
      this.txtName = this.userinfoModel?.realname ?? "";
      this.txtIdCardNo = this.userinfoModel?.idcardnum ?? "";
      this.txtPhone = this.userinfoModel?.loginID ?? "";
      this.txtCompanyName = this.userinfoModel?.danWeiName ?? "";
      this.txtEmail = this.userinfoModel?.EMail ?? "";
      this.signImgUrl = this.userinfoModel?.userSignature ?? "";
    })


  }

  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop(true);
  }

  // 处理提交按钮点击
  async handleSubmit() {


          //生成 P10
          this.submitPost();




  }

  @Builder
  customTextImgBuilder(imgUrl: string | undefined) {
    Row() {
      Image(imgUrl)
        .width(200)
        .height(100)
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    //水平居中
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)

  }

  private submitPost() {
    this.pageLoading = true;
    if (this.mWY_ExpertModel) {
      this.mWY_ExpertModel.isInvoice = this.isInvoice;
    }

    let disPost:generalModel =  this.mWY_ExpertModel ?? {};

    disPost.shfs = this.isLqType;

    if (this.isLqType == "1") {
      disPost.shrxm = "";
      disPost.shrdh = "";
      disPost.provinceCode = "";
      disPost.cityCode = "";
      disPost.countryCode = "";
      disPost.shrdz = "";
    } else {
     //收货人姓名 收货人电话 收货地址
      disPost.shrxm = this.selAddress?.UserName;
      disPost.shrdh = this.selAddress?.Mobile;
      disPost.provinceCode = this.selAddress?.ProvinceCode;
      disPost.cityCode = this.selAddress?.CityCode;
      disPost.countryCode = this.selAddress?.CountryCode;
      disPost.shrdz = this.selAddress?.addressStr;
    }

    if (this.selCity == "1") {
      disPost.cityCode = "0024";
      disPost.fhcityCode = "0024";
    } else {
      disPost.cityCode = "0411";
      disPost.fhcityCode = "0411";
    }
    disPost.userGuid = ContextUtils.getUserInfo()?.userGuid;
    if (this.mWY_ExpertModel?.zddid) {
      // disPost.ddId = this.mWY_ExpertModel?.zddid;
    }
    if (this.mWY_ExpertModel?.isEdit == "1" || this.mWY_ExpertModel?.isEdit == "2") {
      disPost.status = "0";
    }

          easyDataRequest(ZJ_CREATE_DD_HTTP, disPost??{}, "POST").then((res) => {

            // easyDataRequest(UPDATE_USER_INFO_HTTP,{userSignature:this.mWY_ExpertModel?.signature},"POST").then((res) => {
            //   console.log("更新签名图片成功", res["data"])
            //   CoreUtils.toast("更新签名图片成功");
            // })
            this.dicSignUpSuccess = res["data"];
            this.tongLianPay();
            // CoreUtils.alert("云签章申请成功，请前往使用", () => {
            //   this.navPathStack.pop({ isRefresh: true }, true);
            // });
          }).catch((err: object) => {
            CoreUtils.toast(err["msg"] ?? "请求失败，请稍后再试");
            this.navPathStack.popToName("CAHandleMainPage",{isRefresh:true},true)
            this.navPathStack.pushPathByName("CAOrderMainPage",null,true)
          }).finally(() => {
            this.pageLoading = false;
          })

  }

  //通联支付
  tongLianPay(){
    if(this.payType == "wx") {

      // WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
      // launchMiniProgramReq.userName = @"gh_65f0c33e8486";  //拉起的小程序的username
      // launchMiniProgramReq.path = [NSString stringWithFormat:@"pages/pay/pay?orderGuid=%@&out_trade_no=%@&paymethod=%@&userGuid=%@&body=%@&token=%@",tempPayModel.orderGuid,tempPayModel.out_trade_no,tempPayModel.paymethod,self.mUser.UserGuid,tempPayModel.body,self.mUser.token];
      // launchMiniProgramReq.miniProgramType = WXMiniProgramTypeRelease; //拉起小程序的类型
      // [WXApi sendReq:launchMiniProgramReq completion:^(BOOL success) {
      //   NSLog(@"成功");
      //   [self waitingForPayment];
      // }];
      //跳转到微信小程序
      let share = new ShareWxSdk(APP_ID_WX)
      share.wechatLaunchMiniProgram({
        userName:"gh_65f0c33e8486",
        path: `pages/pay/pay?orderGuid=${this.dicSignUpSuccess?.orderguid}&out_trade_no=${this.dicSignUpSuccess?.orderno}&paymethod=03&userGuid=${ContextUtils.getUserInfo()?.userGuid}&body=${this.dicSignUpSuccess?.sqjg}&token=${ContextUtils.getToken()}`,
        miniprogramType: 0, // 拉起小程序的类型
      }as LaunchMiniProgramReq).then((res:SendReqResultWrap)=>{

        if(res instanceof PayResp){
          // 使用支付的类型
        }
        console.log('支付完成后，从微信回来的回调',JSON.stringify(res))
        this.waitingForPayment();
      })


    } else {
      CoreUtils.alert("暂不支持支付宝支付");
      return;
    }
  }
  waitingForPayment() {
    CoreUtils.alert("你有一笔支付正在进行中,请稍后再进行新的操作", () => {
      this.chenggong();
    },true);
  }
  chenggong() {
    easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_HTTP, {orderNo:this.dicSignUpSuccess?.orderNo}, "POST").then((res) => {
      if (res["data"] && res["data"]["orderStatus"] == 2) {
        //已支付
        CoreUtils.alert("恭喜您，签名申请成功", () => {
          this.navPathStack.popToName("CAHandleMainPage",{isRefresh:true},true)
          this.navPathStack.pushPathByName("CAOrderMainPage",null,true)
        });
      } else {
        CoreUtils.toast("未查询到您订单的支付状态，请前往订单列表页查询");
        this.navPathStack.popToName("CAHandleMainPage",{isRefresh:true},true)
        this.navPathStack.pushPathByName("CAOrderMainPage",null,true)
      }
    }).catch((err: object) => {
      CoreUtils.toast("请求失败，请稍后再试");
    })
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
      if (this.selectedImages.length >= 8) {
        CoreUtils.toast('最多选择8张图片');
        return
      }
      PhotoHelper.selectEasy({
        maxSelectNumber:1,
        MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE //可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
      })
        .then(async (result) => {
          let uris = result;
          if (this.selectedImages.length + uris.length > 8) {
            CoreUtils.toast('最多选择8张图片');
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
          Text($r("app.string.ukey_processing")) // 请添加对应的资源字符串
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor($r("app.color.white"))

          // 提交按钮
          Text($r("app.string.next")) // 请添加对应的资源字符串
            .fontSize(16)
            .onClick(() => {
              this.handleSubmit();
            })
            .width(60)
            .height(30)
            .fontColor($r("app.color.white"))
            .textAlign(TextAlign.End)
            .visibility(Visibility.Hidden)
            .padding({ right: 10, top: 5 })
        }
        .width("100%")
        .padding(10)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.main_color"))

        // 页面内容
        Scroll() {
          Column() {
            // 顶部步骤
            Row(){
              Column(){
                Image($r("app.media.0611_ws1"))
                  .width(30)
                  .height(30)
                Text("证书信息")
                  .fontColor("#0F6DD2")
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 5 })
              }
              Text("………")
                .fontColor("#0F6DD2)")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)

              Column(){
                Image($r("app.media.0611_ws2"))
                  .width(30)
                  .height(30)
                Text("申请书")
                  .fontColor("#0F6DD2")
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 5 })
              }

              Text("………")
                .fontColor("#0F6DD2)")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)

              Column(){
                Image($r("app.media.0611_ws3"))
                  .width(30)
                  .height(30)
                Text("订单支付")
                  .fontColor("#0F6DD2")
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 5 })
              }

            }
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ top: 5,bottom:5, left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Column({space: 5}) {
            Row(){
              Text("证书信息")
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)

            }
            .justifyContent(FlexAlign.Start)
            .width("100%")

            Row(){
              Text(this.mWY_ExpertModel?.sqjg ??"")
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Image($r("app.media.0420_usbkey_sel"))
                .width(55)
                .height(55)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width("100%")

              Row(){
                Text("关联平台：") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                Text(this.mWY_ExpertModel?.glpt ??"") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)
              Row(){
                Text("金　　额：") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                Text(parseFloat(this.mWY_ExpertModel?.money).toFixed(2) + "元") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)

              Row(){
                Text("有 效 期 ：") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                Text("自数字证书(CA)制作之日起一年内有效") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)

              Row(){
              Text("重新编辑")
                .margin({top: 10})
                .padding(8)
                .fontSize(14)
                .fontColor($r("app.color.white"))
                .backgroundColor($r("app.color.main_color"))
                .borderRadius(5)
                .onClick(()=> {
                  this.navPathStack.pop(true);
                })
              }
              .width("100%")
              .justifyContent(FlexAlign.End)

              Divider()
                .strokeWidth(5)
                .color($r("app.color.main_background"))
                .margin({ top: 10 ,bottom: 10,left: -16, right: -16 })

              Row(){
                Text("领取方式")
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")

              Row(){


                Row(){
                  if(this.isLqType == '2'){
                    Image($r('app.media.0316_sel'))
                      .width(20)
                  } else {
                    Image($r('app.media.yuan2'))
                      .width(20)
                  }

                  Text("邮寄")
                    .fontSize(16)
                    .margin({left: 5,right: 16})
                }
                .padding(5)
                .onClick(()=> {
                  this.isLqType = '2';
                })
                .layoutWeight(1)

                Row(){
                  if(this.isLqType == '1'){
                    Image($r('app.media.0316_sel'))
                      .width(20)
                  } else {
                    Image($r('app.media.yuan2'))
                      .width(20)
                  }
                  Text("领取")
                    .fontSize(16)
                    .margin({left: 5})
                }
                .layoutWeight(1)
                .padding(5)
                .onClick(()=> {
                  this.isLqType = '1';
                })
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")


              Divider()
                .strokeWidth(5)
                .color($r("app.color.main_background"))
                .margin({ top: 10 ,bottom: 10,left: -16, right: -16 })

              Row(){
                Text(this.isLqType == "2"? "发货城市":"领取城市")
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")

              Row(){

                Row(){
                  if(this.selCity == '1'){
                    Image($r('app.media.0316_sel'))
                      .width(20)
                  } else {
                    Image($r('app.media.yuan2'))
                      .width(20)
                  }

                  Text("沈阳市")
                    .fontSize(16)
                    .margin({left: 5,right: 16})
                }
                .padding(5)
                .onClick(()=> {
                  this.selCity = '1';
                })
                .layoutWeight(1)

                Row(){
                  if(this.selCity == '2'){
                    Image($r('app.media.0316_sel'))
                      .width(20)
                  } else {
                    Image($r('app.media.yuan2'))
                      .width(20)
                  }
                  Text("大连市")
                    .fontSize(16)
                    .margin({left: 5})
                }
                .layoutWeight(1)
                .padding(5)
                .onClick(()=> {
                  this.selCity = '2';
                })
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")

              Divider()
                .strokeWidth(5)
                .color($r("app.color.main_background"))
                .margin({ top: 10 ,bottom: 10,left: -16, right: -16 })

              Row(){
                Text(this.isLqType == "2"? "收货信息：":"领取信息")
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")

              if (this.isLqType == "1") {
                //领取
                Row(){
                  Text(this.selCity == "1"? this.mWY_ExpertModel?.lqbz: this.mWY_ExpertModel?.lqbz1)
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Image($r("app.media.0420_usbkey_sel"))
                    .width(55)
                    .height(55)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width("100%")

                Row(){
                  Text("联系单位：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(this.selCity == "1"? this.mWY_ExpertModel?.lqdw: this.mWY_ExpertModel?.lqdw1) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                Row(){
                  Text("领取地址：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(this.selCity == "1"? this.mWY_ExpertModel?.lqdz: this.mWY_ExpertModel?.lqdz1) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                Row(){
                  Text("联 系 人 ：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(this.selCity == "1"? this.mWY_ExpertModel?.lqlxr: this.mWY_ExpertModel?.lqlxr1) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                Row(){
                  Text("联系电话：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(this.selCity == "1"? this.mWY_ExpertModel?.lqdh: this.mWY_ExpertModel?.lqdh1) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                  Image($r("app.media.0317phone"))
                    .width(22)
                    .height(22)
                    .onClick(()=> {
                      this.callPhone(this.selCity == "1"? this.mWY_ExpertModel?.lqdh: this.mWY_ExpertModel?.lqdh1)
                    })
                }
                .alignItems(VerticalAlign.Top)

              } else {
                //邮寄
                //请选择收货地址
                Row() {
                  Text("收货地址")
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                }
                .justifyContent(FlexAlign.Start)
                .width("100%")
                .margin({ top: 10 })

                Row() {
                  Text("张三 13940123456") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)

                }
                .alignItems(VerticalAlign.Top)

              }

              Divider()
                .strokeWidth(5)
                .color($r("app.color.main_background"))
                .margin({ top: 10 ,bottom: 10,left: -16, right: -16 })

              Row(){
                Text("支付方式")
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")

              Row(){
                Image($r('app.media.0317wchat'))
                  .width(20)
                  .objectFit(ImageFit.Fill)
                  .margin({right: 16})
                Text("微信支付")
                  .fontSize(16)
                  .layoutWeight(1)
                if(this.payType == 'wx'){
                  Image($r('app.media.0316_sel'))
                    .width(20)
                } else {
                  Image($r('app.media.yuan2'))
                    .width(20)
                }
              }
              .padding({left:16,top:16})
              .onClick(()=> {
                this.payType = 'wx';
              })

              Row(){
                Image($r('app.media.0317alipay'))
                  .width(20)
                  .objectFit(ImageFit.Fill)
                  .margin({right: 16})
                Text("支付宝支付")
                  .fontSize(16)
                  .layoutWeight(1)
                if(this.payType == 'zfb'){
                  Image($r('app.media.0316_sel'))
                    .width(20)
                } else {
                  Image($r('app.media.yuan2'))
                    .width(20)
                }
              }
              .padding({left:16,top:16})
              .onClick(()=> {
                this.payType = 'zfb';
              })

              Divider()
                .strokeWidth(5)
                .color($r("app.color.main_background"))
                .margin({ top: 16 ,bottom: 10,left: -16, right: -16 })

              Row(){
                Text("是否开具电子发票")
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)

                Row(){
                if(this.isInvoice == '1'){
                  Image($r('app.media.0316_sel'))
                    .width(20)
                } else {
                  Image($r('app.media.yuan2'))
                    .width(20)
                }

                Text("是")
                  .fontSize(16)
                  .margin({left: 5,right: 16})
                }
                .padding(5)
                .onClick(()=> {
                  this.isInvoice = '1';
                })

                Row(){
                  if(this.isInvoice == '0'){
                    Image($r('app.media.0316_sel'))
                      .width(20)
                  } else {
                    Image($r('app.media.yuan2'))
                      .width(20)
                  }
                  Text("否")
                    .fontSize(16)
                    .margin({left: 5})
                }
                .padding(5)
                .onClick(()=> {
                  this.isInvoice = '0';
                })
              }
              .justifyContent(FlexAlign.Start)
              .width("100%")
              if (this.isInvoice == '1') {

                Text("您办理的云签章为您的个人行为，根据《中华人民共和国发票管理办法》第十九、二十条规定，本公司将为您提供增值税电子普通发票，抬头为申请人姓名。增值税电子普通发票法律效力、基本用途、基本使用规定等与增值税普通发票相同，如需纸质普通发票请联系财务024-67793888。")
                  .fontColor($r("app.color.red_color"))
                  .fontSize(14)
                  .margin({top: 10})
                  .lineHeight(24)

                Text("发票样式预览")
                  .margin({top: 10})
                  .padding(8)
                  .fontSize(14)
                  .fontColor($r("app.color.white"))
                  .backgroundColor($r("app.color.main_color"))
                  .borderRadius(5)
                  .onClick(()=> {
                      //   http://lnwlzj.capass.cn/lnwlzj/1ac0aab102f247b68eec5e411cbddc13.jpg
                  //   图片预览
                    Previewer.show(
                      {
                        imgList: [{ url: encodeURI("http://lnwlzj.capass.cn/lnwlzj/1ac0aab102f247b68eec5e411cbddc13.jpg"), id: "image1" }],
                        initIndex: 0,
                      }
                    )
                  })

                Divider()
                  .strokeWidth(5)
                  .color($r("app.color.main_background"))
                  .margin({ top: 16 ,bottom: -16,left: -16, right: -16 })
              }

            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .width("100%")

          }.width("100%")
        }.width("100%")
        .layoutWeight(1)
        .align(Alignment.TopStart)

        // 提交按钮
        Row() {
          Row() {
            Text(parseFloat(this.mWY_ExpertModel?.money).toFixed(2)) {
            }
            .fontColor("#E38D38")
            .fontWeight(FontWeight.Bold)
            .fontFamily('MyFont')
            .fontSize(24)
            .textAlign(TextAlign.Start)
            .lineHeight(24)

            Text(" 元/一年") {
            }
            .fontColor($r("app.color.black"))
            .fontSize(14)
            .textAlign(TextAlign.Start)
            }
            .alignItems(VerticalAlign.Bottom)
          .layoutWeight(1)

          Text("付 款").fontSize(16).fontColor($r('app.color.white'))
            .backgroundColor($r("app.color.main_color"))
            .borderRadius(5)
            .padding({top: 10, bottom: 10, left: 16, right: 16})
            .textAlign(TextAlign.Center)
            .onClick(()=>{
              this.handleSubmit()
            })
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor($r("app.color.white"))
        .padding(12)


        FullLoading({ loading: this.pageLoading })
      }
      .height("100%")
      .backgroundColor($r("app.color.main_background"))
    }.title(PageTitleBuilder($r('app.string.add_post')))
    // .backgroundColor($r('app.color.main_color'))
    .hideTitleBar(true)
    // .backButtonIcon($r("app.media.arrow_left_b_n"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack

      try {
        this.mWY_ExpertModel = this.navPathStack.getParamByName('UKeyCAHandlePayPage')[0] as generalModel;
        this.isVideo = "0";
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }

  callPhone(arg0: string | undefined) {
    if (arg0) {
      call.makeCall(arg0, (err: BusinessError) => {
        if (!err) {
          console.info("make call success.");
        } else {
          console.error("make call fail, err is:" + JSON.stringify(err));
        }
      });

    }
  }

  @Builder
  justifyText(jModel:justifyTextModel) {
    Row() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(jModel.content.split(''), (item: string, index: number) => {
          Text(item)
            .fontSize(jModel.fontSize??15)
            .fontColor(jModel.fontColor??$r("app.color.gl_999"))
            .lineHeight(24)
        })
      }
      .width(((jModel.maxSize??1)*(jModel.fontSize??15)) + 1)
      Text("：")
        .fontSize(jModel.fontSize??15)
        .fontColor(jModel.fontColor??$r("app.color.gl_999"))
        .lineHeight(24)
    }

  }
}