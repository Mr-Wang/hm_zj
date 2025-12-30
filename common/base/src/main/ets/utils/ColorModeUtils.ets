import { common, ConfigurationConstant } from "@kit.AbilityKit";

const setColorMode = (context: common.UIAbilityContext, colorMode: ConfigurationConstant.ColorMode) => {
  context.getApplicationContext().setColorMode(colorMode);
}

export const setAutoColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
}

export const setDarkColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
}

export const setLightColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
}

/**
 * 设置应用深色模式
 */
export const setAppColorMode = (context: common.UIAbilityContext) => {
  PersistentStorage.persistProp('isFollowSystemSetting', true)
  PersistentStorage.persistProp('enableDarkMode', false)
  const isFollowSystemSetting: boolean | undefined = AppStorage.get('isFollowSystemSetting');
  const enableDarkMode: boolean | undefined = AppStorage.get('enableDarkMode');
  if (isFollowSystemSetting !== undefined && enableDarkMode !== undefined) {
    if (isFollowSystemSetting) {
      context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } else {
      if (enableDarkMode) {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      } else {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      }
    }
  }
}