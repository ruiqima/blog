---
title: JavaScript数组操作方法
description:
toc: true
authors: []
tags: []
categories: []
series: []
date: 2021-04-29T10:22:34+08:00
lastmod: 2021-04-29T10:22:34+08:00
featuredVideo:
featuredImage:
draft: false
---


## 遍历方法

### `for`

```js
for(var i = 0 ; i < array.length ; i++){ ... }
```

### `forEach` 和 `map`

`forEach`  
```js
array1.forEach((currentValue,index,array2) => { ... })
```

`map`  
`map`会将return的值组成一个新数组返回，其他的跟`forEach`一样。
```js
var newMap = array1.map((currentValue,index,array2) => { return...; })
```

以下以`forEach`为例进行说明。[Array.prototype.forEach()](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach#%E5%A6%82%E6%9E%9C%E6%95%B0%E7%BB%84%E5%9C%A8%E8%BF%AD%E4%BB%A3%E6%97%B6%E8%A2%AB%E4%BF%AE%E6%94%B9%E4%BA%86%EF%BC%8C%E5%88%99%E5%85%B6%E4%BB%96%E5%85%83%E7%B4%A0%E4%BC%9A%E8%A2%AB%E8%B7%B3%E8%BF%87%E3%80%82)  

参数：  
`currentValue`：必要，数组中正在处理的当前元素。  
`index`：可选，数组中正在处理的当前元素的索引。  
`array2`：可选，`forEach()`方法正在操作的数组。 

注意：  
- **只操作被初始化了的值**：如`[3,,7]`中，空缺单元不会被调用。  
- **不处理后添加的元素**：遍历范围在第一次`callback`前就已确定，调用`forEach`后添加到数组中的项不会被`callback`访问到。  
- **不能改变原数组基本类型元素的值**：foreach对基本类型的元素拷贝的是值，对引用类型的元素拷贝的是地址。因此`element++`改变不了数值类型数组的值，但`obj.a=1`可以改变引用类型元素的属性值。
- **已初始化的数值可以被中途改变(forEach)**：如果已经存在的值被改变，`callback`调用的值的遍历到他们那一刻的值。  
- **删除元素会导致后面元素前移**：`forEach()`不会在迭代之前创建数组副本：如在迭代过程中删除一个元素会导致所有剩下的项上移一个位置，因此会有元素被跳过。  
- **不能在所有元素都传递给调用函数前终止遍历**：`return`和`break`不能使循环退出。可以通过抛出异常退出。`return`只能终止本次调用。  


### `for...of`

```js
for(variable of iterable){ ... }
```

参数：  
`variable`: 在每次迭代中，将不同属性的值分配给变量。  
`iterable`：被迭代枚举其属性的对象。

可迭代对象有：`Array`，`Map`，`Set`，`String`，`TypedArray`，`arguments`对象等。  

**迭代`String`**  
variable的值是其中每一个字符的值。
```js
let iterable = "boo";

for (let value of iterable) {
  console.log(value);
}
// "b"
// "o"
// "o"
```
**迭代`Map`**

```js
let iterable = new Map([["a", 1], ["b", 2], ["c", 3]]);

for (let entry of iterable) {
  console.log(entry);
}
// ["a", 1]
// ["b", 2]
// ["c", 3]

for (let [key, value] of iterable) {
  console.log(value);
}
// 1
// 2
// 3
```

**迭代`Set`**

```js
let iterable = new Set([1, 1, 2, 2, 3, 3]);

for (let value of iterable) {
  console.log(value);
}
// 1
// 2
// 3
```

**迭代`arguments`对象**

```js
(function() {
  for (let argument of arguments) {
    console.log(argument);
  }
})(1, 2, 3);
// 1
// 2
// 3
```

**关闭迭代器的方法**

由`break`,`throw`,`continue`或`return`终止。  

### 其他

- `for...in`是为遍历对象属性而构建的，不建议与数组一起使用。 [->这里](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Statements/for...in)
- `for...of`与`for...in`的区别：`for...in`以任意顺序迭代对象的可枚举属性，包括自身属性和继承来的属性；`for...of`遍历可迭代对象定义要迭代的数据，不会包括继承来的属性。[->这里](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Statements/for...of)


## 增删改查方法

## `concat(element1, ..., elementN)` - 合并数组

用于合并两个或多个数组。此方法不会更改现有数组，而是**返回一个新数组**。

```js
var arr3 = arr1.concat(arr2);
var arr3 = arr1.concat(arr2, arr0,...);
var arr3 = arr1.concat(value1, value2,...);
```

参数  
`valueN`：数组和/或值，将被合并到一个新的数组中。如果省略了所有`valueN`参数，则`concat`会返回调用此方法的现存数组的一个浅拷贝。

- 浅拷贝，原始数组和新数组都引用相同的对象。如果引用的对象被修改，则更改对于新数组和原始数组都是可见的。
- 数据类型如字符串，数字和布尔（不是String，Number 和 Boolean 对象）：concat将字符串和数字的值复制到新数组中。

**`concat`不会递归到嵌套数组中，只打开一层数组**

```js
var alpha = ['a', 'b', 'c'];
var alphaNumeric = alpha.concat(1, [2, 3]);
console.log(alphaNumeric);
// result in ['a', 'b', 'c', 1, 2, 3]

// 合并嵌套数组（1）
// 传入的参数会被看成一个number和一个array，array会被打开一次
var alpha = ['a', 'b', 'c'];
var alphaNumeric = alpha.concat(1, [2, 3, [4]]);
console.log(alphaNumeric);
// result in ['a', 'b', 'c', 1, 2, 3, [4]]

// 合并嵌套数组（2）
var alpha = ['a', 'b', 'c'];
var alphaNumeric = alpha.concat([1, [2, 3]]);
console.log(alphaNumeric);
// result in ['a', 'b', 'c', 1, [2, 3]]
```

### `join([seperator])` - 将元素连接成字符串

将一个数组（或一个类数组对象）的所有元素连接成一个字符串并**返回这个字符串**。使用`,`分隔符连接。 

```js
var result = elements.join();
var result = elements.join('');
var result = elements.join('-');
```

```js
const elements = ['Fire', 'Air', 'Water'];

console.log(elements.join());
// expected output: "Fire,Air,Water"

console.log(elements.join(''));
// expected output: "FireAirWater"

console.log(elements.join('-'));
// expected output: "Fire-Air-Water"
```

如果`elements`的`length`为0，则返回空字符串。


### `push()` 和 `unshift()`

`push()`将一个或多个元素添加到数组的末尾，并**返回该数组的新长度**。

```js
var length = array.push(element1, ..., elementN);
```

`unshift()`将一个或多个元素添加到数组的开头，并返回该数组的新长度
```js
var length = array.unshift(element1, ..., elementN)
```

### `pop()` 和 `shift()`

`pop()`从数组中删除最后一个元素，并**返回该元素的值**。

```js
var value = array.pop();
```

`shift()`从数组中删除第一个元素，并**返回该元素的值**。

```js
var value = array.shift();
```

### `slice()` - 截取部分数组

**返回一个新的数组对象**，这一对象是一个由 begin 和 end 决定的原数组的**浅拷贝**（包括 begin，不包括end）。**原始数组不会被改变。**

```js
var newArray = array.slice([begin[, end]])
```

参数：  
`begin`：可选，提取起始处的索引，从该索引开始提取原数组元素。  
- 如果省略则从索引为0开始；
- 如果超出原数组的索引范围，则会返回空数组。
- 如果该参数为负数，则表示从原数组中的倒数第几个元素开始提取。

`end`：可选，提取终止处的索引（从 0 开始），在该索引处结束提取原数组元素。包含`begin`，但不包含`end`。
- 如果省略，则 slice 会一直提取到原数组末尾。
- 如果大于数组的长度，slice 也会一直提取到原数组末尾。
- 如果该参数为负数， 则它表示在原数组中的倒数第几个元素结束抽取。

### `splice()` - 删除或替换部分元素

通过删除或替换现有元素或者原地添加新的元素来修改数组,并**返回一个由被删除的元素组成的数组。此方法会改变原数组。**

```js
var deletedElements = array.splice(start, deleteCount, item1,..., itemN)
```

参数：  
`start`；指定修改的开始位置（从0计数）。  
`deleteCount`：表示要移除的数组元素的个数。如果 deleteCount 是 0 或者负数，则不移除元素。这种情况下，至少应添加一个新元素。  
`item`：要添加进数组的元素,从start 位置开始。如果不指定，则 splice() 将只删除数组元素。

## 排序

### `sort()`

```js
array.sort([compareFunction])
```

参数：  
`compareFunction`：用来指定按某种顺序进行排列的函数。如果省略，元素按照转换为的字符串的各个字符的Unicode位点进行排序。
`firstEl`：第一个用于比较的元素。
`secondEl`：第二个用于比较的元素。

默认升序。
比较函数结果<0时，a排在b之前；=0时，相对位置不变；>0时，a排在b之后。

比较函数格式：
```js
function compare(a, b) {
  if (a < b ) {         
    return -1;
  }
  if (a > b ) {
    return 1;
  }
  return 0;
}

// 或

function compareNumbers(a, b) {
  return a - b;
}
```

### `reverse()`

颠倒数组中元素的顺序。返回的是颠倒后的数组，会改变原数组。

```js
array.reverse()
```

## 查找

### `indexOf(element)` 和 `lastIndexOf(element)`

`indexOf(element)`
返回在数组中可以找到一个给定元素的第一个索引，如果不存在，则返回-1。  

```js
arr.indexOf(searchElement[, fromIndex])
```

`lastIndexOf(element)`  
返回指定元素在数组中的最后一个的索引，如果不存在则返回 -1。从数组的后面向前查找，从`fromIndex`处开始。  

```js
arr.lastIndexOf(searchElement[, fromIndex])
```

### `find(func..)`和`findIndex(func..)`

`find(func..)`
返回第一个满足测试函数的元素值。

```js
// Arrow function
arr.find((element[, index[, array]]) => { ... } )

// Callback function
arr.find(callbackFn[, thisArg])
```

```js
const array1 = [5, 12, 8, 130, 44];

const found = array1.find(element => element > 10);

console.log(found);
// expected output: 12
```

`findIndex(func..)`  
返回第一个满足测试函数的元素的`index`。

```js
// Arrow function
arr.findIndex((element[, index[, array]]) => { ... } )

// Callback function
arr.findIndex(callbackFn[, thisArg])
```

```js
const array1 = [5, 12, 8, 130, 44];

const isLargeNumber = (element) => element > 13;

console.log(array1.findIndex(isLargeNumber));
// expected output: 3
```

## 判断元素

### `includes(searchElement)`

`arr.includes(searchElement[, fromIndex])`

判断数组是否包含指定元素。  

### `some(func..)`和`every(func..)`

`every(func..)`  
返回boolean类型值。检测是否数组中的所有元素都满足测试函数。  

```js
// Arrow function
arr.every((element[, index[, array]]) => { ... } )

// Callback function
arr.every(callbackFn[, thisArg])
```

`some(func..)`  
返回boolean类型值。检测数组中是否有元素满足测试函数。 

```js
// Arrow function
arr.some((element[, index[, array]]) => { ... } )

// Callback function
arr.some(callbackFn[, thisArg])
```

## 生成新数组

### `map(func..)`

生成一个由每个元素经处理函数处理后得出的结果按顺序组成的数组。结果中不会删除重复的元素。

```js
// Arrow function
arr.map((element[, index[, array]]) => { ... } )

// Callback function
arr.map(callbackFn[, thisArg])
```

```js
const array1 = [1, 4, 9, 16];

// pass a function to map
const map1 = array1.map(x => x * 2);

console.log(map1);
// expected output: Array [2, 8, 18, 32]
```