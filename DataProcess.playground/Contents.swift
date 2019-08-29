//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    var data = decodeJSONData()
    var group = [Question]()
    var list: ListView!
    
    override func loadView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 370, height: 1000))
        view.backgroundColor = .white
        
        list = ListView(frame: view.frame)
        group = convertTree2FlatGroup(tree: &data)
        list.reload(data: group, completion: { (row, tag) in
            let _ = active(optionID: tag.optionID, tree: &self.data)
            self.group = convertTree2FlatGroup(tree: &self.data)
            self.reloadData()
        })
        view.addSubview(list)
        
        self.view = view
    }
    
    func reloadData() {
        group.forEach({ print(">>>>>> \($0.id)-\($0.question)-\($0.options.count)") })
        list.updateStackView(newQuestions: group)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//func testNormal() {
//    var data = decodeJSONData()
//    var group = convertTree2FlatGroup(tree: &data)
//    data
//    
//    let alien = positionOfOptionInActivePathLagcy(activeID: "OP006", tree: data)
//    let humen = positionOfOptionInActivePathLagcy(activeID: "OP001", tree: data)
//    let men = positionOfOptionInActivePathLagcy(activeID: "OP002", tree: data)
//    let women = positionOfOptionInActivePathLagcy(activeID: "OP003", tree: data)
//    let licenseOK = positionOfOptionInActivePathLagcy(activeID: "OP004", tree: data)
//    let licenseNone = positionOfOptionInActivePathLagcy(activeID: "OP005", tree: data)
//    let addr = positionOfOptionInActivePathLagcy(activeID: "OP010", tree: data)
//    let american = positionOfOptionInActivePathLagcy(activeID: "OP011", tree: data)
//    var earth = positionOfOptionInActivePathLagcy(activeID: "OP008", tree: data)
//    
//    active(optionID: "OP006", tree: &data)
//    group = convertTree2FlatGroup(tree: &data)
//    
//    active(optionID: "OP008", tree: &data)
//    group = convertTree2FlatGroup(tree: &data)
//    
//    earth = positionOfOptionInActivePathLagcy(activeID: "OP008", tree: data)
//}

//func testLagcy() {
//    var data = decodeJSONData()
//    var group = lagcyConvertTree2FlatGroup(tree: &data)
//    data
//
//    let alien = positionOfOptionInActivePathLagcy(activeID: "OP006", tree: data)
//    let humen = positionOfOptionInActivePathLagcy(activeID: "OP001", tree: data)
//    let men = positionOfOptionInActivePathLagcy(activeID: "OP002", tree: data)
//    let women = positionOfOptionInActivePathLagcy(activeID: "OP003", tree: data)
//    let licenseOK = positionOfOptionInActivePathLagcy(activeID: "OP004", tree: data)
//    let licenseNone = positionOfOptionInActivePathLagcy(activeID: "OP005", tree: data)
//    let addr = positionOfOptionInActivePathLagcy(activeID: "OP010", tree: data)
//    let american = positionOfOptionInActivePathLagcy(activeID: "OP011", tree: data)
//    var earth = positionOfOptionInActivePathLagcy(activeID: "OP008", tree: data)
//
//    active(optionID: "OP006", tree: &data)
//    group = lagcyConvertTree2FlatGroup(tree: &data)
//
//    active(optionID: "OP008", tree: &data)
//    group = lagcyConvertTree2FlatGroup(tree: &data)
//
//    earth = positionOfOptionInActivePathLagcy(activeID: "OP008", tree: data)
//}
//
//var data = decodeJSONData()
//var group = lagcyConvertTree2FlatGroup(tree: &data)
//data
//
//let alien = positionOfOptionInActivePathLagcy(activeID: "OP006", tree: data)
//let humen = positionOfOptionInActivePathLagcy(activeID: "OP001", tree: data)
//var earth = positionOfOptionInActivePathLagcy(activeID: "OP008", tree: data)
//
//active(optionID: "OP008", tree: &data)
//group = lagcyConvertTree2FlatGroup(tree: &data)
//
//earth = positionOfOptionInActivePathLagcy(activeID: "OP008", tree: data)
//
