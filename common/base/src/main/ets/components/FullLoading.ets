import { BaseConstants } from "../constants/BaseConstants"

/**
 * 全屏加载中
 */
@ComponentV2
export struct FullLoading {
  @Param loading: boolean = false;

  build() {
    if (this.loading) {
      Column() {
        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .width(45).color($r('app.color.main_color'))
          .style({ strokeWidth: 8, status: ProgressStatus.LOADING })
          .opacity(1)
      }
      .alignItems( HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(BaseConstants.FULL_WIDTH)
      .height(BaseConstants.FULL_HEIGHT)
      .position({ top: 0, left: 0, right: 0, bottom: 0 })
      .zIndex(9999)
    }
  }
}