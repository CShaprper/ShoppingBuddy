
import UIKit
/// Control Target Helper
class ControlTagetTester {
    static func checkTargetForOutlet(outlet: AnyObject?, actionName: String, event: UIControlEvents, controller: UIViewController)->Bool{
        switch outlet {
        //UIButton
        case is UIButton:
            if let btn = outlet as? UIButton{
                if btn.actions(forTarget: controller, forControlEvent: event) != nil {
                    let actions = btn.actions(forTarget: controller, forControlEvent: event)!
                    let myActionName:String = actionName.appending("WithSender:")
                    return actions.contains(myActionName)
                }
            }
            return false
        //UITextfield
        case is UITextField:
            if let txt = outlet as? UITextField{
                if txt.actions(forTarget: controller, forControlEvent: .editingChanged) != nil{
                    let actions = txt.actions(forTarget: controller, forControlEvent: event)!
                    let myActionName:String = actionName.appending("WithSender:")
                    return actions.contains(myActionName)
                }
            }
            return false
        //UISegmentedControl
        case is UISegmentedControl:
            if let seg = outlet as? UISegmentedControl{
                if seg.actions(forTarget: controller, forControlEvent: .valueChanged) != nil{
                    let actions = seg.actions(forTarget: controller, forControlEvent: event)!
                    let myActionName:String = actionName.appending("WithSender:")
                    return actions.contains(myActionName)
                }
            }
            return false
        //UISwitch
        case is UISwitch:
            if let swi = outlet as? UISwitch{
                if swi.actions(forTarget: controller, forControlEvent: .valueChanged) != nil{
                    let actions = swi.actions(forTarget: controller, forControlEvent: event)!
                    let myActionName:String = actionName.appending("WithSender:")
                    return actions.contains(myActionName)
                }
            }
            return false
        default:
            return false
        }
    }
}
