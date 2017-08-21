//
//  CalendarDetailTableViewCell.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class CalendarDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
//    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
