import { DateType, DialogHelper } from "@pura/harmony-dialog";
import {
  Base64Util,
  DateUtil, DisplayUtil, ImageUtil, KeyboardUtil, LogUtil, StrUtil, WindowUtil } from "@pura/harmony-utils";
import { PhotoHelper } from "@pura/picker_utils";
import { BaseResp } from "@tencent/wechat_open_sdk/src/main/ets/model/Base";
import { PayReq, PayResp } from "@tencent/wechat_open_sdk/src/main/ets/model/Pay";
import { ShareWxSdk } from "@zyl/wxcommonlibhar";
import { ContextUtils, CoreUtils, FullLoading, UserInfo } from "jbase";
import { easyDataRequest, easyUploadRequest } from "../../api/EasyRequest";
import { APP_ID_WX, IMAGE_COMPRESSION_SIZE } from "../../config/Index";
import { generalModel } from "../../model/ZJ_Model";
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { fileUri } from "@kit.CoreFileKit";
import { BusinessError } from "@kit.BasicServicesKit";
import fs from '@ohos.file.fs'
import HiSignature from "hi-signature"
import { window } from '@kit.ArkUI';
import { E_UPLOAD_FILE_HTTP } from "../../api/UrlConfigure";

@Builder
export function SignPageBuilder(name: string, param: Object) {
  // console.log("aa");
  SignPage()
}




@ComponentV2
export struct SignPage {
  @Local selIndex5: number = 0;
  @Local selDateStr: string = "";
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local generalModelPageData?: generalModel = undefined;
  @Local gModel?: generalModel = undefined;

  // 用户信息
  @Local userInfo: UserInfo = {};

  @Local payPageData?: generalModel = undefined;

  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local searchText1: string = "";
  @Local searchText2: string = "";
  @Local searchText3: string = "";
  @Local searchText4: string = "";
  @Local selectedImages: string[] = []; // 存储选中的图片路径


  @Local message: string = 'Hello World';
  @Local signature?:HiSignature
  @Local imgUrl?:string
  @Local isSaveSign?:string = "1"
  aboutToAppear(): void {


  }
  aboutToDisappear(): void {
    console.log("aboutToDisappear")
      // 把页面竖屏
      WindowUtil.setPreferredOrientation(window.Orientation.PORTRAIT)
  }
  loadTabsData(): void {

    //把页面横屏
    WindowUtil.setPreferredOrientation(window.Orientation.LANDSCAPE)

    this.userInfo = ContextUtils.getUserInfo() ?? {};

    // this.pageLoading = true;
    //
    // easyDataRequest(this.generalModelPageData?.url,{},"POST").then((res) => {
    //     this.gModel = res?.["data"]?.["item"] || {};
    //     LogUtil.info("loadTabsData success: " + JSON.stringify(res));
    //   this.pageLoading = false;
    //   this.refreshIndex++;
    // })
    //   .catch((err:string) => {
    //     LogUtil.error("loadTabsData error: " + err);
    //   })
    //   .finally(() => {
    //     this.pageLoading = false;
    //     this.refreshIndex++;
    //   });

  }
  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop(true);
  }

  @Builder
  //下拉刷新*/
  customRefreshComponent() {
    Stack() {
      Row() {
        LoadingProgress().height(32)
        Text($r("app.string.Refreshing")).fontSize(16).margin({ left: 20 })
      }
      .alignItems(VerticalAlign.Center)
    }
    .align(Alignment.Center)
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width("100%")
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


  // 添加图片
  handleAddImage() {

    // 关闭键盘
    KeyboardUtil.hide();

      // 这里实现图片选择逻辑
      console.log("添加图片");
      if (this.selectedImages.length >= 8) {
        CoreUtils.toast('最多选择8张图片');
        return
      }
      PhotoHelper.selectEasy({
        maxSelectNumber:8 - this.selectedImages.length,
        MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE //可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
      })
        .then((result) => {
          let uris = result;

          if (this.selectedImages.length + uris.length > 8) {
            CoreUtils.toast('最多选择8张图片');
            return
          }
          this.selectedImages = this.selectedImages.concat(uris);
          // let aaa = this.selectImage(uris[0]);
        }).catch((err: BusinessError) => {
        console.log(`调用相册，异常：\n${JSON.stringify(err)}`);
      });


  }
  //此方法把图片、视频集合的uri转成ArrayBuffer,上传的时候需要用 ArrayBuffer
  async selectImages(result: string[]): Promise<ArrayBuffer[]> {
    let bufferImgs: ArrayBuffer[] = [];
    // //判断是否成功
    if (result && result.length > 0) {
      for (let index = 0; index < result.length; index++) {
        let item = result[index];
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

      console.log("删除图片:", index);
      this.selectedImages.splice(index, 1);
      this.selectedImages = [...this.selectedImages]; // 触发UI更新


  }


  pay() {
    // 调用接口 获取支付内容值：

    let share = new ShareWxSdk(APP_ID_WX)
    share.wechatPay({
      appId: "wx0000000000000000",
      partnerId: "000000000000000",
      prepayId: "wx000000000000000",
      nonceStr: "aaaaaaaaaaaaaaaaaaaa",
      timeStamp: "000000000000000",
      packageValue: "packageValue",
      sign: "000000000000000000000000",
      extData: 'extData',
      signType: 'signType'
    } as PayReq).then((res:BaseResp)=>{

      if(res instanceof PayResp){
        // 使用支付的类型
      }
      console.log('支付完成后，从微信回来的回调',JSON.stringify(res))
    })

    // 唤起支付
    //  new PayAction(MultiMedia.WECHAT)
    //   .setAppId("wxf8c40523e1a1fcdd") // 微信AppId
    //   .setPartnerId("1432749102") // 微信商户ID，merchantId
    //   .setPrepayId("wx26161523845794ecced251acf2b6860000") // 微信支付预支付交易会话ID
    //   .setPackageValue("Sign=WXPay") // 微信支付固定值Sign=WXPay
    //   .setNonceStr("vmall_240926161523_993_2774") // 微信支付随机字符串
    //   .setTimeStamp("1727338524") // 微信支付时间戳
    //   .setSign("rAqsrx5yLfRNBGvlHYuLhUsNK0OPeOLQ5xlvhxFo9guPU4HeNtzRdPaGAXAzXvn7V5chVe8sj3BfvDgwXlCKctCcFIllOgheyZbZ7btFC++9bW0QTijhWo1hZ6LhvjcKQ1zf53RGX7zf7GBu9sheqWPKlWqJJzynBZo8UH5Wow9t/WK5fanNj6ST2U2zPQGxuCH+DBMOKJAhhaalrOXlqj+feEiz1bLAzEmhLzIREgcWJQyZmdI5VO0B8r11ND+o1iBYgoohDUuJc+bd9r6RvmZBSE+HqggWE4p3D0/NzY7mQH+51u0osfOfaTHVLqlUM3IMoXi1vH4a0Qrg1P6c0g==") // 微信支付签名
    //   .setExtData("extData") // 拓展信息
    //   .setCallback(callback) // 回调监听
    //   .pay();

  }
  @Builder
  cellTitle4(content?: string | Resource,status?: string | Resource, onMoreClick?: () => void) {
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
          .fontColor($r("app.color.main_color"))
          .layoutWeight(1)

        // Image($r("app.media.0219xtzscell"))
        //   .width(30)
        //   .height(15)
        //   .margin({ right: 10 })
        // 状态文本
        // Text(status) // 请添加对应的资源字符串
        //   .fontSize(12)
        //   .fontColor($r("app.color.black"))

        if (onMoreClick) {
          Text("再次参赛") // 请添加对应的资源字符串
            .fontSize(10)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .fontColor($r("app.color.white"))
            .backgroundColor($r("app.color.main_color"))
            .borderRadius(15)
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
  @Builder
  justifyCellItem(content: string,value:string) {
    Row() {
      this.justifyText(content)

      Text(value)
        .fontSize(14)
        .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Start)
    .padding(16)
    .border({ width: { bottom: 1 }, color: $r("app.color.color_line") })
    .width("100%")
  }
  @Builder
  justifyText(content: string,fontSize?: number, fontColor?: string | Resource,width?:number) {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(content.split(''), (item: string, index: number) => {
        Text(item)
          .fontSize(fontSize??14)
          .fontColor(fontColor??$r("app.color.gl_999"))
      })
    }.width(width??100)
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
          Text($r("app.string.sign")) // 请添加对应的资源字符串
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor($r("app.color.white"))

          // 提交按钮
          Text($r("app.string.submit")) // 请添加对应的资源字符串
            .fontSize(16)
            .onClick(() => {

            })
            .visibility(Visibility.Hidden)
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


          Scroll(){
            Column(){
              Row(){
                Stack() {
                  Text(this.userInfo?.realname)
                    .width("100%")
                    .height(230)
                    .minFontSize(30)        // 设置最小字号
                    .maxFontSize(200)        // 设置最大字号
                    .maxLines(1)            // 限制为单行，是实现充满效果的关键
                    .textAlign(TextAlign.Center)
                    .fontColor($r("app.color.gl_000"))
                    .opacity(0.7)

                  HiSignature({
                    Width:"100%",
                    Height:230,
                    LineWidth:12,
                    BackgroundColor:"#00000000",
                    onReady:(e)=>{
                      this.signature = e
                    }
                  })
                }

              }

              Row(){
                Text(this.isSaveSign == "1"?"此签名将用于专家协议签署，请准确工整签写。":"此签名将放入数字证书CA中，请准确工整签写。")
                  .fontColor($r("app.color.red_color"))
                  .layoutWeight(1)
                Column(){
                  Button("重签").onClick(()=>{
                    this.signature?.clear()
                  })
                }.margin({left:10})
                Column(){
                  Button("确定").onClick(()=>{
                    this.signature?.toDataUrl((url)=>{
                      if(!url){
                        console.log("未绘制签名")
                        CoreUtils.alert("请先签名")
                        return
                      }
                      this.imgUrl = url

                      //自定义图文，使用局部 @Builder 和 自定义组件
                      DialogHelper.showCustomContentDialog({
                        primaryTitle: "温馨提示",
                        secondaryTitle: "确定使用此签名图片吗?",
                        contentBuilder: () => {
                          this.customTextImgBuilder(this.imgUrl)
                        },
                        buttons: [
                          { value: '取消', fontColor: Color.Black },
                          { value: '确定', fontColor: Color.Red }
                        ],
                        onAction: (action) => {
                          console.log("action",action)
                          if (action === -2) {
                            this.signQRConfirm();
                          }
                        }
                      })
                    })
                  })
                }.margin({left:10})
              }
              .padding({bottom:10,left:16,right:16})
              .backgroundColor("#9f9f9f")
              .layoutWeight(1)
            }

            .layoutWeight(1)
              .backgroundColor($r("app.color.white"))

            }
          }
          .width('100%')
          .layoutWeight(1)
        .align(Alignment.TopStart)
        FullLoading({ loading: this.pageLoading })
    }
    .hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.white"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack

      try {
        this.generalModelPageData = this.navPathStack.getParamByName('SignPage')[this.navPathStack.getParamByName('SignPage').length - 1] as generalModel;
        this.isSaveSign = this.generalModelPageData?.isSaveSign;
         this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
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

  async signQRConfirm() {
    console.log("签字确认订单")

    let param:generalModel = {
      description: "",

    }

    this.pageLoading = true;
    const reg = new RegExp('data:image/\\w+;base64,');
    const base64Str = this.imgUrl?.toString().replace(reg, '');
    //将通用base64字符串转变为arrayBuffer
      let arrayBuffer = Base64Util.decodeSync(base64Str).buffer as ArrayBuffer;
      param.arrImagesUint8 = [arrayBuffer];//await this.selectImages([this.imgUrl ?? ""]);
      param.num = "1"

    easyUploadRequest(E_UPLOAD_FILE_HTTP,param)
      .then((res) => {
        this.navPathStack.pop({ picUrl:res["data"] }, true);
      })
      .catch((error: Error) => {
        console.error("失败:" + error);
        CoreUtils.alert(error.toString()??"");
      }).finally(() => {
      this.pageLoading = false;
    });
  }

}