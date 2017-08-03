
import Foundation

class EmailValidationService: IValidationService{
    var alertMessageDelegate: IAlertMessageDelegate?
    var validationServiceDelegate:IValidationService?
    let title = String.ValidationAlert_Title
    var message = ""
    
    func Validate(validationString: String?) -> Bool {
        var isValid:Bool = false
        isValid = validateNotNil(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateNotEmpty(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateNoAtSign(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateNoDot(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateSpaces(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateMailEndingContainsDot(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateMailEndsWithDotAndAtLeastTwoCharacters(validationString: validationString)
        if !isValid { return isValid }
        isValid = validateMailNotContainsInvalidCharacters(validationString: validationString)
        return isValid
    }
    
    
    private func validateNotNil(validationString: String?) -> Bool{
        if validationString == nil {
            message = String.ValidationEmailEmptyAlert_Message
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateNotEmpty(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if validationString!.isEmpty {
            message = String.ValidationEmailEmptyAlert_Message
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateNoAtSign(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if !validationString!.contains("@") {
            message = String.ValidationEmailShouldContainAtSign
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateNoDot(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if !validationString!.contains(".") {
            message = String.ValidationEmailShouldContainDot
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateSpaces(validationString: String?) -> Bool{
        if validationString == nil { return false }
        if validationString!.contains(" ") {
            message = String.ValidationEmailContainsSpaces
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateMailEndingContainsDot(validationString: String?) -> Bool{
        if validationString == nil { return false }
        let ending = validationString!.components(separatedBy: "@").last
        if ending == nil { return false }
        if ending!.range(of: ".") == nil{
            message = String.ValidationEmailEndingInvalid
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateMailEndsWithDotAndAtLeastTwoCharacters(validationString: String?) -> Bool{
        if validationString == nil { return false }
        let ending = validationString!.components(separatedBy: "@").last
        if ending == nil { return false }
        let endOfEnding = ending!.components(separatedBy: ".").last
        if endOfEnding == nil { return false }
        if endOfEnding!.characters.count < 2 {
            message = String.ValidationEmailEndingInvalid
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    private func validateMailNotContainsInvalidCharacters(validationString: String?) -> Bool{
        if validationString == nil { return false }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        if !emailPredicate.evaluate(with: validationString){
            message = String.ValidationEmailContainsInvalidCharacters
            ShowAlertMessage(title: title, message: message)
            return false
        }
        return true
    }
    internal func ShowAlertMessage(title: String, message: String) {
        if alertMessageDelegate != nil{
            alertMessageDelegate!.ShowAlertMessage(title: title, message: message)
        } else{
            print("AlertMessageDelegate not set from calling class in EmailValidationService")
        }
    }
}
