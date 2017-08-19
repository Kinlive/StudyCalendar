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
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            print("Backspace was pressed")
            isOverCount = false
            beforeText = textField.text
            return true
        }else{
            if isOverCount  {
                return false
            }else {
                beforeText?.append(string)
            }
        }
        
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         beforeText = textField.text //before key in save
        
        
        if  let text = textField.text { // textField have some texts
           
            
            switch textField.tag {
            case 9527:
            if text.characters.count > 3{
                isOverCount = true
                
            }
//            case 16138:
//            if text.characters.count > 5 {
//                isOverCount = true
//            }
            default :
            break
            }
        }else {
             isOverCount = false
        }

        return true
    }
    
}
