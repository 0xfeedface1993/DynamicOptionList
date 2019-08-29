import Foundation

// 问题
public struct Question: Codable {
    public var question: String
    public var id: String
    public var options: [Option]
    public var activeOptionID: String?
}

// 选项
public struct Option: Codable {
    public var name: String
    public var id: String
    public var children: [Question]
}

/// 将JSON二进制数据转化成JSON对象
///
/// - Returns: 问题数组
public func decodeJSONData() -> [Question] {
    let fileURL = Bundle.main.url(forResource: "data", withExtension: "json")!
    
    do {
        let fileData = try Data(contentsOf: fileURL)
        let json = try JSONDecoder().decode([Question].self, from: fileData)
        
        return json
    } catch {
        print(error)
        
        return []
    }
}

/// 遍历多叉树里面的问题节点，并作为一维数组返回
/// 且修改入参的activeID（选中option选项，无论是默认还是之前选中）
///
/// - Parameter tree: option下的所有问题
/// - Returns: 子层所有的问题
public func convertTree2FlatGroup(tree: inout [Question]) -> [Question] {
    // 下层需要返回的问题
    var flatGroup = [Question]()
    tree.enumerated().forEach({ (questionIndex, question) in
        // 若问题无选中项，则默认选择第一项，若无选项则该问题不返回
        guard let activeID = question.activeOptionID ?? question.options.first?.id, let optionIndex = question.options.firstIndex(where: { $0.id == activeID }) else {
            print(">>>>>> x 问题id：\(question.id), \(question.question), 子层选项为空")
            return
        }
        
        // 当前问题返回
        tree[questionIndex].activeOptionID = activeID
        flatGroup.append(tree[questionIndex])
        
        guard question.options[optionIndex].children.count > 0 else {
            print(">>>>>> y 问题id：\(question.id), \(question.question), 子层选项为空")
            return
        }
        
        // 利用递归查找子层的问题，全部返回
        let groups = convertTree2FlatGroup(tree: &tree[questionIndex].options[optionIndex].children)
        flatGroup.append(contentsOf: groups)
    })
    
    return flatGroup
}

/// 遍历多叉树里面的问题节点，并作为一维数组返回(其他平台更加t容易理解的写法)
/// 且修改入参的activeID（选中option选项，无论是默认还是之前选中）
///
/// - Parameter tree: option下的所有问题
/// - Returns: 子层所有的问题
public func lagcyConvertTree2FlatGroup(tree: inout [Question]) -> [Question] {
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

/// 遍历分叉树所有激活路径，找到选中的选项节点，返回它在一维问题数组和选项数组中的位置（即映射）
///
/// - Parameters:
///   - activeID: 选项id
///   - tree: 问题列表
/// - Returns: 问题和选项的位置
public func positionOfOptionInActivePathLagcy(activeID: String, tree: [Question]) -> (questionIndex: Int, optionIndex: Int)? {
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

/// 更换问题的激活选项，并将修改原分叉树
/// 使用此方法后，原分叉树数据变化，但是想要视图上体现需要
/// 调用positionOfOptionInActivePathLagcy生成新的一维问题数组
///
/// - Parameters:
///   - optionID: 选项id
///   - tree: 问题列表
/// - Returns: 修改结果，若此层和下层都找不到选项则返回false
public func active(optionID: String, tree: inout [Question]) -> Bool {
    for (questionIndex, question) in tree.enumerated() {
        // 若问题无选中项，则查找所有选项的问题的选项
        guard let _ = question.options.firstIndex(where: { $0.id == optionID }) else {
            // 利用递归继续查找子层的问题
            for (optionIndex, _) in question.options.enumerated() {
                if tree[questionIndex].options[optionIndex].children.count > 0, active(optionID: optionID, tree: &tree[questionIndex].options[optionIndex].children) {
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
