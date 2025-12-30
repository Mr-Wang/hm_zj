import { generalModel } from "../../model/ZJ_Model";
import { Banner } from '@abner/banner'
import { easyDataRequest } from "../../api/EasyRequest";
import { DateUtil,  ToastUtil } from "@pura/harmony-utils";
import { GET_STUDY_SY, ZJ_GET_DEFAULT_HTTP, ZJ_GET_EXPERT_EVALUATE_UN_READ_COUNT_HTTP } from "../../api/UrlConfigure";
import { AppConfig } from "../../config/Index";


@Entry
@ComponentV2
export struct HomePage {

  @Local searchText: string = "";
  @Local searchTitle: string = "";
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;


  //通知公告列表数据
  @Local newsList: generalModel[] = [];
  //轮播图数据
  @Local reShousList: generalModel[] = [];
  //热门课程数据
  @Local bestTraCourseList: generalModel[] = [];
  //相关培训数据
  @Local onLineTraCourseList: generalModel[] = [];
  //排行1数据
  @Local lawsList: generalModel[] = [];
  //排行2数据
  @Local gzphList: generalModel[] = [];
  //排行3数据
  @Local hjphList: generalModel[] = [];
  //排行4数据
  @Local hdslphList: generalModel[] = [];
  //未读消息数
  @Local mesNum:number = 0;
  //切换类型
  @Local classTabIndex: number = 0;



  @Consumer('pageInfos') pageStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.loadTabsData();
  }

  /*下拉刷新功能*/
  handleRefresh() {
    this.isRefreshing = true;
    this.loadTabsData();
  }

  loadTabsData(): void {
    this.pageLoading = true;


      //获取专家首页数据请求
      easyDataRequest(AppConfig.studyBaseUrl + GET_STUDY_SY, {}, "POSTFORM").then((res) => {
        this.pageLoading = false;
        this.reShousList = res?.["data"]?.["reShousList"];
        this.newsList = res?.["data"]?.["webdbInformationTztgList"];


      }).catch((error: Error) => {
        console.error("获取数据失败:" + error.message);
      }).finally(() => {
        this.getMesNumByRequest();
      })

    //获取专家首页数据请求
    easyDataRequest(ZJ_GET_DEFAULT_HTTP, {}, "POSTFORM").then((res) => {
      this.pageLoading = false;
      this.bestTraCourseList = res?.["data"]?.["bestTraCourseList"];
      this.onLineTraCourseList = res?.["data"]?.["onLineTraCourseList"];
      this.lawsList = res?.["data"]?.["lawsList"];


    }).catch((error: Error) => {
      console.error("获取数据失败:" + error.message);
    }).finally(() => {
      this.getMesNumByRequest();
    })

    setTimeout(() => {
      this.isRefreshing = false;
      this.refreshIndex++;
    }, 500);

  }

  //获取未读消息数
  private getMesNumByRequest() {
    easyDataRequest(ZJ_GET_EXPERT_EVALUATE_UN_READ_COUNT_HTTP, {}, "GET").then((res) => {
      this.mesNum = res?.["data"] ?? 0;
    }).catch((error: Error) => {
      console.error("获取数据失败:" + error.message);
    }).finally(() => {
    });
  }

  @Builder
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
  cellTitle(content?: string | Resource, onMoreClick?: () => void) {
    Stack() {

      Row() {
        // 竖杠
        Image($r("app.media.1127_shutiao"))
          .width(4)
          .height(16)
          .margin({ right: 10 })

        Text(content) // 请添加对应的资源字符串
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.line_blue_color"))
          .layoutWeight(1)
        // if (onMoreClick) {
        //   Image($r("app.media.0814_more"))
        //     .width(30)
        //     .onClick(() => {
        //         onMoreClick();
        //     })
        // }
      }
      .padding(16)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r("app.color.white"))
      .width("100%")
    }
    .width("100%")
    .margin({ top: 5 })
  }
  private self = this;

// 轮播图
  @Builder
  itemMarginPage(index: number, item: generalModel) {
    Column() {
      Image(item?.url ?? $r('app.media.zjhometop'))
        .alt($r('app.media.zjhometop')) // 加载失败时显示占位图
        .objectFit(ImageFit.Fill)
        .width("100%")
        .height("100%")
        .borderRadius(5)
    }
    .width("100%")
    .height("100%")
    .onClick(()=>{
      console.log(this.refreshIndex.toString());

    })
  }


  // 轮播通知公告
  @Builder
  itemMarginLabelPage(index: number, item: generalModel) {
    Row({space:10}) {
      Image($r('app.media.lb'))
        .width(22)
        .height(22)
      Text(item?.title ?? '')
        .fontColor($r("app.color.main_color"))
        .fontSize(14)
        .layoutWeight(1)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.white"))

    .padding({left:16,right:16,top:8,bottom:8})
    .onClick(()=>{
      console.log(this.refreshIndex.toString());
      this.jumpDogInfoPage({  })
    })
  }

  @Builder
  nullData(tsStr:string) {
    Column() {
      Image($r('app.media.nulldata'))
        .objectFit(ImageFit.Fill)
        .width(98)
        .height(64)

      Text(tsStr)
        .fontSize(14)
        .fontColor($r("app.color.gl_999"))
        .margin(16)
    }
    .width("100%")
    .padding({top:30,bottom:30})
  }

  build() {
    Column() {
      // 顶部导航条
      Row() {
        // 搜索框
        Search({ placeholder: $r("app.string.search_placeholder"), value: this.searchText })
          .width(380)
          .enterKeyType(EnterKeyType.Search)
          .onChange((value: string) => {
            this.searchText = value;

          })
          .onSubmit((value: string) => {
            this.handleSearch(value);
          })
          // .onClear(() => {
          //   this.handleSearchClear(); // 添加清除事件处理
          // })
          .placeholderColor(Color.Gray)
          .height(30)
          .margin(5)
          .layoutWeight(1)
          .backgroundColor($r("app.color.white"))
          .borderRadius(4)
          .padding(5)

        // 发布按钮
        Button() {
          Image($r("app.media.0727_add"))
            .objectFit(ImageFit.Contain)
        }.onClick(() => {
          // TODO: 消息通知事件 -暂未实现

        })
        .width(54)
        .height(30)
        .margin({ left: 10, right: 5 })
      }
      .width("100%")
      .padding(10)
      .backgroundColor($r("app.color.main_color"))

      //内容模块-下拉刷新
        Refresh({
          refreshing: this.isRefreshing,
          builder: this.customRefreshComponent()
        }) {
          Scroll(){
            Column() {

              if(this.reShousList.length <= 0) {
                this.nullData("数据获取中...");
              } else {
                //轮播图-普通加载
                Banner({
                  data: this.reShousList,
                  itemPage:  this.itemMarginPage.bind(this),
                  autoPlay:true,
                  bannerHeight:150
                }).margin(16)
              }

              // 功能按钮区域 - 3x4网格
              Grid() {
                // 第一行
                GridItem() {
                  //评标通知
                  this.functionButton($r("app.media.zj_item1"), $r("app.string.bid_evaluation_notice"), 0, () => {
                    // ToastUtil.showToast("暂未开放，敬请期待！");
                    // return;
                    this.pageStack?.pushPathByName('BidEvaluationNoticeListPage', null);
                  })
                }

                GridItem() {
                  //专家评价
                  this.functionButton($r("app.media.zj_item3"), $r("app.string.expert_evaluation"), 0, () => {
                    this.pageStack?.pushPathByName('ExpertEvaluationMainPage', null);
                  })
                }

                GridItem() {
                  // if (this.mesNum > 0) {
                    this.functionButton($r("app.media.zj_item4A"), $r("app.string.ca_convenient_processing"), this.mesNum, () => {

                      this.pageStack?.pushPathByName('CAHandleMainPage', {} as generalModel,(params1) => {
                        if (params1 && params1.result) {
                          this.loadTabsData();
                        }
                      });

                      // this.pageStack?.pushPathByName('MessagesMorePage', {title:"业务处理状态",type:"3"} as generalModel)
                    })
                  // }else {
                  //   this.functionButton($r("app.media.zj_item4A"), $r("app.string.ca_convenient_processing"), 0, () => {
                  //     // this.pageStack?.pushPathByName('MessagesMorePage', {title:"业务处理状态",type:"3"} as generalModel)
                  //   })
                  // }
                }

                // 第二行
                GridItem() {
                  // 劳务报酬结算
                  this.functionButton($r("app.media.zj_item5A"), $r("app.string.settlement_of_labor_remuneration"), 0, () => {
                    ToastUtil.showToast("暂未开放，敬请期待！");
                    return;
                    this.pageStack?.pushPathByName('DogManagePage', null);
                  })
                }

                GridItem() {
                  // 专家信息
                  this.functionButton($r("app.media.zj_item6"),  $r("app.string.expert_information"), 0, () => {
                    ToastUtil.showToast("暂未开放，敬请期待！");
                    return;
                    this.pageStack?.pushPathByName('DataApplicationListPage', null);
                  })
                }

                GridItem() {
                  //咨询投诉
                  this.functionButton($r("app.media.zj_item7A"),  $r("app.string.consultation_and_complaints"), 0, () => {
                    this.pageStack?.pushPathByName('MailingInquiryPage', {title:"咨询投诉" } as generalModel);
                  })
                }

              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .width('100%')
              .height(200)
              .backgroundColor($r("app.color.white"))

              this.cellTitle($r("app.string.notice_notice"),()=>{
                console.log("点击了通知公告")
                // TODO: 通知公告更多页面跳转
                this.pageStack?.pushPathByName('MatchOrVideoMorePage', "1")
              });

              if(this.reShousList.length <= 0) {
                this.nullData("数据获取中...");
              } else {
                //通知公告-普通加载
                Banner({
                  data: this.newsList,
                  itemPage:  this.itemMarginLabelPage.bind(this),
                  autoPlay:true,
                  bannerHeight:44,
                  indicator:false,
                })
                  .borderRadius(5)
                  .borderWidth(1)
                  .borderColor($r("app.color.color_line"))
                  .margin({left:16,right:16})
              }

              Column() {
                Row({space:16}) {
                  Text("热门课程")
                    .fontWeight(this.classTabIndex == 0?FontWeight.Bold:FontWeight.Normal)
                    .fontSize(this.classTabIndex == 0?20:16)
                    .onClick(()=>{
                      this.classTabIndex = 0;
                    })
                  Text("相关培训")
                    .fontWeight(this.classTabIndex == 1?FontWeight.Bold:FontWeight.Normal)
                    .fontSize(this.classTabIndex == 1?20:16)
                    .onClick(()=>{
                      this.classTabIndex = 1;
                    })
                }
                .alignSelf(ItemAlign.Start)

                Text("近千门专题课程，助你吃透各个知识点")
                  .fontSize(14)
                  .fontColor($r("app.color.gl_999"))
                  .fontWeight(FontWeight.Bold)
                  .margin({top:10})

                if(this.classTabIndex == 0) {
                  ForEach(this.bestTraCourseList, (item: generalModel, index: number) => {
                   Row({space:16}){
                     Image(item.Photo)
                       .alt($r("app.media.0211_CourseDef"))
                       .width(113)
                       .height(67)
                       .objectFit(ImageFit.Fill)
                       .borderRadius(5)
                     Column() {
                       Text(item.Title)
                         .fontSize(14)
                         .maxLines(2)
                         .textOverflow({ overflow: TextOverflow.Ellipsis })
                         .layoutWeight(1)
                       Row() {
                         Row() {
                           SymbolGlyph($r('sys.symbol.person_fill'))
                             .fontColor([$r('app.color.gl_999')])
                             .fontSize(12)
                           Text()
                           {
                             Span(item.num + "人报名")
                             if(parseInt(item.num??"0") >= parseInt(item.baomingnum??"0")){
                               Span("(已满)")
                                 .fontColor($r("app.color.red_color"))
                             }
                           }
                           .margin({left: 5})
                           .fontSize(12)
                           .fontColor($r("app.color.gl_999"))
                         }.layoutWeight(1)


                         Text(this.baomingTitle(item))
                           .fontSize(12)
                           .fontColor($r("app.color.white"))
                           .backgroundColor("#89B5FF")
                           .padding({left: 8, right: 8 , top: 5, bottom: 5})
                           .borderRadius(2)
                       }.justifyContent(FlexAlign.SpaceBetween)
                     }
                     .height(67)
                     .layoutWeight(1)
                     .alignItems(HorizontalAlign.Start)
                   }
                   .width('100%')
                   .border({width:{bottom:1},color:$r("app.color.color_line")})
                   .padding({top:10,bottom:10})
                  })
                }
                else {
                  ForEach(this.onLineTraCourseList, (item: generalModel, index: number) => {
                    Row({space:16}){
                      Image(item.Photo)
                        .alt($r("app.media.0211_CourseDef"))
                        .width(113)
                        .height(67)
                        .objectFit(ImageFit.Fill)
                        .borderRadius(5)
                      Column() {
                        Text(item.Title)
                          .fontSize(14)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                        Row() {
                          Row() {
                            SymbolGlyph($r('sys.symbol.person_fill'))
                              .fontColor([$r('app.color.gl_999')])
                              .fontSize(12)
                            Text()
                            {
                              Span(item.num + "人报名")
                              if(parseInt(item.num??"0") >= parseInt(item.baomingnum??"0")){
                                Span("(已满)")
                                  .fontColor($r("app.color.red_color"))
                              }
                            }
                            .margin({left: 5})
                            .fontSize(12)
                            .fontColor($r("app.color.gl_999"))
                          }.layoutWeight(1)


                          Text(this.baomingTitle(item))
                            .fontSize(12)
                            .fontColor($r("app.color.white"))
                            .backgroundColor("#89B5FF")
                            .padding({left: 8, right: 8 , top: 5, bottom: 5})
                            .borderRadius(2)
                        }.justifyContent(FlexAlign.SpaceBetween)
                      }
                      .height(67)
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .border({width:{bottom:1},color:$r("app.color.color_line")})
                    .padding({top:10,bottom:10})
                  })
                }

                Text("查看更多")
                  .margin({top:10})
                  .width('100%')
                  .fontSize(14)
                  .textAlign(TextAlign.Center)
                  .fontColor($r("app.color.main_color"))
                  .onClick(()=>{
                    console.log("查看更多");
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .backgroundColor($r("app.color.white"))
              .width('100%')
              .padding(16)

              Grid() {
                ForEach(this.lawsList, (listItem: generalModel, index: number) => {

                  GridItem(){
                    //通知公告-Item
                    Column(){
                      Text(`【${generalModel.categoryStringByNum(listItem.categorynum)}】`)
                        .fontColor($r("app.color.white"))
                        .margin({top: 5})
                        .width('100%')
                        .textAlign(TextAlign.Start)
                      Text(listItem.title)
                        .margin({top: 5})
                        .fontColor($r("app.color.white"))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(listItem.infocontent)
                        .margin({top: 10})
                        .fontColor($r("app.color.gl_888"))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(DateUtil.getFormatDateStr(listItem.infodate, "yyyy-MM-dd"))
                        .margin({top: 5})
                        .width('100%')
                        .textAlign(TextAlign.End)
                        .fontColor($r("app.color.gl_888"))
                    }
                    .padding({left: 5, right: 8, top: 5, bottom: 8})
                    .justifyContent(FlexAlign.Start)
                    .backgroundImage($r("app.media.0818_syB1"))
                    .backgroundImageSize(ImageSize.FILL)

                    .alignItems(HorizontalAlign.Center)
                    .width("100%")
                    .onClick((event) => {
                      // this.jumpToImagesShow(listItem);
                    })
                  }
                }, (item: generalModel) => item.url?.["xvalue"] || "")
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(12)
              .rowsGap(12)
              .padding(12)
              .width('100%')
              .backgroundColor($r("app.color.white"))
              .margin({top: 5})
              // .sticky(StickyStyle.Header | StickyStyle.Footer)
              .scrollBar(BarState.Off)
              // .onReachEnd(() => {
              //   this.handleScrollEnd(this.currentUrl);
              // })

              Text("查看更多")
                .margin({bottom:10})
                .padding({top:10,bottom:10})
                .width('100%')
                .fontSize(14)
                .textAlign(TextAlign.Center)
                .fontColor($r("app.color.main_color"))
                .backgroundColor($r("app.color.white"))
                .onClick(()=>{
                  console.log("查看更多");
                })


            }
            .width('100%')
          }
          .width("100%")
        }
        .width('100%')
        .layoutWeight(1)
        .onRefreshing(() => {
          this.handleRefresh();
        })
      //这个Loading遮挡框-和网络请求的重复了， 暂时不用
      // FullLoading({ loading: this.pageLoading })
    }
    .height("100%")
  }

  categoryStringByNum(numStr: string) {
    if (numStr.length > 4) {
      numStr = numStr.substring(0, 4);
    }
    let typeStr: string = "";
    switch (numStr) {
      case "5001":
        typeStr = "法律法规";
        break;
      case "5002":
        typeStr = "政策发布";
        break;
      case "5003":
        typeStr = "理论务实";
        break;
      case "5004":
        typeStr = "案例分析";
        break;
      case "5005":
        typeStr = "电子招投标";
        break;
      default:
        typeStr = "法律法规";
        break;
    }
    return typeStr;
  }

  baomingTitle (item: generalModel) {


    if(parseInt(item.num??"0") >= parseInt(item.baomingnum??"0")){
      return "报名已满"
    }
    //判断报名截止时间 是否大于当前时间
    let date1 = new Date();
    //getFormatDate(item.liveEndTime)
    let date2 = DateUtil.getFormatDate(item.liveEndTime);
    if (date1 > date2) {
      return "报名截止"
    }

    return "我要报名"
  }
  @Builder
  functionButton(imageRes: Resource, title: string|Resource, badgeCount: number = 0, onClick: () => void) {
    Stack() {
      Column() {
        Image(imageRes)
          .layoutWeight(1)

        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.black"))
          .margin({bottom: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      this.countBadge(badgeCount)
      // this.countBadge(32)
    }

    .width('100%')
    .height('100%')
    .onClick(() => {
      onClick();
    })
  }


  @Builder
  countBadge(count: number) {
    if (count > 0) {
      Text(count > 99 ? "99+" : count.toString())
        .padding({ top: 2, bottom: 2, left: 5, right: 5 })
        .backgroundColor($r("app.color.red_color"))
        .fontColor($r("app.color.white"))
        .borderRadius(30)
        .fontSize(12)
        .position({ x: '60%', y: '5%' })
    }
  }


  //跳转详情页
  private jumpDogInfoPage(itemModel: generalModel) {
    this.pageStack?.pushPathByName('DogsInfoPage', itemModel, (params) => {
      if (params && params.result['isRefresh']) {
        console.log("子页面让-执行刷新操作");
        // 刷新当前Tab的数据
        this.loadTabsData();


      }
    });
  }

  private jumpWebInfoPage(itemModel: generalModel) {
    let dicPageParam : generalModel = {
      url:itemModel.url
    }
    this.pageStack?.pushPathByName('WebViewInfoPage', dicPageParam, (params) => {
      if (params && params.result['isRefresh']) {
        console.log("子页面让-执行刷新操作");
        // 刷新当前Tab的数据
        this.loadTabsData();

        setTimeout(() => {
          this.isRefreshing = false;
          this.refreshIndex++;
        }, 1000);

      }
    });
  }

  handleSearch(value: string) {
    console.log("trigger search onsubmit" + value);
    this.searchTitle = value; // 保存搜索关键词
  }

}

