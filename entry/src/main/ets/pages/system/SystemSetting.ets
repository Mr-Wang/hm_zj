import { AppUtil, ToastUtil } from "@pura/harmony-utils"
import { BaseConstants, CellList, CellListItemModel, PageTitleBuilder, StringUtils } from "jbase"
import { AppConfig } from "../../config/Index"
import { generalModel } from "../../model/ZJ_Model"

@Builder
export function SystemSettingBuilder(name: string, param: Object) {
  SystemSetting()
}

@ComponentV2
export struct SystemSetting {
  @Local textColor: Resource | null = $r('app.color.black')
  @Local iconColor: Resource | null = $r('app.color.main_color')
  @Local private navPathStack: NavPathStack = new NavPathStack()
  // 处理返回按钮点击
  handleBack() {
    // 这里实现返回逻辑，可能是路由返回或关闭页面
    console.log("返回按钮被点击");
    this.navPathStack.pop(true);
  }

  build() {
    NavDestination() {
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
        .onClick(()=>{
          this.handleBack()
        })

        // 标题
        Text($r("app.string.setting_title")) // 请添加对应的资源字符串
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor($r("app.color.white"))

        // 提交按钮
        Text($r("app.string.submit")) // 请添加对应的资源字符串
          .fontSize(16)
          .visibility(Visibility.Hidden)
          .width(60)
          .height(30)
          .fontColor($r("app.color.white"))
          .textAlign(TextAlign.End)
          .padding({ right: 10, top: 5 })
      }
      .width("100%")
      .padding(10)
      .backgroundColor($r("app.color.main_color"))
      
      Column() {
        // 安全设置和密码修改
        CellList({ itemData: [
          { id:"updatePwd", text: $r('app.string.change_pass'),  iconName: $r('sys.symbol.lock_filled_arrow_counterclockwise') },
          { id:"about", text: $r('app.string.my_about_us'),  iconName: $r('sys.symbol.info_circle') },
          { id:"agreement", text: $r('app.string.set_user_agreement'),  iconName: $r('sys.symbol.square_and_pencil') },
          { id:"policy", text: $r('app.string.set_privacy_policy'),  iconName: $r('sys.symbol.person_shield') },
          { id:"contact_us", text: $r('app.string.contact_us'),  iconName: $r('sys.symbol.questionmark_circle') },
          { id:"version", text: $r('app.string.my_version'),  iconName: $r('sys.symbol.arrow_up_circle'),showRightText:true, rightText:"V"+ AppUtil.getVersionName() },

        ], textColor: this.textColor, iconColor: this.iconColor,
          onItemClick: (item: CellListItemModel, index: number) => {
            switch (item.id) {
              case 'updatePwd':
                this.navPathStack?.pushPathByName('updatePassword', null)
                break;
              case 'about':
                this.navPathStack?.pushPathByName('WebViewInfoPage',{url:`${AppConfig.baseUrl}jsp/club/client/nome/about.jsp`,title:"关于我们"} as generalModel);
                break
              case 'agreement':
                this.navPathStack?.pushPathByName('WebViewInfoPage',{url:`${AppConfig.baseUrl}jsp/club/user_agreement.jsp`,title:"用户协议"} as generalModel);
                break
              case 'policy':
                this.navPathStack?.pushPathByName('WebViewInfoPage',{url:`${AppConfig.baseUrl}jsp/club/client/nome/privacy_policy.jsp`,title:"隐私政策"} as generalModel);
                break
              case 'contact_us':
                this.navPathStack?.pushPathByName('WebViewInfoPage',{url:`${AppConfig.baseUrl}jsp/club/client/nome/contact_us.jsp`,title:"联系我们"} as generalModel);
                break
              case 'version':
                ToastUtil.showToast("当前已是最新版本");
                break
            }
          }}).margin({ top: 14 })
      }
      .width(BaseConstants.FULL_WIDTH)
      .padding({ left: BaseConstants.MODULE_PADDING, right: BaseConstants.MODULE_PADDING })
    }
    .hideTitleBar(true)
    .title(PageTitleBuilder($r('app.string.setting_title')))
    .backgroundColor($r('app.color.back_color'))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
    })
  }
}