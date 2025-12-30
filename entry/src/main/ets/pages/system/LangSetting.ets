import { BaseConstants, StringUtils, LanguageModel, setLanguage, PageTitleBuilder } from 'jbase';
import { i18n } from '@kit.LocalizationKit';

@Builder
export function LangSettingBuilder(name: string, param: Object) {
  LangSetting()
}

@Component
export struct LangSetting {
  // 存储属性
  @StorageProp('currentLanguage') appLanguage: string = 'default'  // 默认跟随系统

  private langData: LanguageModel[] = [
    { code: 'default', name: $r('app.string.follow_system') },
    { code: 'zh-CN', name: '简体中文' },
    { code: 'en-US', name: 'English' }
  ]

  aboutToDisappear(): void {
    AppStorage.setOrCreate('currentLanguage', this.appLanguage);
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.lang_tip'))
          .fontColor($r('app.color.gl_999')).fontSize(14).fontWeight(400)
          .lineHeight(24).margin({ bottom: 16, top: 8 })
          .width(BaseConstants.FULL_WIDTH).padding({ left: 6 })

        ForEach(this.langData, (item: LanguageModel, index: number) => {
          Row() {
            Text(item.name).fontColor($r('app.color.black')).fontSize(16).fontWeight(500).lineHeight(22)
            if (this.appLanguage === item.code) {
              SymbolGlyph($r('sys.symbol.checkmark')).fontColor([$r('app.color.main_color')])
                .fontSize(20).fontWeight(500)
            }
          }
          .itemStyle()
          .margin({ bottom: BaseConstants.MODULE_PADDING })
          .justifyContent(FlexAlign.SpaceBetween)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
          .onClick(() => {
            let tempLang = this.appLanguage
            let tempName: string = typeof item.name === 'object'
              ? StringUtils.getResStr(item.name) : item.name
            this.appLanguage = item.code
            AlertDialog.show(
              {
                title: $r('app.string.tips'),
                message: `${StringUtils.getResStr($r('app.string.lang_switch_tip'))} ${tempName}?`,
                cornerRadius: BaseConstants.BORDER_RADIUS,
                autoCancel: false,
                height: 170,
                primaryButton: {
                  value: $r('app.string.nobtn'),
                  action: () => {
                    this.appLanguage = tempLang
                  }
                },
                secondaryButton: {
                  value: $r('app.string.yesbtn'),
                  action: () => {
                    if (item.code == 'default') {
                      setLanguage(i18n.System.getSystemLanguage())
                    } else {
                      setLanguage(item.code)
                    }
                  }
                }
              }
            )
          })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .title(PageTitleBuilder($r('app.string.lang_setting')))
    .backgroundColor($r('app.color.back_color'))
  }

  @Styles itemStyle() {
    .width(BaseConstants.FULL_WIDTH)
    .height(56)
    .backgroundColor($r('app.color.white'))
    .padding({ left: BaseConstants.MODULE_PADDING + 6, right: BaseConstants.MODULE_PADDING })
    .borderRadius(BaseConstants.BORDER_RADIUS)
  }
}