import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, LogUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  EXPERT_DECRYPT_HTTP,
  EXPERT_DISTANCE_HTTP,
  ZJ_BID_EVALUATION_GET_EXPERT_EVALUATE_HTTP,
  ZJ_GET_EXPERT_EVALUATE_TABLE_HTTP,
  ZJ_HOST_RECORD_PHONE_HTTP, ZJ_REQUEST_REVIEW_HTTP } from "../../api/UrlConfigure";
import { generalModel, justifyTextModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";
import { Previewer } from "@humor/lg-image-previewer";

@Builder
export function EvaluationDetailsPageBuilder(name: string, param: Object) {
  EvaluationDetailsPage()
}

@ComponentV2
export struct EvaluationDetailsPage {

  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()
  @Local gModelList: generalModel[] = [];
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local kfCount: number = 0;

  aboutToAppear(): void {
  }

  loadTabsData(): void {
    this.pageLoading = true;

    easyDataRequest(ZJ_BID_EVALUATION_GET_EXPERT_EVALUATE_HTTP,{drawExpertCode:this.generalModelPageData?.drawExportCode},"GET").then((res) => {
      this.gModelList = res?.["data"]|| [];

      let kfCountZ = 0;
      for (const item of this.gModelList) {
        if (parseInt(item.appealStatus??"")  != 3) {
          kfCountZ += parseInt(item.deductPoints??'')
        }
      }
      this.kfCount = kfCountZ;

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
          Text($r("app.string.view_my_review")) // 请添加对应的资源字符串
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
            // 项目信息
            this.cellTitle("项目信息：")

            Column() {
              this.justifyCellItem({
                content: "项目名称",
                fontSize: 15,
                fontColor: $r("app.color.black"),
                maxSize: 4
              }, this.generalModelPageData?.name ?? "")
              this.justifyCellItem({
                content: "标段名称",
                fontSize: 15,
                fontColor: $r("app.color.black"),
                maxSize: 4
              }, this.generalModelPageData?.bidSectionName ?? "")
              this.justifyCellItem({
                content: "评标时间",
                fontSize: 15,
                fontColor: $r("app.color.black"),
                maxSize: 4
              }, this.generalModelPageData?.pbTime ?? "")
              this.justifyCellItem({
                content: "评标地点",
                fontSize: 15,
                fontColor: $r("app.color.black"),
                maxSize: 4
              }, this.generalModelPageData?.pbAddress ?? "")
              if (this.kfCount > 0) {
                this.justifyCellItem({
                  content: "评价扣分",
                  fontSize: 15,
                  fontColor: $r("app.color.black"),
                  maxSize: 4
                }, this.kfCount + "分")
              }


            }
            .padding(16)
            .width("100%")

            // 评价扣分信息
            this.cellTitle("评价扣分信息：", "考评记录表", () => {
              console.log("考评记录表被点击")
              if (this.gModelList.length > 0) {
                easyDataRequest(ZJ_GET_EXPERT_EVALUATE_TABLE_HTTP, {
                  drawExpertCode: this.generalModelPageData?.drawExportCode,
                  projectId: this.gModelList[0].projectId
                }, "GET").then((res) => {
                  LogUtil.info("考评记录表 success: " + JSON.stringify(res));
                  this.navPathStack?.pushPathByName('WebViewInfoPage',
                    { url: res["data"], title: "考评记录表", type: "2" } as generalModel, false);

                })
                  .catch((err: string) => {
                    LogUtil.error("考评记录表 error: " + err);
                  });
              }


            })
            Column() {
              ForEach(this.gModelList, (item: generalModel, index: number) => {
                this.justifyCellItem({
                  content: "扣分项" + (index + 1),
                  fontSize: 15,
                  fontColor: $r("app.color.black"),
                  maxSize: 4
                }, item.deductionName ?? "")
                this.justifyCellItem({
                  content: "扣分",
                  fontSize: 15,
                  fontColor: $r("app.color.black"),
                  maxSize: 4
                }, item.deductPoints + "分" ?? "")
                if (parseInt(item.deductionId ?? "") <= 3) {
                  this.justifyCellItem({
                    content: "集合时间",
                    fontSize: 15,
                    fontColor: $r("app.color.black"),
                    maxSize: 4
                  }, item.collectedTime ?? "")
                  this.justifyCellItem({
                    content: "签到时间",
                    fontSize: 15,
                    fontColor: $r("app.color.black"),
                    maxSize: 4
                  }, item.signTime ?? "")
                  if (!item.substitute) {
                    this.justifyCellItem({
                      content: "迟到时长",
                      fontSize: 15,
                      fontColor: $r("app.color.black"),
                      maxSize: 4
                    }, item.lateTime + "分" ?? "")

                  } else {
                    this.justifyCellItem({
                      content: "评价时间",
                      fontSize: 15,
                      fontColor: $r("app.color.black"),
                      maxSize: 4
                    }, item.evaluateTime ?? "")
                    if (item.appealable) {
                      this.justifyCellItem({
                        content: "申诉截止时间",
                        fontSize: 15,
                        fontColor: $r("app.color.black"),
                        maxSize: 6
                      }, item.appealEndTime ?? "")
                    }
                    this.justifyCellItem({
                      content: "情况说明",
                      fontSize: 15,
                      fontColor: $r("app.color.black"),
                      maxSize: 4
                    }, item.deductionReason ?? "")
                  }
                  if (parseInt(item.appealStatus ?? "") > 1) {
                    this.justifyCellItem({
                      content: "申诉状态",
                      fontSize: 15,
                      fontColor: $r("app.color.black"),
                      maxSize: 4
                    }, this.appealStatusStr(parseInt(item.appealStatus ?? "")))
                  }

                } else {
                  this.justifyCellItem({
                    content: "评价时间",
                    fontSize: 15,
                    fontColor: $r("app.color.black"),
                    maxSize: 4
                  }, item.evaluateTime ?? "")
                  this.justifyCellItem({
                    content: "情况说明",
                    fontSize: 15,
                    fontColor: $r("app.color.black"),
                    maxSize: 4
                  }, item.deductionReason ?? "")
                  if (parseInt(item.appealStatus ?? "") > 1) {
                    this.justifyCellItem({
                      content: "申诉状态",
                      fontSize: 15,
                      fontColor: $r("app.color.black"),
                      maxSize: 4
                    }, this.appealStatusStr(parseInt(item.appealStatus ?? "")))
                  }
                }

                Row({ space: 16 }) {
                  ForEach(item.deductionAppendixList, (item: string, index: number) => {
                    // if ([picUrl rangeOfString:@".pdf"].length > 0) {
                    if (item.endsWith(".pdf")) {
                      Image($r("app.media.pdf"))
                        .width(40)
                        .height(40)
                        .objectFit(ImageFit.Fill)
                        .onClick(() => {
                          console.log("点开pdf")
                          this.navPathStack?.pushPathByName('WebViewInfoPage',
                            { url: item, title: "查看附件", type: "2" } as generalModel, false);
                        })
                    } else {
                      Image(item)
                        .width(40)
                        .height(40)
                        .objectFit(ImageFit.Fill)
                        .onClick(() => {
                          console.log("点开图片")
                          //打开图片框
                          Previewer.show(
                            {
                              imgList: [{ url: encodeURI(item.trim()), id: "image1" }],
                              initIndex: 0,
                            }
                          )
                        })
                    }
                  })
                }
                .padding(16)
                .width("100%")

                Row({ space: 5 }) {
                  if (item.appealable) {
                    Text(parseInt(item.appealStatus ?? "") == 4 ? "二次申诉" : "我要申诉")
                      .fontColor($r("app.color.white"))
                      .backgroundColor($r("app.color.main_color"))
                      .fontSize(13)
                      .padding(8)
                      .borderRadius(5)
                      .onClick(() => {
                        console.log("我要申诉")
                        this.jumpAddNewAppealPage(item);
                      })
                  }
                  if (parseInt(item.appealStatus ?? "") > 1) {
                    Text("申诉详情")
                      .fontColor($r("app.color.white"))
                      .backgroundColor($r("app.color.main_color"))
                      .fontSize(13)
                      .padding(8)
                      .borderRadius(5)
                      .onClick(() => {
                        console.log("申诉详情")
                        this.jumpGrievanceDetailsPage(item);
                      })
                  }

                }
                .justifyContent(FlexAlign.End)
                .padding({ top: 10, bottom: 10 })
                .width("100%")
              })
            }
            .padding(16)
            .margin({ top: 10, left: 16, right: 16 })
            .backgroundColor($r("app.color.white"))
            .border({ color: "#50dddddd", width: 1, radius: 2 })
            .shadow({
              radius: 2,
              color: "#50dddddd",
              offsetX: 15,
              offsetY: 15
            })
            .borderRadius(10)
          }.width("100%")
        }
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
        this.generalModelPageData = this.navPathStack.getParamByName('EvaluationDetailsPage')[this.navPathStack.getParamByName('EvaluationDetailsPage').length - 1] as generalModel;
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }
    })
  }



  appealStatusStr(appealStatus:number) {
    switch (appealStatus) {
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
        return "";
    }

  }

  @Builder
  cellTitle(content?: string | Resource, status?: string | Resource, onMoreClick?: () => void) {
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
        Text(status) // 请添加对应的资源字符串
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

  //跳转 GrievanceDetailsPage 页
  private jumpGrievanceDetailsPage(itemModel: generalModel) {
    this.navPathStack?.pushPathByName('GrievanceDetailsPage', itemModel, (params) => {
      if (params && params.result) {
        this.loadTabsData();
      }
    });
  }
  //跳转 AddNewAppealPage 页
  private jumpAddNewAppealPage(itemModel: generalModel) {
    this.navPathStack?.pushPathByName('AddNewAppealPage', itemModel, (params) => {
      if (params && params.result) {
        this.loadTabsData();
      }
    });
  }


}