---
title: "JS 继承方法详解"
subtitle: ""
summary: ""
authors: []
tags: []
categories: []
date: 2020-04-25T21:22:22+08:00
lastmod: 2020-04-25T21:22:22+08:00
featured: false
draft: false

image:
    caption: ""
    focal_point: ""
    preview_only: false

projects: []
---

<!-- TOC -->

-   [new 操作的实现原理](#new-操作的实现原理)
-   [使用原型链进行继承](#使用原型链进行继承)
    -   [instanceof 操作符、isPrototypeOf() 方法](#instanceof-操作符isprototypeof-方法)
    -   [问题](#问题)
-   [借用构造函数](#借用构造函数)
    -   [问题](#问题-1)
-   [组合继承](#组合继承)
    -   [不足：会调用两次超类型构造函数](#不足会调用两次超类型构造函数)
-   [原型式继承](#原型式继承)
-   [寄生式继承](#寄生式继承)
-   [寄生组合式继承](#寄生组合式继承)

<!-- /TOC -->

## new 操作的实现原理

以 SuperType 构造函数和 obj 实例为例。

首先明确 new 操作符的预期结果：

-   `obj` 具有 `SuperType` 所有的实例属性、方法和原型属性、方法
-   `obj.constructor === SuperType`, 返回 true
-   `obj.__proto__ == SuperType.prototype`, 返回 true
-   `obj` 上的原型方法与 `SuperType` 原型上的同一方法在内存上应该一致
-   `new` 操作最后返回了一个对象
-   `obj instanceof SuperType`, 返回 true

先给出 SuperType 构造函数的定义：

```javascript
function SuperType() {
    this.prop = true;
    this.func = function () {};
}

SuperType.prototype.protofunc = function () {};
```

验证上述几个 new 操作符的预期结果是否正确：

```javascript
var obj1 = new SuperType();

console.log(obj1.constructor === SuperType); // true
console.log(obj1.__proto__ == SuperType.prototype); // true
console.log(obj1.protofunc === SuperType.prototype.protofunc); // true
console.log(obj1 instanceof SuperType); // true
```

返回结果都为 true，说明上述预期是正确的。

接下来，开始复现 new 操作符的实现过程。封装在函数`newinstance(Type)`中，其中，Type 为对象类型，即相当于`SuperType`。

```javascript
function newinstance(Type) {
    // 首先创建一个对象实例，该对象包括一个 __proto__ 属性，需要指向 Type.prototype
    var o = {
        __proto__: Type.prototype,
    };

    // 接着，对象实例 o 需要具有 Type 的所有实例属性和原型属性
    // 即，在o对象实例上运行 Type 的构造函数，初始化 Type 的那些属性和方法
    Type.apply(o);

    // 最后，需要返回这个对象实例
    return o;
}
```

对该复现进行验证，验证是否满足上述预期结果。

```javascript
// 首先定义函数printAllProps()，用于输出所有可枚举的实例属性、原型属性
// 不用console.log输出的原因见获得对象属性的方法的博文
function printAllProps(obj) {
    let array = [];
    for (let prop in obj) {
        array.push(prop);
        // 如果要输出属性值，使用：
        // array.push(prop + ':' + obj[prop])
    }
    console.log(array);
}
```

```javascript
var obj = newinstance(SuperType);
printAllProps(obj);
```

输出`['prop', 'func', 'protofunc']`，说明已经满足具有所有实例属性、原型属性的预期。

```javascript
console.log(obj.constructor === SuperType); // true
console.log(obj.__proto__ == SuperType.prototype); // true
console.log(obj.protofunc === SuperType.prototype.protofunc); // true
console.log(obj instanceof SuperType); // true
```

全部输出`true`，说明这一步也验证正确。

至此，new 操作符的重现已经完成。

## 使用原型链进行继承

继承是通过创建`SuperType`的实例，并将该实例赋给`SubType.prototype`实现的。

本质是重写原型对象，用另一个类型的实例所代替。

```javascript
function SuperType() {
    this.prop = true;
    this.func = function () {};
}

SuperType.prototype.protofunc = function () {};

function SubType() {
    this.subprop = true;
    this.subfunc = function () {};
}

SubType.prototype = new SuperType(); // !important

var subobj = new SubType();
```

上述代码中，`SubType.prototype = new SuperType()` 给 SubType 换了一个新的原型，因为是直接重写的。`SubType.prototype`指向的是这个新`new`出来的对象。因此最终结果为，`subobj` 中有一个指向`SubType.prototype`的指针，`SubType.prototype`中有一个指向`SuperType.prototype`的指针。

<div style="text-align: center;">
<img src="https://s1.ax1x.com/2020/04/26/JcGKd1.png" width="700px">
</div>

**使用原型链实现继承时，在继承类型中，不能使用对象字面量创建原型方法或属性。**

例如，不能使用以下字面量添加新方法。本质问题是错误地将原型对象重写替换成了另一个对象字面量。

```javascript
SubType.prototype = new SuperType();

// 错误方法
// SubType.prototype = {
//     newfunc: function () {},
// };

// 正确方法
SubType.prototype.newfunc = function () {};
```

### instanceof 操作符、isPrototypeOf() 方法

**所有引用类型都默认继承了 Object。**

`instanceof`

只要这个构造函数在实例的原型链中出现过，就返回 true。

```javascript
console.log(subobj instanceof SubType); // true
console.log(subobj instanceof SuperType); // true
console.log(subobj instanceof Object); // true
```

`isPrototypeOf()`

只要是在原型链中出现过的原型，都可以算作该原型链所派生的实例的原型，返回 true。

```javascript
console.log(SubType.prototype.isPrototypeOf(subobj)); // true
console.log(SuperType.prototype.isPrototypeOf(subobj)); // true
console.log(Object.prototype.isPrototypeOf(subobj)); // true
```

### 问题

问题一：对于**包含引用类型值**的子类型原型，即超类型实例属性、原型属性中包含引用类型的时候，子类型对象公用这些引用类型内存，**对引用类型值的更改会反映在所有对象上。**

问题二：创建子类型对象时，不能在不影响所有对象实例的情况下向超类型构造函数传递参数。

## 借用构造函数

也称**伪造对象继承**或**经典继承**。

本质是，在子类型构造函数内部调用超类型构造函数，同时使用`call()`和`apply()`方法在新创建的子类型对象上执行构造函数。

可以解决使用原型链实现继承的问题一和问题二。

```javascript
function SuperType(supername) {
    this.name = supername;
    this.arrays = ["1", "2"];
    this.func = function () {};
}

function SubType(subname, supername) {
    SuperType.call(this, supername); // !important
    // 为了确保SuperType构造函数不会重写子类型的属性
    // 应先调用超类型构造函数，再进行子类型属性定义
    this.subname = subname;
}

var subobj1 = new SubType("sub", "super");

subobj1.arrays.push("3");

var subobj2 = new SubType("sub", "super");
var superobj = new SuperType("super");
```

使用可以输出可枚举属性名、属性值的`printAllProps()`函数，验证对引用类型值的更改是否影响到了所有对象实例。

```javascript
printAllProps(subobj1);
// [ 'subname:sub', 'name:super', 'arrays:1,2,3', 'func:function () {}' ]
printAllProps(subobj2);
// [ 'subname:sub', 'name:super', 'arrays:1,2', 'func:function () {}' ]
printAllProps(superobj);
// [ 'name:super', 'arrays:1,2', 'func:function () {}']
```

原因： 使用`call()`方法，即在新要创建的子类型对象上**执行了`SuperType()`函数中定义的对象初始化代码**，每个`SubType`类型实例都具有自己的`arrays`副本。

但这同时也带来了借用构造函数继承的问题。

### 问题

-   方法都在构造函数中定义，无法进行函数复用。

```javascript
console.log(subobj1.func === subobj2.func); // false
```

-   在超类型原型中定义的方法，对子类型是不可见的。

如果给`SuperType`类型添加原型函数`protofunc()`如下：

```javascript
SuperType.prototype.protofunc = function () {};
```

在`SubType`对象实例`subobj1`、`subobj2`中将不会包含这个超类型的原型方法，`printAllProps()`结果将如下：

```javascript
printAllProps(subobj1); // [ 'subname:sub', 'name:super', 'arrays:1,2,3', 'func:function () {}' ]
printAllProps(subobj2); // [ 'subname:sub', 'name:super', 'arrays:1,2', 'func:function () {}' ]
printAllProps(superobj); // [ 'name:super', 'arrays:1,2', 'func:function () {}', 'protofunc:function () {}']
```

可以看到，只有`superobj`中包含了该方法。原因：注意上一段中的**加粗字体：执行了`SuperType()`函数中定义的对象初始化代码**——原型上的属性方法不是定义在`SuperType()`构造函数中的，构造函数中仅包含实例属性方法,因此子类型`SubType`的实例中将只会初始化这些实例属性方法。

导致的结果是，所有类型都只能使用构造函数模式。因此借用构造函数很少单独使用。

## 组合继承

也称**伪经典继承**, 将原型链和借用构造函数组合在一起，融合了二者的优点：

-   使用借用构造函数实现对实例属性的继承
-   使用原型链实现对原型属性的继承

```javascript
// 定义超类型的实例属性方法
function SuperType(supername) {
    this.name = supername;
    this.arrays = ["1", "2"];
}

// 定义超类型的原型属性方法
SuperType.prototype.protofunc = function () {};
SuperType.prototype.protonames = ["a", "b"];

// 子类型开始继承
// 1. 使用借用构造函数实现对实例属性的继承
function SubType(subname, supername) {
    SuperType.call(this, supername); // !important

    this.subname = subname;
}

// 2. 使用原型链实现对原型属性的继承
SubType.prototype = new SuperType(); // !important
SubType.prototype.constructor = SubType; // !important

// 创建子类型对象实例
var subobj1 = new SubType("sub", "super");
var subobj2 = new SubType("sub", "super");
```

虽然组合继承目前被使用得很多，但仍有不足。

### 不足：会调用两次超类型构造函数

无论在什么情况下，使用组合继承都会调用两次超类型构造函数：第一次，在重写`SubType`的原型时；第二次，在子类型`SubType`构造函数内部。如下：

```javascript
function SuperType(supername) {
    this.name = supername;
}

function SubType(subname, supername) {
    SuperType.call(this, supername); // 第二次调用

    this.subname = subname;
}

SubType.prototype = new SuperType(); // 第一次调用
SubType.prototype.constructor = SubType;

var subobj1 = new SubType("sub", "super"); // 第二次调用入口
```

实际过程如下：

-   第一次调用时，`SubType.prototype`中会存在属性`name`，来自于`SuperType`的实例属性。
-   第二次调用时，子类型对象实例上会存在实例属性`name`、`subname`，由于实例属性会屏蔽原型属性中的同名属性，真实使用的是实例属性`name`，而原型属性`name`会被屏蔽。

这也就是组合继承中效率较低的地方。解决方法见**寄生组合式继承**。

## 原型式继承

适用情况：只是想让一个对象与另一个对象保持类似的情况下，添加新的属性和方法。

不涉及到类型（`function`），从头到尾使用的都是对象（`var`）。

```javascript
// 注意这是个对象，而不是类型构造函数
// 使用字面量对象、对象实例都可以
var obj = {
    name: "objname",
    arrays: ["1", "2"],
    func: function () {},
};

// Object.create()方法的两种参数形式
var anotherobj1 = Object.create(obj);
var anotherobj2 = Object.create(obj, {
    name: {
        enumerable: true,
        value: "newname",
    },
});
```

`Object.create()`方法创建一个新对象，使用现有的对象来提供新创建的对象的`__proto__`。

`Object.create()`方法有两种参数形式：

-   第一个参数：一个作为新对象原型的对象

-   第二个参数（可选）：为新对象定义新属性的对象，形式与 `Object.defineProperties()`的第二个参数格式相同

特别注意第二个参数中，属性`name`的那四种数据属性，如果没有指定`enumerable: true`，在使用`for..in`和`printAllProps`时，属性不会被枚举到。

修改`anotherobj1`的`arrays`的值，如下：

```javascript
anotherobj1.arrays.push("3");

printAllProps(anotherobj1); // [ 'name:objname', 'arrays:1,2,3', 'func:function () {}' ]
printAllProps(anotherobj2); // [ 'name:newname', 'arrays:1,2,3', 'func:function () {}' ]
```

可以看到，使用原型式继承，同样也会存在使用原型链进行继承时的引用类型值的问题——包含引用类型值的属性始终会共享相应的值。

可通过以下代码验证：

````javascript
console.log(anotherobj1.arrays === anotherobj2.arrays); // true
console.log(anotherobj1.func === anotherobj2.func); // true```
````

## 寄生式继承

适用情况：在主要考虑的是对象，而不是自定义类型或构造函数时。

```javascript
function createAnother(original) {
    // 该Object()函数不是必须，任何返回一个对象的函数都可以
    var clone = Object(original);

    clone.newfunc = function () {};
    return clone;
}

var original = {
    name: "originalName",
};

var another = createAnother(original);

printAllProps(another); // [ 'name:originalName', 'newfunc:function () {}' ]
```

缺点：与构造函数继承类似地，函数不能复用。

## 寄生组合式继承

优点：高效率——弥补组合继承的不足，只调用一次超类型`SuperType`构造函数，避免了在子类型`SubType`的原型`prototype`上创建不必要的多余的属性和方法。

是目前引用类型最理想的继承范式。

本质：使用寄生式继承来继承超类型的原型（即只继承了超类型的原型属性，并没有在子类型原型上添加超类型实例属性），然后再将结果指定给子类型的原型。即，将组合继承中第一次调用超类型构造函数的地方进行了替换。

```javascript
function SuperType(supername) {
    this.name = supername;
}

SuperType.prototype.protofunc = function () {};

function SubType(subname, supername) {
    this.subname = subname;

    SuperType.call(this, supername);
}

// 用以下方式替换组合继承中的第一次调用
// 即，替换掉 SubType.prototype = new SuperType()

// *************************************
function inheritPrototype(subType, superType) {
    var prototype = superType.prototype; // 创建原型对象
    prototype.constructor = subType; // 增强对象
    subType.prototype = prototype; // 指定原型对象
}

inheritPrototype(SubType, SuperType);
// *************************************

SubType.prototype.constructor = SubType;

var subobj = new SubType("sub", "super");

printAllProps(subobj); // [ 'subname:sub', 'name:super', 'protofunc:function () {}' ]
```

为创建的超类型原型副本`prototype`添加`constructor`属性的目的：弥补因重写而失去的默认的`constructor`属性，让`prototype`副本有正确的`constructor`属性指向。
