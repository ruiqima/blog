# 游戏脚本初探索 Android Python Appium

## 问题：Appium打开app会清空用户登录信息  

问题描述：手动打开app可以正常直接进入，使用appium打开app每次都会提示更新并要求重新登录。且每次被appium打开后的首次手动打开也出现上述步骤。

### 解决路径  

搜索到问题[[求助] Appium 打开 App 会自动清除之前登录的帐号信息](https://testerhome.com/topics/9031)  
尝试使用`desired_caps['noReset'] = True`
成功解决问题，app可以正常打开。

**Appium Desired Capabilities**  
Desired Capabilities是JSON对象，键值对形式。每次新的自动会话 automation session开始时，Appium Client（比如说我们的.py文件）都要向Server（Appium）发送Desired Capabilities。  
**常用的Capabilities-Android和iOS平台通用**  
Capability | 描述
--- | ---
`automationName` | 选择哪个`automation engine`。`Appium` (default)/`UiAutomator2`/`Espresso`/`UiAutomator1` for Android/`XCUITest` or `Instruments` for iOS
`platformName` | 哪个操作系统。`iOS`/`Android`/`FirefoxOS`
`platformVersion` | 系统版本号。eg. 10.1
`app` | `.apk`等的绝对路径或者一个http URL。对于`Android`，如果已经指定了`appPackage`和`appActivity`，则不需要填写。
`newCommandTimeout` | Appium将等待Client发出新命令的时间（以秒为单位），超出时间无新命令将假设客户端退出并结束会话
`noReset` | 在此会话之前，请勿重置应用程序状态。详细见[Reset Strategies](http://appium.io/docs/en/writing-running-appium/other/reset-strategies/index.html).
`eventTimings` | 启用或禁用各种Appium内部事件的计时报告（例如，每个命令的开始和结束等）。默认为false。要启用，请使用true。这些计时将以事件属性的形式作为查询当前会话的响应。详细见[Appium Event Timing](http://appium.io/docs/en/advanced-concepts/event-timings/index.html).
**其他常用的Capabilities-仅适用于基于Android的驱动**  
Capability | 描述
--- | ---
`appActivity` | 要从package中启动的Android activity的Activity name
`appPackage` | 要运行的Android应用的Java包
`adbPort` | 用于连接到ADB服务器的端口（默认为5037）
`unicodeKeyboard` | 启用Unicode输入，默认为`false`
`resetKeyboard` | 在运行具有`unicodeKeyboard` capability的Unicode测试之后，将键盘重置为其原始状态。如果单独使用，则忽略。默认为`false`.
`androidScreenshotPath` | 截图将被放置在的路径。默认为`/data/local/tmp`.

更多capabilities详见[Appium Desired Capabilities](http://appium.io/docs/en/writing-running-appium/caps/).