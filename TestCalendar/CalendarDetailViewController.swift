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

    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var showDate: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showScheduleTable.delegate = self
        showScheduleTable.dataSource = self
        guard let date = BaseSetup.selectedDay else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        showDate.text = formatter.string(from: date)
        fetchCalendarData()
        
        //Setup background
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "dark.jpg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
//        dateView.clipsToBounds = true
        self.view.backgroundColor = UIColor(patternImage: image)
        self.view.clipsToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        animateCellView()
    }
    //MARK: - Animate to show table cell
    func animateCellView() {
        showScheduleTable.reloadData()
        
        let cells = showScheduleTable.visibleCells
        let tableHeight: CGFloat = showScheduleTable.bounds.size.height
        
        for i in cells {
            let cell : UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5,
                           delay: 0.05*Double(index),
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .transitionFlipFromBottom  ,
                           animations: {
                            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            index += 1
        }
    }
  
    func fetchCalendarData() {
        itemArray.removeAll()
        guard let selectedDay =  BaseSetup.selectedDay else {
            print("被selected擋下了")
            return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let selectDate = formatter.string(from: selectedDay)
        for i in 0..<calendarCDManager.count(){
            guard let item = calendarCDManager.itemWithIndex(index: i) else {return }
            if item.date == selectDate{
                itemArray.append(item)
            }
        }
        
    }
    func fetchPersonItemWith( item : CalendarData){
        guard let personName = item.personName else { return }
        guard let classTypeName = item.typeName else { return }
        let classTypeItemArray = classTypeCDManager.searchField(field: "typeName", forKeyword: classTypeName) as? [ClassTypeData]
        let personItemArray = personCDManager.searchField(field: "name", forKeyword: personName) as? [PersonData]
        guard let personItem = personItemArray?.first else { return }
        guard let classTypeItem = classTypeItemArray?.first else { return }
        guard let classTypeOvertime = Double(classTypeItem.overtime!) else {return }
        guard let classTypeWorkingHours = Double(classTypeItem.workingHours!) else { return }
        
        guard let refreshCellOfIndexPath = BaseSetup.refreshCellOfIndexPath else { return}
        personItem.overtime += classTypeOvertime
        personItem.workingHours += classTypeWorkingHours
        personCDManager.saveContexWithCompletion { (success) in
            if success {
                self.showScheduleTable.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
                 let refreshIndexPaths = [refreshCellOfIndexPath]
                
                NotificationCenter.default.post(name:Notification.Name(rawValue: "RefreshCalendarCell") , object: refreshIndexPaths)
                //目前尚無法確保 通知的方法是執行再main thread
//                print("是在這裡發生轉動的嗎")
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
            tableView.separatorStyle = .none
//            tableView.separatorColor = UIColor(colorWithHexValue: 0x3399ff)
        }
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! CalendarDetailTableViewCell
        
//        cell.date.text = itemArray[indexPath.row].date
        cell.title.text = itemArray[indexPath.row].personName
        cell.subTitle.text = itemArray[indexPath.row].typeName
        let customView = UIView()
        
        customView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = customView
        
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
                    self.fetchCalendarData()
                    self.fetchPersonItemWith(item: item)
                }
            })
        }
    }
    
}
