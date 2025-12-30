import { BaseConstants, CellList, CellListItemModel, CoreUtils, ContextUtils, UserInfo } from 'jbase'
import { logout } from '../../api/Login'
import { AppConfig } from '../../config/Index'

@ComponentV2
export struct ZJMyPage {
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
    Column() {
      // 头部区域
      Stack(){
        Column() {
          Column() {
            Row() {
              Image(this.userInfo?.avatarPath).width(60).height(60).borderRadius(30)
                .alt($r('app.media.default_head'))
              Column() {
                Text(this.userInfo?.realname).fontSize(18).fontColor($r('app.color.white')).margin({ left: 14 })
                Text(this.userInfo?.mobilePhone).fontSize(15).fontColor($r('app.color.white')).margin({ left: 14, top: 8 })
              }.flexGrow(1).alignItems(HorizontalAlign.Start)
              Row() {
                SymbolGlyph($r('sys.symbol.qrcode')).fontColor([$r('app.color.white')]).fontSize(24)
                SymbolGlyph($r('sys.symbol.chevron_right')).fontColor([$r('app.color.white')])
                  .fontSize(24).margin({ left: 5 })
              }
            }
            .width("100%")
            .onClick(() => {
              this.pageStack?.pushPathByName('userIndex', null)
            })
          }
          .backgroundColor($r("app.color.main_color"))
          .height(160)
          .padding({ top: 38, left: 32, right: 32 })
          .width("100%")
          Column()
            .width("100%")
            .height(30)
            .backgroundColor($r("app.color.white"))
        }

        Row() {
          Text("考核评价结果")
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
          Text("考核评价细则")
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .position({top:130,left:16,right:16})
        .width("92%")
        .backgroundColor($r("app.color.white"))
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
        .borderRadius(5)
        .shadow({
          radius: 5,
          color: "#50dddddd",
          offsetX: 15,
          offsetY: 15
        })
      }
      .width("100%")
      Scroll() {
        Column() {
          this.myItemCell($r('app.media.0224_Myqianshousaomiao'),"身份信息",()=>{
            console.log("身份信息");
          },10)
          this.myItemCell($r('app.media.0717_zjxx'),"专家信息",()=>{
            console.log("专家信息");
          })
          this.myItemCell($r('app.media.1103_zgzs'),"资格证书",()=>{
            console.log("资格证书");
          })
          this.myItemCell($r('app.media.0224_Mymimayimidida'),"修改密码",()=>{
            console.log("修改密码");
          })

          this.myItemCell($r('app.media.0317_order'),"订单管理",()=>{
            console.log("订单管理");
            this.pageStack.pushPathByName("CAOrderMainPage",null)
          },10)
          this.myItemCell($r('app.media.0316_address'),"地址管理",()=>{
            console.log("地址管理");
            this.pageStack.pushPathByName("AddressManagePage",null)
          })
          this.myItemCell($r('app.media.0224_Myks'),"我的考试",()=>{
            console.log("我的考试");
          })
          this.myItemCell($r('app.media.0224_Myxuexi'),"我的课程 ",()=>{
            console.log("我的课程");
          })
          this.myItemCell($r('app.media.0224_Mypingjiayimidida'),"我的收藏",()=>{
            console.log("我的收藏");
          })
          this.myItemCell($r('app.media.0224_Myyinhangka'),"银行卡",()=>{
            console.log("银行卡");
          })
          this.myItemCell($r('app.media.0422_czsc'),"操作手册",()=>{
            console.log("操作手册");
          })

          this.myItemCell($r('app.media.0224_Mysz'),"设置",()=>{
            console.log("设置");
            this.pageStack?.pushPathByName('systemSetting', null)
          },10)

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
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width(BaseConstants.FULL_WIDTH)
    .height("100%")
  }

  @Builder
  myItemCell(iconName:Resource, textStr:string,onItemClick?:()=> void,marginTop:number = 0) {
    Row({ space: 16 }) {
      Image(iconName).width(22).height(22)
        .objectFit(ImageFit.Fill);
      Text(textStr)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1);
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('app.color.gl_000')])
        .fontSize(26);
    }
    .margin({ top: marginTop })
    .backgroundColor($r('app.color.white'))
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
    .border({ color: $r('app.color.color_line'), width: { bottom: 1 } })
    .onClick(() => {
      if(onItemClick != null) {
        onItemClick();
      }
    })
  }

  @Styles itemStyle() {
    .width(BaseConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.white'))
    .borderRadius(BaseConstants.BORDER_RADIUS)
    .padding({ top: BaseConstants.MODULE_PADDING, bottom: BaseConstants.MODULE_PADDING, left: 16, right: 16 })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  }

}