# python游戏脚本制作

## vscode+python+appium

1. 首先完成安装的准备工作  
[Getting Started with Python in VS Code](https://code.visualstudio.com/docs/python/python-tutorial)  

2. Installing Appium  
[Getting Started - Appium](http://appium.io/docs/en/about-appium/getting-started/index.html)  
在当前项目的独立环境中安装库Appium，避免与其他包的冲突。  

```
py -3 -m venv .venv
.venv\scripts\activate
python -m pip install Appium-Python-Client
```

3. Driver-Specific Setup  
Requirements: Java8正确安装  
接下来，安装[The UiAutomator2 Driver (for Android apps)](http://appium.io/docs/en/drivers/android-uiautomator2/index.html)。  
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

`重要！！！使用管理者身份运行vscode`

4. Real Device Setup  
打开开发者模式，用USB连接至电脑。  
在vscode terminal运行`adb devices`  
```
PS C:\Users\30544> adb devices
List of devices attached
xxxxxxxxxxxxxxxx        device
```