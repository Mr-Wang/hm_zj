import { easyDataRequest } from "../../api/EasyRequest"; // 根据你实际路径调整
import { ContextUtils, CoreUtils, FullLoading } from "jbase"; // 根据你实际路径调整
import { DialogHelper } from "@pura/harmony-dialog";
import { generalModel } from "../../model/ZJ_Model";
import { DELETE_ADDRESS_HTTP, GET_USER_ADDRESS_LIST } from "../../api/UrlConfigure";
import { AppConfig } from "../../config/Index";


@Builder
export function AddressManagePageBuilder(name: string, param: Object) {
  ZJ_AddressManagePage()
}

@ComponentV2
export struct ZJ_AddressManagePage {
  @Local addressList: generalModel[] = [];
  @Local pageLoading: boolean = false;
  @Local private  navPathStack: NavPathStack = new NavPathStack();

  // 页面参数
  private isSelectionMode: boolean = false; // 是否是选择模式（从确认订单页进来）

  aboutToAppear() {
    this.loadData();
  }

  /**
   * 加载地址列表
   */
  loadData() {
    this.pageLoading = true;
    // 对应 ObjC: [[MS_BasicDataController sharedInstance] getWithReturnCode:getUserAddressList ...]
    easyDataRequest(AppConfig.studyBaseUrl + GET_USER_ADDRESS_LIST, {CGRUserGuid:ContextUtils.getUserInfo()?.userGuid}, "GET")
      .then((res) => {
        if (res && res['code'] == 0 && res['data']) {
          // 数据解析映射
          this.addressList = res['data'];

        } else {
          CoreUtils.toast(res['msg'] || "获取地址失败");
        }
      })
      .catch((err: Error) => {
        CoreUtils.toast("网络不给力");
      })
      .finally(() => {
        this.pageLoading = false;
      });
  }

  /**
   * 删除地址
   */
  deleteAddress(item: generalModel) {
    DialogHelper.showAlertDialog({
      title: '提示',
      content: '确定要删除该地址吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red
      },
      onAction: (action) => {
        console.log("action",action)
        if (action === -2) {
          this.pageLoading = true;
          easyDataRequest(AppConfig.studyBaseUrl + DELETE_ADDRESS_HTTP, { RowGuid: item.RowGuid }, "POST")
            .then(res => {
              if (res['code'] == 0) {
                CoreUtils.toast("删除成功");
                this.loadData(); // 刷新列表
              } else {
                CoreUtils.toast(res['msg']);
              }
            })
            .finally(() => this.pageLoading = false);
        }
      }
    });
  }

  /**
   * 跳转到编辑/新增页面
   * @param item 如果有值则是编辑，否则是新增
   */
  jumpToEdit(item?: generalModel) {
    // 对应 ObjC: pushViewController:ZJ_EditAddressViewController
    let params: Record<string, Object> = {};
    if (item) {
      params['isEdit'] = true;
      params['detail'] = item;
    } else {
      params['isEdit'] = false;
    }

    this.navPathStack.pushPathByName('EditAddressPage', params, (popInfo) => {
      // 监听返回，如果编辑页保存成功，刷新列表
      if (popInfo && popInfo.result && popInfo.result['refresh']) {
        this.loadData();
      }
    });
  }

  /**
   * 处理地址选择
   */
  handleSelect(item: generalModel) {
    if (this.isSelectionMode) {
      // 对应 ObjC: self.selAddressBlock(tempModel); popViewController
      this.navPathStack.pop(item);
    }
  }

  build() {
    NavDestination() {
      Stack() {
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
              this.navPathStack.pop();
            })
            // 标题
            Text("地址管理") // 请添加对应的资源字符串
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .fontColor($r("app.color.white"))

            // 提交按钮
            Text($r("app.string.submit")) // 请添加对应的资源字符串
              .fontSize(16)
              .onClick(() => {
              })
              .visibility(Visibility.Hidden)
              .width(60)
              .height(30)
              .fontColor($r("app.color.white"))
              .textAlign(TextAlign.End)
              .padding({ right: 10, top: 5 })
          }
          .width("100%")
          .padding(10)
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor($r("app.color.main_color"))

          // 2. 主体内容区 (模仿 ObjC 的 viewBody 样式)
          Column() {
            // 顶部标题栏 + 新增按钮
            Row() {
              Text("配送地址")
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.Black)

              Blank()

              Text("新增配送地址")
                .fontSize(14)
                .fontColor($r("app.color.main_color")) // 假设有主色调资源 MSTHEMEColor
                .onClick(() => this.jumpToEdit())
            }
            .width('100%')
            .height(44)
            .padding({ left: 10, right: 10 })
            .alignItems(VerticalAlign.Center)

            // 分割线
            Divider().color("#F0F0F0").strokeWidth(1).margin({ left: 16, right: 16 })

            // 3. 地址列表
            if (this.addressList.length > 0) {
              List() {
                ForEach(this.addressList, (item: generalModel, index: number) => {
                  ListItem() {
                    this.AddressItemBuilder(item)
                  }
                  .swipeAction({ end: this.SwipeDeleteBuilder(item) }) // 侧滑删除
                })
              }
              .layoutWeight(1)
              .width("100%")
              .scrollBar(BarState.Off)
            } else {
              // 空状态
              Column() {
                Image($r("app.media.nulldata")).width(100).height(100)
                Text("暂无地址，请新增").fontSize(14).fontColor("#999").margin({ top: 10 })
              }
              .width('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
            }
          }
          .margin(16) // 对应 k360Width(16)
          .backgroundColor(Color.White)
          .borderRadius(8) // 对应 rounded:k360Width(44/6)
          .layoutWeight(1) // 让白色卡片填满剩余空间，或者根据内容自适应
          .shadow({ radius: 4, color: "#1A000000", offsetY: 2 })

        }
        .width('100%')
        .height('100%')
        .backgroundColor("#FAFAFA") // 对应 ObjC View 背景色

        // 全局 Loading
        FullLoading({ loading: this.pageLoading })
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
      // 获取传入参数，判断是否是选择模式
      // let params = this.navPathStack.getParamByName("ZJ_AddressManagePage");
      // if (params && params['isSelectionMode']) { this.isSelectionMode = true; }
    })
  }

  // 列表项构建器 (对应 ZJ_AddressManageTableViewCell)
  @Builder
  AddressItemBuilder(item: generalModel) {
    Row() {
      // 左侧信息区
      Column({ space: 6 }) {
        // 姓名 + 电话
        Row() {
          Text(item.UserName)
            .fontSize(14)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Medium)

          Text(item.Mobile)
            .fontSize(14)
            .fontColor(Color.Black)
            .margin({ left: 10 })
        }

        // 地址详情
        Text(this.getFullAddress(item))
          .fontSize(12)
          .fontColor("#666666") // APPTextGayColor
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 默认标签
        if (item.mrDz == "1") {
          Text("默认地址")
            .fontSize(10)
            .fontColor(Color.Red)
            .backgroundColor("#FFF0F0")
            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
            .borderRadius(2)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => this.handleSelect(item)) // 点击整个区域选择

      // 右侧编辑按钮 (对应 btnEdit)
      Image($r("app.media.0317_edit")) // 请替换你的编辑图标 0218_xgdz
        .width(24)
        .height(24)
        .margin({ left: 10 })
        .onClick(() => this.jumpToEdit(item))
    }
    .width("100%")
    .padding({ top: 16, bottom: 16, left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    // 底部线条
    .border({ width: { bottom: 1 }, color: "#F0F0F0" })
  }

  // 辅助方法：获取完整地址字符串
  getFullAddress(item:generalModel): string {
    return `${item.province}${item.city}${item.district}${item.Address}`;
  }
  // 侧滑删除按钮
  @Builder
  SwipeDeleteBuilder(item: generalModel) {
    Button("删除")
      .type(ButtonType.Normal)
      .backgroundColor(Color.Red)
      .fontColor(Color.White)
      .height("100%")
      .width(80)
      .onClick(() => {
        this.deleteAddress(item);
      })
  }
}