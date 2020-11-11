---
title: "游戏脚本初探索 Android Python Appium"
subtitle: ""
summary: ""
authors: [mrq]
tags: [Android, Python, Appium]
categories: ["脚本开发"]
date: 2020-11-07T21:22:22+08:00
lastmod: 2020-11-11T21:22:22+08:00
featured: false
draft: false

image:
    caption: ""
    focal_point: ""
    preview_only: false

projects: []
---

<!-- TOC -->

- [第一步：自动打开游戏](#第一步自动打开游戏)
    - [问题：Appium打开app会清空用户登录信息](#问题appium打开app会清空用户登录信息)
        - [解决路径](#解决路径)
        - [Appium Desired Capabilities](#appium-desired-capabilities)
- [在ScreenShot中利用reference image识别element](#在screenshot中利用reference-image识别element)

<!-- /TOC -->

## 第一步：自动打开游戏

详细的关于这些属性的值如何获取，见文章 *vscode+python+appium安装及简单示例*。

```python
from appium import webdriver
from appium.webdriver.common.touch_action import TouchAction

desired_caps = {}
desired_caps['platformName'] = 'Android'
desired_caps['platformVersion'] = '10.0'
desired_caps['deviceName'] = 'xxxxxxxxxxxxxxxx'
desired_caps['appPackage'] = 'com.cis.jiangnan.taptap'
desired_caps['appActivity'] = 'com.cis.cisframework.CISActivity'
desired_caps['newCommandTimeout']= '100000'
desired_caps['noReset'] = True

driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)
```

### 问题：Appium打开app会清空用户登录信息  

问题描述：手动打开app可以正常直接进入，使用appium打开app每次都会提示更新并要求重新登录。且每次被appium打开后的首次手动打开也出现上述步骤。

#### 解决路径  

搜索到问题[[求助] Appium 打开 App 会自动清除之前登录的帐号信息](https://testerhome.com/topics/9031)  
尝试使用`desired_caps['noReset'] = True`
成功解决问题，app可以正常打开。

#### Appium Desired Capabilities  

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

## 在ScreenShot中利用reference image识别element

首先阅读官方文档[Finding and Interacting with Image Elements](http://appium.io/docs/en/advanced-concepts/image-elements/)  

用计算机程序进行测试。  
我用画图截了“乘号”的图（据说这样能保证像素不变，待考证），并根据官网最下方给的示例代码进行测试。

```python
driver.update_settings({"getMatchedImageResult": True})
el = driver.find_element_by_image('C:/Users/30544/Desktop/test_cross.png')
el.get_attribute('visual') 
```

报错：`selenium.common.exceptions.WebDriverException: Message: An unknown server-side error occurred while processing the command. Original error: 'opencv4nodejs' module is required to use OpenCV features. Please install it first ('npm i -g opencv4nodejs') and restart Appium.`

其中给了一个opencv4nodejs的[how to install](https://github.com/justadudewhohacks/opencv4nodejs#how-to-install)的链接。以下为链接中给出的安装方式。  
> **Important Note!**  
> opencv4nodejs不能安装在含有空格的路径下。比如，安装在"C:\Program Files\some_dir"下时会报错“error C1083 ...”。在Windows环境下安装时，还需要Windows Build Tools来编译OpenCV和opencv4nodejs。  

运行`npm install --save opencv4nodejs`，报错：缺少cmake。
运行`npm install --global windows-build-tools`安装编译OpenCV和opencv4nodejs的Windows Build Tools。  
运行`pip install cmake`之后，重新尝试运行第一条命令`npm install --save opencv4nodejs`，报错的地方通过了，但提示新错误：  

```
CMake Error at CMakeLists.txt(project):
  Generator

    Visual Studio 15 2017 Win64

  could not find any instance of Visual Studio.
```

使用这个[解决方法](https://www.pianshen.com/article/22701428686/)解决了Visual Studio下载速度很慢的问题。
根据[这篇博客](https://www.cnblogs.com/qq2806933146xiaobai/p/13359446.html)对Visual Studio进行了修改——未解决
根据[这篇博客](https://stackoverflow.com/questions/51668676/cmake-visual-studio-15-2017-could-not-find-any-instance-of-visual-studio)更改了VS160xxxx环境变量的值——未解决

重新尝试，先手动安装OpenCV，在官网下载安装程序，手动安装CMake
