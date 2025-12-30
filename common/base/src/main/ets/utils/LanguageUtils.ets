import { common } from "@kit.AbilityKit";
import { i18n } from '@kit.LocalizationKit';

export const setLanguage = (language: string) => {
  i18n.System.setAppPreferredLanguage(language);
  getContext().getApplicationContext().setLanguage(language);
}

export const setAutoLang = () => {
  setLanguage('default');
}

export const setZhCn = () => {
  setLanguage('zh-CN');
}

export const setEnUs = () => {
  setLanguage('en-US');
}

/**
 * 设置应用语言
 */
export const setAppLanguage = (context: common.UIAbilityContext) => {
  PersistentStorage.persistProp('currentLanguage', 'default')
  const appLanguage: string | undefined = AppStorage.get('currentLanguage');
  if (appLanguage !== undefined) {
    if (appLanguage === 'default') {
      setLanguage(i18n.System.getSystemLanguage());
    } else {
      setLanguage(appLanguage);
    }
  }
}