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
  ZJ_EXPERT_LEAVE_RESPONSE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_PRICE_HTTP,
  ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP,
  ZJ_SYS_GET_INFO_HTTP} from "../../api/UrlConfigure";
import { CFCASCAP,CFCASCAPConstants } from "scap";
import { DialogHelper } from "@pura/harmony-dialog";

@Builder
export function HandleTempCAPageBuilder(name: string, param: Object) {
  // console.log("aa");
  HandleTempCAPage()
}

@ComponentV2
export struct HandleTempCAPage {

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
    //验证签名图片
    if (StrUtil.isEmpty(this.signImgUrl)) {
      CoreUtils.toast("请上传个人手写签字图片");
      return;
    }
    if (!this.caAgree) {
      CoreUtils.alert("请您阅读并同意《安心签平台服务协议》和《CFCA数字证书服务协议》");
      return;
    }
    // 请再次确认您本次提交办理的“云签章”适用于辽宁省工程建设项目数字化开标评标系统，且签字完整清晰。


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
          easyDataRequest(ZJ_HANDLE_PROJECT_CLOUD_SIGNATURE_HTTP, dicPost1, "POST").then((res) => {

            easyDataRequest(UPDATE_USER_INFO_HTTP,{userSignature:this.signImgUrl},"POST").then((res) => {
              console.log("更新签名图片成功", res["data"])
              CoreUtils.toast("更新签名图片成功");
            })

            CoreUtils.alert("项目云签章申请成功，请前往使用", () => {
              this.navPathStack.pop({ isRefresh: true }, true);
            });
          }).catch((err: object) => {
            CoreUtils.toast("提交失败");
          }).finally(() => {
            this.pageLoading = false;
          })
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
          Text($r("app.string.project_cloud_signature_processing")) // 请添加对应的资源字符串
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
              Text("项目云签章")
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Image($r("app.media.0420_cloudsign_sel"))
                .width(55)
                .height(55)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 5,bottom:5, left: 16, right: 16 })

            .width("100%")

            Column({space: 16}) {
              Text("选择云签章机构")
                .fontColor($r("app.color.gl_666"))
                .fontWeight(FontWeight.Bold)
                .fontSize(15)
              Row() {
                Image("http://lnwlzj.capass.cn/lnwlzj/05d9b67cb09c4de2b317e0c4392d5b4a.jpg")
                  .width(20)
                  .height(20)
                Text("中国金融认证中心")
                  .fontColor($r("app.color.black"))
                  .fontSize(14)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                Image($r("app.media.0722_wsxx_yes"))
                  .width(20)
                  .height(20)
              }
              .padding({left:16})
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .width("100%")

            Column({space: 16}) {
              Text("云签章有效期")
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.gl_666"))
                .fontSize(15)
              Row() {
                Image("https://lnwlzj.capass.cn/lnwlzj/9d66850bd8894f67a7c0b7303834a3c9.jpg")
                  .width(20)
                  .height(20)
                Text("当前项目可用")
                  .fontColor($r("app.color.black"))
                  .fontSize(14)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                Image($r("app.media.0722_wsxx_yes"))
                  .width(20)
                  .height(20)
              }
              .padding({left:16})
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r("app.color.white"))
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
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
                  Span("个人手写签字（1张）")
                    .fontColor($r("app.color.gl_666"))
                }
                .fontSize(15)
                .fontWeight(FontWeight.Bold)

                Row() {
                  // 已选图片展示和上传按钮容器
                  Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                    // 已选图片
                    if (this.signImgUrl && this.signImgUrl !== '') {
                      Stack() {
                        Image(this.signImgUrl)
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
                            this.signImgUrl = '';
                          })
                      }
                      .width(90)
                      .height(90)
                      .margin(10)
                    } else {
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
                          // this.handleAddImage();
                          this.navPathStack?.pushPathByName('SignPage', {}, (params) => {
                            if (params && params.result['picUrl'] ) {
                              console.log("子页面让-执行刷新操作"+params.result['picUrl']);

                              this.signImgUrl = params.result['picUrl'];
                            }
                          });
                        })
                    }
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
                Text("《安心签平台服务协议》").fontSize(14).fontColor($r('app.color.main_color'))
                  .onClick((event) => {
                    this.navPathStack?.pushPathByName('WebViewInfoPage',
                      { url: `https://www.capass.cn/Avatar/axq_cloud.pdf`, title: "安心签平台服务协议", type: "2" } as generalModel,false);
                    return false
                  })
                Text($r('app.string.and')).fontSize(14).fontColor($r('app.color.gl_888'))
                Text("《CFCA数字证书服务协议》").fontSize(14).fontColor($r('app.color.main_color'))
                  .onClick((event) => {
                    this.navPathStack?.pushPathByName('WebViewInfoPage',
                      { url: `https://www.capass.cn/Avatar/cfca_cloud.pdf`, title: "CFCA数字证书服务协议", type: "2" } as generalModel,false);
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
          Text($r('app.string.submit')).fontSize(16).fontColor($r('app.color.white'))
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
        this.mWY_ExpertModel = this.navPathStack.getParamByName('HandleTempCAPage')[0] as generalModel;
        this.isVideo = "0";
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }

}