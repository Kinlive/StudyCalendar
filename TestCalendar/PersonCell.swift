//
//  PersonCell.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/8.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit


class PersonCell: UICollectionViewCell {
    var hours : Int?
    var overHours : Int?
    var personDetail = PersonDetail()
    
    
    @IBOutlet weak var personName: UILabel!
    
    @IBOutlet weak var hourBar: UIView! //FIXME : -  never use

   
}
