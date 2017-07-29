//
//  PopupMenuViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class PopupMenuViewController: UIViewController {
    var classTypeCDManager : CoreDataManager<ClassTypeData>!
//    var personCDManager : CoreDataManager<PersonData>!
    let baseSetup = BaseSetup()
    
    @IBOutlet weak var menuTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredContentSize = CGSize(width: 300, height: 400)
        showAnimate()
        menuTableView.delegate = self
        menuTableView.dataSource = self
       
        classTypeCDManager = CoreDataManager(
                                                initWithModel: "DataBase",
                                                dbFileName: "classTypeData.sqlite",
                                                dbPathURL: nil,
                                                sortKey: "typeName",
                                                entityName: "ClassTypeData")
//        personCDManager = CoreDataManager(
//                                                initWithModel: "DataBase",
//                                                dbFileName: "personData.sqlite",
//                                                dbPathURL: nil,
//                                                sortKey: "name",
//                                                entityName: "PersonData")
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    


    
    //MARK: - view Animate func
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }) { (finished) in
            if finished {
//                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//                self.view.backgroundColor = UIColor.clear
            }
        }
        
    }
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if finished {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    
}
extension PopupMenuViewController: UITableViewDataSource,UITableViewDelegate{
    //MARK: - tableView Delegate & Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        //..
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //..how much cells
        if classTypeCDManager.count() == 0{
            let displayLabel = UILabel(frame:
                CGRect( x: tableView.frame.width/4, y: 0,
                        width: tableView.frame.width/2,
                        height: tableView.frame.height))
            displayLabel.text = "It's first to add ClassType"
            displayLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            displayLabel.textAlignment = .center
            displayLabel.numberOfLines = 4
            tableView.backgroundView = displayLabel
            tableView.separatorStyle = .none
        }else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor(colorWithHexValue: 0x3399ff)
        }
        return classTypeCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeCell", for: indexPath) as! MenuOfClassTypeTableViewCell
        let item = classTypeCDManager.itemWithIndex(index: indexPath.item)
        
        cell.layer.cornerRadius = 15
        cell.textLabel?.text = item.typeName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let firstLongPressIndex = BaseSetup.saveFirstIndexPath else {
             print("被firsLonPressIndex擋下了")
            return }
//        guard let saveEndIndexPath = BaseSetup.saveEndIndexPath else {
//            print("被saveEndIndexPath擋下了")
//            return
//        }
        //這裡之後要簽點選完班別後 由calendarData收集
        let classTypeItem = classTypeCDManager.itemWithIndex(index: indexPath.item)
        let personItem = personCDManager.itemWithIndex(index: firstLongPressIndex.item)
        guard let classTypeOvertime = Double(classTypeItem.overtime!) else {
            print("被classTypeOvertime擋下了")
            return }
        
      
        let formatter = DateFormatter()
//        let date = Date()
        formatter.dateFormat = "yyyy MM dd"
//        calendarDetailItem.date = formatter.string(from: date)
        guard let dropEndCalendarDate =  BaseSetup.dropEndCalendarDate else {
            print("被dropEndCalendarDate擋下了")
            return }
        guard let currentYear = BaseSetup.currentCalendarYear else {
        print("被currentYear擋下")
        return }
        guard let currentMonth = BaseSetup.currentCalendarMonth else {
        print("被currentMonth擋下")
        return}
        let toSaveDate = "\(currentYear)\(currentMonth)\(dropEndCalendarDate)"
        print("Test toSaveDate ::: \(toSaveDate)")
        
        
        //New create calendarDetailItem
        let calendarDetailItem = calendarCDManager.createItem()
        calendarDetailItem.date = toSaveDate
        calendarDetailItem.personName = personItem.name
        calendarDetailItem.typeName = classTypeItem.typeName
        calendarDetailItem.year = currentYear
        calendarDetailItem.month = currentMonth
        calendarDetailItem.day = dropEndCalendarDate
        
        calendarCDManager.saveContexWithCompletion { (success) in
            if success {
                
                print("Calendar Save OK!")
                
            }
        }
        //避免時數被扣成負數
        if (personItem.overtime - classTypeOvertime) < 0{
            personItem.overtime = 0
        }else{
            personItem.overtime -= classTypeOvertime
        }
        
        print("Test name : \(String(describing: personItem.name)) and time: \(personItem.overtime)")
        personCDManager.saveContexWithCompletion { (success) in
            if success {
                //...發通知reload
                let arrayIndexPath = [firstLongPressIndex]
                NotificationCenter.default.post(name:Notification.Name.init( "RefreshTheCell") , object: arrayIndexPath)
            }
        }
//        self.view.removeFromSuperview()
        self.removeAnimate()
    }

}
