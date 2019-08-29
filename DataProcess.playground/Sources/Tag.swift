import UIKit

public class TagView: UIView {
    enum Postion {
        case leading
        case trailling
        case center
    }
    
    let contentView = UIView()
    let textLabel = UILabel()
    public var optionID : String
    var place : Postion
    var state : Bool = false
    var update : (TagView) -> Void
    
    required init(optionID: String, place: Postion, selectCompletion: @escaping (TagView) -> Void) {
        self.optionID = optionID
        self.place = place
        self.update = selectCompletion
        super.init(frame: CGRect.zero)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        addSubview(contentView)
        addSubview(textLabel)
        
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        textLabel.textColor = .black
        textLabel.textAlignment = .center
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.blue.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTap)))
        
        switch place {
        case .leading:
            contentView.layer.cornerRadius = 5
            contentView.layer.maskedCorners = CACornerMask.layerMinXMinYCorner.union(.layerMinXMaxYCorner)
        case .trailling:
            contentView.layer.cornerRadius = 5
            contentView.layer.maskedCorners = CACornerMask.layerMaxXMinYCorner.union(.layerMaxXMaxYCorner)
        default:
            break
        }
        
        let views = ["t": textLabel, "c": contentView] as [String:Any]
        views.forEach({
            ($0.value as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[c]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[c]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[t]-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[t(>=44)]-|", options: [], metrics: nil, views: views))
    }
    
    @objc func userTap() {
        if self.state {
            return
        }
        
        self.update(self)
    }
    
    func reloadColor(newState: Bool) {
        if self.state == newState {
            return
        }
        
        self.state = newState
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.textLabel.textColor = self.state ? .white:.black
            self.contentView.backgroundColor = self.state ? .blue:.white
        }, completion: nil)
    }
}


extension Notification {
    static let optionValueChange = Notification.Name("goforit")
}
