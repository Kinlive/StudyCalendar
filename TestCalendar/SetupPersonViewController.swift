//
//  SetupPersonViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar

//let colorArray = [0x6FB7B7,0xFF44FF,0x2828FF,0x00FFFF,0x28FF28,0xC07AB8,0xFF2D2D,0xFF5809,0xFF44FF,0x984B4B]
let colorArray = [ 0x2828FF,0xFC6241,0x00FFFF,0x02F78E,0xAE57A4,0xFF2D2D,0x17A288,0x9AFF02,0xFFFEA2,0xBFEAA2]

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
    

    
    @IBOutlet weak var SetupPersonTableView: UITableView!
    
    @IBOutlet weak var showDate: UILabel!{
        didSet{
            showDate.isUserInteractionEnabled = true
            showDate.isMultipleTouchEnabled = true
        }
    }

  //JTApple Calendar
    
    @IBOutlet weak var showClassOfCalendarView: JTAppleCalendarView!
    
    @IBOutlet weak var theCoverView: UIView!
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        // Do any additional setup after loading the view.
        SetupPersonTableView.delegate = self
        SetupPersonTableView.dataSource = self
        setupCalendarView()
        showDetailOfLabel.isHidden = true
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
            guard let item = classTypeCDManager.itemWithIndex(index: i) else {return }
            guard let typeName = item.typeName else {return }
            classTypeArray.append(typeName)
        }
        
    }//viewDidLoad Here
    override func viewWillAppear(_ animated: Bool) {
        animateCellView()   //暫時先不採用
    }
    //MARK: - Tabel Cell animate show
    func animateCellView() {
        SetupPersonTableView.reloadData()
        
        let cells = SetupPersonTableView.visibleCells
        let tableHeight: CGFloat = SetupPersonTableView.bounds.size.width
        
        for i in cells {
            let cell : UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: -tableHeight, y: 0)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.0,
                           delay: 0.3*Double(index),
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .transitionFlipFromLeft  ,
                           animations: {
                            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            index += 1
        }
    }

    
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
    func setupMainView(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "star.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        self.theCoverView.backgroundColor = UIColor(patternImage: image)
    }
    
    //MARK: - Reset the person hours
    func resetPersonHours(){
        for index in 0..<personCDManager.count(){
            guard let item = personCDManager.itemWithIndex(index: index) else {return }
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
            guard let item = calendarCDManager.itemWithIndex(index: i) else {return }
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
            showDate.text = "人員尚未有排班紀錄"
            showClassOfCalendarView.reloadData()
            return
        }
        let monthOfYear = everyMonthDictionary[titleIndex]
            for (key,_) in monthOfYear{
                formatter.dateFormat = "yyyy MM dd"
                guard let thisMonthMiddle = formatter.date(from:"\(key) 15") else {
                    print("在這出門了")
                    return }
                //let it always scroll to the correct month
                showClassOfCalendarView.reloadData()
                showClassOfCalendarView.scrollToDate(thisMonthMiddle)
                
                showDate.text = key
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
                    for typeIndex in 0..<classTypeArray.count{
                        if  classType == classTypeArray[typeIndex] {
                            validCell.selectedView.isHidden = false
                            validCell.selectedView.backgroundColor = UIColor(colorWithHexValue:
                                colorArray[typeIndex])
                        }
                    }
                }
            }
        }
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
        guard let item = personCDManager.itemWithIndex(index: indexPath.item) else {return cell}
         self.personArray.append(item)
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 10
        cell.textLabel?.textColor = UIColor(colorWithHexValue: 0xffffff)
        cell.detailTextLabel?.textColor = UIColor(colorWithHexValue: 0xffffff)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(item.overtime)
     
        let customView = UIView()
        
        customView.backgroundColor = UIColor(colorWithHexValue: 0x46A3FF).withAlphaComponent(0.3)
        cell.selectedBackgroundView = customView
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        everyMonthDictionary.removeAll() /// when change person reset all dictionary
        titleIndex = 0
        self.showDetailOfLabel.isHidden = false
        self.theCoverView.backgroundColor = UIColor(colorWithHexValue: 0x3C3C3C)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.theCoverView.backgroundColor = UIColor(colorWithHexValue: 0x5B5B5B)
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 0.5, animations: {
                     self.theCoverView.backgroundColor = UIColor(colorWithHexValue: 0x5B5B5B).withAlphaComponent(0.7)
                    self.theCoverView.transform = CGAffineTransform(translationX: 0.0, y: self.view.frame.size.height)
                }, completion: { (finished) in
                    if finished {
                        self.theCoverView.isHidden = true
                    }
                })
            }
        }
        
        self.showDetailOfLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        personTmpIndex = indexPath
       
       //////========
        getCalendarDetailData()
        }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let item = personCDManager.itemWithIndex(index: indexPath.item) else {return }
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
  
    func calendar(_ calendar: JTAppleCalendarView,
                              didDeselectDate date: Date,
                              cell: JTAppleCell?,
                              cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }

}

