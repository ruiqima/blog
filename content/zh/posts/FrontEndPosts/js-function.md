---
title: "JavaScript函数的定义及使用"
subtitle: ""
summary: ""
authors: [mrq]
tags: [JavaScript]
categories: ["JavaScript进阶之路"]
date: 2020-04-27T20:34:45+08:00
lastmod: 2020-04-27T20:34:45+08:00
featured: false
draft: false

image:
    caption: ""
    focal_point: ""
    preview_only: false

projects: []
---

<!-- TOC -->

- [定义函数](#定义函数)
    - [函数声明](#函数声明)
    - [函数表达式](#函数表达式)
- [函数的使用](#函数的使用)
    - [作为其他函数参数](#作为其他函数参数)
    - [作为其他函数的返回值](#作为其他函数的返回值)
    - [递归](#递归)
    - [执行环境、作用域链、活动对象](#执行环境作用域链活动对象)
    - [闭包](#闭包)

<!-- /TOC -->

## 定义函数

定义函数有两种方式，总结这两种定义函数的特性和适应情况如下。

### 函数声明

```javascript
function func() {}
```

特征：

-   函数声明提升（可以把函数声明放在调用它的语句后面）

### 函数表达式

```javascript
var func = function () {};
```

特征：

-   此时创建的是匿名函数
-   必须在使用前赋值（即不存在提升）

适合使用 _函数表达式_ 的情况：

-   根据`condition`赋值不同函数（如`if-else`）

```javascript
var condition_func;
var condition = false;

if (condition) {
    condition_func = function () {
        console.log("in if");
    };
} else {
    condition_func = function () {
        console.log("in else");
    };
}

condition_func(); // in else
```

## 函数的使用

### 作为其他函数参数

逆序排列数组，将`reverse`函数作为参数传递给`sort()`。

```javascript
function reverse(a, b) {
    return b - a;
}

var arr = new Array("10", "5", "40");
console.log(arr.sort(reverse));
```

输出结果为，验证正确：

```javascript
["40", "10", "5"];
```

### 作为其他函数的返回值

对象数组，按照其中某一属性值排序。

```javascript
function sortByProp(propertyname) {
    return function (obj1, obj2) {
        let val1 = obj1[propertyname];
        let val2 = obj2[propertyname];

        return val1 - val2;
    };
}

var persons = [
    {
        name: "Jake",
        age: 28,
    },
    {
        name: "Maria",
        age: 23,
    },
    {
        name: "Jimmy",
        age: 15,
    },
];
console.log(persons.sort(sortByProp("age")));
```

输出结果为，验证正确：

```javascript
[
    { name: "Jimmy", age: 15 },
    { name: "Maria", age: 23 },
    { name: "Jake", age: 28 },
];
```

### 递归

一般递归形式如下：

```javascript
function func() {
    func();
}
```

但此时存在一个可能的问题，如果想把函数保存在一个变量中，通过变量调用时就会出现问题。

```javascript
function func() {
    // do sth ...
    func();
}

var anotherfunc = func;
func = null; // 只有anotherfunc一个指向函数的引用
anotherfunc(); // 出错
```

原因：在执行函数时会包括执行名为`func`的函数，但此时`func`已被解引用。

解决方案：使用`arguments.callee`代替函数名——一个指向正在执行的函数的指针，适合于实现函数的递归调用。

```javascript
function func() {
    // do sth ...
    arguments.callee(); // ! important
}

var anotherfunc = func;
func = null;
anotherfunc();
```

### 执行环境、作用域链、活动对象

**变量对象和活动对象**

变量对象（VO）：与执行上下文概念对应，包含了执行上下文中的所有变量、函数以及当前执行上下文函数的参数列表。

活动对象（AO）：进入到执行阶段之后，变量对象转变成了活动对象。

**作用域链**

本质上是一个指向变量对象的指针列表，只引用但不实际包含变量对象。

在函数中访问一个变量时，会从作用域中搜索具有相应名字的变量

**作用域链是怎么创建的**

在函数被创建时，首先创建一个执行环境、以及相应的作用域链。再使用`arguments`和其他命名参数的值来初始化函数的活动对象。

在函数执行过程中，需要在作用域中查找变量。从作用域链链首开始寻找。

**先回顾一下变量提升、函数声明提升**

变量提升：变量的定义提升（注意块级作用域中，用`let`声明的变量不存在变量提升），但赋值不提升。

```javascript
console.log(a); // undefined
var a = 10;
```

函数声明提升

```javascript
f(); // doing sth...
function f() {
    console.log("doing sth...");
}
```

综合来看，可以得知一下代码会输出如下结果 _（如果不知道为什么，请先回顾一下变量提升和函数声明提升的内容）_：

```javascript
a(); // function

var a = function () {
    console.log("anonymous");
};
function a() {
    console.log("function");
}
```

```javascript
var a = function () {
    console.log("anonymous");
};
function a() {
    console.log("function");
}

a(); // anonymous
```

```javascript
var a = "global a"; // 语句1

function b() {
    console.log("global b()");
}

function c(a, b) {
    arguments[1](); // 输出：inner b()，可以看出此处的b已经是inner funciton
    b(); // inner b()

    console.log(a); // global a，语句2
    var a = "inner a";
    function b() {
        console.log("inner b()");
    }
}
c(a, b); // 每步骤输出见上
b(); // global b()
```

有以下关键点：

-   运行到 _语句 1_ 但还未执行时：

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/04/28/J5uvgf.png" width="350px" alt="global VO">
</div>

-   进入函数 c 的执行时，内部函数 b 因为函数声明提升，会将参数 b 的值改为指向这个内部函数 b 。

**作用域链是怎样创建的**

在创建`c()`函数时，会创建一个预先包含全局变量对象的作用域链，该作用域链会被保存在内部的`[[Scope]]`属性中。

当调用`c()`函数时，会为函数创建一个执行环境，然后复制函数的`[[Scope]]`属性中的对象构建起执行环境的作用域链。

然后，又有一个活动对象被创建，并推入执行环境作用域链的前端。

### 闭包

首先要明确**闭包**和**匿名函数**的概念。闭包是指有权访问另一个函数作用域中的变量的函数。_（划重点：要访问另一个函数作用域中的变量）_

**创建方式**

常见方式就是在一个函数内部创建另一个函数。
