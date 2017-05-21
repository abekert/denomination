import Foundation
import UIKit

extension UIViewController {
    
    /// Present UIAlertController with your message and ok button
    func presentError(message: String) -> UIAlertController {
        let alert = UIAlertController (title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        if message.characters.count > 0 {
            self.present(alert, animated: true, completion: nil)
        }
        
        return alert
    }
}
