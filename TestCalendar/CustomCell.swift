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
    @IBOutlet weak var classType1Person: UILabel!
    @IBOutlet weak var classType2Person: UILabel!
    @IBOutlet weak var classType3Person: UILabel!
    @IBOutlet weak var classType4Person: UILabel!
    @IBOutlet weak var howManyPerson: UILabel!
    
}
