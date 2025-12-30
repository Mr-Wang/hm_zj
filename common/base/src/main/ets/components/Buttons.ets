import { BaseConstants } from "../constants/BaseConstants"

/**
 * 主题色按钮的Button
 */
@ComponentV2
export struct MainButton {
  @Param btnText: Resource | string = ''
  @Param fontSize: number = 16
  @Param btnHeight: number = 45
  @Param btnWidth: number | string = '100%'
  // 按钮点击事件
  @Event onButtonClick?: (event: ClickEvent) => void
  build() {
    Button(this.btnText, { type: ButtonType.Normal, stateEffect: true })
      .onClick((event) => {
        if (this.onButtonClick) {
          this.onButtonClick(event)
        }
      })
      .fontSize(this.fontSize)
      .height(this.btnHeight)
      .width(this.btnWidth)
      .borderRadius(BaseConstants.BORDER_RADIUS)
      .backgroundColor($r('app.color.main_color'))
  }
}