---
title: "游戏脚本-自动生产 Android Python Appium"
subtitle: ""
summary: ""
authors: [mrq]
tags: [Android, Python, Appium]
categories: ["脚本开发"]
date: 2020-11-07T21:22:22+08:00
lastmod: 2020-11-18T21:22:22+08:00
featured: false
draft: false

image:
    caption: ""
    focal_point: ""
    preview_only: false

projects: []
---

<!-- TOC -->

- [整体思路](#整体思路)
- [第一步：自动打开游戏](#第一步自动打开游戏)
    - [问题：Appium打开app会清空用户登录信息](#问题appium打开app会清空用户登录信息)
        - [解决路径](#解决路径)
        - [Appium Desired Capabilities](#appium-desired-capabilities)
- [第二步：swipe界面到水井所在位置](#第二步swipe界面到水井所在位置)
- [第三步：点击水井进行生产](#第三步点击水井进行生产)
    - [1. 点击水井](#1-点击水井)
    - [2. 验证水井是否点击正确](#2-验证水井是否点击正确)
    - [3. 选择工人/负责人进行生产](#3-选择工人负责人进行生产)
    - [4. 综合](#4-综合)
    - [5. 循环调用生产函数](#5-循环调用生产函数)
- [问题](#问题)

<!-- /TOC -->

## 整体思路

开发这个脚本的目的是为了可以自动点击水井、生产，不断地进行这个操作。目前的思路是：
- 自动打开游戏
- move屏幕to水井所在位置（水井并不在打开app的初始界面中）
- 图像识别水井（可能有多个），保存这些水井的位置
- loop：
    - for每一个水井，loop：
        - 点击水井
        - 判断界面中是否出现“水井”两字以验证是否点击正确，若有，则识别“普通水”三字并点击；若无，输出log，返回
        - 若界面中识别出“负责人”三字，则识别“直接开始”四字，点击下方一格距离的位置（即点击第一个负责人）；若未出现“负责人”三字，继续循环
    - 等待三分钟
- 手动退出或设置loop最大时长退出  

请确保上次退出时是在应天府，所有识别都是基于应天府的。

## 第一步：自动打开游戏

详细的关于这些属性的值如何获取，见文章 *vscode+python+appium安装及简单示例*。

```python
from appium import webdriver
from appium.webdriver.common.touch_action import TouchAction
import time

desired_caps = {}
desired_caps['platformName'] = 'Android'
desired_caps['platformVersion'] = '10.0'
desired_caps['deviceName'] = 'xxxxxxxxxxxxxxxx'
desired_caps['appPackage'] = 'com.cis.jiangnan.taptap'
desired_caps['appActivity'] = 'com.cis.cisframework.CISActivity'
desired_caps['newCommandTimeout']= '100000'
desired_caps['noReset'] = True

driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)

time.sleep(20)
```

设置`time.sleep(20)`的原因是打开app需要时间，后续操作需要等待app的打开。

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

## 第二步：swipe界面到水井所在位置

首先可以查看app的窗口大小。

```python
print(driver.get_window_size()) # {'width': 1080, 'height': 2265}
```

使用`swipe`移动视图。

```python
driver.swipe(540, 1000, 1050, 1500, 1000) 
```

>**ActionHelpers.swipe(start_x: int, start_y: int, end_x: int, end_y: int, duration=0) -> ActionHelpers**
Swipe from one point to another point, for an optional duration.
>
> *Args:* 
> - start_x: x-coordinate at which to start 
> - start_y: y-coordinate at which to start 
> - end_x: x-coordinate at which to stop 
> - end_y: y-coordinate at which to stop 
> - duration: time to take the swipe, in ms.
>
> *Usage:* driver.swipe(100, 100, 100, 400)
>
> *eturns:* Union['WebDriver', 'ActionHelpers']: Self instance

## 第三步：点击水井进行生产

### 1. 点击水井

这一次并没有尝试图像识别找水井的方式。因为我是绝对值移动到这个屏幕位置的，所以每个水井在屏幕上的位置是相对固定的。因此我直接建立了一个保存有水井位置的tuple：

```python
well_pos_tuple = [{'x': 456, 'y': 1384}, {'x': 530, 'y': 1440}, ...]

```

点击每个水井并进行生产的操作可以封装在一个函数中，点击不同水井则给函数不同的参数值即可。定义函数`cautiousproduce`：

```python
def cautiousproduce(category, pos, check_dir):
    actionsWell = TouchAction(driver)
    actionsWell.tap(None, pos['x'], pos['y']).perform()   # 点击
```

其中`category`是当前进行生产的类型名称，用于错误输出，如“水井”。
`pos`是要点击的位置，在这儿就是tuple中的一个元素。`check_dir`是下一步要进行验证是否点击正确的图片路径。  

### 2. 验证水井是否点击正确

但如果没有正确点击水井会怎么办？有的时候的确会出现未正确点击的现象，尽管我现在还没有弄明白是为什么没有点击正确。因此我们需要验证水井是否点击正确，才能继续进行后续的生产操作。

怎么验证？正确点击水井后会出现选择生产类型的弹框。因此我们验证是否有正确的弹框出现就好了。即，验证屏幕中是否出现“水井”两字。验证图片的路径放在参数`check_dir`中。识别的函数如下。

```python
el = driver.find_element_by_image(check_dir)
```

要注意的一点是，如果识别不到，这个函数会直接抛出一个Exception，因此我们需要`try ... except ...`来handle这种情况。异常处理的具体内容可以参考[python-错误和异常](https://docs.python.org/zh-cn/3/tutorial/errors.html)。

如果不添加异常处理程序且未识别到对应图片，则会有报错：  
```
raise exception_class(message, screen, stacktrace)
selenium.common.exceptions.NoSuchElementException: Message: An element could not be located on the page using the given search parameters.
```
这里面展示了异常类型是`NoSuchElementException`，我们需要处理的就是这个异常。为了识别这个异常类型，我们需要`from selenium.common.exceptions import NoSuchElementException`。

```python
def cautiousproduce(category, pos, check_dir):
    global count
    actionsWell = TouchAction(driver)
    actionsWell.tap(None, pos['x'], pos['y']).perform()   # 点击
    time.sleep(0.5)
    try:
        # 检查是否正确点击水井，是否识别到下一步图像
        driver.find_element_by_image(check_dir)
        # 点击生产第一项
        # ...

    except NoSuchElementException:
        print("Oops~~"+category+"未被正确点击")
```

添加了异常处理之后就会报出我们自己定义的语句了！  

```
(.venv) PS ~> python hello.py
Oops~~水井未被正确点击
```

### 3. 选择工人/负责人进行生产

正确点击水井之后就可以开始生产啦！因为每次都只生产普通水，弹框在屏幕的位置又是固定的，所以直接给绝对位置进行点击即可。需要变量`first_product_pos`来存储“普通水”（即第一个选项）的位置。

```python
        # 点击生产第一项
        actionsProduce = TouchAction(driver)
        actionsProduce.tap(
            None, first_product_pos['x'], first_product_pos['y']).perform()
```

接下来会遇到的问题是，有负责人剩余时需要要负责人进行生产，还需要进行一次点击；而没有剩余的时候直接就开始生产了。因此判断是否有选择负责人的弹框也是一个必要步骤。采用识别是否出现“负责人”三字的方法来判断。同样，注意，也需要进行异常处理。  

```python
        # 检查是否需要负责人
        try:
            fuzeren = driver.find_element_by_image(fuzeren_dir)
            actionFuzeren = TouchAction(driver)
            actionFuzeren.tap(
                None, furenren_pos['x'], furenren_pos['y']).perform()
            print('负责人-开始生产'+category)
        except NoSuchElementException:
            count = count+1
            print('工人-开始生产'+category+')
```

### 4. 综合

综合起来，进行一个水井生产操作的函数`cautiousproduce`如下：  

```python
def cautiousproduce(category, pos, check_dir):
    actionsWell = TouchAction(driver)
    actionsWell.tap(None, pos['x'], pos['y']).perform()   # 点击
    time.sleep(0.5)
    
    try:
        # 检查是否正确点击水井，是否识别到下一步图像
        driver.find_element_by_image(check_dir)
        # 点击生产第一项
        actionsProduce = TouchAction(driver)
        actionsProduce.tap(
            None, first_product_pos['x'], first_product_pos['y']).perform()
        time.sleep(0.5)

        # 检查是否需要负责人
        try:
            fuzeren = driver.find_element_by_image(fuzeren_dir)
            actionFuzeren = TouchAction(driver)
            actionFuzeren.tap(
                None, furenren_pos['x'], furenren_pos['y']).perform()
            print('负责人-开始生产'+category)
        except NoSuchElementException:
            count = count+1
            print('工人-开始生产'+category)

    except NoSuchElementException:
        print("Oops~~"+category+"未被正确点击")
```

### 5. 循环调用生产函数  

生产函数有了，剩下的就是对每个水井调用这个生产函数，并每隔三分钟（生产时间）调用一次。综合调用函数为：  

```python
def producewell(pos_list):
    for pos in pos_list:
        cautiousproduce('水井', pos, check_well_dir)
    global timer
    timer = threading.Timer(200, producewell, [pos_list])
    timer.start()
```

运用了计数器。参考：

- [Python3-定时任务四种实现方式](https://blog.51cto.com/huangyg/2367088)
- [16.2.7. Timer Objects](https://docs.python.org/2/library/threading.html#timer-objects)

## 问题

这种方法很原始，点击的都是绝对坐标，不灵活。只能很基本地完成我的需求。有几个很大的缺陷待完善，还有一些问题的原因不明确待改善。  

1. 图像识别时间过长
每点击一个水井都要进行两次图像识别的操作，很耗时间。现在的效果是3分07秒才开始了4个水井的生产，很慢。考虑解决方法：只识别第一个水井是否点击正确，后面的水井使用相对一第一个水井的位置点击。只要第一个水井点击成功了，就不会存在后面的水井点击不上的问题。

2. 不够灵活
都使用的是绝对位置。在第二步移动到水井所在位置中还没有想好代替方法，但是在点击每个水井的位置这一点是，可以采用问题1的相对位置的解决方法。

3. 对交互的特殊节点把握不准确
有的时候会点击到别的地方去，这一点我还没有想明白。有的时候水井不是按照tuple元素的顺序进行生产的，这一点也没有想明白。