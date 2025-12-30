import { DialogHelper } from "@pura/harmony-dialog";
import { DateUtil, LocationUtil, StrUtil, WantUtil } from "@pura/harmony-utils";
import { ContextUtils, CoreUtils, FullLoading } from "jbase";
import { easyDataRequest, easyRequest } from "../../api/EasyRequest";
import {
  EXPERT_DECRYPT_HTTP,
  EXPERT_DISTANCE_HTTP,
  ZJ_GET_APPEAL_LIST_HTTP,
  ZJ_HOST_RECORD_PHONE_HTTP, ZJ_REQUEST_REVIEW_HTTP } from "../../api/UrlConfigure";
import { generalModel } from "../../model/ZJ_Model";
// import需要的模块
import { call, observer } from '@kit.TelephonyKit';
import { BusinessError } from "@kit.BasicServicesKit";

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
export function ProjectEvaluationMainPageBuilder(name: string, param: Object) {
  // console.log("aa");
  ProjectEvaluationMainPage()
}

@ComponentV2
export struct ProjectEvaluationMainPage {
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
      return"bidevaluation/getBidNoticeList?key=3";
    } else if(withKey == 1){
      return ZJ_GET_APPEAL_LIST_HTTP;
    } else if(withKey == 2){
      return "bidevaluation/getBidNoticeList?key=2";
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
          Text($r("app.string.project_evaluation")) // 请添加对应的资源字符串
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
          .tabBar(new SubTabBarStyle("评价项目")
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
          .tabBar(new SubTabBarStyle("我的申诉")
            .labelStyle({ selectedColor: $r("app.color.main_color"), font: { size: 16 } })
            .indicator({ color: $r("app.color.main_color"), marginTop: 5 })
            .padding({
              left: 10,
              right: 10,
              top: 0,
              bottom: 0
            })
          )

          TabContent(){

            Refresh({
              refreshing: this.isRefreshing,
              builder: this.customRefreshComponent()
            }) {
              //评标通知列表
              this.listCellBuilder(2)
            }
            .width('100%')
            .layoutWeight(1)
            .onRefreshing(() => {
              this.handleRefresh(this.getCurrentUrl(this.currentTabIndex ?? 0));
              this.refreshIndex++; // 触发UI更新
            })

          }
          .align(Alignment.TopStart)
          .tabBar(new SubTabBarStyle("历史项目")
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
        this.generalModelPageData = this.navPathStack.getParamByName('ProjectEvaluationMainPage')[this.navPathStack.getParamByName('ProjectEvaluationMainPage').length - 1] as generalModel;
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
               //我的申诉
               Column() {
                 Column() {
                   Text(DateUtil.getFormatDateStr(itemModel.createtime, "yyyy-MM-dd HH:mm:ss")) {
                   }
                   .fontColor($r("app.color.gl_999"))
                   .fontSize(16)
                   .textAlign(TextAlign.End)
                   .lineHeight(24)
                   .width("100%")

                   Row(){
                     Text("项目名称：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.projectName) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("标段名称：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.bidSectionName) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("申诉条目：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.deductionName) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("申诉时间：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.evaluateTime) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("申诉状态：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(this.appealStatusStr(parseInt(itemModel.appealStatus??""))) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)


                   if(withIndex == 1) {
                     Row({space:5}){

                       Text("查看申诉")
                         .fontColor($r("app.color.white"))
                         .backgroundColor($r("app.color.main_color"))
                         .fontSize(13)
                         .padding(8)
                         .borderRadius(5)
                         .onClick(() => {
                           console.log("查看申诉")
                           this.jumpGrievanceDetailsPage(itemModel);
                         })
                     }
                     .justifyContent(FlexAlign.End)
                     .padding({top:10,bottom:10})
                     .width("100%")
                   }


                   Image($r("app.media.0701_yqr"))
                     .width(53)
                     .height(53)
                     .position({top:-16,left:-16})
                     .visibility(Visibility.None)

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
               //评价项目和历史项目
               Column() {
                 Column() {
                   Text(DateUtil.getFormatDateStr(itemModel.createtime, "yyyy-MM-dd HH:mm:ss")) {
                   }
                   .fontColor($r("app.color.gl_999"))
                   .fontSize(16)
                   .textAlign(TextAlign.End)
                   .lineHeight(24)
                   .width("100%")

                   Row(){
                     Text("项目名称：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.name) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("标段名称：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.bidSectionName) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)


                   Row(){
                     Text("招 标 人 ：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.tendereeName) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)

                   Row(){
                     Text("代理机构：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.daili) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)


                   Text("评标时间："+DateUtil.getFormatDateStr(itemModel.pbTime, "yyyy-MM-dd HH:mm")) {
                   }
                   .fontColor($r("app.color.gl_666"))
                   .fontSize(16)
                   .textAlign(TextAlign.Start)
                   .lineHeight(24)
                   .width("100%")
                   Row(){
                     Text("评标地点：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.pbAddress) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)


                   Text("集合时间："+DateUtil.getFormatDateStr(itemModel.time, "yyyy-MM-dd HH:mm")) {
                   }
                   .fontColor($r("app.color.gl_666"))
                   .fontSize(16)
                   .textAlign(TextAlign.Start)
                   .lineHeight(24)
                   .width("100%")

                   Row(){
                     Text("集合地点：") {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     Text(itemModel.place) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .layoutWeight(1)
                   }
                   .alignItems(VerticalAlign.Top)


                   Text("签到状态："+(itemModel.leaveFlag ? "已请假":itemModel.signFlag == "1"?"正常签到" : itemModel.signFlag == "2" ? "迟到签到"  : "未签到")) {
                   }
                   .fontColor($r("app.color.gl_666"))
                   .fontSize(16)
                   .textAlign(TextAlign.Start)
                   .lineHeight(24)
                   .width("100%")

                   if (itemModel.signFlag == "1" || itemModel.signFlag == "2") {
                     Text("签到时间："+itemModel.signTime) {
                     }
                     .fontColor($r("app.color.gl_666"))
                     .fontSize(16)
                     .textAlign(TextAlign.Start)
                     .lineHeight(24)
                     .width("100%")
                   }

                   //是否隔夜评标
                   if (itemModel.isOvernight) {
                     Text("是否隔夜评标："+itemModel.isOvernight)
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .width("100%")
                   }
                   //预计评标时长
                   if (itemModel.estimatedEvaluationTime) {
                     Text("预计评标时长："+itemModel.estimatedEvaluationTime)
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .width("100%")
                   }
                   //预计劳务报酬（含税报酬）
                   if (itemModel.estimatedEvaluationPrice) {
                     Text("预计劳务报酬（含税报酬）："+itemModel.estimatedEvaluationPrice)
                       .fontColor($r("app.color.gl_666"))
                       .fontSize(16)
                       .textAlign(TextAlign.Start)
                       .lineHeight(24)
                       .width("100%")
                   }

                   if(withIndex == 0 && parseInt(itemModel.deductionCount??"0") > 0) {
                     Row({space:5}){

                       Text("查看评价")
                         .fontColor($r("app.color.white"))
                         .backgroundColor($r("app.color.main_color"))
                         .fontSize(13)
                         .padding(8)
                         .borderRadius(5)
                         .onClick(() => {
                           console.log("查看评价")
                           this.jumpEvaluationDetailsPage(itemModel);
                         })
                     }
                     .justifyContent(FlexAlign.End)
                     .padding({top:10,bottom:10})
                     .width("100%")
                   }


                   Image($r("app.media.0701_yqr"))
                     .width(53)
                     .height(53)
                     .position({top:-16,left:-16})

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


  decryptionStep1() {
    // 第一步：获取定位信息
    if(LocationUtil.isLocationEnabled()) {
      this.pageLoading = true;
      LocationUtil.requestLocationPermissions().then((grant) => {
        if (grant) { //已授权
          LocationUtil.getCurrentLocationEasy().then((location) => {
            let locationStr = `当前位置1：\n${JSON.stringify(location, null, 2)}\n\n`;
            console.log(locationStr);
            //验证签到位置
            let dicPost:generalModel = {
              longitude: location.longitude.toString(),
              latitude: location.latitude.toString(),
              id: this.selExperModel?.id
            }

            easyDataRequest(
              EXPERT_DISTANCE_HTTP,
              dicPost, "POSTFORM")
              .then((res) => {
                if (res['code'] == 0) {
                  // 验证通过，进行下一步操作
                  if (this.selExperModel) {
                    this.selExperModel.longitude = location.longitude.toString();
                    this.selExperModel.latitude = location.latitude.toString();
                  }
                  this.decryptionStep2()
                } else {
                  CoreUtils.alert("当前位置不在签到范围内，请移动至指定区域后再尝试签到。")
                  this.pageLoading = false
                }
              })
              .catch((err:object) => {
                CoreUtils.toast(err['msg'])
              })

          }).catch((err: BusinessError) => {
            let locationStr = `当前位置~异常信息：\n错误码： ${err.code}\n错误信息：${err.message}`;
            console.log(locationStr)
            if (err.code == 201) {
              LocationUtil.requestLocationPermissions().then((grant) => {
                if (grant) { //已授权
                  CoreUtils.toast("授权成功");
                } else {
                  CoreUtils.toast("请在设置中开启定位权限");
                  WantUtil.toAppSetting();
                }
              });
            }else {
              CoreUtils.toast(locationStr);
              this.pageLoading = false;
            }
          });

        } else {
          CoreUtils.toast("请在设置中开启定位权限");
          WantUtil.toAppSetting();
        }
      });

    } else {
      CoreUtils.alert("请开启定位权限")
      return;
    }

  }

  decryptionStep2() {
      //没有同意过- 提示
      this.initPDFData();


  }

  initPDFData() {

    // NSMutableDictionary *postDic = [NSMutableDictionary new];
    // [postDic setObject:self.selExperModel.id forKey:@"id"];
    // [postDic setObject:self.mUser.idcardnum forKey:@"idcardnum"];
    // [postDic setObject:self.selExperModel.drawExportCode forKey:@"drawExportCode"];
    // [[MS_BasicDataController sharedInstance] postWithURL:zj_requestReview_HTTP params:postDic jsonData:nil showProgressView:YES success:^(id successCallBack) {
    //   NSString *pdfurl = successCallBack;
    //   [self bindPDFView:pdfurl];
    // } failure:^(NSString *failureCallBack) {
    //   [SVProgressHUD showErrorWithStatus:failureCallBack];
    // } ErrorInfo:^(NSError *error) {
    //   [SVProgressHUD showErrorWithStatus:@"请求失败，请稍后再试"];
    // }];

    let dicPost:generalModel = {
      id: this.selExperModel?.id,
      idcardnum: ContextUtils.getUserInfo()?.idcardnum,
      drawExportCode: this.selExperModel?.drawExportCode
    }

    easyDataRequest(
      ZJ_REQUEST_REVIEW_HTTP,
      dicPost, "POSTFORM")
      .then((res) => {
        if (res['code'] == 0) {
          // 验证通过，进行下一步操作
          this.bindPDFView(res['data']);
        } else {
          CoreUtils.alert("当前位置不在签到范围内，请移动至指定区域后再尝试签到。")
        }
      })
      .catch((err:object) => {
        CoreUtils.toast(err['msg'])
      })
      .finally(() => this.pageLoading = false)
  }

  bindPDFView(pdfUrl: string) {
    console.log(pdfUrl)
    this.jumpAgreementWebViewInfoPage({
      pageTitle:"请您阅读并签署协议",
      url: pdfUrl,
      type:"2",
      drawExportCode: this.selExperModel?.drawExportCode,
      id: this.selExperModel?.id,
    })
  }

  decryptionStep3() {
    this.pageLoading = false
    //    3.调用接口签到项目信息，刷新列表；
    let dicPost:generalModel = {
      id: this.selExperModel?.id,
      idCard: ContextUtils.getUserInfo()?.idcardnum,
      longitude: this.selExperModel?.longitude,
      latitude: this.selExperModel?.latitude,
      wordPath: this.signSuccessDic?.contract,
      tenderProjectCode: this.signSuccessDic?.tenderProjectCode,
      drawExportCode: this.signSuccessDic?.drawExportCode
    }

    easyDataRequest(
      EXPERT_DECRYPT_HTTP,
      dicPost, "POSTFORM")
      .then((res) => {
        if (res['code'] == 0) {
          CoreUtils.toast("签到成功");
          this.loadTabsData();
        } else {
          CoreUtils.alert(res['msg'])
        }
      })
      .catch((err:object) => {
        CoreUtils.toast(err['msg'])
      })
      .finally(() => this.pageLoading = false)


  }
  @Builder
  customInputAlertBuilder() {
    Column() {
      Text("")
      {
        Span("　　辽宁专家服务已为您提供当前号码的加密保护，接听方无法获取您当前的真实手机号码。\n　　请确认下面号码是您本次拨出的手机号码（如使用双卡手机或非专家库注册手机登录APP的请选择或使用当前的外呼手机号码。")
          .fontColor($r("app.color.black"))
        Span("可以登记非专家库注册的手机号码")
          .fontColor($r("app.color.red_color"))
        Span("）如号码有误请修改后拨打，否则会提示拨打的是空号。")
          .fontColor($r("app.color.black"))
      }
      .fontSize(14)
      .lineHeight(20)

      TextInput({placeholder:"请输入本机号码" , text: this.callPhone})
        .cancelButton({ style: CancelButtonStyle.INPUT })
        .onChange((value: string) => {
          this.callPhone = value
        })
        .type(InputType.PhoneNumber)
        .fontSize(14)
        .margin({top:10})
    }
    .border({color:$r("app.color.color_line"),width:{bottom:1}})
    .padding({bottom:10})

  }

  //跳转 webview 页
  private jumpAgreementWebViewInfoPage(itemModel: generalModel) {
    this.navPathStack?.pushPathByName('AgreementWebViewInfoPage', itemModel, (params) => {
      if (params && params.result && (params.result as generalModel).tenderProjectCode) {
        this.signSuccessDic = params.result as generalModel;
        this.decryptionStep3();
      }
    });
  }
  //跳转 EvaluationDetailsPage 页
  private jumpEvaluationDetailsPage(itemModel: generalModel) {
    this.navPathStack?.pushPathByName('EvaluationDetailsPage', itemModel, (params) => {
      if (params && params.result) {
        this.loadTabsData();
      }
    });
  }

  //跳转 GrievanceDetailsPage 页
  private jumpGrievanceDetailsPage(itemModel: generalModel) {
    this.navPathStack?.pushPathByName('GrievanceDetailsPage', itemModel, (params) => {
      if (params && params.result) {
        this.loadTabsData();
      }
    });
  }



}