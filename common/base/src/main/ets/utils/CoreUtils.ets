import { preferences, ValueType } from "@kit.ArkData"
import { font, window } from "@kit.ArkUI"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { setAppColorMode } from "./ColorModeUtils"
import { setAppLanguage } from "./LanguageUtils"
import { UserConstants } from "../constants/UserConstants"
import { promptAction, KeyboardAvoidMode } from '@kit.ArkUI'
import { UserInfo } from './ContextUtils'
import { ToastUtil } from "@pura/harmony-utils"
import { DialogHelper } from "@pura/harmony-dialog"

let dataPreferences: preferences.Preferences | null = null
let windowStageObj: window.WindowStage
let appContext: common.UIAbilityContext

const systemCreated = (err: BusinessError, context: common.UIAbilityContext) => {
  if (err.code) {
    hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '')
    return
  }
  font.registerFont({
    familyName: 'iconfont',
    familySrc: '/fonts/iconfont.ttf'
  })

  hilog.info(0x0000, 'registerFont', '注册字体成功')
  hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.')
  // 设置深色模式
  setAppColorMode(context)
  // 设置语言
  setAppLanguage(context)
}

export class CoreUtils {

  /**
   * 设置全局存储
   */
  static setJhmData = (key: string, value: ValueType | UserInfo) => {
    if (!dataPreferences) {
      return false
    }
    dataPreferences.putSync(key, value)
    console.debug('setJhmData: ' + key + ' ' + value)
    dataPreferences.flush((err: BusinessError) => {
      if (err) {
        console.error(`Failed to flush. Code:${err.code}, message:${err.message}`)
        return
      }
      console.info('Succeeded in flushing.')
    })
    return true
  }

  /**
   * 获取全局存储
   */
  static getJhmData = (key: string, defaultValue: string) => {
    if (!dataPreferences) {
      return ''
    }
    return dataPreferences.getSync(key, defaultValue)
  }

  /**
   * 删除全局存储
   */
  static delJhmData = (key: string) => {
    if (!dataPreferences) {
      return false
    }
    dataPreferences.deleteSync(key)
    dataPreferences.flush((err: BusinessError) => {
      if (err) {
        console.error(`Failed to flush. Code:${err.code}, message:${err.message}`)
        return
      }
      console.info('Succeeded in flushing.')
    })
    return true
  }

  /**
   * 初始化系统
   */
  static initSystem = (windowStage: window.WindowStage, context: common.UIAbilityContext) => {
    // 初始化全局存储
    dataPreferences = preferences.getPreferencesSync(context, { name: 'JhmStore' });
    windowStageObj = windowStage;
    appContext = context;
    let token = this.getJhmData(UserConstants.TOKEN_KEY, '');
    console.log('token: ' + token);
    if (!!token) {
      this.toIndex()
    } else {
      this.toLogin()
    }
  }

  /**
   * 跳转到首页
   */
  static toIndex = () => {
    if (!!windowStageObj) {
      windowStageObj.loadContent('pages/Index', (err) => {
        let windowClass: window.Window = windowStageObj.getMainWindowSync()
        windowClass.setWindowLayoutFullScreen(false)
        windowClass.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
        systemCreated(err, appContext)
      })
    } else {
      console.error('windowStageObj is null')
    }
  }

  /**
   * 跳转到登录页
   */
  static toLogin = () => {
    if (!!windowStageObj) {
      windowStageObj.loadContent('pages/Login', (err) => {
        let windowClass: window.Window = windowStageObj.getMainWindowSync()
        windowClass.setWindowLayoutFullScreen(true)
        systemCreated(err, appContext)
      })
    } else {
      console.error('windowStageObj is null')
    }
  }

  /**
   * 退出登录
   */
  static logout = () => {
    this.delJhmData(UserConstants.TOKEN_KEY)
    this.delJhmData(UserConstants.CTT_KEY)
  }

  /**
   * 吐司提示
   */
  static toast = (message: string | Resource, duration?: number) => {
    ToastUtil.showToast(message);
    // let temp = duration || 2000
    // promptAction.showToast({
    //   message: message,
    //   duration: temp
    // })
  }

  static alert = (message: string | Resource, onAlertClick?: () => void,isCanBtn:boolean = false) => {
    DialogHelper.showAlertDialog({
      title: "温馨提示",
      content: message.toString()??"",
      actionCancel: false, //点击操作按钮不关闭弹框
      autoCancel: false, //点击遮障层时，不关闭弹窗
      backCancel: false, //点击返回键，不关闭弹窗
      primaryButton: isCanBtn?"取消":"",
      secondaryButton: "确定",
      onAction: (action, dialogId) => {
        DialogHelper.closeDialog(dialogId); //关闭弹框
        let alertIndex:number = Math.abs(action) - 1;
        if (alertIndex == 0) {
          return;
        }
        if (onAlertClick) {
          onAlertClick();
        }
      }
    })
  }
}