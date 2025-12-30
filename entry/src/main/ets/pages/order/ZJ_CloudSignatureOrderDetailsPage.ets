import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, LogUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  EXPERT_DECRYPT_HTTP,
  EXPERT_DISTANCE_HTTP,
  ZJ_BID_EVALUATION_GET_EXPERT_EVALUATE_HTTP,
  ZJ_CANCEL_CLOUD_SIGNATURE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_HTTP,
  ZJ_GET_EXPERT_EVALUATE_TABLE_HTTP,
  ZJ_HOST_RECORD_PHONE_HTTP, ZJ_REQUEST_REVIEW_HTTP } from "../../api/UrlConfigure";
import { generalModel, justifyTextModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";
import { Previewer } from "@humor/lg-image-previewer";
import { systemShare } from "@kit.ShareKit";
import { common } from "@kit.AbilityKit";
import { uniformTypeDescriptor } from "@kit.ArkData";
import { ShareWxSdk } from "@zyl/wxcommonlibhar";
import { LaunchMiniProgramReq, PayResp, SendReqResultWrap } from "@tencent/wechat_open_sdk";
import { APP_ID_WX } from "../../config/Index";

@Builder
export function CloudSignatureOrderDetailsPageBuilder(name: string, param: Object) {
  CloudSignatureOrderDetailsPage()
}

@ComponentV2
export struct CloudSignatureOrderDetailsPage {

  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local gModelData?: generalModel = undefined;
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local kfCount: number = 0;

  aboutToAppear(): void {
  }

  loadTabsData(): void {
    this.pageLoading = true;

    easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_HTTP,{orderNo:this.generalModelPageData?.orderNo},"POST").then((res) => {
      this.gModelData = res?.["data"]|| [];
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
          Text($r("app.string.order_info")) // 请添加对应的资源字符串
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor($r("app.color.white"))

          // 提交按钮
          Text($r("app.string.submit")) // 请添加对应的资源字符串
            .fontSize(16)
            .onClick(() => {

            })
            .height(30)
            .visibility(Visibility.Hidden)
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

            Column() {
              Row(){
                Text("订单信息") {
                }
                .fontColor($r("app.color.black"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)
              .padding({top:5,bottom:5})
              Row(){
                Text("云签章") {
                }
                .fontColor($r("app.color.black"))
                .fontWeight(FontWeight.Bold)
                .fontSize(18)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)
              .padding({top:10,bottom:10})

              Row(){
                Text("订单编号：") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                Text(this.gModelData?.orderNo) {
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
                Text(parseFloat(this.gModelData?.totalPrice).toFixed(2)+"元") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)

              // if(StrUtil.isNotEmpty(this.gModelData?.signCertificateSerial)) {
              //   Row(){
              //     Text("有效期至：") {
              //     }
              //     .fontColor($r("app.color.gl_666"))
              //     .fontSize(16)
              //     .textAlign(TextAlign.Start)
              //     .lineHeight(24)
              //     Text(this.gModelData?.expireDate) {
              //     }
              //     .fontColor($r("app.color.gl_666"))
              //     .fontSize(16)
              //     .textAlign(TextAlign.Start)
              //     .lineHeight(24)
              //     .layoutWeight(1)
              //   }
              //   .alignItems(VerticalAlign.Top)
              // } else {
                Row(){
                  Text("有 效 期 ：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text("自数字证书(CA)制作之日起"+this.gModelData?.validityPeriod+"内有效") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)
              // }

              Row(){
                Text("订单日期：") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                Text(this.gModelData?.createTime) {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)



              Row(){
                Text("订单状态：") {
                }
                .fontColor($r("app.color.gl_666"))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                Text(this.orderStatusStr(parseInt(this.gModelData?.orderStatus??""))) {
                }
                .fontColor(this.orderStatusColorStr(parseInt(this.gModelData?.orderStatus??"")))
                .fontSize(16)
                .textAlign(TextAlign.Start)
                .lineHeight(24)
                .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)

              if(parseInt(this.gModelData?.orderStatus??"0") > 0) {
                Row({space:10}){

                  Text("取消订单")
                    .fontColor($r("app.color.gl_999"))
                    .backgroundColor($r("app.color.white"))
                    .borderColor($r("app.color.gl_999"))
                    .borderWidth(1)
                    .fontSize(13)
                    .borderRadius(5)
                    .padding({top:8,bottom:8,left:10,right:10})
                    .textAlign(TextAlign.Center)
                    .width(85)
                    .visibility(this.gModelData?.orderStatus=="1"?Visibility.Visible:Visibility.None)
                    .onClick(() => {
                      console.log("取消订单")
                      CoreUtils.alert("是否取消订单？", () => {
                        this.cancelOrder(this.gModelData?.orderNo);
                      },true);

                      // this.jumpEvaluationDetailsPage(this.gModelData?);
                    })

                  Text("去支付")
                    .fontColor($r("app.color.white"))
                    .backgroundColor("#63ce90")
                    .fontSize(13)
                    .padding({top:8,bottom:8,left:10,right:10})
                    .textAlign(TextAlign.Center)
                    .width(85)
                    .borderRadius(5)
                    .visibility(this.gModelData?.orderStatus=="1"?Visibility.Visible:Visibility.None)
                    .onClick(() => {
                      console.log("去支付")

                      DialogHelper.showActionSheetDialog({
                        title: "请选择支付方式",
                        cancelFontColor: Color.Red,
                        cancelFontWeight: FontWeight.Normal,
                        backCancel:true,
                        sheets: ["微信支付","支付宝支付"],
                        onAction: (index) => {
                          console.log("点击了："+index);
                          this.tongLianPay(index);
                        }
                      })

                    })

                }
                .justifyContent(FlexAlign.End)
                .padding({top:10,bottom:10})
                .width("100%")
              }


              Image($r("app.media.0420_cloudsign_sel"))
                .width(75)
                .height(75)
                .position({top:15,right:0})

              Divider()
                .strokeWidth(5)
                .color($r("app.color.main_background"))
                .margin({ top: 10 ,bottom: 10,left: -16, right: -16 })


              if (StrUtil.isNotEmpty(this.gModelData?.signCertificateSerial)) {
                Row(){
                  Text("证书信息") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text("") {
                  }
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                Row(){
                  Text("证书序号：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(this.gModelData?.signCertificateSerial) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                Row(){
                  Text("证书状态：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(StrUtil.isNotEmpty(this.gModelData?.signCertificateSerial)? StrUtil.isEmpty(this.gModelData?.expireDate)?"无到期时间":DateUtil.compareDate(this.gModelData?.expireDate,Date.now())>1?"已过期":"已生效":"未生效") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                Row(){
                  Text("证书厂商：") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text(this.gModelData?.manufacturer) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)

                if(StrUtil.isNotEmpty(this.gModelData?.signCertificateSerial)) {
                  Row(){
                    Text("有效期至：") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    Text(this.gModelData?.expireDate) {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)
                }


                Divider()
                  .strokeWidth(5)
                  .color($r("app.color.main_background"))
                  .margin({ top: 10 ,bottom: 10,left: -16, right: -16 })
              }



              if(this.gModelData?.invoice == "1") {
                Column() {
                  Row(){
                    Text("发票信息") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    Text("") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)

                  Row(){
                    Text("发票抬头：") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    Text(this.gModelData?.userName) {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)

                  Row(){
                    Text("发票金额：") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    Text(parseFloat(this.gModelData?.totalPrice).toFixed(2)+"元") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)

                  Row(){
                    Text("开票状态：") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    Text(StrUtil.isNotEmpty(this.gModelData?.invoiceUrl)?"已开票":"未开票") {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)

                  Row(){
                    Text("*云签章证书生成后24小时自动开具发票，开具后在此处下载") {
                    }
                    .fontColor($r("app.color.org_color"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .layoutWeight(1)
                  }
                  .alignItems(VerticalAlign.Top)

                  if(StrUtil.isNotEmpty(this.gModelData?.invoiceUrl)) {


                    Image($r("app.media.icon_dzfp"))
                      .width(48)
                      .height(35)
                      .position({top:10,right:10})

                    Row({space:10}){

                      Text("查看发票")
                        .fontColor($r("app.color.white"))
                        .backgroundColor($r("app.color.main_color"))
                        .fontSize(13)
                        .padding({top:8,bottom:8,left:10,right:10})
                        .textAlign(TextAlign.Center)
                        .width(85)
                        .borderRadius(5)
                        .onClick(() => {
                          console.log("查看发票")
                          let shareUrl :string = this.gModelData?.invoiceUrl??"";
                          console.log("分享链接:"+shareUrl);
                          let data: systemShare.SharedData = new systemShare.SharedData({
                            utd: uniformTypeDescriptor.UniformDataType.HTML,
                            content: shareUrl
                          });
                          let controller: systemShare.ShareController = new systemShare.ShareController(data);
                          // 获取UIAbility上下文对象
                          let uiContext: UIContext = this.getUIContext();
                          let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
                          controller.show(context, {
                            previewMode: systemShare.SharePreviewMode.DETAIL,
                            selectionMode: systemShare.SelectionMode.SINGLE
                          });
                        })
                    }
                    .justifyContent(FlexAlign.End)
                    .padding({top:20,bottom:10})
                    .width("100%")
                  }
                }
              } else {
                Row(){
                  Text("是否开具发票：否") {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  Text('') {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)
              }


            }
            .width("100%")
            .padding(16)
            .backgroundColor($r("app.color.white"))


          }.width("100%")
        }
        .width("100%")
        .align(Alignment.TopStart)
        .layoutWeight(1)

      }
      .layoutWeight(1)
    }.hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.main_background"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      try {
        this.generalModelPageData = this.navPathStack.getParamByName('CloudSignatureOrderDetailsPage')[this.navPathStack.getParamByName('CloudSignatureOrderDetailsPage').length - 1] as generalModel;
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }
    })
  }

  //通联支付
  tongLianPay(withIndex:number){
    if(withIndex == 0) {
      //跳转到微信小程序
      let share = new ShareWxSdk(APP_ID_WX)
      share.wechatLaunchMiniProgram({
        userName:"gh_65f0c33e8486",
        path: `pages/pay/pay?orderGuid=${this.gModelData?.orderGuid}&out_trade_no=${this.gModelData?.orderNo}&paymethod=03&userGuid=${ContextUtils.getUserInfo()?.userGuid}&body=${this.gModelData?.productDescription}&token=${ContextUtils.getToken()}`,
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
    easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_HTTP, {orderNo:this.gModelData?.orderNo}, "POST").then((res) => {
      if (res["data"] && res["data"]["orderStatus"] == 2) {
        //已支付
        CoreUtils.alert("恭喜您，签名申请成功", () => {
          this.loadTabsData();
        });
      } else {
        CoreUtils.toast("未查询到您订单的支付状态");
        this.loadTabsData();
      }
    }).catch((err: object) => {
      CoreUtils.toast("请求失败，请稍后再试");
    })
  }

  cancelOrder(orderNo: string | undefined) {
    this.pageLoading = true;
    easyDataRequest(ZJ_CANCEL_CLOUD_SIGNATURE_HTTP,{orderNo:this.generalModelPageData?.orderNo},"POSTFORM").then((res) => {
      CoreUtils.toast("取消成功");
      this.navPathStack.pop({ isRefresh: true }, true);
    })
      .catch((err:string) => {
        LogUtil.error("loadTabsData error: " + err);
      })
      .finally(() => {
        this.pageLoading = false;
        this.refreshIndex++;
      });
  }

  orderAuditStatusStr(appealStatus:number) {
    // 0待审核 、1 审核通过、2 审核未通过、
    switch (appealStatus) {
      case 0:
        return "待审核";
      case 1:
        return "审核通过";
      case 2:
        return "审核未通过";
      default:
        return "";
    }

  }
  orderStatusStr(appealStatus:number) {
    // orderStatus  1待支付 、2已支付、3 已发货 4 已领取 5 已取消
    switch (appealStatus) {
      case 1:
        return "待支付";
      case 2:
        return "已支付";
      case 3:
        return "已发货";
      case 4:
        return "已领取";
      case 5:
        return "已取消";

      default:
        return "";
    }

  }

  orderAuditStatusColorStr(appealStatus:number) {
    // 0待审核 、1 审核通过、2 审核未通过、
    switch (appealStatus) {
      case 0:
        return "#ff9600";
      case 1:
        return "#06C06F";
      case 2:
        return "#EA0000";

      default:
        return "";
    }

  }

  orderStatusColorStr(appealStatus:number) {
    // orderStatus  1待支付 、2已支付、3 已发货 4 已领取 5 已取消
    switch (appealStatus) {
      case 1:
        return "#EA0000";
      case 2:
        return "#666666";
      case 3:
        return "#06C06F";
      case 4:
        return "#06C06F";
      case 5:
        return "#1F1F24";

      default:
        return "";
    }

  }


}