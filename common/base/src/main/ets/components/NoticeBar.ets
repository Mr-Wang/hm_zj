import { NoticeBarModel } from "../types/AllTypes"

@ComponentV2
export struct NoticeBar {
  // 通知标题
  @Param noticeTitle: Resource = $r('app.string.notice_title')
  // 通知数据
  @Param noticeData: Array<NoticeBarModel> = []
  // 自动播放
  @Param autoPlay: boolean = true
  // 图标大小
  @Param iconSize: number = 17
  // 文本大小
  @Param textSize: number = 15

  // 通知点击事件
  onNoticeClick?: (item: NoticeBarModel, index: number) => void

  build() {
    Flex({ justifyContent: FlexAlign.Start }) {
      SymbolGlyph($r('sys.symbol.bell_fill'))
        .fontColor([$r('app.color.notice_color')])
        .fontSize(this.iconSize)
        .margin({ right: 5 })
        .width('auto')
      Swiper() {
        ForEach(this.noticeData, (item: NoticeBarModel, index) => {
          Row() {
            Text(this.noticeTitle).fontSize(this.textSize).margin({ right: 4 })
            Text(item.title).fontSize(this.textSize).fontColor($r('app.color.gl_888'))
          }
          .justifyContent(FlexAlign.Start)
          .onClick(() => {
            if (this.onNoticeClick) {
              this.onNoticeClick(item, index)
            }
          })
        })
      }
      .autoPlay(this.autoPlay)
      .indicator(false)
      .vertical(true)
      .flexGrow(1)
    }
  }
}
