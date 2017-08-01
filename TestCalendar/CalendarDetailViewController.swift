//
//  CalendarDetailViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class CalendarDetailViewController: UIViewController {
    
    var itemArray = [CalendarData]()
    
    @IBOutlet weak var showScheduleTable: UITableView!

    
    @IBOutlet weak var showDate: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showScheduleTable.delegate = self
        showScheduleTable.dataSource = self
        guard let date = BaseSetup.selectedDay else { return }
        showDate.text = date
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchCalendarDataWith()
        
    }
    
    func fetchCalendarDataWith() {
        guard let selectedDay =  BaseSetup.selectedDay else {
            print("被dropEndCalendarDate擋下了")
            return }
        guard let currentYear = BaseSetup.currentCalendarYear else {
            print("被currentYear擋下")
            return }
        guard let currentMonth = BaseSetup.currentCalendarMonth else {
            print("被currentMonth擋下")
            return}
        let currentDate = "\(currentYear)\(currentMonth)\(selectedDay)"
        
        
        for i in 0..<calendarCDManager.count(){
            let item = calendarCDManager.itemWithIndex(index: i)
            if item.date == currentDate{
                itemArray.append(item)
            }
        }
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
        if itemArray.count == 0{
            let displayLabel = UILabel(frame:
                CGRect( x: tableView.frame.width/4, y: 0,
                        width: tableView.frame.width/2,
                        height: tableView.frame.height))
            displayLabel.text = "Not plan person today"
            displayLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            displayLabel.textAlignment = .center
            displayLabel.numberOfLines = 4
            tableView.backgroundView = displayLabel
            tableView.separatorStyle = .none
        }else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
//            tableView.separatorColor = UIColor(colorWithHexValue: 0x3399ff)
        }
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! CalendarDetailTableViewCell
//        cell.textLabel?.text = "Name here"
//        let item = calendarCDManager.itemWithIndex(index: indexPath.item)
//        cell.date.text = item.date
//        cell.title.text = item.personName
//        cell.subTitle.text = item.typeName
        cell.date.text = itemArray[indexPath.row].date
        cell.title.text = itemArray[indexPath.row].personName
        cell.subTitle.text = itemArray[indexPath.row].typeName
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return tableView.frame.height/7
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = itemArray[indexPath.row]
            calendarCDManager.deleteItem(item: item)
            calendarCDManager.saveContexWithCompletion(completion: { (success) in
                if success {
                    print("為什麼沒有刷新??????")
                    self.showScheduleTable.reloadData()
                }
            })
        }
    }
    
}
