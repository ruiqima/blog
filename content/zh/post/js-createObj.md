---
title: "JS 创建对象模式"
subtitle: ""
summary: ""
authors: []
tags: []
categories: ["JavaScript进阶之路"]
date: 2020-04-25T17:06:58+08:00
lastmod: 2020-04-25T17:06:58+08:00
featured: false
draft: false

image:
    caption: ""
    focal_point: ""
    preview_only: false

projects: []
---

<!-- TOC -->

-   [工厂模式](#工厂模式)
-   [构造函数模式](#构造函数模式)
-   [原型模式](#原型模式)
    -   [原型与原型链](#原型与原型链)
    -   [构造函数、原型和实例的关系](#构造函数原型和实例的关系)
    -   [原型的动态性](#原型的动态性)
    -   [原型模式的缺点](#原型模式的缺点)
-   [组合使用构造函数模式和原型模式（用得最多）](#组合使用构造函数模式和原型模式用得最多)
-   [动态原型模式](#动态原型模式)
-   [寄生构造函数模式](#寄生构造函数模式)
-   [稳妥构造函数模式](#稳妥构造函数模式)

<!-- /TOC -->

## 工厂模式

本质：用函数封装创建对象的细节。  
特点：

-   显式创建了对象（如`Object`）
-   不使用`new`
-   有`return`语句
-   缺点：没有解决对象识别问题，即怎样知道一个对象的类型。（如代码倒数第二行的`false`）

```javascript
function createPerson(name, age) {
    var o = new Object();

    o.name = name;
    o.age = age;
    o.sayName = function () {};

    return o;
}

var person = createPerson("Joker", 23);

console.log(person instanceof createPerson); // false
console.log(person.__proto__); //{}
```

## 构造函数模式

特点：

-   没有显式创建对象
-   直接将属性和方法赋给了`this`对象
-   没有`return`语句
-   创建新实例需使用`new`操作符
-   可以解决工厂模式不能确定对象类型的问题
-   缺点：会导致不同实例中的方法不是同一个`Function`实例，导致不同的作用域链和标识符解析。（同一个名为`sayName` 的方法在不同实例中是不同 Function 对象）（如代码倒数第三行的`false`）

```javascript
function Person(name, age) {
    this.name = name;
    this.age = age;
    this.friends = ["1", "2"];
    this.sayName = function () {};
}

var person1 = new Person("Joker", 23);
var person2 = new Person("Joker1", 24);

person1.friends.push("3");
console.log(person1.friends); //[ '1', '2', '3' ]
console.log(person2.friends); //[ '1', '2' ]
console.log(person1.sayName === person2.sayName); //false

console.log(person1 instanceof Person); //true
console.log(person1.__proto__); //Person {}
```

## 原型模式

### 原型与原型链

我们创建的每个函数都有一个 prototype 属性，即原型属性。prototype 属性是一个指针，指向一个包含可以由特定类型的所有实例共享的属性和方法的对象。

prototype 就是通过调用构造函数而创建的那个对象实例的原型对象，使用原型对象的好处是可以让所有对象实例共享包含的属性和方法。

### 构造函数、原型和实例的关系

每个构造函数都有一个原型对象，原型对象都包含一个指向构造函数的指针，而实例都包含一个指向原型对象的内部指针。

**什么叫让所有对象实例共享包含的属性和方法**

直接在对象实例上定义方法的缺点是，不同对象实例中包含的方法不是同一个 Function 实例——在 ECMAScript 中的函数是对象，每定义一个函数，就是实例化一个对象。以这种方式创建函数，会导致不同的作用域链和标识符解析。

而使用原型对象则可以做到让所有对象实例共享包含的属性和方法。

```javascript
function Person() {}
Person.prototype={
    name :  'defaultName',
    age = 'defaultAge'
}
Person.prototype.sayName = function () {
  console.log(this.name)
}

var person1 = new Person()
var person2 = new Person()

//使用原型对象的好处，可以让所有对象实例共享它所包含的属性和方法
console.log(person1.sayName == person2.sayName) // true
```

**原型链**

[^_^]: 以下是注释

    ```mermaid
    graph BT
    person-->|__proto__|Person.prototype
    Person.prototype-->|constructor|Person
    Person-->|prototype|Person.prototype
    Person.prototype-->|__proto__|Object.prototype
    Object.prototype-->|constructor|Object
    Object-->|prototype|Object.prototype
    Object.prototype-->|__proto__|null
    ```

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/04/24/JBhO5F.png" alt="原型链图片" width="500"/>
</div>

**有关方法**

`ObjectName.prototype.isPrototypeOf(instanceName)`
实例 instanceName 的原型是否是 ObjectName.prototype。

`Object.getPrototypeOf(instanceName)`
获取实例 instanceName 的原型的名称。

```javascript
var person = new Person();
console.log(Person.prototype.isPrototypeOf(person)); // true
console.log(Object.getPrototypeOf(person) == Person.prototype); //true
```

### 原型的动态性

对原型对象的修改会及时体现在实例上，就算在实例创建以后。

```javascript
var person1 = new Person();
Person.prototype.sayHi = function () {
    console.log("sayHi");
};
person1.sayHi(); // sayHi
```

但是，如果重写整个原型对象，情况则会不一样。

```javascript
var person2 = new Person();
Person.prototype = {
    sayName: function () {
        console.log("sayName");
    },
};
person2.sayName(); // person2.sayName is not a function
```

原因如下图，初始化 person2 时与原来的 Person.prototype 有联系，重写了 Person.prototype 之后相当于新 new 了一个出来，与原来那个已经不是同一个了。

[^_^]:
    ```mermaid
    graph LR
    Person-->Person_Prototype
    Person-->New_Person_Prototype
    person2-->Person_Prototype
    　　
    ```

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/04/25/JyCzT0.png" alt="原型链图片" width="700"/>
</div>

在此之后，如果再新建对象实例，则会与新 new 的 prototype 建立联系，会拥有新 prototype 上面的属性，但不会拥有原 prototype 上的属性。

```javascript
var person3 = new Person();
console.log(person3.name); // undefined
person3.sayName(); // sayName
```

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/04/25/JyCxwq.png" alt="原型链图片" width="700"/>
</div>

### 原型模式的缺点

本质是原型中的所有属性被很多实例共享的问题。对于是基本类型值的属性不要紧，但是对于引用类型属性，更改一个实例上的该属性值，会导致所有实例中的该属性值都被更改——因为改引用类型值是存在于对象原型 Prototype 上的，而不是对象实例中。

```javascript
function Person() {}
Person.prototype = {
    arrays: ["1", "2"],
};
var person1 = new Person();
var person2 = new Person();
person1.arrays.push("3");

console.log(person1.arrays); // [ '1', '2', '3' ]
console.log(person2.arrays); // [ '1', '2', '3' ]
```

因此，很少单独使用原型模式。

## 组合使用构造函数模式和原型模式（用得最多）

为解决上述问题，组合使用构造函数模式与原型模式。

优点：构造函数模式用于定义实例，原型模式用于定义方法和共享的属性。每个实例都会有自己的一份实例属性的副本，又共享着对方法的引用，最大限度的节省了内存。这种混成模式还支持向构造函数传递参数。

```javascript
// 1. 构造函数模式
function Person(name, age) {
    this.name = name;
    this.age = age;
    this.friends = ["A", "B"];
}

// 2. 原型模式
Person.prototype = {
    constructor: Person, //会让constructor变为可枚举的属性
    sayName: function () {
        console.log(this.name);
    },
};

var person3 = new Person("Joker", 23);
var person4 = new Person("Rekoj", 32);

// 共用方法（通过原型定义）
// 但引用类型的属性不会相互干扰（通过构造函数模式定义）
person3.friends.push("fox");
console.log(person3.friends); // [ 'A', 'B', 'fox' ]
console.log(person4.friends); // [ 'A', 'B' ]
console.log(person3.friends === person4.friends); // false
console.log(person3.sayName === person4.sayName); //true
```

其中，为`Person.prototype`添加`constructor`属性的目的：弥补因重写原型而失去的默认的`constructor`属性。添加`constructor`属性的操作会使`constructor`变为可枚举的属性。

## 动态原型模式

原理跟组合使用构造函数模式和原型模式一样，但是把原型定义操作封装在了构造函数中。本质是通过构造函数初始化原型。

在构造函数中的 if 语句是为了判断是否在该对象上定义了`sayName`的方法——也就是说，当`Person`的原型上还未定义`sayName`方法时（如第一次执行`new Person(...)`语句时），`if`语句会执行，即进行原型的初始化；一旦 Person 的原型被初始化过（如第二次执行`new Person(...)`语句时），根据原型的动态性，`sayName`已被定义，不会再进入 if 语句中。

```javascript
function Person(name, age, job) {
    this.name = name;
    this.age = age;
    this.friends = ["A", "B"];

    if (typeof this.sayName != "function") {
        // !important
        Person.prototype.sayName = function () {
            console.log(this.name);
        };
    }
}

var person3 = new Person("Joker", 23, "tricker");
var person4 = new Person("Rekoj", 32, "rekcirt");

person3.friends.push("fox");
console.log(person3.friends);
console.log(person4.friends);
console.log(person3.friends === person4.friends);
console.log(person3.sayName === person4.sayName);
```

且如果原型上需要定义多个方法和属性，也只需要一个`if`语句判断，选其中一个属性或方法判断即可。

要特别注意的是，`if`语句中的`Person.prototype`不能使用对象字面量重写原型，原因之前说过，会切断现有实例与新原型之间的联系。

## 寄生构造函数模式

使用情况：如，想创建一个具有额外方法的特殊数组，由于不能直接写修改 Array 构造函数，因此可以使用这个模式。

特点：

-   不能依赖 instanceof 操作符来确定对象类型（如下面的例子，array 是 instanceof Array，但不是 SpecialArray）
-   使用`new`操作符

```javascript
function SpecialArray() {
    var values = new Array();
    values.push.apply(values, arguments);
    values.toSpecialString = function () {
        return this.join("+");
    };
    return values;
}

var array = new SpecialArray("a", "b", "c");
console.log(array.toSpecialString()); // a+b+c

console.log(array instanceof SpecialArray); // false
console.log(array.__proto__); // []
console.log(array instanceof Array); // true
```

## 稳妥构造函数模式

特点：

-   适用于一些安全的环境中（如会禁止使用`this`和`new`），或防止数据被其它应用程序改动（如只允许通过方法访问到属性值）
-   新创建对象的实例方法不使用`this`
-   不适用`new`操作符
-   不能依赖 instanceof 操作符来确定对象类型（跟寄生构造函数模式类似）

```javascript
function Person(name, age) {
    var o = new Object();

    o.sayName = function () {
        console.log(name);
    };
    return o;
}

var person = Person("Joker", 23);
console.log(person.name); //undefined
person.sayName(); //Joker
```
