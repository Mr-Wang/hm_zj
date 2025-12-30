import { BaseConstants } from "../constants/BaseConstants"

@ComponentV2
export struct CellListItem {
  // 是否显示图标
  @Param showIcon: boolean = true
  // 图标颜色
  @Param iconColor: Resource | null = null
  // 图标名称
  @Param iconName: Resource | null = null
  // 图标大小
  @Param iconSize: number = 22
  // 文本内容
  @Param text: string | Resource | null = ''
  // 文本大小
  @Param textSize: number = 16
  // 文本颜色
  @Param textColor: Resource | null = null
  // 显示右侧箭头
  @Param showArrow: boolean = true
  // 显示右侧文字
  @Param showRightText: boolean = false
  // 右侧文本内容
  @Param textRight: string | Resource | null = ''

  build() {
    Row() {
      if (this.showIcon) {
        SymbolGlyph(this.iconName).fontColor([this.iconColor]).fontSize(this.iconSize).margin({ right: 10 })
      }
      Text(this.text).fontSize(this.textSize).fontColor(this.textColor).flexGrow(1)
      if(this.showRightText) {
        Text(this.textRight).fontSize(this.textSize).fontColor(this.textColor)
          .margin({right:10})
      }

      if (this.showArrow) {
        SymbolGlyph($r('sys.symbol.chevron_right')).fontColor([$r('app.color.gl_888')]).fontSize(24)
      }
    }.itemStyle().width(BaseConstants.FULL_WIDTH)
  }

  @Styles itemStyle() {
    .width(BaseConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.white'))
    .borderRadius(BaseConstants.BORDER_RADIUS)
    .padding(BaseConstants.MODULE_PADDING)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  }
}

export interface CellListItemModel {
  id?: string,
  showIcon?: boolean
  iconName?: Resource | null
  iconSize?: number
  text: string | Resource
  textSize?: number
  showArrow?: boolean
  showRightText?: boolean
  rightText?: string | Resource
}

@ComponentV2
export struct CellList {
  @Param itemData: CellListItemModel[] = []
  @Param textColor: Resource | null = null
  @Param iconColor: Resource | null = null
  // 列表点击事件
  @Event onItemClick?: (item: CellListItemModel, index: number) => void
  build() {
    Column() {
      if (this.itemData.length > 0) {
        ForEach(this.itemData, (item: CellListItemModel, index: number) => {
          CellListItem({
            showIcon: item.showIcon,
            iconName: item.iconName,
            iconSize: item.iconSize,
            text: item.text,
            textSize: item.textSize,
            showArrow: item.showArrow,
            textColor: this.textColor,
            iconColor: this.iconColor,
            textRight: item.rightText,
            showRightText: item.showRightText,
          }).onClick(() => {
            this.onItemClick && this.onItemClick(item, index)
          })
          if (index != this.itemData.length - 1) {
            Divider().margin({ left: item.iconName ? 45 : 23 }).color($r('app.color.border_e9'))
          }
        })
      }
    }
    .width(BaseConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.white'))
    .borderRadius(BaseConstants.BORDER_RADIUS)
  }

}

