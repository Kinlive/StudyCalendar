//
//  CustomCell.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/6.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar
class CustomCell: JTAppleCell {
    var date : Date?
    
    
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var selectedView:UIView!
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var howManyPerson: UILabel!
    
}
