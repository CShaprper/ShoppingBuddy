
import UIKit

extension UINavigationBar{
        func setGradientBackground(colors: [CGColor]) {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y:0, width:self.bounds.width, height: self.bounds.height)
            gradientLayer.colors = colors           
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
}
