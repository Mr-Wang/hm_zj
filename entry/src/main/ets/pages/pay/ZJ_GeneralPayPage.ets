import { BaseResp } from "@tencent/wechat_open_sdk/src/main/ets/model/Base";
import { PayReq, PayResp } from "@tencent/wechat_open_sdk/src/main/ets/model/Pay";
import { ShareWxSdk } from "@zyl/wxcommonlibhar";
import { APP_ID_WX } from "../../config/Index";
import { generalModel } from "../../model/ZJ_Model";

@Builder
export function GeneralPayPageBuilder(name: string, param: Object) {
  // console.log("aa");
  GeneralPayPage()
}




@ComponentV2
export struct GeneralPayPage {
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()


  aboutToAppear(): void {


  }

  loadTabsData(): void {
    this.pageLoading = true;

    setTimeout(() => {
      this.isRefreshing = false;
      this.refreshIndex++;
    }, 1000);

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
          Text(this.generalModelPageData?.title ?? "商品下单") // 请添加对应的资源字符串
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
            Column() {
              //搜索结果-Item
              Column() {

                Row() {
                  Text() {
                    Span('项目名称：');
                    Span((this.generalModelPageData?.catalogName ?? "").trim()).fontColor($r("app.color.black"));
                  }
                  .fontColor($r("app.color.gl_999"))
                  .fontSize(14)
                  .layoutWeight(1);
                }
                .justifyContent(FlexAlign.Start)
                .padding(16)
                .width("100%");

                Divider()
                  .color($r('app.color.color_line'))
                  .vertical(false)
                  .strokeWidth(1)
                  .width("100%");
                Row() {
                  Text() {
                    Span('缴费金额：');
                    Span((this.generalModelPageData?.balance ?? "").trim()).fontColor($r("app.color.main_color"));
                  }
                  .fontColor($r("app.color.gl_999"))
                  .fontSize(14)
                  .layoutWeight(1);

                }.justifyContent(FlexAlign.Start)
                .padding(16)
                .width("100%");

                Divider()
                  .color($r('app.color.color_line'))
                  .vertical(false)
                  .strokeWidth(1)
                  .width("100%");
                Row() {
                  Text() {
                    Span('支付方式：');
                    Span("微信").fontColor($r("app.color.black"));
                  }
                  .fontColor($r("app.color.gl_999"))
                  .fontSize(14)
                  .layoutWeight(1);

                }.justifyContent(FlexAlign.Start)
                .padding(16)
                .width("100%");

                Row(){
                  Divider()
                    .color($r('app.color.main_color'))
                    .vertical(false)
                    .strokeWidth(4)
                    .layoutWeight(1)
                  Divider()
                    .color($r('app.color.color_line'))
                    .vertical(false)
                    .strokeWidth(4)
                    .layoutWeight(1)
                }

                Row() {
                  Button("确认支付")
                    .width(200)
                    .height(40)
                    .backgroundColor($r("app.color.main_color"))
                    .fontColor($r("app.color.white"))
                    .borderRadius(20)
                    .onClick(() => {
                      this.pay();
                    })
                  }
                  .justifyContent(FlexAlign.End)
                  .padding(16)
                  .layoutWeight(1)
                }
              }
              .width("100%")
              .backgroundColor($r("app.color.white"))

            }
          }
          .width('100%')
          .layoutWeight(1)
        .align(Alignment.TopStart)
        // FullLoading({ loading: this.pageLoading })
    }
  .hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.white"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack

      try {
        this.generalModelPageData = this.navPathStack.getParamByName('GeneralPayPage')[this.navPathStack.getParamByName('GeneralPayPage').length - 1] as generalModel;
         this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }
}