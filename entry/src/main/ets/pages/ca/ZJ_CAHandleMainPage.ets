import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, LogUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  EXPERT_DECRYPT_HTTP,
  EXPERT_DISTANCE_HTTP,
  ZJ_BID_EVALUATION_GET_EXPERT_EVALUATE_HTTP,
  ZJ_CANABLE_TO_HANDLE_HTTP,
  ZJ_EVALUATE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_TYPE_HTTP,
  ZJ_GET_EXPERT_EVALUATE_BY_ID_HTTP,
  ZJ_GET_EXPERT_EVALUATE_TABLE_HTTP,
  ZJ_HANDLE_CLOUD_SIGNATURE_INTRODUCE_HTTP,
  ZJ_HOST_RECORD_PHONE_HTTP, ZJ_REQUEST_REVIEW_HTTP } from "../../api/UrlConfigure";
import { generalModel, justifyTextModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";
import { Previewer } from "@humor/lg-image-previewer";

@Builder
export function CAHandleMainPageBuilder(name: string, param: Object) {
  CAHandleMainPage()
}

@ComponentV2
export struct CAHandleMainPage {

  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local gModelList?: generalModel[] = [];
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local kfCount: number = 0;

  @Local usbkeyCaOrderStatus: number = 0;  // 实体锁状态
  @Local signatureOrderStatus: number = 0;      // 云签章状态
  @Local selectedType: string = ''; // 当前选中的类型
  @Local wxtsStr: generalModel = {}; // 温馨提示数据
  @Local wxtsCAStr: generalModel = {}; // 实体CA温馨提示
  @Local yqztdStr: generalModel = {}; // 云签章特点
  @Local catdStr: generalModel = {}; // 实体CA特点

  aboutToAppear(): void {
  }

  loadTabsData(): void {
    this.pageLoading = true;

    easyDataRequest(ZJ_HANDLE_CLOUD_SIGNATURE_INTRODUCE_HTTP,{},"POSTFORM").then((res) => {
      this.gModelList = res?.["data"] || [];

      // 实体CA 温馨提示
      this.wxtsCAStr = this.gModelList?.find(item => item.id == '3') || {};
      // 云签章 温馨提示
      this.wxtsStr = this.gModelList?.find(item => item.id == '9') || {};
      //  云签章特点
      this.yqztdStr = this.gModelList?.find(item => item.id == '4') || {};
      //实体CA特点
      this.catdStr = this.gModelList?.find(item => item.id == '8') || {};

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


    easyDataRequest(ZJ_CANABLE_TO_HANDLE_HTTP,{},"POSTFORM").then((res) => {
      this.usbkeyCaOrderStatus = res?.["data"]?.caOrder || 0;
      this.signatureOrderStatus = res?.["data"]?.signatureOrder || 0;

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
          Text($r("app.string.ca_convenient_processing")) // 请添加对应的资源字符串
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
              if(this.selectedType == "1"){
                Text(this.wxtsCAStr?.url +"\n　　" + this.wxtsCAStr?.codeText?.replace(/\r/g, "\n"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(24)
              }else if(this.selectedType == "2"){
                Text(this.wxtsStr?.url +"\n　　" + this.wxtsStr?.codeText?.replace(/\r/g, "\n"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(24)
              } else {
                Text("温馨提示\n　　为了提供更好数据共享服务，压缩办理流程、时限，减少材料重复提供，加强个人信息保密，各位专家可根据各主管部门的电子化要求，自愿选择此便捷渠道申请办理。")
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(24)
              }

              Text(){
                Span("*")
                  .fontColor($r("app.color.red_color"))
                Span("请选择申请类型：")
              }
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .lineHeight(24)
              .margin({top:50, bottom: 20})

              Row({space:16}){
                Column(){
                  Image(this.selectedType == "1"? $r("app.media.0420_usbkey_sel") : $r("app.media.0420_usbkey"))
                    .width(100)
                    .height(100)

                  Text("实体CA锁")
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .lineHeight(24)
                    .textAlign(TextAlign.Center)
                    .width(100)
                    .fontColor(this.selectedType == "1"?$r("app.color.main_color"):$r("app.color.gl_666"))
                  if(this.selectedType == "1"){
                    Image($r("app.media.0420_sel_right"))
                      .width(43)
                      .height(43)
                      .position({top: -16, right: -16})
                  }

                  if(this.usbkeyCaOrderStatus == 1) {
                    Image($r("app.media.0420_yes"))
                      .width(43)
                      .height(43)
                      .position({top: -16, left: -16})
                  } else if(this.usbkeyCaOrderStatus == 2) {
                    Image($r("app.media.0420_out"))
                      .width(43)
                      .height(43)
                      .position({top: -16, left: -16})
                  }
                }
                .border({color:this.selectedType == "1"?$r("app.color.main_color"):$r("app.color.gl_666"),width:1,radius:10})
                .layoutWeight(1)
                .padding(16)
                .onClick(()=>{
                  this.selectedType = "1"
                })

                Column(){
                  Image(this.selectedType == "2"? $r("app.media.0420_cloudsign_sel") : $r("app.media.0420_cloudsign"))
                    .width(100)
                    .height(100)

                  Text("云签章")
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .lineHeight(24)
                    .textAlign(TextAlign.Center)
                    .width(100)
                    .fontColor(this.selectedType == "2"?$r("app.color.main_color"):$r("app.color.gl_666"))

                  if(this.selectedType == "2"){
                    Image($r("app.media.0420_sel_right"))
                      .width(43)
                      .height(43)
                      .position({top: -16, right: -16})
                  }

                  if(this.signatureOrderStatus == 1) {
                    Image($r("app.media.0420_yes"))
                      .width(43)
                      .height(43)
                      .position({top: -16, left: -16})
                  } else if(this.signatureOrderStatus == 2) {
                    Image($r("app.media.0420_out"))
                      .width(43)
                      .height(43)
                      .position({top: -16, left: -16})
                  }

                }
                .border({color:this.selectedType == "2"?$r("app.color.main_color"):$r("app.color.gl_666"),width:1,radius:10})
                .layoutWeight(1)
                .padding(16)
                .onClick(()=>{
                  this.selectedType = "2"
                })

              }

              if (this.selectedType == "1"){
                Text(){
                  Span(this.catdStr.url + "\n")
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                  Span(this.catdStr.codeText)
                }
                .fontSize(14)
                .fontColor($r("app.color.red_color"))
                .lineHeight(24)
                .margin({top:30, bottom: 20})
              } else if (this.selectedType == "2"){
                Text(){
                  Span(this.yqztdStr.url + "\n")
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                  Span(this.yqztdStr.codeText)
                }
                .fontSize(14)
                .fontColor($r("app.color.red_color"))
                .lineHeight(24)
                .margin({top:30, bottom: 20})
              }


            }
            .width("100%")
            .alignItems(HorizontalAlign.Start)

            .padding(16)

        }
          .width("100%")
          .layoutWeight(1)
        }
        .align(Alignment.TopStart)
        .width("100%")
        .layoutWeight(1)

        Row({space: 16}) {
          Button("取消")
            .height(44)
            .type(ButtonType.Normal)
            .backgroundColor($r("app.color.white"))
            .border({color: $r("app.color.gl_666"), width: 1})
            .fontColor($r("app.color.gl_666"))
            .borderRadius(5)
            .layoutWeight(1)
            .onClick(() => {
              this.navPathStack.pop(true);
            })

          Button("确认")
            .height(44)
            .type(ButtonType.Normal)
            .backgroundColor($r("app.color.main_color"))
            .fontColor($r("app.color.white"))
            .borderRadius(5)
            .layoutWeight(1)
            .onClick(() => {
              this.btnSubmitAction()
            })
        }
        .justifyContent(FlexAlign.End)
        .padding(16)
      }
      .layoutWeight(1)
    }.hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.main_background"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      try {
        this.generalModelPageData = this.navPathStack.getParamByName('CAHandleMainPage')[this.navPathStack.getParamByName('CAHandleMainPage').length - 1] as generalModel;
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }
    })
  }

  btnSubmitAction() {

    if (this.selectedType == "1") {
      this.CABanLi()
    } else if (this.selectedType == "2") {
      this.cloudSignBanLi()
    } else {
      CoreUtils.alert("请先选择申请类型");
    }
  }
  CABanLi() {

    easyDataRequest(ZJ_CANABLE_TO_HANDLE_HTTP,{},"POSTFORM").then((res) => {
      this.usbkeyCaOrderStatus = res?.["data"]?.caOrder || 0;
      this.signatureOrderStatus = res?.["data"]?.signatureOrder || 0;

      LogUtil.info("loadTabsData success: " + JSON.stringify(res));
      this.pageLoading = false;
      this.refreshIndex++;


      if(this.usbkeyCaOrderStatus == 0) {
        this.navPathStack.pushPathByName("UKeyCAHandlePage",{}, (params) => {
          if (params && params.result) {
            this.loadTabsData();
          }
        });
      } else {
        CoreUtils.alert("您已有CA办理订单",()=>{

          this.navPathStack.pushPathByName("CAOrderMainPage",{}, (params) => {
            if (params && params.result) {
              this.loadTabsData();
            }
          });

        },true);
      }

    })
      .catch((err:string) => {
        LogUtil.error("loadTabsData error: " + err);
      })
      .finally(() => {
        this.pageLoading = false;
        this.refreshIndex++;
      });


  }
  cloudSignBanLi() {


    easyDataRequest(ZJ_CANABLE_TO_HANDLE_HTTP,{},"POSTFORM").then((res) => {
      this.usbkeyCaOrderStatus = res?.["data"]?.caOrder || 0;
      this.signatureOrderStatus = res?.["data"]?.signatureOrder || 0;

      LogUtil.info("loadTabsData success: " + JSON.stringify(res));
      this.pageLoading = false;
      this.refreshIndex++;

      if(this.signatureOrderStatus == 0) {
        easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_TYPE_HTTP,{},"POSTFORM").then((res) => {

          let dicCloudSignatureType:generalModel = res?.["data"] || [];
          dicCloudSignatureType.url = this.wxtsStr.url;
          dicCloudSignatureType.codeText = this.wxtsStr.codeText;

          this.navPathStack.pushPathByName("CloudCAHandlePage",dicCloudSignatureType, (params) => {
            if (params && params.result) {
              this.loadTabsData();
            }
          });

        })
          .catch((err:string) => {
          })
          .finally(() => {
          });


      } else {
        CoreUtils.alert("您已有CA办理订单",()=>{

          this.navPathStack.pushPathByName("CAOrderMainPage",{}, (params) => {
            if (params && params.result) {
              this.loadTabsData();
            }
          });

        },true);
      }

    })
      .catch((err:string) => {
        LogUtil.error("loadTabsData error: " + err);
      })
      .finally(() => {
        this.pageLoading = false;
        this.refreshIndex++;
      });

  }
}