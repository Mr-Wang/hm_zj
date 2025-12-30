import { common } from '@kit.AbilityKit';
import { setDarkColorMode, setLightColorMode, setAutoColorMode, BaseConstants, StringUtils,
  PageTitleBuilder } from 'jbase';

@Builder
export function DarkSettingBuilder(name: string, param: Object) {
  DarkModeSetting()
}

@Component
export struct DarkModeSetting {
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false;
  @StorageProp('isFollowSystemSetting') isFollowSystemSetting: boolean = true;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToDisappear(): void {
    // 持久化设置
    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
    AppStorage.setOrCreate('isFollowSystemSetting', this.isFollowSystemSetting);
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.dark_tip'))
          .fontColor($r('app.color.gl_999')).fontSize(14).fontWeight(400)
          .lineHeight(24).margin({ bottom: 16, top: 8 })
          .width(BaseConstants.FULL_WIDTH).padding({ left: 6 })
        Row() {
          Text($r('app.string.follow_system')).fontColor($r('app.color.black'))
            .fontSize(16).fontWeight(500).lineHeight(22)
          Toggle({ type: ToggleType.Switch, isOn: this.isFollowSystemSetting })
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.isFollowSystemSetting = true;
                this.enableDarkMode = false;
                setAutoColorMode(this.context);
              } else {
                this.isFollowSystemSetting = false;
                if (this.enableDarkMode) {
                  setDarkColorMode(this.context);
                } else {
                  setLightColorMode(this.context);
                }
              }
            })
        }
        .itemStyle()
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: BaseConstants.MODULE_PADDING })

        Row() {
          Text($r('app.string.dark_mode')).fontColor($r('app.color.black')).fontSize(16)
            .fontWeight(500).lineHeight(22)
          Toggle({ type: ToggleType.Switch, isOn: this.enableDarkMode })
            .onChange((isOn: boolean) => {
              this.enableDarkMode = isOn;
              if (isOn) {
                this.isFollowSystemSetting = false;
                setDarkColorMode(this.context);
              } else if (!this.isFollowSystemSetting) {
                setLightColorMode(this.context);
              }
            })
        }
        .itemStyle()
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ left: 16, right: 16 })
    }
    .title(PageTitleBuilder($r('app.string.dark_mode')))
    .backgroundColor($r('app.color.back_color'))
  }

  @Styles itemStyle() {
    .width(BaseConstants.FULL_WIDTH)
    .height(56)
    .backgroundColor($r('app.color.white'))
    .padding({
      left: BaseConstants.MODULE_PADDING + 6,
      right: BaseConstants.MODULE_PADDING
    })
    .borderRadius(BaseConstants.BORDER_RADIUS)
  }
}