---
title: JavaScript排序算法
description:
toc: true
authors: []
tags: []
categories: []
series: []
date: 2021-05-12T17:29:57+08:00
lastmod: 2021-05-12T17:29:57+08:00
featuredVideo:
featuredImage:
draft: false
---

## 冒泡排序

### 基础

思路：
- 比较相邻的元素。如果第一个比第二个大，就交换他们两个。
- 对每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。这步做完后，最后的元素会是最大的数。
- 针对所有的元素重复以上的步骤，除了最后一个。
- 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。

[动画演示](https://github.com/MisterBooo/Article#12-%E5%8A%A8%E7%94%BB%E6%BC%94%E7%A4%BA)

```js
function bubbleSort(arr) {
    for (var i = 0; i < arr.length - 1; i++) {
        for (var j = 0; j < arr.length - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                let temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}
```
备注：  
每次都从第一个元素开始比较，所以`i`和`j`都是从`0`开始的。是每次都会在数组最后多一个已经排好了序的元素。  

### 优化

优化方向：
- 每次循环最大的元素都会被放到最后，因此下一次循环可以不再比较这些元素。
- 当某次循环中没有任何元素进行互换时，说明排序已经完成，不必再进行接下来的循环。

```js
function optimizedBubbleSort(arr) {
    for (var i = 0; i < arr.length - 1; i++) {
        let swapped = false;
        for (var j = 0; j < arr.length - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                let temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
                swapped = true;
            }
        }
        if (!swapped) {
            break;
        }
    }
}
```

## 插入排序

- 将第一个待排序序列第一个元素看做一个有序序列，把第二个元素到最后一个元素当成是未排序序列。  
- 从头到尾依次扫描未排序序列，将扫描到的每个元素插入有序序列的适当位置。  

```js
function insertionSort(arr){
    if(arr.length==1){
        return arr;
    }else{
        for(var i=1;i<arr.length;i++){
            for(var j=0;j<i;j++){
                if(arr[j]>=arr[i]){
                    var temp=arr[i];
                    arr.splice(i,1);
                    arr.splice(j,0,temp);
                }
            }
        }   
        return arr;
    }
}
```

## 选择排序

- 在未排序序列中找到最小（大）元素，与未排序序列的第一个元素进行互换。即，放到了已排序序列的末端。
- 再从剩余未排序元素中继续寻找最小（大）元素，与未排序序列的第一个元素进行互换。
- 重复第二步，直到所有元素均排序完毕。

```js
function selectionSort(arr){
    for(var i=0;i<arr.length-1;i++){
        // 记录未排序序列的第一个元素位置
        let currentIndex=i;
        let min=arr[currentIndex];
        let minIndex=currentIndex;
        // 从未排序序列中找到最小元素并记录其位置
        for(var j=i+1;j<arr.length;j++){
            if(arr[j]<min){
                minIndex=j;
                min=arr[j];
            }
        }
        // 交换未排序序列的第一个元素和最小元素
        let temp=arr[minIndex];
        arr[minIndex]=arr[currentIndex];
        arr[currentIndex]=temp;
    }
}
```

## 快速排序

- 随机选取数组中的一个数作为基数`pivot`（可以简单地选择最后一个元素）
- 将比`pivot`大的元素全部移到`pivot`左边，比`pivot`大的元素全部移到`pivot`的右边。以选取最后一个元素为`pivot`为例。
    - 使用下标`i`记录分界线：在`i`之前（包括`i`）的元素的值都小于`pivot`，在`i`之后的元素是大于等于`pivot`元素和未分类元素
    - 使用`j`记录当前检查的未分类元素：在`j`之前的元素都已被分类
    - 即，`i`之前（包括`i`）是比`pivot`小的元素，在`i`和`j`（不包括`j`）之间是比`pivot`大的元素，在`j`之后（包括`j`）是未分类的元素
    - 当`j`的元素小于`pivot`时，这个元素应该被放到比`pivot`小的元素序列的末尾。因此，将`j`处元素与`i+1`处元素进行互换，并且`i++`。此时的`i`又指向了比`pivot`小的元素序列的末尾
    - 当`j`的元素大于等于`pivot`时，这个元素本来就应该在`i`的右边，所以不需要进行更多操作。此时`j++`，继续将下一个元素分类
    - 当`j==r`，即`j`已经扫描到了`pivot`所在位置时，`pivot`之前的元素都已经被分类，大小界限之分是在`i`和`i+1`之间。此时，将`pivot`值与`i+1`处值进行交换，使得`pivot`值的左边的值都比它小，右边的值都比它大。本次分类结束。
- 再对原`pivot`左边的序列和右边的序列都进行分类操作。
- 当需要被分类的序列的长度小于等于1时，分类操作结束。

这是分治的思想。

```js
function quickSort(arr, l, r) {
    if (l >= r) {
        return;
    } else {
        p = partition(arr, l, r);
        // 当原pivot没有被换到第一个或第二个元素处
        // 否则没有左边需要被排序
        if (p > 1) {
            quickSort(arr, l, p - 1);
        }
        // 当原pivot没有被换到倒数第一个或倒数第二个元素处
        // 否则没有右边需要被排序
        if (p < arr.length - 2) {
            quickSort(arr, p + 1, r);

        }
    }
}

function partition(arr, l, r) {
    // 选择最后一个元素作为本次的pivot
    let pivot = arr[r];
    let i = l - 1;
    for (var j = l; j < r; j++) {
        if (arr[j] < pivot) {
            i++;
            let temp = arr[j];
            arr[j] = arr[i];
            arr[i] = temp;
        }
    }
    let temp = pivot;
    arr[r] = arr[i + 1];
    arr[i + 1] = temp;
    return i + 1;
}
```