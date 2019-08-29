# 动态选项列表及多叉树数据维护

最近项目遇到一个比较复杂的数据处理问题，实现如下效果，其实也不是复杂，而是很绕逻辑很容易搞错。故写下此篇文章记录解析方法和过程，供各位参考。

本文的思路是利用多叉树遍历、映射等方法实现数据的重组和维护。

## 举个栗子

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/ania.gif)

突然有一天外星人到访地区，我们成立了宇宙居委会，要对地球上所有高等智慧生物做登记，这时候要开发一款App来采集这些生物的信息，采集的信息如下：

*1. 生命形式

```
- 人类
	- 性别
		- 男
		- 女 
	- 飞行驾照
		- 有
		- 无
- 外星人
```

*2. 住址

```
- 地球
	- 国家
		- 中国
			- 省份 
				- 云南
				- 新疆
				- 北京
				- 浙江
		- 日本
			- 地区
				- 陆地
				- 海上
		- 美国
- 赛博坦
```

从中我们不难看出有两种数据类型：**问题（Question）** 和 选项 **（Option）**。选项里面是包含问题的，比如只要选择了人类就要回答`性别`和`飞行驾照`的问题，而外星人没有性别所以不用回答。

那么赛博坦的后台开发人员给我们下面的数据结构让app生成一个动态的选择表单：

```
[
    {
        "question": "生命形式",
        "id": "FORM001",
        "options": [
            {
                "name": "人类",
                "id": "OP001",
                "children": [
                    {
                        "question": "性别",
                        "id": "FORM002",
                        "options": [
                            {
                                "name": "男",
                                "id": "OP002",
                                "children": []
                            },
                            {
                                "name": "女",
                                "id": "OP003",
                                "children": []
                            }
                        ]
                    },
                    {
                        "question": "是否有飞行驾照",
                        "id": "FORM003",
                        "options": [
                            {
                                "name": "无",
                                "id": "OP004",
                                "children": []
                            },
                            {
                                "name": "有",
                                "id": "OP005",
                                "children": []
                            }
                        ]
                    }
                ]
            },
            {
                "name": "外星人",
                "id": "OP006",
                "children": []
            }
        ]
    },
    {
        "question": "住址",
        "id": "FORM004",
        "options": [
            {
                "name": "赛博坦星球",
                "id": "OP007",
                "children": []
            },
            {
                "name": "地球",
                "id": "OP008",
                "children": [
                    {
                        "question": "国家",
                        "id": "FORM005",
                        "options": [
                            {
                                "name": "中国",
                                "id": "OP009",
                                "children": [
                                    {
                                        "question": "省份",
                                        "id": "FORM006",
                                        "options": [
                                            {
                                                "name": "云南",
                                                "id": "OP010",
                                                "children": []
                                            },
                                            {
                                                "name": "北京",
                                                "id": "OP011",
                                                "children": []
                                            },
                                            {
                                                "name": "新疆",
                                                "id": "OP012",
                                                "children": []
                                            },
                                            {
                                                "name": "浙江",
                                                "id": "OP013",
                                                "children": []
                                            },
                                        ]
                                    }
                                ]
                            },
                            {
                                "name": "日本",
                                "id": "OP014",
                                "children": [
                                    {
                                        "question": "地区",
                                        "id": "FORM007",
                                        "options": [
                                            {
                                                "name": "陆地",
                                                "id": "OP015",
                                                "children": []
                                            },
                                            {
                                                "name": "海上",
                                                "id": "OP016",
                                                "children": []
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "name": "美国",
                                "id": "OP017",
                                "children": []
                            }
                        ]
                    }
                ]
            }
        ]
    }
]
```

## 数据分析

我们可以用多叉树来理解这个数据，无论问题还是选项都是可以作为节点。首先json数据是个数组，顶层自然就是整个json，数组里面每个元素都是节点，第二层这样就有两个节点，以此类推，得到如下的多叉树结构。

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/default3p.png)

### 每一个问题只能选一个选项，选项下包含的问题是必须显示的

这就意味着每条到达末端的路径上面的节点就是我们所要显示的问题和选项。

首先，json顶层选项包含两个问题，**选项的问题是必须显示的**，所以激活两个节点：

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/beta.png)

先看第一个问题，生命形式，它有两个选项，**只能选一个选项**，默认我们选中第一项，所以激活人类节点。人类是个选项，因此性别和飞行驾照是必须显示的，默认选中各自的第一个选项。此时到达树的末端，返回最近的上层问题，也就是第二层，下一个问题是住址，住址有两个选项，**只能选一个选项**，默认选中第一项赛博坦星球，此时所有选中选项和问题都被遍历了：

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/x3p.png)

### Bingo！！！

所有可遍历的路径都走完了，我们回过头来看有以下3条激活路径：

```
x - 生命形式（人类）- 性别（男）

x - 生命形式（人类）- 驾照（有）

x - 住址（赛博坦星球）
```

寻找激活路径上的问题，所以我们要显示 **4** 个问题：`生命形式`、`性别`、`驾照`、`住址`，每个问题对应的选项也显示，高亮选中的选项。

### 用户开始点击！

到了最激动人心的时候，用户切换为外星人选项，这时候这个选项的激活路径要重新生成。使用上面的方法，遍历一遍下层节点，得到如下激活路径。

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/x2p.png)

整理一遍，也就是新的 **2** 条激活路径：

```
x - 生命形式（外星人）

x - 住址（赛博坦星球）
```

激活路径上只有 **2** 个问题要显示：`生命形式`、`住址`。

## 代码实现

有了上面的分析，我们可以很容易的就得到需要用户选择的问题和选项，那么具体体现到代码是什么样的呢？

作为iOS开发者，且让人更容易理解，下面我使用Swift代码来实现如上数据解析过程。

### 模型

首先生成模型，上面也提到了数据结构只有两种：问题和选项。

```
// 问题
struct Question: Codable {
    var question: String
    var id: String
    var options: [Option]
}

// 选项
struct Option: Codable {
    var name: String
    var id: String
    var children: [Question]
}
```

两种之间明显存在互相包含的关系，所以这里非常容易让人头晕。

拿到数据并解析成上面的模型后，我们并不能直接使用，因为还差1个标识变量：`问题选中项`，没有这个标识，我们就不知道哪个节点被激活，所以将添加标识`activeOptionID`：

```
// 问题
struct Question: Codable {
    var question: String
    var id: String
    var options: [Option]
    var activeOptionID: String?
}
```

好的，下面开始解析, 这里借用数学上的映射概念，我们按**从左至右、从上至下**顺序寻找到如下问题列表：

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/reflect2p.png)


对应的代码如下，返回的是上述图片左侧的问题列表：

```
/// 遍历多叉树里面的问题节点，并作为一维数组返回(其他平台更加t容易理解的写法)
/// 且修改入参的activeID（选中option选项，无论是默认还是之前选中）
///
/// - Parameter tree: option下的所有问题
/// - Returns: 子层所有的问题
func lagcyConvertTree2FlatGroup(tree: inout [Question]) -> [Question] {
    // 下层需要返回的问题
    var flatGroup = [Question]()
    let range = 0..<tree.count
    for i in range {
        let subRange = 0..<tree[i].options.count
        
        // 若问题无选中项，则默认选择第一项，若无选项则该问题不返回
        guard let activeID = tree[i].activeOptionID ?? tree[i].options.first?.id else {
            continue
        }
        
        for j in subRange {
            let option = tree[i].options[j]
            if option.id == activeID {
                // 返回本层的问题，第一个
                tree[i].activeOptionID = activeID
                flatGroup.append(tree[i])
                
                // 查找子层的问题，全部返回
                let groups = lagcyConvertTree2FlatGroup(tree: &tree[i].options[j].children)
                flatGroup.append(contentsOf: groups)
                break
            }
        }
    }
    
    return flatGroup
}
```

测试结果：

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/flat2p.png)

### 测试结果分析

可以看到原始数据提取出的问题数组`group`和我们根据分叉树分析的结果一致。同时我们又实现了对原数据也就是分茶树的维护，证明了可修改分叉树的激活路径，也就是对应用户的点击切换事件。

### 维护分叉树

数据回写其实就是上面说的维护分叉树，一切以`data`为准，保存数据唯一性并且在切换激活路径的时候之前选中的下级分支选项选中状态能得到保存。

**想要修改分叉树的数据，就得实现实现一维数组到分叉树的映射关系。**

实现方法依然是基于相同的**从左至右、从上至下**遍历顺序，使用数学的映射概念，我们UI显示一个问题列表，那么数据必须是一维的一个数组，这样才能一一对应，虽然可以使用遍历分叉树的方法，但是最差情况下，假设分叉树有n层、m条路径，那么复杂度就是O(O(n*m)), 十分耗费性能并且很可能导致UI卡顿，因此我们只在数据更新时遍历一次一次获取映射关系即可。

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/reflect2p.png)

对应的实现代码如下，核心就是递归遍历。

```
/// 遍历分叉树所有激活路径，找到选中的选项节点，返回它在一维问题数组和选项数组中的位置（即映射）
///
/// - Parameters:
///   - activeID: 选项id
///   - tree: 问题列表
/// - Returns: 问题和选项的位置
func positionOfOptionInActivePathLagcy(activeID: String, tree: [Question]) -> (questionIndex: Int, optionIndex: Int)? {
    for (questionIndex, question) in tree.enumerated() {
        // 若此问题无激活节点，跳过
        guard let actID = question.activeOptionID else {
            continue
        }
        
        // 若选项id在本问题内，则遍历本层即可
        if let optionIndex = question.options.firstIndex(where: { $0.id == activeID && actID == activeID }) {
            return (questionIndex, optionIndex)
        }
        
        // 选项id不在本层，遍历查找选项下的所有问题
        for option in question.options {
            guard let result = positionOfOptionInActivePathLagcy(activeID: activeID, tree: option.children) else {
                continue
            }
            
            // 因为是下层，所以位移要+1
            return (questionIndex + result.questionIndex + 1, result.optionIndex)
        }
    }
    
    return nil
}
```
方法`positionOfOptionInActivePathLagcy`返回的是选项在一维问题列表的位置。

测试结果：

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/position2px.png)

### 测试结果分析

可以看到外星人位置信息是`nil`即为空，激活路径中不包含外星人，所以这个方法是可靠的。

那么同理，我们绕过激活匹配（`activeOptionID`不判断），就可以实现反向映射，找到选中选项和它属于的问题，将问题的`activeOptionID`赋值，不需要处理上层的数据。

```
/// 更换问题的激活选项，并将修改原分叉树
/// 使用此方法后，原分叉树数据变化，但是想要视图上体现需要
/// 调用positionOfOptionInActivePathLagcy生成新的一维问题数组
///
/// - Parameters:
///   - optionID: 选项id
///   - tree: 问题列表
/// - Returns: 修改结果，若此层和下层都找不到选项则返回false
func active(optionID: String, tree: inout [Question]) -> Bool {
    for (questionIndex, question) in tree.enumerated() {
        // 若问题无选中项，则查找所有选项的问题的选项
        guard let _ = question.options.firstIndex(where: { $0.id == optionID }) else {
            // 利用递归继续查找子层的问题
            for (optionIndex, _) in question.options.enumerated() {
                if active(optionID: optionID, tree: &tree[questionIndex].options[optionIndex].children) {
                    return true
                }
            }
            continue
        }
        
        // 修改当前问题的激活选项
        tree[questionIndex].activeOptionID = optionID
        return true
    }
    
    return false
}
```

测试结果：

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/switch3px.png)

### 测试结果分析

地球之前是没有选中，我们使用`active(optionID:tree:)`方法选中对应的地球选项后，就能得到国家、省份的路径就出现了。数据和树的激活路径一致！

![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/3p.png)


### 视图增删处理

视图显示我们使用列表的方式，根据一维的问题列表可以很方便的生成问题列表，但是在处理点击事件即新问题列表生成后，我们有两种方案：

1. 完全生成新的视图列表，清除原列表
2. 对原列表进行增加视图和删除视图操作

因为app端始终是嵌入式设备，性能有限且有功耗问题，关键是要实现一种延续性体验和其他动画效果，全部生成视图列表会导致这些要求很难甚至无法实现。

我们可以分析出以下几种情况：

**新增在内部**  
![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/move1.png)

**新增在末尾**  
![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/move2.png)

**从原列表删除**  
![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/move3.png)

**相同长度，原列表有删除项，新列表有新增项**  
![](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/move4.png)

现在立即做代码实现会让人头大，非常的绕。所以要有一个清晰的思路才可以写代码，现在我们来理一下。

首先当用户点击选项以后会有两个集合：

- 原问题集合**A**
- 新问题集合**B**

我们要找出三个集合：

- 删除问题集合C
- 新增问题集合D
- 保留问题集合E

计算过程：


| 结果集合  | 计算公式 |
|:------------- |:---------------:|
| E      | A U B  |
| C      | A - E        |
| D | B - E       |

### 保留问题

新问题集合和原问题集合的交集就是保留问题，也就是遍历原问题集合，看这个问题在新问题集合中是否存在，存在就说明是保留问题。

```
var remaindIds = [String]()
for rowid in originRowIDs {
	for question in newQuestions {
		if question.id == rowid {
			remaindIds.append(question.id)
          break
       }
	}
}
```

### 删除问题

原问题集合中除保留问题外，都是属于删除问题，也就是原问题集合对保留问题的差集。

```
var deletesIds = [String]()
for rowid in originRowIDs {
    for remiandid in remaindIds {
        if remiandid == rowid {
            break
        }
    }
    
    deletesIds.append(rowid)
}
```

### 新增问题

新问题集合中除了保留问题外，都是新增问题，也就是新问题集合对保留问题的差集。

```
var newRowIds = [String]()
for question in newQuestions {
    for remiandid in remaindIds {
        if question.id == rowid {
           break
        }
    }
    
	newRowIds.append(question.id)
}
```

这样我们就拿到三个需要在后面做判断的数据了。

## 视图处理操作

根据上面的数据我们就可以对原视图做增删保留的操作，具体逻辑如下：

![程序流程图](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/pro.png)

实现代码， 可以理解`stackView`为列表视图，`Row`为问题视图：

```
public func updateStackView(newQuestions: [Question]) {
        let originRows = self.stackView.arrangedSubviews.map({ $0 as! Row })
        let originRowIDs = originRows.map({ $0.questionID })
        
        /// 删除问题
        let deleteRowIds = originRowIDs.filter({ rowid in newQuestions.first(where: { question in question.id == rowid }) == nil })
        /// 新增问题
        let newRowIds = newQuestions.filter({ question in originRowIDs.first(where: { rowid in rowid == question.id }) == nil })
        /// 保存问题
        let remianIds = originRowIDs.filter({ rowid in newQuestions.first(where: { question in question.id == rowid }) != nil })
        
        print(">>>>>> 删除问题： \(deleteRowIds.joined(separator: "、"))")
        print(">>>>>> 新增问题： \(newRowIds.map({ $0.id }).joined(separator: "、"))")
        print(">>>>>> 保存问题： \(remianIds.joined(separator: "、"))")
        
        /// 获取最长的问题列表
        let maxCount = max(originRows.count, newQuestions.count)
        
        /// 插入位置
        var anchor = 0
        
        for i in 0..<maxCount {
            /// 新问题列表大于原列表，且当前位置为新问题
            if i > originRows.count - 1 {
                /// 此问题在原列表中存在，但因为超出原问题列表，插入位置无需更新（已是最后的位置）
                guard remianIds.first(where: { $0 == newQuestions[i].id }) == nil else {
                    continue
                }
                
                /// 新问题不再原k列表中，插入新问题，并位移动插入位置到新问题之后
                self.stackView.insertArrangedSubview(Row(data: newQuestions[i], selectCompeltion: originRows.first!.update), at: anchor)
                anchor += 1
                continue
            }
            
            /// 新问题列表小于原列表，且当前位置为原问题
            if i > newQuestions.count - 1 {
                /// 新问题列表中不包含此问题，删除此问题，但插入位置不变
                guard let _ = remianIds.first(where: { $0 == originRows[i].questionID }) else {
                    self.stackView.removeArrangedSubview(originRows[i])
                    originRows[i].removeFromSuperview()
                    continue
                }
                
                /// 新问题列表中包含此问题，保留此问题，移动插入位置到此问题之后
                anchor += 1
                continue
            }
            
            /// 当前问题不超过新问题和原列表
            
            /// 此问题不在新列表中，删除原问题
            if let _ = deleteRowIds.first(where: { $0 == originRows[i].questionID }) {
                self.stackView.removeArrangedSubview(originRows[i])
                originRows[i].removeFromSuperview()
                
                /// 并查找新列表相同位置是否是新增问题
                if let _ = newRowIds.first(where: { $0.id == newQuestions[i].id }) {
                    self.stackView.insertArrangedSubview(Row(data: newQuestions[i], selectCompeltion: originRows.first!.update), at: anchor)
                    anchor += 1
                }
                continue
            }
            
            /// 此问题是新列表中的新增问题
            if let _ = newRowIds.first(where: { $0.id == newQuestions[i].id }) {
                self.stackView.insertArrangedSubview(Row(data: newQuestions[i], selectCompeltion: originRows.first!.update), at: anchor)
                anchor += 1
                continue
            }
            
            /// 此问题不在原列表中，且是新增问题
            guard let _ = remianIds.first(where: { $0 == originRows[i].questionID }) else {
                self.stackView.removeArrangedSubview(originRows[i])
                originRows[i].removeFromSuperview()
                
                self.stackView.insertArrangedSubview(Row(data: newQuestions[i], selectCompeltion: originRows.first!.update), at: anchor)
                anchor += 1
                continue
            }
            
            /// 此问题为保留问题
            anchor += 1
        }
    }
}
```

当然，还有一些比如按钮、文字、点击事件、大小位置等处理代码，但是这里不作讨论。
完成相关的编码后，我们可以得到如下运行结果：

![效果gif](https://raw.githubusercontent.com/0xfeedface1993/DynamicOptionList/master/images/ania.gif)

## 总结

全文思路就是根据需求和数据结构建立一个数学模型，辅以编程技巧来实现我们想要的UI效果。关键在于理解需求和逻辑，其他东西都是帮助理解。希望本文能对你有所帮助！

完整代码下载地址：<https://github.com/0xfeedface1993/DynamicOptionList>
