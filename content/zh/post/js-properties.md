---
title: "Js Properties"
subtitle: ""
summary: ""
authors: []
tags: []
categories: []
date: 2020-04-28T23:22:42+08:00
lastmod: 2020-04-28T23:22:42+08:00
featured: false
draft: false

image:
    caption: ""
    focal_point: ""
    preview_only: false

projects: []
---

<!-- TOC -->

-   [属性类型](#属性类型)
    -   [数据属性](#数据属性)
    -   [访问器属性](#访问器属性)
    -   [读取属性的特性](#读取属性的特性)
    -   [判断是否包含某属性和 in 操作符](#判断是否包含某属性和-in-操作符)
    -   [获取属性](#获取属性)
        -   [for-in——所有枚举属性](#for-in所有枚举属性)
        -   [Object.keys()——可枚举实例属性的字符串数组](#objectkeys可枚举实例属性的字符串数组)
        -   [Object.getOwnPropertyNames()——所有实例属性的字符串数组](#objectgetownpropertynames所有实例属性的字符串数组)
        -   [注意 console.log()](#注意-consolelog)

<!-- /TOC -->

# 属性类型

## 数据属性

`[[Configurable]]`：表示能否通过 delete 删除属性，能否修改属性特性，能否把属性修改为访问器属性。
`[[Enumerable]]`：表示能否通过 for-in 循环返回属性。
`[[Writable]]`：表示是否能修改属性值。
`[[Value]]`：包含这个属性的数据值，默认值为`undefined`。

当直接在对象上定义属性时（即`var Person={name:'Joker'}`），前三个属性都默认为`true`。

**修改属性默认的特性的方法——Object.defineProperty()**

在调用 Object.defineProperty()方法创建一个新的属性时，如果不指定`considerable`，`innumerable`和`writeable`特性的默认值都是`false`。当只是修改一个已定义的属性的特性时，无此限制。

一旦把属性的`considerable`定义为`false`，即，把属性定义为不可配置的，则不能变回可配置了，且修改除`writable`之外的属性都会发生错误。

```
var Person = {}
Object.defineProperty(person, 'name', {
  value: 'Joker',	//如果不指定那三个属性，则都默认为false
})

// 'use strict' //声明为严格模式
person.name = 'rewrite' // 在严格模式下会报错，在非严格模式下下会忽略该语句
```

在非严格模式下，修改已设置`writable`为`false`的属性的值，赋值操作将会被忽略；在严格模式下，将抛出错误。

```
var person = {
  name: 'defaultname',
}

Object.defineProperty(person, 'name', {
  writable: false,		//设置name属性为不可修改
})

person.name = 'rewrite1'			//重写失败，在非严格模式下会忽略，严格模式下会报错
console.log(person1.name)		//defaultname

Object.defineProperty(person1, 'name', {
  writable: true,		//重新设置name属性为可修改
})

person1.name = 'rewrite2'		//可以修改
console.log(person1.name)		//rewrite2
```

## 访问器属性

包含`getter`和`setter`函数。在读取访问器属性时，会调用`get`函数负责返回有效的值；在写入访问期属性时会调用`set`函数并传入新值，负责如何处理数据。
通过`Object.defineProperty()`来定义。
使用访问器属性的常见方式是，设置一个属性的值会导致其他属性发生变化，如下：

```
var book = {
  year: 2000,
  edition: 1,
}

Object.defineProperty(book, 'year', {
  get: function () {
    return this.year
  },
  set: function (newValue) {
    if (newValue >= 2000) {		// 改变year的同时改变edition
      this.edition = Math.floor((newValue - 2000) / 3) + 1
    }
  },
})

book.year = 2001
console.log(book.edition)		// 1

book.year = 2010
console.log(book.edition)		// 4
```

只指定`getter`意味着属性不可写，非严格模式下，尝试写入会被忽略，严格模式下，会抛出错误。
只指定`setter`意味着属性不可读，非严格模式下，会返回`undefined`，严格模式下，会抛出错误。

## 读取属性的特性

```
var person = {}

Object.defineProperty(person, 'name', {
  enumerable: false,
  value: 'name',
})

// 读取属性的特性
var descriptor = Object.getOwnPropertyDescriptor(person, 'name')
console.log(descriptor.enumerable) 		//false
console.log(descriptor.value) 		//name
```

## 判断是否包含某属性和 in 操作符

`.hasOwnProperty()`用于检测一个属性存在于实例中，还是在原型中。当存在于实例中时返回 true。

```
function Person() {}
Person.prototype.name = 'defaultName'		//添加一个原型属性
person.job = 'instanceJob'		//添加一个实例属性
console.log(person.hasOwnProperty('job')) 	// true
console.log(person.hasOwnProperty('name')) 	// false
```

`in操作符`：检测属性是否在实例或原型中，只要包括，就为 true。

```
console.log('name' in person1) 		// true
console.log('job' in person1)		 // true
```

**结合 in 操作符和 hasOwnProperty()可以判断一个属性是实例属性还是原型属性**

```
function hasPrototypeProperty(obj, name) {
  return !obj.hasOwnProperty(name) && name in obj
}

console.log(hasPrototypeProperty(person, 'name')) // true
console.log(hasPrototypeProperty(person, 'job')) // false
```

## 获取属性

### for-in——所有枚举属性

```
// 现在person实例有实例属性name、sayName，原型属性job、sayJob
for (let prop in person1) {
  console.log(prop) //所有实例属性、原型属性
}
```

注意`let prop in person1`中的 prop 的类型是`String`，因此如果要通过`prop`访问`person1`中的属性的值，应使用`person1[pop]`，而不能使用`person1.prop`。

访问 js 对象属性值`[]`和`.`的区别：`[]`中接受的是字符串，如`person1["name"]`，而`.`接受的是直接的属性名，如`person1.name`。

被设置为不可枚举，即 emunerable 为 false 的属性在 for..in 中不会被访问到。

```
function Person() {}
//定义原型属性，其中一个在后面被设置为不可枚举
Person.prototype.protoNameEmun = 'protoNameEmun'
Person.prototype.protoNameUnemun = 'protoNameUnemun'
Person.prototype.protoSayName = function () {}

var person = new Person()

//定义实例属性，其中一个在后面被设置为不可枚举
person.instanceNameEmun = 'instanceNameEmun'
person.instanceNameUnemun = 'instanceNameUnemun'
person.instanceSayName = function () {}

// 定义为不可枚举
Object.defineProperties(person, {
  protoNameUnemun: {
    enumerable: false,
  },
  instanceNameUnemun: {
    enumerable: false,
  },
})

// 输出实例属性、原型属性中所有可枚举的，不可枚举的不输出
// 输出：instanceNameEmun、instanceSayName、protoNameEmun、protoSayName
for (let prop in person) {
  console.log(prop)
}
```

### Object.keys()——可枚举实例属性的字符串数组

`Object.keys()`方法这个方法接收一个对象作为参数，返回一个包含所有**可枚举的实例属性**的**字符串数组**。
同样，对于上述的例子：

```
var key1 = Object.keys(Person.prototype)
var key2 = Object.keys(person)

console.log(key1)	//[ 'protoNameEmun', 'protoNameUnemun', 'protoSayName' ]
console.log(key2)	//[ 'instanceNameEmun', 'instanceSayName' ]
```

### Object.getOwnPropertyNames()——所有实例属性的字符串数组

返回包含所有实例属性（不论是否可以枚举）的字符串数组。

```
var names1 = Object.getOwnPropertyNames(Person.prototype)
var names2 = Object.getOwnPropertyNames(person)

console.log(names1)
// [ 'constructor', 'protoNameEmun', 'protoNameUnemun', 'protoSayName' ]
console.log(names2)
// [  'instanceNameEmun',  'instanceNameUnemun',  'instanceSayName',  'protoNameUnemun' ]
```

注意在 name1 中包含了不可枚举属性 constructor，正说明了“不论是否可以枚举”这一点。

### 注意 console.log()

在 vscode 中 console.log(obj)出来的对象，显示的只有实例属性。
假设`SuperType`中包括实例属性和方法`name, sayName`，包括原型方法`sayProto`，则：

```
// 自定义一个能打印出所有实例属性、原型属性的方法，使用for..in
function printAllProps(obj) {
  let array = []
  for (let prop in obj) {
    array.push(prop)
  }
  console.log(array)
}

var obj = new SuperType('Joker')
console.log(obj)
printAllProps(obj)
```

最后两行在 vscode 中打印出来的内容分别为：
`SuperType { name: 'Joker', sayName: [Function] }`
`[ 'name', 'sayName', 'sayProto' ]`

可以看到，原型上的`sayProto`方法并没有在`console.log`中打印出来。
