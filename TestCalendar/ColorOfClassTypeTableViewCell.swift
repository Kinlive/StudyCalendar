//
//  ColorOfClassTypeTableViewCell.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/9/2.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class ColorOfClassTypeTableViewCell: UITableViewCell {
    @IBOutlet weak var colorBackgroundView: UIView!
    @IBOutlet weak var colorTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
