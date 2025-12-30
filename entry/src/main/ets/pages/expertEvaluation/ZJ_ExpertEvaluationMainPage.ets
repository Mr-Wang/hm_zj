import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  EXPERT_DECRYPT_HTTP,
  EXPERT_DISTANCE_HTTP, ZJ_HOST_RECORD_PHONE_HTTP, ZJ_REQUEST_REVIEW_HTTP } from "../../api/UrlConfigure";
import { generalModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";

@Builder
export function ExpertEvaluationMainPageBuilder(name: string, param: Object) {
  ExpertEvaluationMainPage()
}

@ComponentV2
export struct ExpertEvaluationMainPage {

  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
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
          Text($r("app.string.bid_evaluation_notice")) // 请添加对应的资源字符串
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
        Column({space:16}) {
          Image($r("app.media.xmpj"))
            .objectFit(ImageFit.Fill)
            .width('100%')
            .onClick(() => {
              console.log("项目评价")
              // ProjectEvaluationMainPage
              this.navPathStack.pushPathByName("ProjectEvaluationMainPage", null, true);
            })
          Image($r("app.media.ndpj"))
            .objectFit(ImageFit.Fill)
            .width('100%')
            .onClick(() => {
              console.log("年度评价")
              this.navPathStack.pushPathByName("AnnualEvaluationMainPage", null, true);
            })
        }
        .width('100%')
        .padding(16)
        .layoutWeight(1)
      }
      .layoutWeight(1)
    }.hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.white"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
    })
  }
}