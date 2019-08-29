import UIKit

public class Row: UIView {
    let titleLabel = UILabel()
    let stackView = UIStackView(arrangedSubviews: [])
    var questionID : String
    var update : (Row, TagView) -> Void
    
    required init(data: Question, selectCompeltion: @escaping (Row, TagView) -> Void) {
        self.questionID = data.id
        self.update = selectCompeltion
        super.init(frame: CGRect.zero)
        config()
        
        titleLabel.text = data.question
        
        let tags = data.options.enumerated().map({ option -> TagView in
            let tag = TagView(optionID: option.element.id, place: option.offset == 0 ? .leading:(option.offset == data.options.count - 1 ? .trailling:.center), selectCompletion: { tagView in
                if tagView.state {
                    return
                }
                
                self.stackView.arrangedSubviews.map({ $0 as! TagView }).forEach({
                    $0.reloadColor(newState: $0 == tagView)
                })
                self.update(self, tagView)
            })
            tag.textLabel.text = option.element.name
            tag.reloadColor(newState: option.element.id == data.activeOptionID)
            return tag
        })
        
        var lastView : UIView?
        for tag in tags {
            tag.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(tag)
            let views = lastView != nil ? ["x": tag, "p": lastView!]:["x": tag]
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: lastView != nil ? "H:[x(p)]":"H:[x]", options: [], metrics: nil, views: views))
            lastView = tag
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        addSubview(titleLabel)
        addSubview(stackView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        stackView.axis = .horizontal
        stackView.spacing = 0
        
        let views = ["t": titleLabel, "c": stackView] as [String:Any]
        views.forEach({
            ($0.value as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[c]-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[t]-[c]-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[t]-|", options: [], metrics: nil, views: views))
    }
}
