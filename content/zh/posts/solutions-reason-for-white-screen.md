---
title: 导致页面白屏的原因
description: ''
toc: true
authors:
  - mrq
tags:
  - Frontend
categories: []
series: []
date: ' 2020-04-20T15:05:27+08:00'
lastmod: ' 2020-04-20T15:05:27+08:00'
featuredImage: ''
draft: false

---

## script脚本阻塞DOM渲染

直接使用`<script>`，html会按照顺序来加载并执行脚本。  
在脚本加载和执行的过程中，会阻塞后续的DOM渲染。  
例如：在页面中引用第三方脚本时，如果第三方服务商出现了一些小问题，比如延迟之类的，就会使得页面白屏。  

**解决方案**  
使用`<script>`元素的`async`或`defer`属性。  
***async***：表示应立即下载脚本，但不妨碍页面中的其他操作。仅对外部脚本文件有效。  
***defer***：表示脚本可以延迟到文档完全被解析和显示之后再执行。仅对外部脚本文件有效。  