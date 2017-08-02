//
//  SetupPersonViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar


class SetupPersonViewController: UIViewController {
    var personArray : [PersonData] = [PersonData]()
    var calendarDataArray : [CalendarData] = [CalendarData]() //Save all every person's class
    var everyMonthDictionary : [[String : [CalendarData]]] = [[String : [CalendarData]]]()
    //for index pass from didSelect cell to button use
    var personTmpIndex : IndexPath?
    
    var titleIndex : Int = 0
    var classTypeArray = [String]() // for switch classType color
    
    //Calendar color setup ..
    let outsideMonthColor = UIColor.clear
    let monthColor = UIColor(colorWithHexValue: 0xffffff)
    let selectedMonthColor = UIColor(colorWithHexValue : 0xffffff)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue : 0x4e3f5d)
    let formatter = DateFormatter()
    let currentFormatter = DateFormatter()
    let currentDate = Date()
    
//MARK: - IBOutlet here
    @IBOutlet weak var showPersonDetail: UIView! //never use
   
    @IBOutlet weak var showDetailOfLabel: UILabel! //person name
    
    @IBOutlet weak var showHoursOfLabel: UILabel!
    
    @IBOutlet weak var SetupPersonTableView: UITableView!
    
    @IBOutlet weak var showDate: UILabel!{
        didSet{
            showDate.isUserInteractionEnabled = true
            showDate.isMultipleTouchEnabled = true
        }
    }
    @IBOutlet weak var showClassPerMonth: UITextView!{
        didSet{
            showClassPerMonth.isUserInteractionEnabled = true
        }
    }
  //JTApple Calendar
    
    @IBOutlet weak var showClassOfCalendarView: JTAppleCalendarView!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SetupPersonTableView.delegate = self
        SetupPersonTableView.dataSource = self
        setupCalendarView()
//        showClassPerMonth.isHidden = true
//        showClassOfCalendarView.ibCalendarDelegate = self
//        showClassOfCalendarView.ibCalendarDataSource = self
        showDetailOfLabel.isHidden = true
        showHoursOfLabel.isHidden = true
        let leftSwipe = UISwipeGestureRecognizer(target: self,
                                                                                action: #selector(swipeGestureRecognizer(_:)))
        leftSwipe.direction = .left
        showDate.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                                                  action: #selector(swipeGestureRecognizer(_:)))
        rightSwipe.direction = .right
        showDate.addGestureRecognizer(rightSwipe)

        
        //                    print("IS date == dateStr ========")
        for i in 0..<classTypeCDManager.count() {
            let item = classTypeCDManager.itemWithIndex(index: i)
            guard let typeName = item.typeName else {return }
            classTypeArray.append(typeName)
        }
        
    }//viewDidLoad Here
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - IBAction here
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        createAlertView()
    }
    
    //之後reset可考慮搬到Setting Page
    @IBAction func resetOverTimeBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "人員時數重置",
                                                 message: "確認後將進行人員時數重置,請確認您當月份班別已安排完成?",
                                                 preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default) { (isOK) in
            self.resetPersonHours()
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    //MARK: - Reset the person hours
    func resetPersonHours(){
        for index in 0..<personCDManager.count(){
            let item = personCDManager.itemWithIndex(index: index)
            item.overtime = BaseSetup.overHoursOfMonth
            item.workingHours = BaseSetup.hoursOfMonth
        }
        personCDManager.saveContexWithCompletion { (success) in
            if success {
                self.SetupPersonTableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
            }
        }
    }
    //MARK: - Add new person method
    func createAlertView(){
        let alert = UIAlertController.init(title: nil, message: "Please key in Name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            let item = personCDManager.createItem()
            item.systemBaseName = alert.textFields?[0].text
            item.name = alert.textFields?[0].text
            item.overtime = BaseSetup.overHoursOfMonth
            item.workingHours = BaseSetup.hoursOfMonth
            //以下三個尚未使用,日後安排移除
            item.month = months[6]
            item.year = years[0]
            item.yearAndMonth = "\(years[0])\(months[6])"
            personCDManager.saveContexWithCompletion(completion: { (success) in
                if(success){
                    self.SetupPersonTableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
                }
            })
        }//ok action block here
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - GetCalendarData on Array
    func getCalendarDetailData(){
        calendarDataArray.removeAll()
        for i in 0..<calendarCDManager.count(){
            let item = calendarCDManager.itemWithIndex(index: i)
            guard let personName = item.personName else {return }
            if personName == showDetailOfLabel.text{ //Get All  selected person's class
                calendarDataArray.append(item)
            }
        }
        handleEveryPersonClass { (success) in
            if success {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy MM"//FIXME: - fixed formatter
                let currentMonth = formatter.string(from: Date())
                print("EveryMonthDictionary: \(everyMonthDictionary.count)")
                for (index,everyMonth) in everyMonthDictionary.enumerated() {
                    for (key , _) in everyMonth {
                        if key == currentMonth{
                            titleIndex = index //when first display if it have currentDate data will show else show it had
//                            print("Print index : \(index)")
                        }
                    }
                }
                toShowSomeoneWorkingOfMonth()
            }
        }
    }
    func toShowSomeoneWorkingOfMonth(){
        if everyMonthDictionary.isEmpty {
            showDate.text = "Invailid"
            showClassPerMonth.text = ""
            return
        }
        let monthOfYear = everyMonthDictionary[titleIndex]
            for (key,value) in monthOfYear{
                var allWorkingOfMonthStr = String()
                for aMan in value{
                    guard let name = aMan.personName else {return }
                    guard let classType = aMan.typeName else {return }
                    guard let date = aMan.date else {return }
                    let oneDays = "\(name)\(classType)\(date)\n"
                    allWorkingOfMonthStr.append(oneDays)
                }
                
                formatter.dateFormat = "yyyy MM dd"
                guard let thisMonthMiddle = formatter.date(from:"\(key) 15") else {
                    print("在這出門了")
                    return }
                //let it always scroll to the correct month
                showClassOfCalendarView.reloadData()
                showClassOfCalendarView.scrollToDate(thisMonthMiddle)
                
                showDate.text = key
                showClassPerMonth.text = allWorkingOfMonthStr
            }
    }
    
    //MARK: - Add dictionary
    typealias HandleCompletion = (_ success : Bool ) -> Void
    func handleEveryPersonClass( completion : HandleCompletion){
        var howMuchDayWorkingOfMonth : [CalendarData] = [CalendarData]()
        for perYear in years{
            for perMonth in months{
                let perDate : String = "\(perYear) \(perMonth)"
                for person in calendarDataArray{
                    guard let year = person.year else { return}
                    guard let month = person.month else { return}
                    let arrayYearAndMonth : String = "\(year) \(month)"
                    if arrayYearAndMonth == perDate{
                        howMuchDayWorkingOfMonth.append(person)//get all working of month
                    }
                }
                if howMuchDayWorkingOfMonth.count > 0{
                    everyMonthDictionary.append([perDate : howMuchDayWorkingOfMonth])
                     howMuchDayWorkingOfMonth.removeAll()
                }
            }
        }
        completion(true)
    }

    
    //MARK: - SwipeGesture
    func swipeGestureRecognizer(_ swipe : UISwipeGestureRecognizer){
        switch swipe.direction {
        case UISwipeGestureRecognizerDirection.left:
            titleIndex += 1
            if titleIndex > (everyMonthDictionary.count)-1 {
                titleIndex = 0
            }
        case UISwipeGestureRecognizerDirection.right:
            titleIndex -= 1
            if titleIndex < 0  {
                titleIndex = everyMonthDictionary.count-1
            }
        default:
            break
        }
        toShowSomeoneWorkingOfMonth()
    }
    //MARK: - CalendarView Setup method here 
    func setupCalendarView(){
        //Setup calendar space
        showClassOfCalendarView.minimumLineSpacing = 0
        showClassOfCalendarView.minimumInteritemSpacing = 0
        showClassOfCalendarView.visibleDates { visibleDates in
            //Setup labels
            self.setupViewOfCalendar(from: visibleDates)
        }
        
    }
    func handleShowClassDate( validCell : ShowClassOfMonthCell , cellState : CellState ){
        formatter.dateFormat = "yyyy MM dd"
        let dateStr = formatter.string(from: cellState.date)
//        print("TESTTT:::: \(dateStr)")
        if everyMonthDictionary.isEmpty{
            print("everyMonthDictionary.isEmpty")
            return
        }
        ////
        let monthOfYear = everyMonthDictionary[titleIndex]
        for (_,value) in monthOfYear{
            for aMan in value{
                guard let classType = aMan.typeName else {return }
                guard let date = aMan.date else {return }
//                print("Had??  \(date) and \(dateStr)")
                if date == dateStr{
                    for typeName in classTypeArray{
                        if  classType == typeName {
                            
                        }
                    }
                
                    validCell.selectedView.isHidden = false
                    validCell.selectedView.backgroundColor = UIColor.red
                }
            }
//            
//            formatter.dateFormat = "yyyy MM dd"
//            guard let thisMonthMiddle = formatter.date(from:"\(key) 15") else {
//                print("在這出門了")
//                return }
            //let it always scroll to the correct month
//            showClassOfCalendarView.scrollToDate(thisMonthMiddle)
        }
        
        /////
    }
    
    func handleCellTextColor(view : JTAppleCell? , cellState : CellState){
        guard let validCell = view as? ShowClassOfMonthCell else{ return }
        if validCell.isSelected{
            //            validCell.dateLabel.textColor = selectedMonthColor //Change date color when selected
        }else{
            if cellState.dateBelongsTo == .thisMonth{
                handleShowClassDate(validCell: validCell, cellState: cellState)
                validCell.dateLabel.textColor = monthColor
            }else {
                validCell.dateLabel.textColor = outsideMonthColor
                //                validCell.isUserInteractionEnabled = false
            }
//            validCell.selectedView.isHidden = true
        }
    }
    func handleCellSelected(view : JTAppleCell? , cellState : CellState){
        guard let validCell = view as? ShowClassOfMonthCell else{ return }
        
        if validCell.isSelected{
            validCell.selectedView.isHidden = false
            //            validCell.selectedView.alpha = 1.0
            UIView.animate(withDuration: 0.3, animations: {
                validCell.selectedView.alpha = 0.0
            }, completion: { (finished) in
                if finished {
                    validCell.selectedView.isHidden = true
                    validCell.selectedView.alpha = 0.4
                }
            })
        }else{
            validCell.selectedView.isHidden = true
        }
    }
    //FIXME: - This can be delete
    func setupViewOfCalendar(from visibleDates : DateSegmentInfo){
////        let date = visibleDates.monthDates.first!.date
////        self.formatter.dateFormat = "yyyy"
////        self.year.text = self.formatter.string(from: date)
//        //To save year and month
////        BaseSetup.currentCalendarYear = self.year.text
////        self.formatter.dateFormat = "MMMM"
////        self.month.text = self.formatter.string(from: date)
////        self.formatter.dateFormat = "MM"
////        BaseSetup.currentCalendarMonth = self.formatter.string(from: date)
//        
    }

    
}//Class out here

//MARK: - TableView Delegate & DataSource
extension SetupPersonViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if personCDManager.count() == 0{
            let displayLabel = UILabel(frame:
                                                            CGRect( x: tableView.frame.width/4, y: 0,
                                                                           width: tableView.frame.width/2,
                                                                           height: tableView.frame.height))
            displayLabel.text = "Tap plus to add person list"
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
        return personCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetupPersonTableViewCell", for: indexPath) as! SetupPersonTableViewCell
        let item = personCDManager.itemWithIndex(index: indexPath.item)
         self.personArray.append(item)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(item.overtime)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        everyMonthDictionary.removeAll() /// when change person reset all dictionary
        titleIndex = 0
        self.showDetailOfLabel.isHidden = false
        self.showHoursOfLabel.isHidden = false
        
        self.showDetailOfLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        self.showHoursOfLabel.text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
        personTmpIndex = indexPath
       
       //////========
        getCalendarDetailData()
        }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = personCDManager.itemWithIndex(index: indexPath.item)
            personCDManager.deleteItem(item: item)
            personCDManager.saveContexWithCompletion(completion: { (success) in
                if success {
                    self.SetupPersonTableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
                }
            })
        }
    }
}
// MARK: - JTAppleCalendarViewDataSource
extension SetupPersonViewController:JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
    
}
//MARK: - JTApple CalendarView protocol method
extension SetupPersonViewController:JTAppleCalendarViewDelegate{
    //Display the cell
    func calendar(_ calendar: JTAppleCalendarView,
                              cellForItemAt date: Date,
                              cellState: CellState,
                              indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "ShowClassOfMonthCell", for: indexPath) as! ShowClassOfMonthCell
        
        formatter.dateFormat = "dd"
        cell.dateLabel.text = formatter.string(from: cellState.date)
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }
    //Didselect
//    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        formatter.dateFormat = "dd"
//        BaseSetup.selectedDay = formatter.string(from: cellState.date)
//        handleCellSelected(view: cell, cellState: cellState)
//        handleCellTextColor(view: cell, cellState: cellState)
//        print("Cellstate is \n: \(cellState.row())\n and \(cellState.dateSection().range) \n and other \(cellState.date)\n and \(cellState.text)\n ")
//        
//    }
    func calendar(_ calendar: JTAppleCalendarView,
                              didDeselectDate date: Date,
                              cell: JTAppleCell?,
                              cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
//    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
//        setupViewOfCalendar(from: visibleDates)
//    }
}

