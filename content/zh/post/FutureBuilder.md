# Dart异步、Flutter FutureBuilder\<T> class

## 问题描述

情景：通过flutter插件把键值对写入本机储存，从本机获取写入的键值对，页面一加载就把值显示出来。  

问题点：

- 键值对的写入和获取都是异步操作
- 需要在写入且读取后，页面中显示的值应该是最新获取到的值

## 解决方案

### Dart异步——Future，async，await

[官方文档](https://dart.dev/codelabs/async-await)说的很清楚

### Flutter——FutureBuilder\<T\> class

[官方文档](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
>Widget that builds itself based on the latest snapshot of interaction with a Future.  

#### 最关键的两部分

1. 定义一个`Future<T>`类型的变量`_future`。`FutureBuilder<T>`最终呈现出来的内容是根据`_future`的状态的来的。以String类型为例。

```dart
Future<String> _future = ...
```

`_future`的赋值可以有多种方式，例如：

```dart
// 1. 使用Future<T>.delayed(...)
_future = Future<String>.delayed(
  Duration(seconds: 2),
  () => 'Data Loaded',
);

//或者 2. 接收返回类型为Future<T>的函数的返回值
Future<String> func() async {
  return asyncfunc();
}
_future = func();

```

2. 定义一个`FutureBuilder<T>()`的Widget。以String类型为例。

```dart
FutureBuilder<String>(
      future: _future, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = ...   //_future已经ConnectionState.done且成功时需要显示的页面内容
        } else if (snapshot.hasError) {
          child = ...   //_future已经ConnectionState.done但有error时需要显示的页面内容
        } else {
          child = ...   //_future已经ConnectionState.none/waiting时需要显示的页面内容
        }
        return child；
      },
    );
```

>The builder is provided with an [AsyncSnapshot] object whose [AsyncSnapshot.connectionState] property will be one of the following values:
>- [ConnectionState.none]: [future] is null. The [AsyncSnapshot.data] will be set to [initialData], unless a future has previously completed, in which case the previous result persists.
>- [ConnectionState.waiting]: [future] is not null, but has not yet completed. The [AsyncSnapshot.data] will be set to [initialData], unless a future has previously completed, in which case the previous result persists.
>- [ConnectionState.done]: [future] is not null, and has completed. If the future completed successfully, the [AsyncSnapshot.data] will be set to the value to which the future completed. If it completed with an error, [AsyncSnapshot.hasError] will be true and [AsyncSnapshot.error] will be set to the error object.  
> 
>This builder **must only return a widget** and should not have any side effects as it may be called multiple times.

#### 本例实例

基本框架如下：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StorageTestWidget(),
    );
  }
}

class StorageTestWidget extends StatefulWidget {
  StorageTestWidget({Key key}) : super(key: key);

  @override
  _StorageTestWidgetState createState() => _StorageTestWidgetState();
}

class _StorageTestWidgetState extends State<StorageTestWidget> {
  // 定义存取方法...

  // 关键部分1：定义Future<String>类型变量_future...
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      // 关键部分2：定义FutureBuilder<String>()中的内容...

    );
  }
}
```

在`_StorageTestWidgetState class`中具体为：

```dart
class _StorageTestWidgetState extends State<StorageTestWidget> {
  
  final _storage = new FlutterSecureStorage(); // Create storage
  Future<String> _future; // 定义Future<String>类型变量_future
  String _value;  //_value用于保存获取到的值

  // From here...
  // 定义写方法
  Future<void> write() async {
    return await _storage.write(key: 'key', value: 'value');
  }
  //定义返回值是Future<String>的读方法
  Future<String> read() async {
    _value = await _storage.read(key: 'key');
    return _storage.read(key: 'key');
  }
  // To here

  // 将返回类型为Future<String>的函数的返回值赋值给_future
  @override
  void initState() {
    super.initState();
    write();
    _future = read();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = Text(
            _value, //value showed
            style: TextStyle(color: Colors.amber),
          );
        } else if (snapshot.hasError) {
          child = Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Colors.amber),
          );
        } else {
          child = Text(
            'ConnectionState.none/waiting',
            style: TextStyle(color: Colors.amber),
          );
        }
        return Center(
          child: child,
        );
      },
    );
  }
}
```