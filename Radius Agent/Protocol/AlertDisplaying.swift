//
//  AlertDisplaying.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import UIKit

typealias AlertAction = (UIAlertAction) -> Void
protocol AlertDisplaying {
    func displayAlert(title: String, message: String)
}

extension AlertDisplaying where Self: UIViewController {
    func displayAlert(title: String, message: String) {
        displayAlert(title: title,
                     message: message,
                     actions: [UIAlertAction(title: "Ok", style: .default, handler: nil)])
    }
    
    private func displayAlert(title: String? = "", message: String? = "", actions: [UIAlertAction] = []) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}
