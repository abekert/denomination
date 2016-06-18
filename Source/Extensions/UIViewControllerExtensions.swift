import Foundation
import UIKit

extension UIViewController {
    /// Present UIAlertController with your message and ok button
    func presentError(message: String) -> UIAlertController {
        let alert = UIAlertController (title: "Ошибка", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        if message.characters.count > 0 {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        return alert
    }
}