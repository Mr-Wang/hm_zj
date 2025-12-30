import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, LogUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  EXPERT_DECRYPT_HTTP,
  EXPERT_DISTANCE_HTTP,
  ZJ_BID_EVALUATION_GET_EXPERT_EVALUATE_HTTP,
  ZJ_EVALUATE_HTTP,
  ZJ_GET_CALL_RESULT_HTTP,
  ZJ_GET_EXPERT_EVALUATE_BY_ID_HTTP,
  ZJ_GET_EXPERT_EVALUATE_TABLE_HTTP,
  ZJ_HOST_RECORD_PHONE_HTTP, ZJ_REQUEST_REVIEW_HTTP } from "../../api/UrlConfigure";
import { generalModel, justifyTextModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";
import { Previewer } from "@humor/lg-image-previewer";

@Builder
export function OverallParticipationInTheEvaluationPageBuilder(name: string, param: Object) {
  OverallParticipationInTheEvaluationPage()
}

@ComponentV2
export struct OverallParticipationInTheEvaluationPage {

  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local gModel?: generalModel = undefined;
  @Local refuseList?:generalModel[] = [];
  @Local unansweredList?:generalModel[] = [];
  @Local unDialedList?:generalModel[] = [];
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local kfCount: number = 0;

  aboutToAppear(): void {
  }

  loadTabsData(): void {
    this.pageLoading = true;

    easyDataRequest(ZJ_EVALUATE_HTTP,{},"POSTFORM").then((res) => {
      this.gModel = res?.["data"]|| [];
      if (this.gModel) {
        this.gModel.studyScoreModel = res?.["data"]["studyScore"]|| {};
        this.gModel.rewardScoreModel = res?.["data"]["rewardScore"]|| {};
        this.gModel.otherScoreModel = res?.["data"]["otherScore"]|| {};
        this.gModel.illegalMattersModel = res?.["data"]["illegalMatters"]|| {};

        easyDataRequest(ZJ_GET_CALL_RESULT_HTTP,{},"POSTFORM").then((res) => {
          if (res?.["data"]["list"]) {
            this.refuseList = res?.["data"]["list"]["refuse"]|| [];
            this.unansweredList = res?.["data"]["list"]["unanswered"]|| [];
            this.unDialedList = res?.["data"]["list"]["unDialed"]|| [];
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
          Text($r("app.string.overall_participation_in_the_evaluation")) // 请添加对应的资源字符串
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
            if (this.refreshIndex > 0 && this.gModel != null) {
              Column() {

                this.cellTitle("总体参评得分：" + parseFloat(this.gModel?.participation?.participationScore??"").toFixed(1) + "分")

                Row({ space: 10 }) {
                  Column({ space: 10 }) {
                    Row() {
                      Text("年度语音电话未接听数")
                        .width(150)
                        .fontSize(14)
                        .fontColor("#000000")
                        .fontWeight(FontWeight.Bold)
                      Text(this.gModel?.participation?.unanswered+"次")
                        .fontSize(14)
                        .width(50)
                        .textAlign(TextAlign.Center)
                        .fontColor($r("app.color.main_color"))
                        .fontWeight(FontWeight.Bold)
                      Text("转换扣分"+ parseFloat(this.gModel?.participation?.unansweredDeductPoints).toFixed(1)+"分")
                        .fontSize(14)
                        .width(100)
                        .textAlign(TextAlign.End)
                        .fontColor("#c23431")
                        .fontWeight(FontWeight.Bold)
                    }
                    .justifyContent(FlexAlign.SpaceBetween)
                    .width("100%")

                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                }
                .padding(10)
                .backgroundColor($r("app.color.white"))
                .border({ color: "#50dddddd", width: 1, radius: 2 })
                .shadow({
                  radius: 2,
                  color: "#50dddddd",
                  offsetX: 15,
                  offsetY: 15
                })
                .borderRadius(10)
                .margin(10)
                .onClick(() => {
                  console.log("点击了总体参评得分")
                });

                Row({ space: 10 }) {
                  Column({ space: 10 }) {
                    Row() {
                      Text("年度主动拒绝参评数")
                        .width(150)
                        .fontSize(14)
                        .fontColor("#000000")
                        .fontWeight(FontWeight.Bold)
                      Text(parseFloat(this.gModel?.participation?.refuse).toFixed(0) +"次")
                        .fontSize(14)
                        .width(50)
                        .textAlign(TextAlign.Center)
                        .fontColor($r("app.color.main_color"))
                        .fontWeight(FontWeight.Bold)
                      Text("转换扣分"+parseFloat(this.gModel?.participation?.refuseDeductPoints).toFixed(1)+"分")
                        .fontSize(14)
                        .width(100)
                        .textAlign(TextAlign.End)
                        .fontColor("#c23431")
                        .fontWeight(FontWeight.Bold)
                    }
                    .justifyContent(FlexAlign.SpaceBetween)
                    .width("100%")

                    ForEach(this.unDialedList, (item : generalModel,index) => {
                      Row() {
                        Text(item.startTime+" 拨打未接听 ")
                          .fontSize(14)
                          .fontColor("#000000")
                          .fontWeight(FontWeight.Bold)
                      }
                    });

                    ForEach(this.refuseList, (item : generalModel,index) => {
                      Row() {
                        Text(item.startTime+" 主动拒绝评标邀请 ")
                          .fontSize(14)
                          .fontColor("#000000")
                          .fontWeight(FontWeight.Bold)
                      }
                    });
                    ForEach(this.unansweredList, (item : generalModel,index) => {
                      Row() {
                        Text(item.startTime+" 拨通未回复 ")
                          .fontSize(14)
                          .fontColor("#000000")
                          .fontWeight(FontWeight.Bold)
                      }
                    });

                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .padding(10)
                .backgroundColor($r("app.color.white"))
                .border({ color: "#50dddddd", width: 1, radius: 2 })
                .shadow({
                  radius: 2,
                  color: "#50dddddd",
                  offsetX: 15,
                  offsetY: 15
                })
                .borderRadius(10)
                .margin(10)

              }
              .width("100%")
            }



        }
          .width("100%")
          .layoutWeight(1)
        }
        .align(Alignment.TopStart)
        .width("100%")
        .layoutWeight(1)
      }
      .layoutWeight(1)
    }.hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.main_background"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      try {
        this.generalModelPageData = this.navPathStack.getParamByName('OverallParticipationInTheEvaluationPage')[this.navPathStack.getParamByName('OverallParticipationInTheEvaluationPage').length - 1] as generalModel;
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }
    })
  }


  appealStatusStr1(appealStatus:number) {
    switch (appealStatus) {
      case 0:
        return "未读";
      case 1:
        return "已读";
      case 2:
        return "申诉中";
      case 3:
        return "申诉成功";
      case 4:
        return "申诉失败";
      default:
        return "申诉失败";
    }

  }


  appealStatusStr(appealStatus:number) {
    switch (appealStatus) {
      case 0:
        return "未读";
      case 1:
        return "已读";
      case 2:
        return "申诉中";
      case 3:
        return "申诉成功";
      case 4:
        return "申诉失败";
      case 5:
        return "二次申诉中";
      case 6:
        return "二次申诉成功";
      case 7:
        return "二次申诉失败";
      default:
        return "未知状态";
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
      //   .width(50)
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

  @Builder
  justifyCellItem(jModel:justifyTextModel,value:string) {
    Row() {
      this.justifyText(jModel)

      Text(value)
        .fontSize(15)
        .fontColor($r("app.color.gl_999"))
        .layoutWeight(1)
        .lineHeight(24)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
    // .padding(16)
    // .border({ width: { bottom: 1 }, color: $r("app.color.color_line") })
    .width("100%")
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