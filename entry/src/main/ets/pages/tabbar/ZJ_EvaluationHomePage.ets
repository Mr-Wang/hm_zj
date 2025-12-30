import { generalModel } from "../../model/ZJ_Model";
import { Banner } from '@abner/banner'
import { easyDataRequest } from "../../api/EasyRequest";
import { DateUtil,  ToastUtil } from "@pura/harmony-utils";
import {
  GET_EXAM_HOME_HTTP,
  GET_EXAM_LIST_HTTP,
  GET_INFORMATION_LIST_HTTP,
  GET_STUDY_SY,
  GET_TP_URL_HTTP,
  GET_TRA_ENROL_HOME_HTTP,
  ZJ_GET_DEFAULT_HTTP, ZJ_GET_EXPERT_EVALUATE_UN_READ_COUNT_HTTP } from "../../api/UrlConfigure";
import { AppConfig } from "../../config/Index";
import { getUserInfo } from "../../api/Login";
import { ContextUtils } from "jbase";


@Entry
@ComponentV2
export struct EvaluationHomePage {
  currentTabIndex: number | undefined;
  private scroller: ListScroller = new ListScroller();
  @Local searchText: string = "";
  @Local searchTitle: string = "";
  @Local pageLoading: boolean = false;
  @Local refreshIndex: number = 0;
  @Local isRefreshing: boolean = false;
  @Local currentPage: number = 1;

  //轮播图数据
  @Local reShousList: generalModel[] = [];
  //考评列表数据
  @Local examList: generalModel[] = [];
  @Local examErrorStr: string = "";


  @Local result: boolean = false;
  @Local examCount: number = 0;
  @Local questionCount: number = 0;
  @Local averageScore: number = 0;

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

      //获取考评首页轮播数据请求
      easyDataRequest(AppConfig.studyBaseUrl + GET_TP_URL_HTTP, {type:"3"}, "POSTFORM").then((res) => {
        this.pageLoading = false;
        this.reShousList = res?.["data"];

      }).catch((error: object) => {
        console.error("获取数据失败:" + error["msg"]);
      }).finally(() => {

      })
    //获取考评首页数据请求
    easyDataRequest(AppConfig.studyBaseUrl + GET_EXAM_HOME_HTTP, {}, "POSTFORM").then((res) => {
      this.pageLoading = false;
      this.examCount = res?.["data"]?.["examCount"] ?? 0;
      this.questionCount = res?.["data"]?.["questionCount"] ?? 0;
      this.averageScore = res?.["data"]?.["averageScore"] ?? 0;
      this.result = res?.["data"]?.["result"];
    }).catch((error: object) => {
      //TODO：这个傻逼接口 正确时 code 返回 1，不同后台人员写的随心所欲
      this.pageLoading = false;
      this.examCount = error?.["data"]?.["examCount"] ?? 0;
      this.questionCount = error?.["data"]?.["questionCount"] ?? 0;
      this.averageScore = error?.["data"]?.["averageScore"] ?? 0;
      this.result = error?.["data"]?.["result"];

    }).finally(() => {

    })


    //获取考评首页数据请求
    easyDataRequest(AppConfig.studyBaseUrl + GET_EXAM_LIST_HTTP, {baomingidcard:ContextUtils.getUserInfo()?.idcardnum}, "POSTFORM").then((res) => {
      this.pageLoading = false;
      this.examList = res?.["data"];
    }).catch((error: object) => {

      this.pageLoading = false;
      this.examList = [];
      this.examErrorStr = error?.["msg"];
    }).finally(() => {

    })






    setTimeout(() => {
      this.isRefreshing = false;
      this.refreshIndex++;
    }, 500);

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

              Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
                TabContent(){
                  Column() {
                    // 功能按钮区域 - 3x4网格
                    Grid() {
                      // 第一行
                      GridItem() {
                        //重新测试
                        this.functionButton($r("app.media.0225_Khcxce"), $r("app.string.retest"), 0, () => {
                          ToastUtil.showToast("暂未开放，敬请期待！");
                          return;
                          this.pageStack?.pushPathByName('RegistrationForTheCompetitionListPage', null);
                        })
                      }

                      GridItem() {
                        //试题回顾
                        this.functionButton($r("app.media.0225_Khsthg"), $r("app.string.review_of_test_questions"), 0, () => {
                          ToastUtil.showToast("暂未开放，敬请期待！");
                          return;
                          this.pageStack?.pushPathByName('BusinessApplicationMainPage', null);
                        })
                      }

                      GridItem() {
                        //历史记录
                        this.functionButton($r("app.media.0225_Khlscj"), $r("app.string.historical_records"), 0, () => {
                          ToastUtil.showToast("暂未开放，敬请期待！");
                          return;
                          // this.pageStack?.pushPathByName('MessagesMorePage', {title:"业务处理状态",type:"3"} as generalModel)
                        })

                      }

                    }
                    .columnsTemplate('1fr 1fr 1fr')
                    .rowsTemplate('1fr')
                    .width('100%')
                    .height(100)
                    .backgroundColor($r("app.color.white"))

                    Row() {
                      Row(){
                        Text() {
                          Span(this.examCount.toString()+"\n")
                            .fontSize(16)
                            .fontColor($r("app.color.black"))
                            .fontWeight(FontWeight.Bold)
                          Span("测试次数")
                            .fontColor($r("app.color.gl_999"))
                            .fontSize(14)
                        }
                        .lineHeight(24)
                        .textAlign(TextAlign.Center)
                        Text() {
                          Span(this.questionCount.toString()+"\n")
                            .fontSize(16)
                            .fontColor($r("app.color.black"))
                            .fontWeight(FontWeight.Bold)
                          Span("测试题数")
                            .fontColor($r("app.color.gl_999"))
                            .fontSize(14)
                        }
                        .lineHeight(24)
                        .textAlign(TextAlign.Center)
                        Text() {
                          Span(this.averageScore.toString()+"\n")
                            .fontSize(16)
                            .fontColor($r("app.color.black"))
                            .fontWeight(FontWeight.Bold)
                          Span("平均成绩")
                            .fontColor($r("app.color.gl_999"))
                            .fontSize(14)
                        }
                        .lineHeight(24)
                        .textAlign(TextAlign.Center)
                      }
                      .backgroundImage($r("app.media.imgNumsBg"))
                      .backgroundImageSize(ImageSize.FILL)
                      .height(84)
                      .width("100%")
                      .justifyContent(FlexAlign.SpaceAround)
                      .padding({left:10,right:10})
                    }
                    .padding(10)

                    Image($r("app.media.0225_Khkscy"))
                      .margin(16)
                      .height(77)
                      .objectFit(ImageFit.Fill)

                  }
                  .width("100%")
                  .alignItems(HorizontalAlign.Start)

                }
                .align(Alignment.TopStart)
                .tabBar(new SubTabBarStyle("模拟考试")
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

                  Column() {
                    // 功能按钮区域 - 3x4网格
                    Grid() {
                      // 第一行
                      GridItem() {
                        //开始考试
                        this.functionButton($r("app.media.0225_Khksks"), $r("app.string.begin_the_exam"), 0, () => {
                          ToastUtil.showToast("暂未开放，敬请期待！");
                          return;
                          this.pageStack?.pushPathByName('RegistrationForTheCompetitionListPage', null);
                        })
                      }

                      GridItem() {
                        //试题回顾
                        this.functionButton($r("app.media.0225_Khsthg"), $r("app.string.review_of_test_questions"), 0, () => {
                          ToastUtil.showToast("暂未开放，敬请期待！");
                          return;
                          this.pageStack?.pushPathByName('BusinessApplicationMainPage', null);
                        })
                      }

                      GridItem() {
                        //历史记录
                        this.functionButton($r("app.media.0225_Khlscj"), $r("app.string.historical_records"), 0, () => {
                          ToastUtil.showToast("暂未开放，敬请期待！");
                          return;
                          // this.pageStack?.pushPathByName('MessagesMorePage', {title:"业务处理状态",type:"3"} as generalModel)
                        })

                      }

                    }
                    .columnsTemplate('1fr 1fr 1fr')
                    .rowsTemplate('1fr')
                    .width('100%')
                    .height(100)
                    .backgroundColor($r("app.color.white"))

                    //考试通知
                    this.cellTitle($r("app.string.exam_notice"));
                    //考试通知列表
                    if (this.examList.length > 0) {

                    } else {
                      Column({space: 16}) {
                        Image($r("app.media.0116nobg"))
                          .width("60%")
                          .objectFit(ImageFit.Fill)
                        Text(this.examErrorStr)
                          .fontColor($r("app.color.gl_000"))
                          .fontSize(14)
                      }
                      .layoutWeight(1)
                      .width("100%")
                      .alignItems(HorizontalAlign.Center)
                    }

                  }
                  .width("100%")
                  .alignItems(HorizontalAlign.Start)


                }
                .align(Alignment.TopStart)
                .tabBar(new SubTabBarStyle("考试考核")
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

