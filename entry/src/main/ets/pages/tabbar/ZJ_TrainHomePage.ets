import { generalModel } from "../../model/ZJ_Model";
import { Banner } from '@abner/banner'
import { easyDataRequest } from "../../api/EasyRequest";
import { DateUtil,  ToastUtil } from "@pura/harmony-utils";
import {
  GET_INFORMATION_LIST_HTTP,
  GET_STUDY_SY,
  GET_TRA_ENROL_HOME_HTTP,
  ZJ_GET_DEFAULT_HTTP, ZJ_GET_EXPERT_EVALUATE_UN_READ_COUNT_HTTP } from "../../api/UrlConfigure";
import { AppConfig } from "../../config/Index";


@Entry
@ComponentV2
export struct TrainHomePage {
  private scroller: ListScroller = new ListScroller();
  @Local searchText: string = "";
  @Local searchTitle: string = "";
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local currentPage: number = 1;

  //轮播图数据
  @Local reShousList: generalModel[] = [];
  //最新课程数据
  @Local newTraCourseList: generalModel[] = [];
  //精品培训数据
  @Local bestTraCourseList: generalModel[] = [];
  //热门课程
  @Local askTraCourseList: generalModel[] = [];

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
    this.currentPage = 1;

      //获取培训首页数据请求
      easyDataRequest(AppConfig.studyBaseUrl + GET_TRA_ENROL_HOME_HTTP, {}, "POSTFORM").then((res) => {
        this.pageLoading = false;
        this.reShousList = res?.["data"]?.["reShouList"];
        this.newTraCourseList = res?.["data"]?.["newTraCourseList"];
        this.askTraCourseList = res?.["data"]?.["askTraCourseList"];
        this.bestTraCourseList = res?.["data"]?.["bestTraCourseList"];

      }).catch((error: object) => {
        //TODO：这个傻逼接口 正确时 code 返回 1，不同后台人员写的随心所欲
        this.pageLoading = false;
        this.reShousList = error?.["data"]?.["reShouList"];
        this.newTraCourseList = error?.["data"]?.["newTraCourseList"];
        this.askTraCourseList = error?.["data"]?.["askTraCourseList"];
        this.bestTraCourseList = error?.["data"]?.["bestTraCourseList"];
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
  cellTitle(content?: string | Resource, moreTitle?:string, onMoreClick?: () => void) {
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


        if (onMoreClick) {
          Text(moreTitle) // 请添加对应的资源字符串
            .fontSize(14)
            .fontColor($r("app.color.gl_999"))
            .onClick(() => {
                onMoreClick();
            })
        }
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
                  //免费培训
                  this.functionButton($r("app.media.0210_mfpx"), $r("app.string.free_training"), 0, () => {
                    ToastUtil.showToast("暂未开放，敬请期待！");
                    return;
                    this.pageStack?.pushPathByName('RegistrationForTheCompetitionListPage', null);
                  })
                }

                GridItem() {
                  //在线培训
                  this.functionButton($r("app.media.0210_zxzb"), $r("app.string.online_training"), 0, () => {
                    ToastUtil.showToast("暂未开放，敬请期待！");
                    return;
                    this.pageStack?.pushPathByName('BusinessApplicationMainPage', null);
                  })
                }

                GridItem() {
                  //录播课程
                    this.functionButton($r("app.media.0210_jxlx"), $r("app.string.recorded_courses"), 0, () => {
                      ToastUtil.showToast("暂未开放，敬请期待！");
                      return;
                      // this.pageStack?.pushPathByName('MessagesMorePage', {title:"业务处理状态",type:"3"} as generalModel)
                    })

                }

                GridItem() {
                  // 全部
                  this.functionButton($r("app.media.0210_qb"), $r("app.string.all"), 0, () => {
                    ToastUtil.showToast("暂未开放，敬请期待！");
                    return;
                    this.pageStack?.pushPathByName('DogManagePage', null);
                  })
                }
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsTemplate('1fr')
              .width('100%')
              .height(100)
              .backgroundColor($r("app.color.white"))

              this.cellTitle($r("app.string.latest_course_notice"));
              ForEach(this.newTraCourseList, (item: generalModel) => {
                Column() {
                  Text(item.Title)
                    .fontColor(this.baomingTitle(item)== "正在报名"?$r("app.color.white"):$r("app.color.black"))
                    .fontSize(16)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text("开课时间："+DateUtil.getFormatDateStr(item.coursestarttime,"yyyy-MM-dd HH:mm"))
                      .fontColor(this.baomingTitle(item)== "正在报名"?$r("app.color.white"):$r("app.color.gl_999"))
                      .fontSize(14)
                      .margin({left:15})
                      .maxLines(1)
                      .layoutWeight(1)
                    Text(this.baomingTitle(item))
                      .fontColor( this.baomingTitle(item)== "正在报名"?"#BCD79D": $r("app.color.gl_999"))
                      .fontSize(14)
                      .margin({left:15})
                      .maxLines(1)
                  }
                  .margin({top:10})

                }
                .backgroundImage( this.baomingTitle(item)== "正在报名"?$r("app.media.zxtz0"):$r("app.media.zxtz"+2))
                .backgroundImageSize(ImageSize.FILL)
                .alignItems(HorizontalAlign.Start)
                .padding(10)
                .backgroundColor($r("app.color.white"))
                .margin({ left: 16, right: 16, bottom: 5,top:5 })
                .onClick(() => {
                  console.log("点击了最新课程");
                  this.pageStack?.pushPathByName('VideoDetailPage', item);
                })
              })

              //精品培训
              this.cellTitle($r("app.string.premium_training"));

              Grid() {
                ForEach(this.bestTraCourseList, (listItem: generalModel, index: number) => {

                  GridItem(){
                    //通知公告-Item
                    Column(){
                      Image(listItem.Photo)
                        .width(160)
                        .height(90)
                        .objectFit(ImageFit.Fill)
                        .borderRadius(5)
                      Text(listItem.Title)
                        .margin({top: 5})
                        .fontSize(14)
                        .fontColor($r("app.color.black"))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Row() {
                        Text(listItem.Price)
                          .fontColor($r("app.color.gl_888"))
                          .layoutWeight(1)
                          .visibility(Visibility.Hidden)
                        Text(listItem.num + "人报名")
                          .width('100%')
                          .textAlign(TextAlign.End)
                          .fontSize(12)
                          .fontColor($r("app.color.gl_888"))
                      }
                      .margin({top: 5})

                    }
                    .padding({left: 5, right: 8, top: 5, bottom: 8})
                    .justifyContent(FlexAlign.Start)
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
              //热门课程
              this.cellTitle($r("app.string.popular_courses"));

              ForEach(this.askTraCourseList, (item: generalModel, index: number) => {
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
                .padding({top:10,bottom:10,left:16,right:16})
                .backgroundColor($r("app.color.white"))
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

    return "正在报名"
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

  @Builder
  functionButton(imageRes: Resource, title: string|Resource, badgeCount: number = 0, onClick: () => void) {
    Stack() {
      Column() {
        Image(imageRes)
          .layoutWeight(1)

        Text(title)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .fontSize(14)
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

