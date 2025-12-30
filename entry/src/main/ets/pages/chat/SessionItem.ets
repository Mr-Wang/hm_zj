import { BaseConstants } from "jbase"
import { ChatSession } from "./ChatType"

@Builder
export function SessionItem(session: ChatSession) {
  Row() {
    Image($r('app.media.app_icon'))
      .width(50)
      .height(50)
      .borderRadius(BaseConstants.BORDER_RADIUS)
      .margin({ right: 12 })

    Column() {
      Row() {
        Text(session.title).fontSize(16).fontWeight(FontWeight.Medium)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      }.width(BaseConstants.FULL_WIDTH)

      Row() {
        Text(session.timestamp).fontSize(14).fontColor($r('app.color.gl_888'))
      }.width(BaseConstants.FULL_WIDTH).margin({ top: 8 })
    }
    .flexGrow(1)
  }
  .width(BaseConstants.FULL_WIDTH)
  .padding(12)
  .backgroundColor($r('app.color.white'))
  .borderRadius(BaseConstants.BORDER_RADIUS)
}