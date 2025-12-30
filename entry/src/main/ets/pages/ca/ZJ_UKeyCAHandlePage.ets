import { ContextUtils, CoreUtils, FullLoading, PageTitleBuilder, UserInfo } from "jbase";
import { PhotoHelper, PickerUtil } from '@pura/picker_utils';
import { BusinessError } from "@kit.BasicServicesKit";
import { ImageUtil, KeyboardUtil, LogUtil, RegexUtil, StrUtil, ToastUtil } from "@pura/harmony-utils";
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
  ZJ_EXPERT_LEAVE_RESPONSE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP,
  ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP,
  ZJ_SYS_GET_INFO_HTTP} from "../../api/UrlConfigure";
import { CFCASCAP,CFCASCAPConstants } from "scap";
import { DialogHelper } from "@pura/harmony-dialog";
import { Previewer } from "@humor/lg-image-previewer";

@Builder
export function UKeyCAHandlePageBuilder(name: string, param: Object) {
  // console.log("aa");
  UKeyCAHandlePage()
}

@ComponentV2
export struct UKeyCAHandlePage {
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
      this.idcardAImgUrl = this.userinfoModel?.sfzzm ?? "";
      this.idcardBImgUrl = this.userinfoModel?.sfzfm ?? "";
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
      exportType: this.isCFCA == "1"?"cfca":"bjca"
    };
    easyDataRequest(ZJ_CA_CREATE_CA_HTTP, dicPost, "POST").then((res) => {
      dicPost.sfzzm = this.idcardAImgUrl;
      dicPost.sfzfm = this.idcardBImgUrl;
      dicPost.pdfUrl = res["data"];
      this.navPathStack.pushPathByName("UKeyCAPdfPage", dicPost);

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
          manufacturer: this.isCFCA == "1"?"CFCA":"BJCA",
          validityPeriod: "12",
        };
        easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP, dicPost, "POSTFORM").then((res) => {
          let dicPost1: generalModel = {
            id: this.mWY_ExpertModel?.id,
            yxqName: "一年",
            money: res["data"],
            manufacturer: this.isCFCA == "1"?"CFCA":"BJCA",
            validityPeriod: "12",
            pkcs10: p10Request,
            identification: this.txtIdCardNo,
            userName: this.txtName,
            caName: this.isCFCA == "1"?"中国金融认证中心":"北京数字认证股份有限公司",
            exportType: this.isCFCA == "1"?"CFCA":"BJCA",
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
                .fontColor("#8B8B8B")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)

              Column(){
                Image($r("app.media.0611_ws2"))
                  .width(30)
                  .height(30)
                Text("申请书")
                  .fontColor("#8B8B8B")
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

            Row(){
              Text("办理专家CA数字证书（UKEY）")
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Image($r("app.media.0420_usbkey_sel"))
                .width(55)
                .height(55)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 5,bottom:5, left: 16, right: 16 })
            .width("100%")

            Text("特别说明：" +"\n　　" + "为了提供更好数据共享服务，压缩办理流程、时限，减少材料重复提供，加强个人信息保密，各位专家可根据各主管部门的电子化要求，自愿选择此便捷渠道申请办理互联互通专家（CA）数字证书（可互联互通辽宁建设工程信息网、辽宁政府采购网、朝阳市公共资源交易平台、大连市公共资源交易平台）。")
              .fontSize(14)
              .fontColor($r("app.color.red_color"))
              .padding({ top: 5,bottom:5, left: 16, right: 16 })



            Column({space: 16}) {
              Text(){
                Span("选择CA机构")
                Span(" 以下CA机构，功能相同，请自主选择")
                  .fontColor($r("app.color.red_color"))
                  .fontWeight(FontWeight.Normal)
                  .fontSize(12)
              }
                .fontColor($r("app.color.gl_666"))
                .fontWeight(FontWeight.Bold)
                .fontSize(15)

              Row() {
                Image($r("app.media.cfcaicon"))
                  .width(20)
                  .height(20)
                Text("中国金融认证中心（CFCA）")
                  .fontColor($r("app.color.black"))
                  .fontSize(14)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                if(this.isCFCA == "1") {
                  Image($r("app.media.0722_wsxx_yes"))
                    .width(20)
                    .height(20)
                } else {
                  Image($r("app.media.yuan2"))
                    .width(20)
                    .height(20)
                }

              }
              .padding({left:16,top:5,bottom:5})
              .onClick(() => {
                this.isCFCA = "1";
              })
              Row() {
                Image($r("app.media.bjcaicon"))
                  .width(20)
                  .height(20)
                Text("北京数字认证股份有限公司（BJCA）")
                  .fontColor($r("app.color.black"))
                  .fontSize(14)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                if(this.isCFCA != "1") {
                  Image($r("app.media.0722_wsxx_yes"))
                    .width(20)
                    .height(20)
                } else {
                  Image($r("app.media.yuan2"))
                    .width(20)
                    .height(20)
                }
              }
              .padding({left:16,top:5,bottom:5})
              .onClick(() => {
                this.isCFCA = "2";
              })
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .width("100%")

            Column({space: 16}) {
              Text("证书有效期")
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.gl_666"))
                .fontSize(15)
                .margin({ top: 10 })
              Row() {
                Image("https://lnwlzj.capass.cn/lnwlzj/9d66850bd8894f67a7c0b7303834a3c9.jpg")
                  .width(20)
                  .height(20)
                Text("一年")
                  .fontColor($r("app.color.black"))
                  .fontSize(14)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                Image($r("app.media.0722_wsxx_yes"))
                  .width(20)
                  .height(20)
              }
              .padding({left:16,top:5,bottom:5})
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .padding({ bottom: 16, left: 16, right: 16 })
            .width("100%")
            .margin({ top: 10 })

            Column({space: 16}) {
              Text("选择专家类型")
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.gl_666"))
                .fontSize(15)
                .margin({ top: 10 })
              Row() {
                SymbolGlyph($r('sys.symbol.person_filled_2_badge_plus_fill'))
                  .fontColor(["#999999"])
                  .fontSize(22)
                  .width(20)
                  .height(20)
                Text("评标专家（或招标人评委）")
                  .fontColor($r("app.color.black"))
                  .fontSize(14)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                Image($r("app.media.0722_wsxx_yes"))
                  .width(20)
                  .height(20)
              }
              .padding({left:16,top:5,bottom:5})
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .padding({ bottom: 16, left: 16, right: 16 })
            .width("100%")
            .margin({ top: 10 })

            Column(){
              // 申请人姓名
              Row(){
                Text(""){
                  Span("*")
                    .fontColor($r("app.color.red_color"))
                  Span("申请人姓名")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                TextInput({
                  placeholder: "请输入申请人姓名",
                  text: this.txtName,
                })
                  .fontSize(15)
                  .layoutWeight(1)
                  .enabled(false)
                  .backgroundColor(Color.Transparent)
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.txtName = value
                  })
              }
              .width("100%")
              .padding({ top: 5, bottom: 5, left: 16, right: 16 })
              .border({width:{bottom:1},color:$r("app.color.color_line")})
              // 身份证号
              Row(){
                Text(""){
                  Span("*")
                    .fontColor($r("app.color.red_color"))
                  Span("身份证号")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                TextInput({
                  placeholder: "请输入身份证号",
                  text: this.txtIdCardNo,
                })
                  .type(InputType.Normal)
                  .enabled(false)
                  .fontSize(15)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.txtIdCardNo = value
                  })
              }
              .width("100%")
              .padding({ top: 5, bottom: 5, left: 16, right: 16 })
              .border({width:{bottom:1},color:$r("app.color.color_line")})

              //手机号码
              Row(){
                Text(""){
                  Span("*")
                    .fontColor($r("app.color.red_color"))
                  Span("手机号码")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                TextInput({
                  placeholder: "请输入手机号码",
                  text: this.txtPhone,
                })
                  .enabled(false)
                  .type(InputType.Normal)
                  .fontSize(15)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.txtPhone = value
                  })
              }
              .width("100%")
              .padding({ top: 5, bottom: 5, left: 16, right: 16 })
              .border({width:{bottom:1},color:$r("app.color.color_line")})

              //单位名称
              Row(){
                Text(""){
                  Span("*")
                    .fontColor($r("app.color.red_color"))
                  Span("单位名称")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                TextInput({
                  placeholder: "请输入单位名称",
                  text: this.txtCompanyName,
                })
                  .type(InputType.Normal)
                  .fontSize(15)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.txtCompanyName = value
                  })
              }
              .width("100%")
              .padding({ top: 5, bottom: 5, left: 16, right: 16 })
              .border({width:{bottom:1},color:$r("app.color.color_line")})

              // 邮箱
              Row(){
                Text(""){
                  Span("*")
                    .fontColor($r("app.color.red_color"))
                  Span("邮箱")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                TextInput({
                  placeholder: "请输入邮箱",
                  text: this.txtEmail,
                })
                  .type(InputType.Normal)
                  .fontSize(15)
                  .layoutWeight(1)
                  .backgroundColor(Color.Transparent)
                  .textAlign(TextAlign.End)
                  .onChange((value: string) => {
                    this.txtEmail = value
                  })
              }
              .width("100%")
              .padding({ top: 5, bottom: 5, left: 16, right: 16 })
              .border({width:{bottom:1},color:$r("app.color.color_line")})


              Column() {
                Text(""){
                  Span("*")
                    .fontColor($r("app.color.red_color"))
                  Span("请拍摄并上传您的身份证照片")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                Row() {
                  // 已选图片展示和上传按钮容器
                  Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                    // 已选图片
                      Stack() {
                        if(this.idcardAImgUrl) {
                          Image(this.idcardAImgUrl ?? $r("app.media.0407_guohui"))
                            .alt($r("app.media.0407_guohui"))
                            .width(151)
                            .height(115)
                            .objectFit(ImageFit.Fill)
                            .borderColor(Color.Gray)
                            .onClick(() => {
                              //图片预览
                              Previewer.show(
                                {
                                  imgList: [{ url: encodeURI(this.idcardAImgUrl), id: "image1" }],
                                  initIndex: 0,
                                }
                              )

                            })
                          // 删除按钮
                          Image($r("app.media.0615_del"))
                            .width(24)
                            .height(24)
                            .objectFit(ImageFit.Fill)
                            .position({ x: 136, y: -10 })
                            .backgroundColor(Color.Blue)
                            .borderRadius(12)
                            .onClick(() => {
                              console.log("删除图片")
                              this.idcardAImgUrl = '';
                            })
                        } else {
                          Image($r("app.media.0407_guohui"))
                            .width(151)
                            .height(115)
                            .objectFit(ImageFit.Fill)
                            .borderColor(Color.Gray)
                            .onClick(() => {
                              //弹出选择照片
                              this.handleAddImage(0);
                            })
                        }

                      }
                      .width(151)
                      .height(115)
                      .margin(10)

                      Stack() {
                        if (this.idcardBImgUrl ) {
                          Image(this.idcardBImgUrl ?? $r("app.media.0407_renxiang"))
                            .alt($r("app.media.0407_renxiang"))
                            .width(151)
                            .height(115)
                            .objectFit(ImageFit.Fill)
                            .borderColor(Color.Gray)
                            .onClick(() => {
                              //查看图片
                              Previewer.show(
                                {
                                  imgList: [{ url: encodeURI(this.idcardBImgUrl), id: "image1" }],
                                  initIndex: 0,
                                }
                              )
                            })

                          // 删除按钮
                          Image($r("app.media.0615_del"))
                            .width(24)
                            .height(24)
                            .objectFit(ImageFit.Fill)
                            .position({ x: 136, y: -10 })
                            .backgroundColor(Color.Blue)
                            .borderRadius(12)
                            .onClick(() => {
                              this.idcardBImgUrl = '';
                            })
                        } else {
                          Image($r("app.media.0407_renxiang"))
                            .width(151)
                            .height(115)
                            .objectFit(ImageFit.Fill)
                            .borderColor(Color.Gray)
                            .onClick(() => {
                              //弹出选择照片
                              this.handleAddImage(1);
                            })
                        }

                      }
                      .width(151)
                      .height(115)
                      .margin(10)

                  }
                  .width("100%")
                  .alignSelf(ItemAlign.Start)
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .width("100%")
              }
              .alignItems(HorizontalAlign.Start)
              .width("100%")
              .padding({ top: 16, bottom: 10, left: 16, right: 16 })
              .border({width:{bottom:1},color:$r("app.color.color_line")})

              Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center, wrap: FlexWrap.Wrap }) {
                Radio({
                  value: 'Radio1', group: 'radioGroup', indicatorType: RadioIndicatorType.TICK
                }).checked(this.caAgree).height(20).width(20)
                  .onClick((event) => {
                    this.caAgree = !this.caAgree
                    return false
                  })
                Text($r('app.string.pls_read_agree')).fontSize(14).fontColor($r('app.color.gl_888'))
                Text("《数字证书服务协议》").fontSize(14).fontColor($r('app.color.main_color'))
                  .onClick((event) => {
                    this.navPathStack?.pushPathByName('WebViewInfoPage',
                      { url: `https://lnwlzj.capass.cn/lnwlzj/%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%E6%9C%8D%E5%8A%A1%E5%8D%8F%E8%AE%AE%EF%BC%88BJCA%E5%8F%8ACFCA%EF%BC%89(1).pdf`, title: "数字证书服务协议", type: "2" } as generalModel,false);
                    return false
                  })
                Text($r('app.string.and')).fontSize(14).fontColor($r('app.color.gl_888'))
                Text("《CA数字证书产品售后服务说明书》").fontSize(14).fontColor($r('app.color.main_color'))
                  .onClick((event) => {
                    this.navPathStack?.pushPathByName('WebViewInfoPage',
                      { url: `https://www.capass.cn/Avatar/cashfw.pdf`, title: "CA数字证书产品售后服务说明书", type: "2" } as generalModel,false);
                    return false
                  })
              }
              .width("100%")
              .padding({ top: 10, bottom: 10, left: 16, right: 16 })
              .onClick(() => {
                this.caAgree = !this.caAgree
              })

            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .width("100%")
            .margin({ top: 10 })

          }.width("100%")
        }.width("100%")
        .layoutWeight(1)

        // 提交按钮
        Row() {
          Text($r('app.string.next')).fontSize(16).fontColor($r('app.color.white'))
            .layoutWeight(1)
            .backgroundColor($r("app.color.main_color"))
            .borderRadius(5)
            .padding(12)
            .textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Center)
        .padding(12)
        .onClick(()=>{
          this.handleSubmit()
        })

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
        this.mWY_ExpertModel = this.navPathStack.getParamByName('UKeyCAHandlePage')[0] as generalModel;
        this.isVideo = "0";
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }

}