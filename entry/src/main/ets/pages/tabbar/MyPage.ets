import { BaseConstants, CellList, CellListItemModel, CoreUtils, ContextUtils, UserInfo } from 'jbase'
import { logout } from '../../api/Login'
import { AppConfig } from '../../config/Index'

@ComponentV2
export struct MyPage {
  @Consumer('pageInfos') pageStack: NavPathStack = new NavPathStack();
  @Local textColor: Resource | null = $r('app.color.black')
  @Local iconColor: Resource | null = $r('app.color.main_color')
  // @StorageProp('currentColorMode')
  // @Monitor('onColorModeChange') currentMode: number = 0
  private userInfo: UserInfo | null = null
  onColorModeChange(changedPropertyName: string) {
    this.textColor = $r('app.color.black')
    this.iconColor = $r('app.color.main_color')
  }

  aboutToAppear(): void {
    this.userInfo = ContextUtils.getUserInfo()
  }

  build() {
    Navigation() {
      Column() {
        // 头部区域
        Row() {
          if (!!this.userInfo?.avatarPath) {
            Image(AppConfig.baseUrl + this.userInfo?.avatarPath).width(70).height(70).borderRadius(BaseConstants.BORDER_RADIUS)
          } else {
            Image($r('app.media.logo')).width(70).height(70).borderRadius(BaseConstants.BORDER_RADIUS)
          }
          Column() {
            Text(this.userInfo?.realname).fontSize(18).fontColor($r('app.color.black')).margin({ left: 14 })
            Text(this.userInfo?.mobilePhone).fontSize(15).fontColor($r('app.color.gl_888')).margin({ left: 14, top: 8 })
          }.flexGrow(1).alignItems(HorizontalAlign.Start)
          Row() {
            SymbolGlyph($r('sys.symbol.qrcode')).fontColor([$r('app.color.gl_888')]).fontSize(24)
            SymbolGlyph($r('sys.symbol.chevron_right')).fontColor([$r('app.color.gl_888')])
              .fontSize(24).margin({ left: 5 })
          }
        }.itemStyle().onClick(() => {
          this.pageStack?.pushPathByName('userIndex', null)
        })
        // 我的收藏
        CellList({ itemData: [
          { text: $r('app.string.my_favorites'),  iconName: $r('sys.symbol.star') }
        ], textColor: this.textColor, iconColor: this.iconColor }).margin({ top: 14 })
        // 其它一些
        CellList({ itemData: [
          { id: 'about', text: $r('app.string.my_about_us'), iconName: $r('sys.symbol.info_circle') },
          { id: 'feedback', text: $r('app.string.my_feedback'), iconName: $r('sys.symbol.square_and_pencil') },
          { id: 'help', text: $r('app.string.my_help_center'), iconName: $r('sys.symbol.questionmark_circle') },
          { id: 'version', text: $r('app.string.my_version'), iconName: $r('sys.symbol.arrow_up_circle') },
          { id: 'share', text: $r('app.string.my_share'), iconName: $r('sys.symbol.share') },
        ], textColor: this.textColor, iconColor: this.iconColor , onItemClick: (item: CellListItemModel, index: number) => {
          switch (item.id) {
            case 'about':
              this.pageStack?.pushPathByName('aboutUs', null)
              break
            case 'feedback':
              this.pageStack?.pushPathByName('feedback', null)
              break
            case 'help':
              this.pageStack?.pushPathByName('helpCenter', null)
              break
            case 'version':
              break
            case 'share':
              break
          }
        }}).margin({ top: 14 })
        // 设置
        CellList({ itemData: [
          { text: $r('app.string.my_settings'),  iconName: $r('sys.symbol.gearshape') }
        ], textColor: this.textColor, iconColor: this.iconColor, onItemClick: (item: CellListItemModel, index: number) => {
          this.pageStack?.pushPathByName('systemSetting', null)
        }}).margin({ top: 14 })
        // 退出登录
        Row() {
          Text($r('app.string.my_logout')).fontSize(16).fontColor($r('app.color.red_color'))
        }.itemStyle().margin({ top: 18 }).justifyContent(FlexAlign.Center)
        .onClick(() => {
          AlertDialog.show(
            {
              title: $r('app.string.tips'),
              message: $r('app.string.my_logout_tips'),
              cornerRadius: BaseConstants.BORDER_RADIUS,
              height: 170,
              primaryButton: {
                value: $r('app.string.nobtn'),
                action: () => {}
              },
              secondaryButton: {
                value: $r('app.string.yesbtn'),
                action: () => {
                  // logout()
                  CoreUtils.logout()
                  CoreUtils.toLogin()
                }
              }
            }
          )
        })
      }
      .width(BaseConstants.FULL_WIDTH)
      .padding(BaseConstants.MODULE_PADDING)
    }.title($r('app.string.mine'), { backgroundColor: $r('app.color.white') })
    .titleMode(NavigationTitleMode.Mini).hideBackButton(true).backgroundColor($r('app.color.back_color'))
  }

  @Styles itemStyle() {
    .width(BaseConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.white'))
    .borderRadius(BaseConstants.BORDER_RADIUS)
    .padding({ top: BaseConstants.MODULE_PADDING, bottom: BaseConstants.MODULE_PADDING, left: 16, right: 16 })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  }

}