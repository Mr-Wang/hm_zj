import { BaseConstants, MainButton, PageTitleBuilder } from "jbase"

@Builder
export function UserIndexBuilder(name: string, param: Object) {
  UserIndex()
}

@ComponentV2
export struct UserIndex {
  @Local private navPathStack: NavPathStack = new NavPathStack()
  private sexSelect: number | number[] = 0
  private sexData: string[] = ['男', '女']
  private labelPading: Padding | Length | LocalizedPadding = { top: 20, bottom: 20 }

  @Builder IconArrow() {
    SymbolGlyph($r('sys.symbol.chevron_right')).fontColor([$r('app.color.gl_888')])
      .fontSize(24).margin({ left: 10 })
  }

  @Builder LabelText(name: string | Resource) {
    Text(name).fontSize(16).fontColor($r('app.color.black'))
  }

  @Builder LabelShow(name: string | Resource) {
    Text(name).fontSize(16).fontColor($r('app.color.gl_888'))
  }

  @Builder DividerItem(margin: Margin | Length | LocalizedMargin) {
    Divider().margin(margin).color($r('app.color.border_e9'))
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          this.LabelText($r('app.string.user_avatar'))
          Row() {
            Image($r('app.media.app_icon')).width(60).height(60).borderRadius(BaseConstants.BORDER_RADIUS)
            this.IconArrow()
          }
        }.itemStyle().justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem({ top: 20 })
        // 用户名称
        Row() {
          this.LabelText($r('app.string.user_name'))
          Row() { this.LabelShow('admin') }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem(0)
        // 用户昵称
        Row() {
          this.LabelText($r('app.string.user_nickname'))
          Row() {
            TextInput({ text: 'Jie.' }).inputStyle().fontSize(16).fontColor($r('app.color.black'))
              .textAlign(TextAlign.End)
            this.IconArrow()
          }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem(0)
        // 手机号码
        Row() {
          this.LabelText($r('app.string.user_phone'))
          Row() {
            TextInput({ text: '13529061734' }).type(InputType.PhoneNumber)
              .inputStyle().fontSize(16).fontColor($r('app.color.black'))
              .textAlign(TextAlign.End)
            this.IconArrow()
          }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem(0)
        // 电子邮箱
        Row() {
          this.LabelText($r('app.string.user_email'))
          Row() {
            TextInput({ text: '476743842@qq.com' }).type(InputType.Email)
              .inputStyle().fontSize(16).fontColor($r('app.color.black'))
              .textAlign(TextAlign.End)
            this.IconArrow()
          }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem(0)
        // 性别
        Row() {
          this.LabelText($r('app.string.user_gender'))
          Row() {
            this.LabelShow($r('app.string.gender_male'))
            this.IconArrow()
          }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          TextPickerDialog.show({
            range: this.sexData,
            selected: this.sexSelect,
            disappearTextStyle: {color: $r('app.color.black'), font: { size: 15, weight: FontWeight.Lighter}},
            textStyle: {color: $r('app.color.black'), font: { size: 20, weight: FontWeight.Normal}},
            selectedTextStyle: {color: $r('app.color.black'), font: { size: 30, weight: FontWeight.Bolder}},
            canLoop: false,
            onAccept: (value: TextPickerResult) => {
              // 设置select为按下确定按钮时候的选中项index，这样当弹窗再次弹出时显示选中的是上一次确定的选项
              //this.select = value.index
              //console.log(this.select + '')
              // 点击确定后，被选到的文本数据展示到页面
              //this.v = value.value as string
              //console.info("TextPickerDialog:onAccept()" + JSON.stringify(value))
            }
          })
        })
        this.DividerItem(0)
        // 所属部门
        Row() {
          this.LabelText($r('app.string.user_department'))
          Row() { this.LabelShow('研发部门 / 董事长') }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem(0)
        // 所属角色
        Row() {
          this.LabelText($r('app.string.user_role'))
          Row() { this.LabelShow('超级管理员') }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
        this.DividerItem(0)
        // 创建时间
        Row() {
          this.LabelText($r('app.string.user_create_time'))
          Row() { this.LabelShow('2025-02-11 01:02:03') }
        }.itemStyle().padding(this.labelPading).justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ top: 20, bottom: 10, left: 20, right: 20 })
      .backgroundColor($r('app.color.white'))
      .borderRadius(BaseConstants.BORDER_RADIUS)
      .margin(BaseConstants.MODULE_PADDING)

      Column() {
        MainButton({ 
          btnText: $r('app.string.user_save'), 
          btnWidth: '100%',
          onButtonClick: () => {
            
          }
        })
      }
      .padding({ top: 16, left: 20, right: 20 })
      .width(BaseConstants.FULL_WIDTH)

    }
    .title(PageTitleBuilder($r('app.string.user_profile')))
    .backgroundColor($r('app.color.back_color'))
  }

  @Styles itemStyle() {
    .width(BaseConstants.FULL_WIDTH)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  }

  @Styles inputStyle() {
    .backgroundColor($r('app.color.white'))
    .borderRadius(0)
    .width(200)
    .padding(0)
  }
}