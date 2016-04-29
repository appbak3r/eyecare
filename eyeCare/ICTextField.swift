//
//  ICTextField.swift
//  eyeCare
//
//  Created by Alexey Dmitriev on 29/04/16.
//  Copyright © 2016 IonCloud. All rights reserved.
//

import Cocoa

class ICTextField: NSTextField {
    
    override func textDidChange(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("ICTextFieldDidChange", object: self)
        super.textDidChange(notification)
    }
}