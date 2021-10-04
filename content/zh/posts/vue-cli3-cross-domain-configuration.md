---
title: vue-cli3 跨域配置-含示例
description: ''
toc: true
authors:
  - mrq
tags:
  - Vue
categories: []
series: []
date: '2020-03-12T14:18:48+08:00'
lastmod: '2020-03-12T14:18:48+08:00'
featuredImage: ''
draft: false
---

## 安装axios  

在项目目录下运行：`cnpm install --save axios vue-axios`.

## 示例

以在`main.js`中连接后台为例，其他页面在`axios`前加上`this.`即可。  

### main.js

```javascript
import Vue from 'vue'   //重要！！！
import axios from 'axios'   //重要！！！
import VueAxios from 'vue-axios'    //重要！！！
import App from './App.vue'

Vue.config.productionTip = false

Vue.use(VueAxios, axios)    //重要！！！

new Vue({
  render: h => h(App),
  router
}).$mount('#app')

//************************************重要！！！
axios({ //如果是在其他页面，使用this.axios
  method: 'post',
  url: '/api/user', //  "/api"很重要！！！！
  data: {
    username: 'xxxxx',
    password: 'xxxxx'
  }
})
  .then(function(response) {
    alert(response)
  })
  .catch(function(error) {
    alert(error)
  })
```

`url: '/api/user'`中，`/api`是在`vue.config.js`中配置的（详见后续），`/user`是接口地址，更多可参考[官方文档](https://github.com/axios/axios)。  

### vue.config.js

文件内容应该是这个格式：  

```javascript
module.exports = {
    ...
}
```

修改如下：  

```javascript
module.exports = {
devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:4000',    //API服务器的地址
        ws: true,   //代理websockets
        changeOrigin: true, // cnpm 虚拟的站点需要更管origin
        pathRewrite: {
          //重写路径 比如'/api/aaa/ccc'重写为'/aaa/ccc'
          '^/api': ''
        }
      }
    }
  }
}
```