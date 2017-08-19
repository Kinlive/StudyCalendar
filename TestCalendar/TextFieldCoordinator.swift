//
//  TextFieldCoordinator.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/8/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class TextFieldCoordinator: NSObject, UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if isOverCount  {
            return false
        }
        beforeText?.append(string)
        
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        beforeText = textField.text
        
        if  let text = textField.text { // textField have some texts
            
            switch textField.tag {
            case 9527:
            if text.characters.count > 3{
                isOverCount = true
                return true
            }
            case 16138:
            if text.characters.count > 5 {
                isOverCount = true
                return true
            }
            default :
            break
            }
       }
        
        isOverCount = false
        
        return true
    }
    
}
