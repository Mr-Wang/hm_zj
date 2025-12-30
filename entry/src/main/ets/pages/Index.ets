import { BaseConstants } from 'jbase'
import { HomePage } from './tabbar/ZJ_HomePage';
import { TabItemView } from './comps/TabItemView';
import { MyPage } from './tabbar/MyPage';
import { StudyHomePage } from './tabbar/ZJ_StudyHomePage';
import { TrainHomePage } from './tabbar/ZJ_TrainHomePage';
import { EvaluationHomePage } from './tabbar/ZJ_EvaluationHomePage';
import { ZJMyPage } from './tabbar/ZJ_MyPage';
import { WindowUtil } from '@pura/harmony-utils';

/**
 * 首页页面
 */
@Entry
@ComponentV2
struct Index {
  private controller: TabsController = new TabsController()
  @Local pageIndex: number = 0;
  @Provider('pageInfos') pageStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    WindowUtil.setWindowSystemBarProperties({
      statusBarColor: '#2A7AFD',       // 你的颜色
      statusBarContentColor: '#FFFFFF' // 图标/文字颜色
    })
  }

  build() {
    Navigation(this.pageStack) {
      Tabs({ barPosition: BarPosition.End, index: this.pageIndex, controller: this.controller }) {
        // 专家首页
        TabContent(){ HomePage() }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_WIDTH)
        .tabBar(this.tabBuilder(0, $r('app.media.shouyeweixuan'),$r('app.media.shouyexuan'), $r('app.string.home')))
        // 学习首页
        TabContent(){ StudyHomePage() }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_WIDTH)
        .tabBar(this.tabBuilder(1, $r('app.media.xuexiweixuan'),$r('app.media.xuexixuan'), $r('app.string.study')))


        // 培训
        TabContent(){
          TrainHomePage()
        }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_WIDTH)
        .tabBar(this.tabBuilder(2, $r('app.media.peixunweixuan'),$r('app.media.peixunxuan'), $r('app.string.train')))

        //考评
        TabContent(){
          EvaluationHomePage()
        }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_WIDTH)
        .tabBar(this.tabBuilder(3, $r('app.media.ceyanweixuan'),$r('app.media.ceyanxuan'), $r('app.string.exam')))
        // 我的
        TabContent(){ ZJMyPage() }
        .width(BaseConstants.FULL_WIDTH)
        .height(BaseConstants.FULL_WIDTH)
        .tabBar(this.tabBuilder(4, $r('app.media.wodeweixuan'),$r('app.media.wodexuan'), $r('app.string.mine')))
      }
      .barOverlap(true)
      .animationDuration(300)
      .onTabBarClick((index: number) => this.pageIndex = index)
      .onChange((index: number) => this.pageIndex = index)
      .divider({ strokeWidth: 1, color: $r('app.color.color_line') })
      .backgroundColor($r('app.color.main_background'))
      .barBackgroundColor($r('app.color.bar_background'))
      .barMode(BarMode.Fixed)
      .vertical(false)
      .fadingEdge(false)
      .barOverlap(false)
    }
    .mode( NavigationMode.Stack)
    .height(BaseConstants.FULL_HEIGHT)
    .hideTitleBar(true)
    .titleMode(NavigationTitleMode.Mini)
  }


  /**
   * Tab菜单
   */
  @Builder
  tabBuilder(index: number, icon: string  | Resource, check_icon: string | Resource, text: string | Resource) {
    TabItemView({ text: text, icon: icon,check_icon:check_icon, check: index === this.pageIndex })
  }

}