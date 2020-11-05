# python游戏脚本制作

## vscode+python+appium

**首先完成安装的准备工作**  
[Getting Started with Python in VS Code](https://code.visualstudio.com/docs/python/python-tutorial)  

**安装Appium**  
[Getting Started - Appium](http://appium.io/docs/en/about-appium/getting-started/index.html)  

```
npm install -g appium
```

**安装特定的驱动**  
Requirements: Java8正确安装  
接下来，安装[The UiAutomator2 Driver (for Android apps)](http://appium.io/docs/en/drivers/android-uiautomator2/index.html)  

- [配置PATH](https://www.java.com/en/download/help/path.html)  
- 配置JAVA_HOME为JDK路径
- 安装[Andriod SDK](https://developer.android.com/studio/index.html)，配置ANDROID_HOME为Android SDK路径。  

```
ANDROID_HOME = C:\Users\30544\AppData\Local\Android\Sdk
```

- 给PATH添加值

```
%ANDROID_HOME%\tools
%ANDROID_HOME%\platform-tools
```  

*重要！！！使用管理者身份运行vscode*

- 连接真机  
打开开发者模式，用USB连接至电脑。（手机打开USB调试，选择传输文件）运行如下：

```
PS C:\Users\30544> adb devices
List of devices attached
xxxxxxxxxxxxxxxx        device
```

**确认安装是否正确**  
安装appium-doctor：`npm install -g appium-doctor`  
若运行`appium-doctor --android`后显示一些信息，则说明安装成功。  

**选择一个Appium Client**  
https://github.com/appium/python-client  
在当前项目的独立环境中安装库Appium，避免与其他包的冲突。  

```
py -3 -m venv .venv
.venv\scripts\activate
python -m pip install Appium-Python-Client
```

**启动Appium**
运行`appium`，会呈现出一些信息。这个port information很重要，即localhost:portnumber，一般默认为4723.

**一个例子**  
在当前项目中新建hello.py文件，初始代码为：  

```
from appium import webdriver

desired_caps = {}
desired_caps['platformName'] = 'Android'    //platformName
desired_caps['platformVersion'] = '10.0'    //platformVersion
desired_caps['deviceName'] = 'xxxxxxxxxxxxxxxx' //deviceName
desired_caps['appPackage'] = 'com.huawei.calculator'  //appPackage
desired_caps['appActivity'] = '.Calculator'    //appActivity
// desired_caps['newCommandTimeout']= '1000000'

driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)
```
`platformName`：真机是什么平台的，Android/IOS
`platformVersion`：平台版本号
`deviceName`：运行`appium`时的结果，步骤真机配置中的xxxxxxxxxxxxxxxx  
`appPackage`：目录`C:\Users\30544\AppData\Local\Android\Sdk\tools\bin`下有一个批处理文件`uiautomatorviewer.bat`，点击运行。确保真机可以被ADB检测到，打开想要进行操作的app，点击左上角的两个Screenshot按钮中的一个。

1.png

注意，这相当于是截图，不会跟随你手机屏幕显示的内容进行变化，所以当切换想查看的界面时，要重新点击Screenshot。以华为计算器为例，打开计算器，点击Screenshot，鼠标移动到按键“4”的上方，呈现出的信息如图所示。`package`即为`appPackage`的值。

2.png

`appActivity`：这个值要通过运行cmd命令获取。运行`adb shell activity activities | findstr "ResumedActivity"`，结果为：

```
ResumedActivity: ActivityRecord{3e87b44 u0 com.huawei.calculator/.Calculator t2278}
```

在com.huawei.calculator的斜杠后面就是appActivity的值，为`.Calculator`。

`newCommandTimeout`：这个是可选的，当这些操作执行完后过一段时间，程序会自动退出。如果不希望很快就自动退出，可以设置为一个较大的值。

**另一个例子**  
这个例子用来实现打开计算器，依次按“1”、“+”、“2”、“=”。  
前面的配置跟上一个例子是一样的。现在要另外做的是：找到要点击的按键、将对这四个按键的点击操作一次放到动作链中、执行动作链。  
获取元素有[很多方法](http://appium.io/docs/en/commands/element/find-element/)，这里采用通过id获取元素的方式。  
id在刚刚的批处理程序截图中`resource_id`中有，是`digit_1`。 

```
el_1 = driver.find_element_by_id('digit_1')
el_2 = driver.find_element_by_id('digit_2')
el_add = driver.find_element_by_id('op_add')
el_eq = driver.find_element_by_id('eq')
```

将这个四个元素的点击操作加入`actions`。  

```
actions = TouchAction(driver)
actions.tap(el_1)
actions.tap(el_add)
actions.tap(el_2)
actions.tap(el_eq)
```

执行动作链。

```
actions.perform()
```