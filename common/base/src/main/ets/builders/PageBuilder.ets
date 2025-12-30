import { BaseConstants } from "../constants/BaseConstants";

@Builder
export function PageTitleBuilder(title: ResourceStr) {
  Text(title)
    .height(BaseConstants.FULL_HEIGHT)
    .fontSize(21)
    .fontColor($r('app.color.white'))
    .fontWeight(700)
    .padding({ left: BaseConstants.MODULE_PADDING - 4 })
}
