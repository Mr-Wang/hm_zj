import { ContextUtils, CoreUtils, FullLoading, PageTitleBuilder, UserInfo } from "jbase";
import { PhotoHelper, PickerUtil } from '@pura/picker_utils';
import { BusinessError } from "@kit.BasicServicesKit";
import { DeviceUtil, ImageUtil, KeyboardUtil, LogUtil, RegexUtil, StrUtil, ToastUtil } from "@pura/harmony-utils";
import { fileUri } from "@kit.CoreFileKit";
import fs from '@ohos.file.fs'
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { image } from "@kit.ImageKit";
import { IMAGE_COMPRESSION_SIZE } from "../../config/Index";
import { generalModel } from "../../model/ZJ_Model";
import { easyDataRequest, easyUploadRequest } from "../../api/EasyRequest";
import { E_UPLOAD_FILE_HTTP,
  UPDATE_USER_INFO_HTTP,
  ZJ_CA_CREATE_CA_HTTP,
  ZJ_CA_REQUEST_CA_HTTP,
  ZJ_EXPERT_LEAVE_RESPONSE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP,
  ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP,
  ZJ_SYS_GET_INFO_HTTP} from "../../api/UrlConfigure";
import { CFCASCAP,CFCASCAPConstants } from "scap";
import { DialogHelper } from "@pura/harmony-dialog";
import { Previewer } from "@humor/lg-image-previewer";
import { webview } from "@kit.ArkWeb";

@Builder
export function UKeyCAPdfPageBuilder(name: string, param: Object) {
  // console.log("aa");
  UKeyCAPdfPage()
}

@ComponentV2
export struct UKeyCAPdfPage {
  @Local signSuccessDic?: generalModel = undefined;
  @Local signPdfUrl: undefined;
  @Local isCFCA: string = "1";

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
  @Local idcardAImgUrl: string = "";//国徽面
  @Local idcardBImgUrl: string = "";//人像面


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

  @Local isSignText: string = "0";
  @Local userInfo?:UserInfo = undefined;

  private userinfoModel?:UserInfo = undefined;
  private  controller: webview.WebviewController = new webview.WebviewController()

  aboutToAppear(): void {

    this.userInfo = ContextUtils.getUserInfo()??{};

  }

  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop(true);
  }

  // 处理提交按钮点击
  async handleSubmit() {

    // 这里实现提交逻辑，调用API等
    // 关闭键盘
    KeyboardUtil.hide();
    //验证非空字段
    if (StrUtil.isEmpty(this.txtName)) {
      CoreUtils.toast("请输入姓名");
      return;
    }
      if (StrUtil.isEmpty(this.txtIdCardNo)) {
      CoreUtils.toast("请输入身份证号");
      return;
    }
    if (StrUtil.isEmpty(this.txtPhone)) {
      CoreUtils.toast("请输入手机号码");
      return;
    }
    if (StrUtil.isEmpty(this.txtCompanyName)) {
      CoreUtils.toast("请输入单位名称");
      return;
    }
    if (StrUtil.isEmpty(this.txtEmail)) {
      CoreUtils.toast("请输入邮箱");
      return;
    }
    //验证手机号格式
    if (!RegexUtil.isPhone(this.txtPhone)) {
      CoreUtils.toast("手机号格式不正确！");
      return;
    }
    //验证邮箱格式
    if (!RegexUtil.isEmail(this.txtEmail)) {
      CoreUtils.toast("邮箱格式不正确！");
      return;
    }
    //验证身份证图片
    if (StrUtil.isEmpty(this.idcardAImgUrl)) {
      CoreUtils.toast("请上传国徽面图片");
      return;
    }
    if (StrUtil.isEmpty(this.idcardBImgUrl)) {
      CoreUtils.toast("请上传人像面图片");
      return;
    }
    if (!this.caAgree) {
      CoreUtils.alert("请您阅读并同意《数字证书服务协议》和《CA数字证书产品售后服务说明书》");
      return;
    }
    // 请再次确认您本次提交办理的“云签章”适用于辽宁省工程建设项目数字化开标评标系统，且签字完整清晰。



    let dicPost: generalModel = {
      yzbm: "",
      txdz: "",
      dwmc: this.txtCompanyName,
      email: this.txtEmail,
      phone: this.txtPhone,
      idcardnum: this.txtIdCardNo,
      sqrxm: this.txtName,
    };
    easyDataRequest(ZJ_CA_CREATE_CA_HTTP, dicPost, "POST").then((res) => {
      dicPost.sfzzm = this.idcardAImgUrl;
      dicPost.sfzfm = this.idcardBImgUrl;
      dicPost.pdfUrl = res["data"];

      /*
       *  WY_CAPdfViewController *tempController = [WY_CAPdfViewController new];
            if ([self.isEdit isEqualToString:@"1"] || [self.isEdit isEqualToString:@"2"]) {
                tempController.isEdit = self.isEdit;
                tempController.dicEditInfo = self.dicEditInfo;
            }
            //身份证正反面
            [postDic setObject:self.idcardImgUrlA forKey:@"sfzzm"];
            [postDic setObject:self.idcardImgUrlB forKey:@"sfzfm"];

            tempController.dicPostCAInfo = postDic;
            tempController.pdfUrl = res[@"data"];
            [self.navigationController pushViewController:tempController animated:YES];

        } else if ([code integerValue] == 10) {
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"温馨提示" message:res[@"data"] preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"取消办理" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

            }]];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"继续办理" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                WY_CAPdfViewController *tempController = [WY_CAPdfViewController new];
                if ([self.isEdit isEqualToString:@"1"] || [self.isEdit isEqualToString:@"2"]) {
                    tempController.isEdit = self.isEdit;
                    tempController.dicEditInfo = self.dicEditInfo;
                }
                //身份证正反面
                [postDic setObject:self.idcardImgUrlA forKey:@"sfzzm"];
                [postDic setObject:self.idcardImgUrlB forKey:@"sfzfm"];
                tempController.dicPostCAInfo = postDic;
                tempController.pdfUrl = res[@"data"];
                [self.navigationController pushViewController:tempController animated:YES];

            }]];
             [self presentViewController:alertControl animated:YES completion:nil];
             * */


    }).catch((err: object) => {
      if (err["code"] == 10) {
        CoreUtils.alert(err["data"], () => {
          // this.navPathStack.pushPathByName("",null);
        },true);
      } else {
        CoreUtils.toast(err["msg"]);
      }
      this.pageLoading = false;
    });


    return;

    //自定义图文，使用局部 @Builder 和 自定义组件
    DialogHelper.showCustomContentDialog({
      primaryTitle: "温馨提示",
      secondaryTitle: "请再次确认您本次提交办理的“云签章”适用于辽宁省工程建设项目数字化开标评标系统，且签字完整清晰。",
      contentBuilder: () => {
        this.customTextImgBuilder(this.signImgUrl)
      },
      buttons: [
        { value: '取消', fontColor: Color.Black },
        { value: '确定', fontColor: Color.Red }
      ],
      onAction: (action) => {
        console.log("action",action)
        if (action === -2) {
          //生成 P10
          this.submitPost();
        }
      }
    })



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
    CFCASCAP.getInstance(this.getUIContext().getHostContext() as Context)
      .generateP10Request("111111", CFCASCAPConstants.CERT_TYPE_SM2, true)
      .then((p10Request) => {
        console.log("生成P10成功" + p10Request);
        // 调用项目云签章办理接口
        //查钱接口
        let dicPost: generalModel = {
          manufacturer: "CFCA",
          validityPeriod: "12",
        };
        easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP, dicPost, "POSTFORM").then((res) => {
          let dicPost1: generalModel = {
            id: this.mWY_ExpertModel?.id,
            yxqName: "一年",
            money: res["data"],
            manufacturer: "CFCA",
            validityPeriod: "12",
            pkcs10: p10Request,
            identification: this.txtIdCardNo,
            userName: this.txtName,
            caName: "中国金融认证中心",
            exportType: "CFCA",
            signature: this.signImgUrl,
            companyName: this.txtCompanyName,
            email: this.txtEmail,
            phoneNumber: this.txtPhone,
            expertId: this.mWY_ExpertModel?.expertId
          };

          this.navPathStack.pushPathByName("CloudCAHandlePayPage", dicPost1);
          this.pageLoading = false;
          // easyDataRequest(ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP, dicPost1, "POST").then((res) => {
          //
          //   easyDataRequest(UPDATE_USER_INFO_HTTP,{userSignature:this.signImgUrl},"POST").then((res) => {
          //     console.log("更新签名图片成功", res["data"])
          //     CoreUtils.toast("更新签名图片成功");
          //   })
          //
          //   CoreUtils.alert("项目云签章申请成功，请前往使用", () => {
          //     this.navPathStack.pop({ isRefresh: true }, true);
          //   });
          // }).catch((err: object) => {
          //   CoreUtils.toast("提交失败");
          // }).finally(() => {
          //   this.pageLoading = false;
          // })
        }).catch((err: object) => {
          CoreUtils.toast("查询失败");
          this.pageLoading = false;
        });


      })
      .catch((err: Error) => {
        console.log("生成P10失败" + JSON.stringify(err));
        this.pageLoading = false;
      });
  }

  // 添加图片

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
        if (this.selectedImages.length >= 1) {
          CoreUtils.toast('最多选择1张图片');
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
                this.idcardBImgUrl = res["data"];
              } else {
                this.selectedImages = this.selectedImages.concat(res["data"]);
                this.idcardAImgUrl = res["data"];
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
                .fontColor("#8B8B8B)")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)

              Column(){
                Image($r("app.media.0611_ws3h"))
                  .width(30)
                  .height(30)
                Text("订单支付")
                  .fontColor("#8B8B8B")
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 5 })
              }

            }
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ top: 5,bottom:5, left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Web({ src: "", controller: this.controller })
              .javaScriptAccess(true)
              .onPageEnd(()=>{
                console.log("页面加载完成，注入图片点击监听");
              })
              .onControllerAttached(() => {

                this.initWebView();
              }).layoutWeight(1)
              .zoomAccess(true) // 允许缩放
              .initialScale(1) // 设置初始缩放比例
              .databaseAccess(true) // 允许数据库存储
              .domStorageAccess(true) // 允许DOM存储

          }.width("100%")
        }.width("100%")
        .layoutWeight(1)

        // // 提交按钮
        // Row() {
        //   Text($r('app.string.next')).fontSize(16).fontColor($r('app.color.white'))
        //     .layoutWeight(1)
        //     .backgroundColor($r("app.color.main_color"))
        //     .borderRadius(5)
        //     .padding(12)
        //     .textAlign(TextAlign.Center)
        // }
        // .justifyContent(FlexAlign.Center)
        // .padding(12)
        // .onClick(()=>{
        //   this.handleSubmit()
        // })

        // 底部导航条
        Row({space: 10}) {
          // 底部导航条内容
          //取消按钮、重新签名按钮、签名按钮
          Button() {
            Text($r("app.string.cancel")) // 请添加对应的资源字符串
              .fontSize(16)
              .fontColor($r("app.color.gl_999"))
          }
          .backgroundColor($r("app.color.white"))
          .borderRadius(1)
          .borderColor($r("app.color.gl_999"))
          .borderWidth(1)
          .onClick(() => {
            this.handleBack();
          })
          .height('100%')
          .layoutWeight(1)

          // 重新签名按钮
          Button() {
            Text($r("app.string.reSign")) // 请添加对应的资源字符串
              .fontSize(16)
              .fontColor($r("app.color.gl_999"))
          }
          .backgroundColor($r("app.color.white"))
          .borderRadius(1)
          .borderColor($r("app.color.gl_999"))
          .borderWidth(1)
          .visibility(this.isSignText == "1"?Visibility.Visible:Visibility.None)
          .onClick(() => {
            this.navPathStack?.pushPathByName('SignPage', {}, (params) => {
              if (params && params.result['picUrl'] ) {
                console.log("子页面让-执行刷新操作"+params.result['picUrl']);
                //调用接口签字；
                this.signPDFByUserSignature(params.result['picUrl']);
              }
            });
          })
          .height('100%')
          .layoutWeight(1)

          // 签名按钮
          Button() {
            Text(this.isSignText != "1"?$r("app.string.sign"):$r("app.string.confirm")) // 请添加对应的资源字符串
              .fontSize(16)
              .fontColor($r("app.color.white"))
          }
          .onClick(() => {
            //如果没有签过字 -  判断 用户信息中 是否有签字-
            if(this.isSignText != "1"){
              //如果有-直接调用接口签字；
              if(this.userInfo?.userSignature != null){
                //调用接口签字；
                this.signPDFByUserSignature(this.userInfo?.userSignature);
              }else{
                //如果没有- 去签字页保存后-再调用接口签字；
                this.navPathStack?.pushPathByName('SignPage', {isSaveSign:"1"} as generalModel, (params) => {
                  if (params && params.result['picUrl'] ) {
                    console.log("子页面让-执行刷新操作"+params.result['picUrl']);
                    //调用接口签字；
                    this.signPDFByUserSignature(params.result['picUrl']);
                  }
                });
              }
            }else{
              //如果已经签字 点击确认返回
              this.navPathStack.pushPathByName("UKeyCAHandlePayPage",this.signSuccessDic,true);

            }


          })
          .borderRadius(1)
          .backgroundColor($r("app.color.main_color"))
          .height('100%')
          .layoutWeight(1)
        }
        .height(60)
        .padding(10)
        .backgroundColor($r("app.color.white"))

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
        this.mWY_ExpertModel = this.navPathStack.getParamByName('UKeyCAPdfPage')[0] as generalModel;
        this.isVideo = "0";
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }

  private initWebView() {
    if (this.mWY_ExpertModel != null) {
      //判断 如果不是一个有效 url，url中不包含 http 则不加载页面
      if (!this.mWY_ExpertModel?.pdfUrl?.includes("http")) {
        ToastUtil.showToast("不是有效地址"+this.mWY_ExpertModel?.pdfUrl);
        return;
      }
      this.controller.loadUrl(this.mWY_ExpertModel?.pdfUrl??"",
        [
          { headerKey: "systemtype", headerValue: "ios" },
          { headerKey: "token", headerValue: ContextUtils.getToken().toString() }]);
    }else {
      ToastUtil.showToast("参数错误");
    }

  }


  signPDFByUserSignature(userSignature: string) {

    let postDic:generalModel = this.mWY_ExpertModel ?? {};
    postDic.signature = encodeURI(userSignature)
    if (this.mWY_ExpertModel?.exportType == "cfca" || this.mWY_ExpertModel?.exportType == "cfcaImage") {
      postDic.exportType = "cfcaImage";
    } else {
      postDic.exportType = "bjcaImage";
    }
    postDic.userGuid = ContextUtils.getUserInfo()?.userGuid;

    easyDataRequest(ZJ_CA_REQUEST_CA_HTTP, postDic, "POST")
      .then((res) => {
        if (res['code'] == 0) {
          this.signPdfUrl = res['data']["sqs"];
          this.signSuccessDic = res['data'] as generalModel;
          this.controller.loadUrl(this.signPdfUrl,
            [
              { headerKey: "systemtype", headerValue: "ios" },
              { headerKey: "token", headerValue: ContextUtils.getToken().toString() },
              { headerKey: "appKey", headerValue: DeviceUtil.getODID() }]);
          this.isSignText = "1"
        }
      })
      .catch((err:object) => {
        CoreUtils.toast(err['msg'])
      })
      .finally(() => this.pageLoading = false)
  }

}