import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  ZJ_CANCEL_CLOUD_SIGNATURE_HTTP,
  ZJ_CA_DELETE_DD_HTTP,
  ZJ_GET_APPEAL_LIST_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_HTTP,
  ZJ_GET_CLOUD_SIGNATURE_LIST_HTTP,
  ZJ_GET_MY_DEAL_HTTP,  } from "../../api/UrlConfigure";
import { generalModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";
import { ShareWxSdk } from "@zyl/wxcommonlibhar";
import { APP_ID_WX } from "../../config/Index";
import { LaunchMiniProgramReq, PayResp, SendReqResultWrap } from "@tencent/wechat_open_sdk";

// 列表数据源
class TimeTableDataSource implements IDataSource {
  private list: generalModel[] = [];
  private listener?: DataChangeListener;
  private hasMore: boolean = false;
  private isLoading: boolean = false;
  private isLoaded: boolean = false;
  private listUrl: string;
  private currentPage: number = 1;
  private pageItemNum: number = 10;

  constructor(listUrl: string) {
    this.listUrl = listUrl;
  }

  // 添加一个方法来检查是否已加载数据
  hasLoaded(): boolean {
    return this.isLoaded;
  }

  // 加载数据方法
  loadData(isRefresh: boolean = false) {
    if (this.isLoading) return;

    this.isLoading = true;

    // 构建请求URL，截取listUrl中bidevaluation/getBidNoticeList?key=2的?后面的参数 key=2 取出 2， 并且给requestUrl复制？前面的内容

    let requestUrl = this.listUrl;
    let keyValue = "";

    //判断是否有keyName参数，如果有则去掉keyName参数，如果没有则去掉？后面的内容
    if (this.listUrl.indexOf("?") > 0) {
      requestUrl = requestUrl.split("?")[0];
      let keyName = this.listUrl.split("?")[1];
      keyValue = keyName.split("=")[1];
    }


    //下一页请求方式
    if (!isRefresh) {
      this.currentPage ++;
    } else {
      this.currentPage = 1;
    }
    if(requestUrl == ZJ_GET_APPEAL_LIST_HTTP) {
      easyDataRequest(requestUrl,{currentPage:this.currentPage.toString(),pageItemNum:this.pageItemNum.toString()}, "GET").then((res) => {
        console.log("获取数据成功");
        let rawData: generalModel[] = [];
        rawData = res?.["data"] || [];
        let newData: generalModel[] = [];
        if (Array.isArray(rawData)) {
          newData = rawData;
        } else if (rawData) {
          newData = [rawData];
        }

        if (isRefresh) {
          this.list = newData;
        } else {
          this.list = this.list.concat(newData);
        }

        try {
          // 判断是否有更多数据
          this.hasMore = parseInt(res?.["data"]?.["allPageNum"]) > this.currentPage;
        }
        catch (error) {
          this.hasMore = false;
        }

        this.isLoaded = true; // 标记数据已加载
        this.notifyDataReload();
      }).catch((error: Error) => {
        console.error("获取数据失败:" + error.message);
      }).finally(() => {
        this.isLoading = false;
      });
    } else {
      easyDataRequest(requestUrl,{currentPage:this.currentPage.toString(),pageItemNum:this.pageItemNum.toString(),key:keyValue,zjidcard:ContextUtils.getUserInfo()?.idcardnum}, "POSTFORM").then((res) => {
        console.log("获取数据成功");
        let rawData: generalModel[] = [];
        rawData = res?.["data"]?.["data"] || [];
        let newData: generalModel[] = [];
        if (Array.isArray(rawData)) {
          newData = rawData;
        } else if (rawData) {
          newData = [rawData];
        }

        if (isRefresh) {
          this.list = newData;
        } else {
          this.list = this.list.concat(newData);
        }

        try {
          // 判断是否有更多数据
          this.hasMore = parseInt(res?.["data"]?.["allPageNum"]) > this.currentPage;
        }
        catch (error) {
          this.hasMore = false;
        }

        this.isLoaded = true; // 标记数据已加载
        this.notifyDataReload();
      }).catch((error: Error) => {
        console.error("获取数据失败:" + error.message);
      }).finally(() => {
        this.isLoading = false;
      });
    }

  }

  refresh() {
    this.loadData(true);
  }

  loadMore() {
    if (this.hasMore && !this.isLoading) {
      this.loadData(false);
    }
  }

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): generalModel {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listener = listener;
  }

  unregisterDataChangeListener(): void {
    this.listener = undefined;
  }

  private notifyDataReload() {
    this.listener?.onDataReloaded();
  }
}

@Builder
export function CAOrderMainPageBuilder(name: string, param: Object) {
  // console.log("aa");
  CAOrderMainPage()
}

@ComponentV2
export struct CAOrderMainPage {
  @Local currentTabIndex: number | undefined;
  signSuccessDic?: generalModel = undefined;
  @Local callPhone: string = "";
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  private scroller: ListScroller = new ListScroller();
  private dataSources: Map<string, TimeTableDataSource> = new Map();
  @Local  currentUrl:string = "";
  @Local generalModelPageData?: generalModel = undefined;
  @Local private navPathStack: NavPathStack = new NavPathStack()

  @Local selExperModel?: generalModel = undefined;

  aboutToAppear(): void {
  }

  getCurrentUrl(withKey:number) {
    if(withKey == 0){
      return ZJ_GET_CLOUD_SIGNATURE_LIST_HTTP;
    } else if(withKey == 1){
      return ZJ_GET_MY_DEAL_HTTP;
    }
    return "";
  }

  // 数据变化监听器
  private dataChangeListener: DataChangeListener = {
    onDataReloaded: () => {
      console.log('数据重新加载完成，更新UI');
      const dataSource = this.getDataSource(this.getCurrentUrl(this.currentTabIndex ?? 0));
      dataSource.getData(0);
       setTimeout(() => {
        this.refreshIndex++; // 触发UI更新
        this.isRefreshing = false;
        this.pageLoading = false;
      }, 1000);
    },
    onDataAdded: (index: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataAdd: (index: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataMoved: (from: number, to: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataMove: (from: number, to: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataDeleted: (index: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataDelete: (index: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataChanged: (index: number): void => {
      throw new Error("Function not implemented.");
    },
    onDataChange: (index: number): void => {
      throw new Error("Function not implemented.");
    },
    onDatasetChange: (dataOperations: DataOperation[]): void => {
      throw new Error("Function not implemented.");
    }
  };

  loadTabsData(): void {
    this.pageLoading = true;


    const dataSource = this.getDataSource(this.getCurrentUrl(this.currentTabIndex ?? 0));
    dataSource.refresh();
    this.callPhone = ContextUtils.getUserInfo()?.loginID??"";
    setTimeout(() => {
      this.isRefreshing = false;
      this.pageLoading = false;
      this.refreshIndex++;
    }, 1000);
  }

  getDataSource(url: string): TimeTableDataSource {
    if (!this.dataSources.has(url)) {
      const dataSource = new TimeTableDataSource(url);
      // 立即注册监听器
      dataSource.registerDataChangeListener(this.dataChangeListener);

      this.dataSources.set(url, dataSource);
    }
    return this.dataSources.get(url)!;
  }

  handleRefresh(url: string) {
    this.isRefreshing = true;
    const dataSource = this.getDataSource(url);
    dataSource.refresh();

    setTimeout(() => {
      this.isRefreshing = false;
      this.refreshIndex++;
    }, 1000);

  }

  handleScrollEnd(url: string) {
    const dataSource = this.getDataSource(url);
    dataSource.loadMore();
    this.refreshIndex++; // 触发UI更新
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
          Text($r("app.string.order_management")) // 请添加对应的资源字符串
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

        Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
          TabContent(){

            Refresh({
              refreshing: this.isRefreshing,
              builder: this.customRefreshComponent()
            }) {
              //评标通知列表
              this.listCellBuilder(0)
            }
            .width('100%')
            .layoutWeight(1)
            .onRefreshing(() => {
              this.handleRefresh(this.getCurrentUrl(this.currentTabIndex ?? 0));
              this.refreshIndex++; // 触发UI更新
            })

          }
          .align(Alignment.TopStart)
          .backgroundColor($r("app.color.main_background"))
          .tabBar(new SubTabBarStyle("云签章订单")
            .labelStyle({ selectedColor: $r("app.color.main_color"), font: { size: 16 } })
            .indicator({ color: $r("app.color.main_color"), marginTop: 5 })
            .padding({
              left: 10,
              right: 10,
              top: 0,
              bottom: 0
            })
          )
          .width("100%")

          TabContent(){


            Refresh({
              refreshing: this.isRefreshing,
              builder: this.customRefreshComponent()
            }) {
              //评标通知列表
              this.listCellBuilder(1)
            }
            .width('100%')
            .layoutWeight(1)
            .onRefreshing(() => {
              this.handleRefresh(this.getCurrentUrl(this.currentTabIndex ?? 0));
              this.refreshIndex++; // 触发UI更新
            })

          }
          .align(Alignment.TopStart)
          .backgroundColor($r("app.color.main_background"))
          .tabBar(new SubTabBarStyle("实体锁订单")
            .labelStyle({ selectedColor: $r("app.color.main_color"), font: { size: 16 } })
            .indicator({ color: $r("app.color.main_color"), marginTop: 5 })
            .padding({
              left: 10,
              right: 10,
              top: 0,
              bottom: 0
            })
          )

        }
        .layoutWeight(1)
        .width("100%")
        .backgroundColor($r("app.color.white"))
        .onChange((index: number) => {
          // console.log("Tab切换至索引:" + index);
          console.log("Tab切换至索引:" + index);
          this.handleTabChange(index); // 使用新的Tab切换处理方法

        })


        FullLoading({ loading: this.pageLoading })
      }
      .layoutWeight(1)
    }.hideTitleBar(true)
    .height("99%")
    .backgroundColor($r("app.color.white"))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack

      try {
        this.generalModelPageData = this.navPathStack.getParamByName('CAOrderMainPage')[this.navPathStack.getParamByName('CAOrderMainPage').length - 1] as generalModel;
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }


  @Builder
  //评标通知列表*/
  listCellBuilder(withIndex: number = 0) {
    if (this.refreshIndex > 0 && this.getDataSource(this.getCurrentUrl(withIndex)).totalCount() > 0) {
      //赛事列表
      List({ space: 0, scroller: this.scroller }) {
        LazyForEach(this.getDataSource(this.getCurrentUrl(withIndex)), (itemModel: generalModel, index: number) => {
           ListItem() {
             if (withIndex == 1) {
               //实体锁订单
               Column() {
                 Column() {
                   Text(DateUtil.getFormatDateStr(itemModel.createDate, "yyyy-MM-dd HH:mm:ss")) {
                   }
                   .fontColor($r("app.color.gl_999"))
                   .fontSize(16)
                   .textAlign(TextAlign.End)
                   .lineHeight(24)
                   .width("100%")

                   Row(){
                     Text(itemModel.sqjg) {
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
                     Text("金　　额：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.amountPrice+"元") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   if(StrUtil.isNotEmpty(itemModel.dqsj)) {
                     Row(){
                       Text("有效期至：") {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       Text(itemModel.dqsj) {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .layoutWeight(1)
                     }
                     .alignItems(VerticalAlign.Top)
                   } else {
                     Row(){
                       Text("有 效 期 ：") {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       Text("自数字证书(CA)制作之日起一年内有效") {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .layoutWeight(1)
                     }
                     .alignItems(VerticalAlign.Top)
                   }


                   Row(){
                     Text("领取方式：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel?.islingqu=="1"?"领取":"邮寄（顺丰寄付）") {
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
                     Text(this.orderStatusStr(parseInt(itemModel?.orderStatus??""))) {
                     }
                     .fontColor(this.orderStatusColorStr(parseInt(itemModel?.orderStatus??"")))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("审核状态：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(this.orderAuditStatusStr(parseInt(itemModel?.status??""))) {
                     }
                     .fontColor(this.orderAuditStatusColorStr(parseInt(itemModel?.status??"")))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Text("*数字证书(CA)审核自支付成功之日起24小时内审核，请随时关注数字证书(CA)审核状态。审核状态为待审核或审核未通过状态无法制作证书且不能领取。")
                     .fontColor($r("app.color.red_color"))
                     .lineHeight(24)

                   if(withIndex == 1 && parseInt(itemModel.orderStatus??"0") > 0) {
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
                         .visibility(itemModel.orderStatus=="1"?Visibility.Visible:Visibility.None)
                         .onClick(() => {
                           console.log("取消订单")
                           // this.jumpEvaluationDetailsPage(itemModel);
                           CoreUtils.alert("是否取消订单？", () => {
                             this.uKeyCancelOrder(itemModel?.orderNo);
                           },true);
                         })

                       Text("去支付")
                         .fontColor($r("app.color.white"))
                         .backgroundColor("#63ce90")
                         .fontSize(13)
                         .padding({top:8,bottom:8,left:10,right:10})
                         .textAlign(TextAlign.Center)
                         .width(85)
                         .borderRadius(5)
                         .visibility(itemModel.orderStatus=="1"?Visibility.Visible:Visibility.None)
                         .onClick(() => {
                           console.log("去支付")
                           // this.jumpEvaluationDetailsPage(itemModel);
                           DialogHelper.showActionSheetDialog({
                             title: "请选择支付方式",
                             cancelFontColor: Color.Red,
                             cancelFontWeight: FontWeight.Normal,
                             backCancel:true,
                             sheets: ["微信支付","支付宝支付"],
                             onAction: (index) => {
                               console.log("点击了："+index);
                               this.tongLianPay(index,itemModel);
                             }
                           })
                         })

                       Text("订单详情")
                         .fontColor($r("app.color.white"))
                         .backgroundColor($r("app.color.main_color"))
                         .fontSize(13)
                         .padding({top:8,bottom:8,left:10,right:10})
                         .textAlign(TextAlign.Center)
                         .width(85)
                         .borderRadius(5)
                         .onClick(() => {
                           console.log("订单详情-ukey")
                           this.navPathStack.pushPathByName("UKeyOrderDetailsPage",itemModel, (params) => {
                             if (params && params.result) {
                               this.loadTabsData();
                             }
                           });
                         })
                     }
                     .justifyContent(FlexAlign.End)
                     .padding({top:10,bottom:10})
                     .width("100%")
                   }


                   Image($r("app.media.0323ukey"))
                     .width(75)
                     .height(35)
                     .position({top:30,right:0})

                 }
                 .width("100%")
                 .padding(16)
                 .backgroundColor($r("app.color.white"))
                 .border({color:"#50dddddd",width:1,radius:2})
                 .shadow({
                   radius: 2,
                   color: "#50dddddd",
                   offsetX: 15,
                   offsetY: 15
                 })
                 .borderRadius(10)
                 .onClick(() => {

                 });
               }
               .padding(10)
               .width('100%')

             } else {
               //云签章订单
               Column() {
                 Column() {
                   Text(DateUtil.getFormatDateStr(itemModel.createTime, "yyyy-MM-dd HH:mm:ss")) {
                   }
                   .fontColor($r("app.color.gl_999"))
                   .fontSize(16)
                   .textAlign(TextAlign.End)
                   .lineHeight(24)
                   .width("100%")

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
                     Text("金　　额：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.totalPrice+"元") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   if(StrUtil.isNotEmpty(itemModel.signCertificateSerial)) {
                     Row(){
                       Text("有效期至：") {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       Text(itemModel.expireDate) {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .layoutWeight(1)
                     }
                     .alignItems(VerticalAlign.Top)
                   } else {
                     Row(){
                       Text("有 效 期 ：") {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       Text("自数字证书(CA)制作之日起"+itemModel.validityPeriod+"内有效") {
                       }
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .layoutWeight(1)
                     }
                     .alignItems(VerticalAlign.Top)
                   }




                   Row(){
                     Text("订单状态：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(this.orderStatusStr(parseInt(itemModel?.orderStatus??""))) {
                     }
                     .fontColor(this.orderStatusColorStr(parseInt(itemModel?.orderStatus??"")))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   if(withIndex == 0 && parseInt(itemModel.orderStatus??"0") > 0) {
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
                         .visibility(itemModel.orderStatus=="1"?Visibility.Visible:Visibility.None)
                         .onClick(() => {
                           console.log("取消订单")
                           CoreUtils.alert("是否取消订单？", () => {
                             this.cloudSignCancelOrder(itemModel?.orderNo);
                           },true);
                         })

                       Text("去支付")
                         .fontColor($r("app.color.white"))
                         .backgroundColor("#63ce90")
                         .fontSize(13)
                         .padding({top:8,bottom:8,left:10,right:10})
                         .textAlign(TextAlign.Center)
                         .width(85)
                         .borderRadius(5)
                         .visibility(itemModel.orderStatus=="1"?Visibility.Visible:Visibility.None)
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
                               this.tongLianPay(index,itemModel);
                             }
                           })
                         })

                       Text("订单详情")
                         .fontColor($r("app.color.white"))
                         .backgroundColor($r("app.color.main_color"))
                         .fontSize(13)
                         .padding({top:8,bottom:8,left:10,right:10})
                         .textAlign(TextAlign.Center)
                         .width(85)
                         .borderRadius(5)
                         .onClick(() => {
                           console.log("订单详情")
                           this.navPathStack.pushPathByName("CloudSignatureOrderDetailsPage",itemModel, (params) => {
                             if (params && params.result) {
                               this.loadTabsData();
                             }
                           });
                         })
                     }
                     .justifyContent(FlexAlign.End)
                     .padding({top:10,bottom:10})
                     .width("100%")
                   }


                   Image($r("app.media.0420_cloudsign_sel"))
                     .width(75)
                     .height(75)
                     .position({top:30,right:0})

                 }
                 .width("100%")
                 .padding(16)
                 .backgroundColor($r("app.color.white"))
                 .border({color:"#50dddddd",width:1,radius:2})
                 .shadow({
                   radius: 2,
                   color: "#50dddddd",
                   offsetX: 15,
                   offsetY: 15
                 })
                 .borderRadius(10)
                 .onClick(() => {
                   this.navPathStack.pushPathByName("CloudSignatureOrderDetailsPage",itemModel, (params) => {
                     if (params && params.result) {
                       this.loadTabsData();
                     }
                   });
                 });
               }
               .padding(10)
               .width('100%')
             }

            };

        }, (item: generalModel, index: number) =>item.id + this.refreshIndex.toString());
      }
      .width('100%')
      .layoutWeight(1)
      .sticky(StickyStyle.Header | StickyStyle.Footer)
      .scrollBar(BarState.Off)
      .onReachEnd(() => {
        this.handleScrollEnd(this.getCurrentUrl(withIndex));
      })
    } else {
      //暂无数据
      // 没有数据时显示空状态
      Column() {
        Image($r("app.media.nulldata")) // 请替换为实际的空状态图标
          .width(100)
          .height(100)
        Text(this.refreshIndex == 0?'加载中，请稍后':'暂无数据')
          .fontSize(16)
          .margin({ top: 16 })
          .fontColor($r("app.color.gl_999"))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }

  }

  cloudSignCancelOrder(orderNo: string | undefined) {
    this.pageLoading = true;
    easyDataRequest(ZJ_CANCEL_CLOUD_SIGNATURE_HTTP,{orderNo:orderNo},"POSTFORM").then((res) => {
      CoreUtils.toast("取消成功");
      this.loadTabsData();
     })
      .catch((err:string) => {
        CoreUtils.toast(err);
      })
      .finally(() => {
        this.pageLoading = false;
        this.refreshIndex++;
      });
  }


  uKeyCancelOrder(orderNo: string | undefined) {
    this.pageLoading = true;
    easyDataRequest(ZJ_CA_DELETE_DD_HTTP,{OrderNo:orderNo},"POSTFORM").then((res) => {
      CoreUtils.toast("取消成功");
      this.loadTabsData();
    })
      .catch((err:string) => {
        CoreUtils.toast(err);
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

  // 添加方法：切换Tab时加载数据
  handleTabChange(index: number) {
    this.currentTabIndex = index;
    this.refreshIndex++;

    // 确保切换Tab时加载数据
    const dataSource = this.getDataSource(this.getCurrentUrl(index));

    // 如果数据尚未加载，则加载数据
    if (!dataSource.hasLoaded()) {
      dataSource.refresh();
    }
  }



  //通联支付
  tongLianPay(withIndex:number,itemModel: generalModel){
    if(withIndex == 0) {
      //跳转到微信小程序
      let share = new ShareWxSdk(APP_ID_WX)
      share.wechatLaunchMiniProgram({
        userName:"gh_65f0c33e8486",
        path: `pages/pay/pay?orderGuid=${itemModel.orderGuid}&out_trade_no=${itemModel.orderNo}&paymethod=03&userGuid=${ContextUtils.getUserInfo()?.userGuid}&body=${itemModel.productDescription}&token=${ContextUtils.getToken()}`,
        miniprogramType: 0, // 拉起小程序的类型
      }as LaunchMiniProgramReq).then((res:SendReqResultWrap)=>{

        if(res instanceof PayResp){
          // 使用支付的类型
        }
        console.log('支付完成后，从微信回来的回调',JSON.stringify(res))
        this.waitingForPayment(itemModel);
      })


    } else {
      CoreUtils.alert("暂不支持支付宝支付");
      return;
    }
  }
  waitingForPayment(itemModel: generalModel) {
    CoreUtils.alert("你有一笔支付正在进行中,请稍后再进行新的操作", () => {
      this.chenggong(itemModel);
    },true);
  }
  chenggong(itemModel: generalModel) {
    easyDataRequest(ZJ_GET_CLOUD_SIGNATURE_HTTP, {orderNo:itemModel?.orderNo}, "POST").then((res) => {
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
}