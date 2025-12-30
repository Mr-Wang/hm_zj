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

// 列表数据源
class TimeTableDataSource implements IDataSource {
  private list: generalModel[] = [];
  private listener?: DataChangeListener;
  private hasMore: boolean = false;
  private isLoading: boolean = false;
  private isLoaded: boolean = false;
  private listUrl: string;
  private currentPage: number = 1;
  private key: string = "1";
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

    // 构建请求URL，添加搜索参数
    let requestUrl = this.listUrl;

    //下一页请求方式
    if (!isRefresh) {
      this.currentPage ++;
    } else {
      this.currentPage = 1;
    }
    easyDataRequest(requestUrl,{currentPage:this.currentPage.toString(),key:this.key,pageItemNum:this.pageItemNum.toString(),zjidcard:ContextUtils.getUserInfo()?.idcardnum}, "POSTFORM").then((res) => {
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
export function BidEvaluationNoticeListPageBuilder(name: string, param: Object) {
  // console.log("aa");
  BidEvaluationNoticeListPage()
}

@ComponentV2
export struct BidEvaluationNoticeListPage {
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

  getCurrentUrl() {
    this.currentUrl = "bidevaluation/getBidNoticeList"
  }

  // 数据变化监听器
  private dataChangeListener: DataChangeListener = {
    onDataReloaded: () => {
      console.log('数据重新加载完成，更新UI');
      const dataSource = this.getDataSource(this.currentUrl);
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

    this.getCurrentUrl();
    const dataSource = this.getDataSource(this.currentUrl);
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

        Refresh({
          refreshing: this.isRefreshing,
          builder: this.customRefreshComponent()
        }) {
          //评标通知列表
          this.listCellBuilder()
        }
        .width('100%')
        .layoutWeight(1)
        .onRefreshing(() => {
          this.getCurrentUrl();
          this.handleRefresh(this.currentUrl);
          this.refreshIndex++; // 触发UI更新
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
        this.generalModelPageData = this.navPathStack.getParamByName('BidEvaluationNoticeListPage')[this.navPathStack.getParamByName('BidEvaluationNoticeListPage').length - 1] as generalModel;
        this.loadTabsData()
      } catch (ee) {
        console.error("未获取到上一页数据");
      }

    })
  }


  @Builder
  //评标通知列表*/
  listCellBuilder() {
    if (this.refreshIndex > 0 && this.getDataSource(this.currentUrl).totalCount() > 0) {
      //赛事列表
      List({ space: 0, scroller: this.scroller }) {
        LazyForEach(this.getDataSource(this.currentUrl), (itemModel: generalModel, index: number) => {
           ListItem() {
              Column() {
                Column() {
                  Text(DateUtil.getFormatDateStr(itemModel.createtime, "yyyy-MM-dd HH:mm:ss")) {
                  }
                  .fontColor($r("app.color.gl_999"))
                  .fontSize(16)
                  .textAlign(TextAlign.End)
                  .lineHeight(24)
                  .width("100%")
                  Text("项目名称："+itemModel.name) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .width("100%")
                  Text("代理机构："+itemModel.daili) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .width("100%")
                  Text("集合时间："+DateUtil.getFormatDateStr(itemModel.time, "yyyy-MM-dd HH:mm")) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .width("100%")
                  if(StrUtil.isNotEmpty(itemModel.major)) {
                    Text("抽取专业："+itemModel.major) {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .width("100%")
                  }

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

                  if(itemModel.remark) {
                    Text("备注："+itemModel.remark) {
                    }
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(16)
                    .textAlign(TextAlign.Start)
                    .lineHeight(24)
                    .width("100%")
                  }

                  Text("当前状态："+(itemModel.leaveFlag ? "已请假":itemModel.signFlag == "1" || itemModel.signFlag == "2" ? "已签到"  : "未签到")) {
                  }
                  .fontColor($r("app.color.gl_666"))
                  .fontSize(16)
                  .textAlign(TextAlign.Start)
                  .lineHeight(24)
                  .width("100%")

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

                  Row({space:5}){

                    Text("在线请假")
                      .fontColor($r("app.color.white"))
                      .backgroundColor($r("app.color.main_color"))
                      .fontSize(13)
                      .padding(8)
                      .borderRadius(5)
                      .onClick(() => {
                        console.log("在线请假")
                        this.jumpAddOnlineLeavePage(itemModel);
                      })

                    Text("办理项目云签章")
                      .fontColor($r("app.color.white"))
                      .backgroundColor($r("app.color.main_color"))
                      .fontSize(13)
                      .padding(8)
                      .borderRadius(5)
                      .onClick(() => {
                        console.log("办理项目云签章")
                        this.navPathStack?.pushPathByName('HandleTempCAPage', itemModel, (params) => {
                          if (params && params.result['isRefresh']) {
                            this.loadTabsData();
                          }
                        });
                      })

                    Text("拨打应急电话")
                      .fontColor($r("app.color.white"))
                      .backgroundColor($r("app.color.main_color"))
                      .fontSize(13)
                      .padding(8)
                      .borderRadius(5)
                      .onClick(() => {
                        console.log("拨打应急电话")

                        DialogHelper.showCustomContentDialog({
                          primaryTitle: "外呼拨出手机号登记",
                          contentBuilder: () => {
                            this.customInputAlertBuilder()
                          },
                          width: 280,
                          buttons: [
                            { value: '取消', fontColor: $r("app.color.main_color")  },
                            { value: '立即呼叫（加密）', fontColor: $r("app.color.main_color") }
                          ],
                          onAction: (action) => {
                            if (action == -2) {
                              let dicPost:generalModel = {
                                callOut: this.callPhone,
                                callIn: itemModel.yjphone
                              }

                              easyDataRequest(
                                ZJ_HOST_RECORD_PHONE_HTTP,
                                dicPost, "POSTFORM")
                                .then((res) => {
                                  if (res['code'] == 0) {
                                    // CoreUtils.makeCall(res['data'])
                                    // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
                                    // 从API15开始支持tel格式电话号码，如："tel:13xxxx"
                                    call.makeCall(res['data'], (err: BusinessError) => {
                                      if (!err) {
                                        console.info("make call success.");
                                      } else {
                                        console.error("make call fail, err is:" + JSON.stringify(err));
                                      }
                                    });

                                  }
                                })
                                .catch((err:object) => {
                                  CoreUtils.toast(err['msg'])
                                })
                                .finally(() => this.pageLoading = false)

                              console.log("立即呼叫"+this.callPhone)

                            } else {
                              console.log("取消")
                            }
                          }
                        })

                      })


                    Text("签到")
                      .fontColor($r("app.color.white"))
                      .backgroundColor($r("app.color.main_color"))
                      .fontSize(13)
                      .padding(8)
                      .borderRadius(5)
                      .onClick(() => {
                        console.log("签到")

                        if(itemModel.isNeedHandleCA =="1" && itemModel.isHandleCA != "1") {
                          CoreUtils.alert("您本次参与评标的项目需要采用电子签名方式。请您先完成项目云签章自主办理，再进行签到，以免影响评标工作。")
                        } else {
                          //    点签到 -先判断此项目是否需要办理云签章- 如果不需要办理 直接签到；
                          this.selExperModel = itemModel;
                          this.decryptionStep1()
                        }

                      })
                  }
                  .justifyContent(FlexAlign.End)
                  .padding({top:10,bottom:10})


                  Text(itemModel.platformContent)
                    .fontColor($r("app.color.black"))
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .width("100%")
                    .lineHeight(20)
                    .padding({top:10,bottom:10})
                    .margin({bottom:40})

                  Text(itemModel.message)
                    .fontColor($r("app.color.gl_666"))
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .width("110%")
                    .padding({left:10,right:10,top:5,bottom:5})
                    .position({right:-16,bottom:-16,left:-16})
                    .lineHeight(20)
                    .backgroundColor("#FAFAFA")

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

            };

        }, (item: generalModel, index: number) =>item.id + this.refreshIndex.toString());
      }
      .width('100%')
      .layoutWeight(1)
      .sticky(StickyStyle.Header | StickyStyle.Footer)
      .scrollBar(BarState.Off)
      .onReachEnd(() => {
        this.handleScrollEnd(this.currentUrl);
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
  //跳转 AddOnlineLeavePage 页
  private jumpAddOnlineLeavePage(itemModel: generalModel) {
    this.navPathStack?.pushPathByName('AddOnlineLeavePage', itemModel, (params) => {
      if (params && params.result) {
        this.loadTabsData();
      }
    });
  }

}