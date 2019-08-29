import UIKit

public class ListView: UIView {
    let stackView = UIStackView(frame: CGRect.zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let views = ["c": stackView] as [String:Any]
        views.forEach({
            ($0.value as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[c]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[c]->=0-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reload(data: [Question], completion: @escaping (Row, TagView) -> Void) {
        if self.stackView.arrangedSubviews.count > 0 {
            let vs = self.stackView.arrangedSubviews
            vs.forEach({
                self.stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            })
        }
        
        data.map({ Row(data: $0, selectCompeltion: completion) }).forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.addArrangedSubview($0)
            let views = ["x": $0] as [String:Any]
            
             NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[x]|", options: [], metrics: nil, views: views))
        })
    }
    
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
