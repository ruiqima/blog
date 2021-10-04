---
title: script加载方式以及元素属性
description: ''
toc: true
authors:
  - mrq
tags:
  - JavaScript
categories:
  - JavaScript进阶之路
series: []
date: '2020-04-23T15:05:39+08:00'
lastmod: '2020-04-23T15:05:39+08:00'
featuredImage: ''
draft: false

---

## 解释器对&#60;script&#62;中内容的加载方式  

**解析嵌入式JavaScript代码**：在解释器对`<script>`;元素内部的所有代码求值完毕之前，页面中的其余内容都不会被浏览器加载或显示。  
**解析外部JavaScript文件**：在解析外部文件，包括下载该文件时，页面的处理也会暂时停止。  
只要不存在`defer`或`async`属性，浏览器都会按照`<script>`元素在页面中出现的先后顺序对它们一次进行解析。  

而这种加载方式可能会导致问题，**在脚本加载和执行的过程中，会阻塞后续的DOM渲染**。例如，在页面中引用第三方脚本时，如果第三方服务商出现了一些小问题，比如延迟之类的，就会使得页面白屏。  

解决方案：使用`<script>`元素的`async`或`defer`属性。  

## script标签的位置  

**传统做法放在&#60;head&#62;元素中（不推荐）**  
但这意味着必须等到全部JavaScript代码都被下载解析和执行完后，才能开始呈现页面的内容，浏览器在遇到`<body>`标签时才开始呈现内容。  

而对于那些需要加载很多JavaScript代码的页面来说，则会导致浏览器再呈现页面时出现明显的延迟，而在延迟期间的浏览器窗口会是一片空白。  

**放在&#60;body&#62;元素中页面内容的后面**  

```javascript
<body>
    <!---页面内容-->
    <script type="text/javascript" src="example1.js"></script>
    <script type="text/javascript" src="example2.js"></script>
</body>
```

## 延迟脚本和异步脚本

### 延迟脚本：defer属性  

`defer`属性用于表明脚本在执行时不会影响页面的构造，即，表明脚本会被延迟到整个页面都解析完毕后再运行。  

```javascript
<script type="text/javascript" defer="defer" src="example.js"></script>
```

对于脚本执行的先后顺序，HTML5规范和实际执行过程中不一样：  

- HTML5规范要求脚本按照它们出现的先后顺序执行。第一个延迟脚本会先于第二个延迟脚本执行，且所有延迟脚本都会先于`DOMContentLoaded`事件执行。
- 实际执行过程中，延迟脚本并不一定会按顺序执行，也不一定会在`DOMContentLoaded`事件触发前执行。  

因此，最好只包含一个延迟脚本。  

### 异步脚本：async属性

`async`属性只使用与外部脚本文件。`async`的目的是为了不让页面等待脚本下载和执行，从而异步加载页面其他内容。  

```javascript
<script type="text/javascript" async src="example.js"></script>
```

但是，标记为`async`的脚本并不保证按照指定他们的先后顺序执行。也正因为这一点，确保要加载的脚本间互不依赖。也由于是异步加载页面其他内容，异步脚本再加载期间也最好不要修改DOM。  