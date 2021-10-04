---
title: 安装Opencv4nodejs的坑
description: ''
toc: true
authors:
  - mrq
tags:
  - Appium
  - opencv4nodejs
  - Installation
categories:
  - 脚本开发
series: []
date: '2020-11-12T15:46:05+08:00'
lastmod: '2020-11-12T15:46:05+08:00'
featuredImage: ''
draft: false
---

<!-- TOC -->

- [基本信息](#基本信息)
- [太长不看只要正确步骤](#太长不看只要正确步骤)
- [走过的路&踩过的坑](#走过的路踩过的坑)

<!-- /TOC -->

## 基本信息

平台：Win10  
安装目的：使用Appium提供的[Finding and Interacting with Image Elements](http://appium.io/docs/en/advanced-concepts/image-elements/)功能模块  
各种Packages的版本：

- npm 6.14.8
- node v14.15.0  
- python 3.9.0

其他：Visual Studio 2019（在安装过程中被换成了VS2017）  
之前的操作：在成功将Appium和真机连接之后，运行官方文档提供的sample code后，提示函数依赖opencv4nodejs模块，应运行`npm i -g opencv4nodejs`进行安装，一系列报错开始...

## 太长不看只要正确步骤

1. 卸载VS2019，在[MicroSoft Visual Studio Subscriptions](https://my.visualstudio.com/Downloads?PId=6542)安装VS2017，选择正确的工作负载（“使用C++的桌面开发”、“Visual Studio扩展开发”）和单个组件（“适用于Windows的Git”、“用域CMake和Linux的Visual C++工具”、“用于CMake的Visual C++工具”、“适用于桌面的VC++ 2015.3 v14.00（v140）工具集”）
2. 手动安装cmake，运行`pip install cmake`  
3. 手动安装OpendCV
    - 运行`set OPENCV4NODEJS_DISABLE_AUTOBUILD=1`
    - 在这个命令行接着运行`choco install OpenCV -y -version 4.5.0`
    - 设置系统环境变量
        - `OPENCV_BIN_DIR`:`C:\tools\opencv\build\x64\vc15\bin`
        - `OPENCV_INCLUDE_DIR`:`C:\tools\opencv\build\include`
        - `OPENCV_LIB_DIR`:`C:\tools\opencv\build\x64\vc15\lib`
        - `Path`中新建: `%OPENCV_BIN_DIR%`
    - 重启命令行
4. 更新`npm`和`node`
    - 更新`npm`：`npm install -g npm`
    - 更新`node`：`where node`查看之前的版本安装地址。在[node官网](https://nodejs.org/en/)下载最新版的`.msi`安装包，覆盖安装之前的版本。
5. 运行`npm i -g opencv4nodejs`

## 走过的路&踩过的坑

运行Appium官方文档[Finding and Interacting with Image Elements](http://appium.io/docs/en/advanced-concepts/image-elements/)给的sample code：

```python
driver.update_settings({"getMatchedImageResult": True})
el = driver.find_element_by_image('C:/Users/30544/Desktop/test_cross.png')
el.get_attribute('visual') 
```

报错：`selenium.common.exceptions.WebDriverException: Message: An unknown server-side error occurred while processing the command. Original error: 'opencv4nodejs' module is required to use OpenCV features. Please install it first ('npm i -g opencv4nodejs') and restart Appium.`

其中给了一个opencv4nodejs的[how to install](https://github.com/justadudewhohacks/opencv4nodejs#how-to-install)的链接。
> **Important Note!**  
> opencv4nodejs不能安装在含有空格的路径下。比如，安装在"C:\Program Files\some_dir"下时会报错“error C1083 ...”。在Windows环境下安装时，如果没有Visual Studio，还需要Windows Build Tools来编译OpenCV和opencv4nodejs。  

运行`npm install --save opencv4nodejs`，报错：缺少cmake。
运行`npm install --global windows-build-tools`安装编译OpenCV和opencv4nodejs的Windows Build Tools。（待确认，有VS2017的话需要这一步吗）  
**运行`pip install cmake`之后**，重新尝试运行第一条命令`npm install --save opencv4nodejs`，报错的地方通过了，但提示新错误：  

```
CMake Error at CMakeLists.txt(project):
  Generator

    Visual Studio 15 2017 Win64

  could not find any instance of Visual Studio.
```

本来想的是，把它要找的那个从VS2017变成VS2019，尝试了各种对VS2019的设置、对环境变量的设置、对`mscv`的设置等等，都未解决。使用这个[解决方法](https://www.pianshen.com/article/22701428686/)解决了Visual Studio下载速度很慢的问题。  

部分未能解决的方法：

- [CMake: Visual Studio 15 2017 could not find any instance of Visual Studio](https://stackoverflow.com/questions/51668676/cmake-visual-studio-15-2017-could-not-find-any-instance-of-visual-studio)更改了VS160xxxx环境变量的值——未解决
- [could not find any instance of Visual Studio. (solved) #3472](https://github.com/ycm-core/YouCompleteMe/issues/3472)
- [CMake problem: could not find any instance of Visual Studio](https://stackoverflow.com/questions/60068168/cmake-problem-could-not-find-any-instance-of-visual-studio)  
- 根据[这篇博客](https://www.cnblogs.com/qq2806933146xiaobai/p/13359446.html)对Visual Studio进行了修改——未解决


**解决方法：卸载VS2019， 安装VS2017**  
那干脆直接把VS2019换成VS2017不就好了！它要什么给它什么！

1. **下载**：VS2017的下载入口太隐蔽了，在[MicroSoft Visual Studio Subscriptions](https://my.visualstudio.com/Downloads?PId=6542)中在搜索框中搜索`2017`才会有。下载其中的`Visual Studio Community 2017 (version 15.9)`版本，选项为`mul`, `English`, `EXE`。
2. **问题：无法从"https://aka.ms/vs/15/release/channel"下载通道清单**：单纯的网络问题。几种解决办法：一是到[站长工具](https://tool.chinaz.com/dns/)里的DNS查询输入aka.ms找相对快一点的DNS并修改hosts文件，按[这篇博客](https://www.pianshen.com/article/22701428686/)来就行；二是等一个晚上（真的...），我就是睡了一觉第二天起来试的第一遍就OK了，不敢相信，找个网好的合适时机吧。
2. **选择工作负载和组件**：现在成功把含有VS2017的Visual Studio Installer下载下来了，在选择工作负载和组件的时候要特别注意确保以下被勾选。

- 工作负载：确认“使用C++的桌面开发”、“Visual Studio扩展开发”
- 单个组件：“适用于Windows的Git”、“用域CMake和Linux的Visual C++工具”、“用于CMake的Visual C++工具”、“适用于桌面的VC++ 2015.3 v14.00（v140）工具集”

再次尝试运行`appium`和`python test.py`，原来的问题解决了，但接着出了一个新的问题。官方文档的意思是运行`npm i -g opencv4nodejs`运行了一个自动构建脚本帮你直接安装cmake、opencv的，然而在运行到这些安装时都出了问题。既然这样，何不尝试自己手动先把cmake和opencv安装得没问题了再说呢？  

于是，接下来开始参考官方文档的Installing OpenCV Manually部分。

我们选择了自行设置OpenCV，因此需要设置一个环境变量以阻止自动构建脚本运行： 
 
- **运行`set OPENCV4NODEJS_DISABLE_AUTOBUILD=1`——设置临时环境变量**  
注意，这条命令仅在当前命令行窗口有效，因此不要关闭这个cmd窗口，接下来有关的步骤仍在这个窗口中进行。
- **运行`choco install OpenCV -y -version 4.5.0`——安装OpenCV**  
找不到`choco`命令的话安装一个就行了。4.5.0是当前的OpenCV最新版本，你可以选择自己需要的版本。  
- **设置系统环境变量**  
在通过自己的OpenCV安装来安装opencv4nodejs之前，需要设置以下环境变量：

    - `OPENCV_BIN_DIR`: `C:\tools\opencv\build\x64\vc15\bin`
    - `OPENCV_INCLUDE_DIR`: `C:\tools\opencv\build\include`
    - `OPENCV_LIB_DIR`: `C:\tools\opencv\build\x64\vc15\lib`
    - `Path`中新建: `%OPENCV_BIN_DIR%`

配置第一个环境变量的时候踩了个大坑，在最后才发现，感谢[Issue: #84](https://github.com/justadudewhohacks/opencv4nodejs/issues/84)的回答者们。  

最后记得**重启命令行**。  

**运行`npm i -g opencv4nodejs`** ，这次没有报错了，然而远远还不够...

再次尝试运行`appium`和`python test.py`，运行`appium`的命令行报错`Failed to load global package 'opencv4nodejs': The “path” argument must be of type string. Received type undefined... Error: The specified module could not be found.`  

难道是我的`opencv4nodejs`没有安装好或者找不到吗？以下是对于这个问题我进行的操作：

- 根据[Issue: #11865](https://github.com/appium/appium/issues/11865)中KazuCocoa提供的回答，我尝试运行了`npm list opencv4nodejs`，在我的python虚拟环境中的确是`--empty`，这就很奇怪了
- 查看运行着`appium`的命令行报错，它提供了找不到的地址，但是这个地址打开有opencv4nodejs.node这个文件

解决方法：[Issue: #50](https://github.com/justadudewhohacks/opencv4nodejs/issues/50)中justadudewhohacks的回答启发了我。发现是环境变量配置错误。之前给出的环境变量已经是正确版本了。根据[Issue: #84](https://github.com/justadudewhohacks/opencv4nodejs/issues/84)中marcelogft的回答解决，感谢！

再次尝试运行`appium`和`python test.py`，运行`appium`的命令行报错`The module ... was compiled against a different Node.js version using`.

**解决方法：更新`npm`和`node`至最新版本，rebuild module `opencv4nodejs`**
既然提示版本问题就更新版本。  
更新`npm`和`node`的方法来自[Windows系统下更新npm和node](https://www.jianshu.com/p/0f3fdf6c0d5f)。  
更新`opencv4nodejs`的方法来自[Node - was compiled against a different Node.js version using NODE_MODULE_VERSION 51](https://stackoverflow.com/questions/46384591/node-was-compiled-against-a-different-node-js-version-using-node-module-versio)

- 更新`npm`：使用`npm -v`查看当前版本，使用`npm install -g npm`或`npm install npm@latest -g`升级至最新版本
- 更新`node`：使用`where node`查看之前的版本安装在哪儿。在[node官网](https://nodejs.org/en/)下载最新版的`.msi`安装包，覆盖安装之前的版本即可。这个过程比较长，会打开Windows Powershell，需要重启电脑等等，跟着上面提示的步骤来就可以了，如果运行安装包安装失败应该怎么办也都在输出中写明了。
- rebuild opencv4nodejs：进入到opencv4nodejs的安装路径下，在我这里是进入到`~\AppData\Roaming\npm\node_modules`，运行`npm rebuild opencv4nodejs --update-binary`。因为之前更新了npm和node，这里的binary files也要进行更新。

再次运行`appium`和`python test.py`，识别代码运行成功！！安装完成！！  

希望未来的开发之路顺利！有困难我也能很好很耐心地去解决！