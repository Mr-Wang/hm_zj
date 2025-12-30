@ComponentV2
export struct TabItemView {
  @Require @Param text: string | Resource;
  @Require @Param icon: string | Resource;
  @Require @Param check_icon: string | Resource;
  @Require @Param check: boolean;

  build() {
    Column() {
      Image(this.check ?this.check_icon:this.icon)
        .width(22)
        .height(23)
        .objectFit(ImageFit.Fill)
        .fillColor(this.check ? $r('app.color.main_color') : $r('app.color.gl_888'))
        .margin({ top: 3 })
      Text(this.text)
        .fontSize(12)
        .fontColor(this.check ? $r('app.color.main_color') : $r('app.color.gl_888'))
        .fontStyle(FontStyle.Normal)
        .margin({ top: 3 })
    }
    .backgroundColor(Color.Transparent)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .alignSelf(ItemAlign.Center)
  }
}