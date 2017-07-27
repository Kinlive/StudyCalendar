//
//  CalendarDetailViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class CalendarDetailViewController: UIViewController {
    
    @IBOutlet weak var showScheduleTable: UITableView!
    
    @IBOutlet weak var showDate: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 900, height: 600)
        // Do any additional setup after loading the view.
        showScheduleTable.delegate = self
        showScheduleTable.dataSource = self
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension CalendarDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        //..
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //..
        return calendarCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! CalendarDetailTableViewCell
//        cell.textLabel?.text = "Name here"
        let item = calendarCDManager.itemWithIndex(index: indexPath.item)
        cell.date.text = item.date
        cell.title.text = item.personName
        cell.subTitle.text = item.typeName
        
        return cell
    }
    
}
