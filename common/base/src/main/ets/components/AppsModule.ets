import { BaseConstants } from "../constants/BaseConstants"
import { AppItemModel } from "../types/AllTypes"
import { StringUtils } from "../utils/StringUtils"

@ComponentV2
export struct AppsModule {
  // 应用模块标题
  @Param moduleTitle: string | Resource = '-'
  // 应用数据
  @Param appsData: AppItemModel[] = []
  // 标签颜色
  @Param labelColor: string | Resource = $r('app.color.black')
  // 标签大小
  @Param labelSize: number = 14
  // 图标大小
  @Param iconSize: number = 53
  // 列数
  @Param columns: number = 4
  // 显示编辑按钮
  @Param showEditBtn: boolean = false
  // 显示添加按钮
  @Param showAddBtn: boolean = false
  @Local childNavStack: NavPathStack = new NavPathStack()

  // 点击事件
  onItemClick?: (item: AppItemModel, index: number) => void
  // 编辑应用点击事件
  onEditClick?: () => void
  // 点击添加按钮事件
  onAddClick?: () => void

  handleColumns() {
    let tempArray: string[] = []
    for (let index = 0; index < this.columns; index++) {
      tempArray.push('1fr')
    }
    return tempArray.join(' ')
  }

  build() {
    Column() {
      // 应用模块
      Flex() {
        Text(this.moduleTitle).fontSize(18).fontColor($r('app.color.black')).fontWeight(500).flexGrow(1)
        if (this.showEditBtn) {
          Text('\ue6ef').fontSize(14).fontColor($r('app.color.gl_888')).fontFamily('iconfont')
            .padding({ top: 5, bottom: 4 })
          Text(`${StringUtils.getResStr($r('app.string.edit_app'))}`).fontSize(14)
            .fontColor($r('app.color.gl_888')).fontFamily('iconfont')
            .padding(4)
            .onClick(() => {
              this.onEditClick && this.onEditClick()
            })
        }
      }.itemPadding()

      Grid() {
        ForEach(this.appsData, (item: AppItemModel, index: number) => {
          GridItem() {
            Column() {
              Image(item.imageUrl).width(this.iconSize).height(this.iconSize).borderRadius(BaseConstants.BORDER_RADIUS)
              Text(item.appName).fontSize(this.labelSize).fontColor(this.labelColor).margin({ top: 8 })
            }
          }
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
          .onClick(() => {
            this.onItemClick && this.onItemClick(item, index)
          })
        })
        if (this.showAddBtn) {
          GridItem() {
            Row() {
              SymbolGlyph($r('sys.symbol.plus')).fontColor([$r('app.color.gl_999')]).fontSize(22)
            }
            .width(this.iconSize)
            .height(this.iconSize)
            .backgroundColor($r('app.color.back_eee'))
            .justifyContent(FlexAlign.Center)
            .borderRadius(BaseConstants.BORDER_RADIUS)
          }
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
          .onClick(() => {
            this.onAddClick && this.onAddClick()
          })
        }

      }.columnsTemplate(this.handleColumns()).padding({ top: 6, bottom: 16, left: 6, right: 6 }).rowsGap(15)
    }
    .width(BaseConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.white'))
    .borderRadius(BaseConstants.BORDER_RADIUS)
  }

  @Styles itemPadding() {
    .padding({ top: BaseConstants.MODULE_PADDING, bottom: BaseConstants.MODULE_PADDING, left: 18, right: 18 })
  }
}