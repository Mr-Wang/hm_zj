import { AbilityConstant, Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { font, window } from '@kit.ArkUI';
import { CustomTheme, CustomColors, ThemeControl } from '@kit.ArkUI';
import { CoreUtils, FullLoading } from 'jbase';
import { AppUtil } from '@pura/harmony-utils'
import { Previewer } from "@humor/lg-image-previewer"
import {efRcp} from '@yunkss/ef_rcp'
import { AppConfig, APP_ID_WX } from '../config/Index';
import { handleWeChatCallIfNeed } from '@zyl/wxcommonlibhar'; // 包

import BuildProfile from 'BuildProfile';

// 自定义主题颜色
class MainColors implements CustomColors {
  brand = $r('app.color.main_color')
}

class PageCustomTheme implements CustomTheme {
  colors?: CustomColors;
  constructor(colors: CustomColors) {
    this.colors = colors;
  }
}


@Builder
function MyLoadingImg() {
  // Image($r('app.media.loading'))
  //   .width(100)
  //   .height(100);
  Column({space:16}) {
    Progress({ value: 0, total: 100, type: ProgressType.Ring })
      .width(45).color($r('app.color.main_color'))
      .style({ strokeWidth: 8, status: ProgressStatus.LOADING })
      .opacity(1)
    Text("正在加载...").fontColor($r("app.color.black"))
      .fontSize(14)
      .fontFamily('MyFont')
      .opacity(0.9)
  }
  .alignItems( HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .width(180)
  .height(100)
  .backgroundColor($r("app.color.white"))
  .opacity(0.8)
  .borderRadius(20)
  .zIndex(9999)
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 创建实例
    const MainColorsTheme = new PageCustomTheme(new MainColors());
    ThemeControl.setDefaultTheme(MainColorsTheme);
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    AppUtil.init(this.context);

    // handleWeChatCallIfNeed(want,APP_ID_WX) // 微信需要的


  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }


  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // 初始化系统
    CoreUtils.initSystem(windowStage, this.context);

    // //初始化多端api服务
    // MultiApi.instance
    //   .setWechat("wxf8c40523e1a1fcdd", "9734c76f3f83ed4dfc454275f6efda7b")
    //   .setDebug(BuildProfile.DEBUG)
    //   .init(this.context);

    //初始化图片弹框控件 自定义全局配置，按需使用
    Previewer.setConfig((config) => {
      // config.placeholderNormal = $r('app.media.placeholder_normal')
      // config.placeholderFailed = $r('app.media.placeholder_failed')
      config.finalBgColor = 'rgba(0, 0, 0, 1)'
      config.bgDuration = 100
      config.magnifyDuration = 250
      config.topBarBgColor = $r("app.color.main_color")
    })

    efRcp
    //设置请求路径
      .setBaseURL(AppConfig.baseUrl)
      //启用打印日志
      .enableLogInterceptor()
      //更改loading文本
      .setLoadingContent('加载中请稍后...')
      //表示如果response.toJSON()异常时将响应字符串返回,false则表示值返回异常提醒而不返回结果
      .convertError(true)
      //设置一部分不需要从接口获取的常量公共头
      .addCommonHeaders({
        "iszjapp":"1",
        "systemtype":"ios"
      })
      .setTimeOut({
        connectMs:100000,
        transferMs:100000
      })
      //设置loading为gif图片
      // .setLoadingImg(wrapBuilder(MyLoadingImg))
      //启动lottie  与setLoadingImg互斥不可同事使用
      // .enableLottie()
      //设置自定义loading样式和内容
      .setLoadingBuilder(wrapBuilder(MyLoadingImg))
      //添加系统以及业务编码监听
      .addCodeEvent({
        businessCodeName: 'csxErrorCode',
        listener: (sysCode, busCode) => {
          //此处解决弹框不出现问题
          CoreUtils.toast(sysCode + '+++++++' + busCode);
        }
        //创建session对象,需要再设置为一系列操作后再调用，否则设置不生效,可在特殊情况处设置其他操作后重新创建session
      })
      .setUploadEvent({
        onUploadProgress: (progress) => {
          console.log( "---------测试上传进度----------", progress + "%");
        }
      }).create();

    font.registerFont({
      familyName: 'MyFont', familySrc: $rawfile('MyFont.ttf')
    })

    //  设置状态栏颜色（主窗口此时已创建）
    const win = windowStage.getMainWindowSync();
    win.setWindowSystemBarProperties({
      statusBarColor: '#2A7AFD',       // 你的颜色
      statusBarContentColor: '#FFFFFF' // 图标/文字颜色
    });

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    // MultiApi.instance.onForeground();

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  // 回到app的监听及数据
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // handleWeChatCallIfNeed(want,APP_ID_WX) // 微信需要的
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }


  onConfigurationUpdate(newConfig: Configuration): void {

  }
}