import { BaseConstants, MainButton, PageTitleBuilder } from "jbase"

@Builder
export function AboutUsBuilder(name: string, param: Object) {
  AboutUs()
}

// 关于我们页面
@ComponentV2
export struct AboutUs {
  @Local private navPathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        Column() {
          // Logo
          Image($r('app.media.logo'))
            .width(100)
            .height(100)
            .margin({ top: 16, bottom: 16 })
            .borderRadius(BaseConstants.BORDER_RADIUS)
          
          // App名称
          Text($r('app.string.app_name'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
          
          // 版本信息
          Row() {
            Text($r('app.string.about_version'))
              .fontSize(14)
              .fontColor($r('app.color.gl_999'))
            Text('v1.0.0')
              .fontSize(14)
              .fontColor($r('app.color.gl_999'))
              .margin({ left: 4 })
          }.margin({ bottom: 24 })

          Column() {
            // 公司名称
            Text($r('app.string.about_company'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 20, bottom: 8 })

            // 公司口号
            Text($r('app.string.about_slogan'))
              .fontSize(16)
              .fontColor($r('app.color.gl_666'))
              .margin({ bottom: 24 })

            // 公司简介
            Text($r('app.string.about_desc'))
              .fontSize(14)
              .fontColor($r('app.color.gl_666'))
              .textAlign(TextAlign.Center)
              .margin({ left: 20, right: 20, bottom: 10 })
              .lineHeight(24)
          }
          .padding(BaseConstants.MODULE_PADDING)
          .borderRadius(BaseConstants.BORDER_RADIUS)
          .backgroundColor($r('app.color.white'))


        }
        .width(BaseConstants.FULL_WIDTH)
        .alignItems(HorizontalAlign.Center)
      }
      .padding({ top: 16, left: 20, right: 20 })
      .width(BaseConstants.FULL_WIDTH)
    }
    .title(PageTitleBuilder($r('app.string.my_about_us')))
    .backgroundColor($r('app.color.back_color'))
  }
}