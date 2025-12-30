

@ComponentV2
export struct CellInfoItem {
  @Param title: string = "";
  @Param content: string = "";
  @Param clickable: boolean = true;
  @Param isLeft :boolean = false;
  @Event onClickAA?: () => void

  build() {
    Column() {
      Row() {
        if(this.isLeft) {
          Text(this.title)
            .fontSize(14)
            .fontColor($r("app.color.black"))
            .width("28%")
          Text(this.content)
            .fontSize(14)
            .fontColor($r("app.color.black"))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        } else {
          Text(this.title)
            .fontSize(14)
            .fontColor("#99999B")
            .layoutWeight(1)

          Text(this.content)
            .fontSize(14)
            .fontColor(Color.Black)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.clickable) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('app.color.gl_888')])
              .fontSize(24)
              .margin({ left: 10 })
          }
        }

      }
      .width("100%")
      .padding(20)

      Divider()
        .color("#e7e7e7")
        .strokeWidth(1)
    }
    .onClick(() => {
      if (this.clickable && this.onClickAA) {
        this.onClickAA();
      }
    })
  }
}