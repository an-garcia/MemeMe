//
//  EditTextFieldDelegate.swift
//  MemeMe
//
//  Created by xengar on 2017-11-08.
//  Copyright © 2017 xengar. All rights reserved.
//

import Foundation
import UIKit

class EditTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    // MARK: Properties

    
    /**
     * Examines the new string whenever the text changes.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    

    // Removes default text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let value : String = textField.text!
        if (value == "TOP" || value == "BOTTOM") {
            textField.text = ""
        }
    }
    
    // Dismiss the keyboard when the user press return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
}
