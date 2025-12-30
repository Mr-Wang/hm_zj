import { SymbolGlyphModifier } from "@kit.ArkUI"
import { BaseConstants } from "../constants/BaseConstants"
/**
 * 搜索框组件
 */
@ComponentV2
export struct SearchInput {
  // 搜索框占位符
  @Param plText: Resource = $r('app.string.search')
  // 组件圆角
  @Param compRadius: number = BaseConstants.BORDER_RADIUS
  // 组件背景色
  @Param backColor: ResourceColor = $r('app.color.back_color')
  // 占位符颜色
  @Param plColor: ResourceColor = $r('app.color.input_pl')
  // 组件高度
  @Param compHeight: number = 40
  // 是否开启自动完成
  @Param autoComplete: boolean = false
  // 自动完成延时
  @Param autoCompleteTime: number = 500
  // 自动完成定时器
  private timerId: number = 0
  @Local inputValue: string = ''
  private controller: SearchController = new SearchController()

  // 搜索提交事件
  onSearchSubmit?: (value: string) => void

  build() {
    Row() {
      Search({ value: this.inputValue, placeholder: this.plText, controller: this.controller })
        .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
          .fontColor([$r('app.color.black')]).fontSize(18))
        .width(BaseConstants.FULL_WIDTH)
        .height(this.compHeight)
        .backgroundColor(this.backColor)
        .placeholderColor(this.plColor)
        .placeholderFont({ size: 15, weight: 400 })
        .textFont({ size: 15, weight: 400 })
        .margin(0)
        .borderRadius(this.compRadius)
        .onSubmit((value: string) => {
          this.onSearchSubmit && this.onSearchSubmit(value)
        })
        .onChange((value: string) => {
          this.inputValue = value
          if (value === '' && !this.autoComplete) {
            this.onSearchSubmit && this.onSearchSubmit(value)
          }
          if (this.autoComplete) {
            this.timerId > 0 && clearTimeout(this.timerId)
            this.timerId = setTimeout(() => {
              this.onSearchSubmit && this.onSearchSubmit(value)
            }, this.autoCompleteTime)
          }
        })
    }
  }
}