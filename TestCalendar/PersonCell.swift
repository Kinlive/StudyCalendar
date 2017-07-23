//
//  PersonCell.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/8.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit


class PersonCell: UICollectionViewCell {
    var hours : Double?
    var overHours = 0.0
    var personDetail = PersonDetail()
    
    
    @IBOutlet weak var personName: UILabel!
    
    @IBOutlet weak var hourBar: KDCircularProgress!
//    @IBOutlet weak var hourBar: UIView! //FIXME : -  never use

   
    
}
