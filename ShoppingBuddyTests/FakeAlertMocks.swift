
import UIKit
@testable import ShoppingBuddy

//MARK: - Fake Alert Mock
public class FakeValidationAlertMock:IValidationService {
    var title:String?
    var message:String?
    
    public func ShowValidationAlert(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

