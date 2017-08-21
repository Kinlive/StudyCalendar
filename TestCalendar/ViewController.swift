//
//  ViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/6.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData


let personCDManager = CoreDataManager<PersonData>(
                                                initWithModel: "DataBase",
                                                dbFileName: "personData.sqlite",
                                                dbPathURL: nil,
                                                sortKey: "name",
                                                entityName: "PersonData")
let classTypeCDManager = CoreDataManager<ClassTypeData>(
                                                initWithModel: "DataBase",
                                                dbFileName: "classTypeData.sqlite",
                                                dbPathURL: nil,
                                                sortKey: "startTime",
                                                entityName: "ClassTypeData")
let calendarCDManager = CoreDataManager<CalendarData>(
                                                initWithModel: "DataBase",
                                                dbFileName: "calendarData.sqlite",
                                                dbPathURL: nil,
                                                sortKey: "date",
                                                entityName: "CalendarData")
//formatter yyyy
let years = ["2017","2018","2019","2020","2021","2022","2023","2024","2025","2026"]
let months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
//For save endIndexPath 
let endIndexPathLock = NSLock()


class ViewController: UIViewController{
    let formatter = DateFormatter()
    let currentFormatter = DateFormatter()
    let currentDate = Date()
    //celander here
    //test 裝值
    var perPerson = [SetupOnStartData]()
    let baseSetup = BaseSetup()
   //
    var longPress = UILongPressGestureRecognizer()
    let gsManager = GestureSetupManager()
    let personCVCoorinator = PersonCollectionViewCoorinator()
   
  
    @IBOutlet weak var weekBar: UIView!
    @IBOutlet var mainUIView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var personCellView: UICollectionView!
    
    @IBOutlet weak var classTypeIBOut: UIButton!
    @IBOutlet weak var personIBOut: UIButton!
    @IBOutlet weak var settingIBOut: UIButton!
    
    
   //  personCellView: UICollectionView!
    //Calendar color setup ..
    let outsideMonthColor = UIColor(colorWithHexValue : 0x333333)
    let monthColor = UIColor(colorWithHexValue: 0xffffff)
    let selectedMonthColor = UIColor(colorWithHexValue : 0xffffff)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue : 0x4e3f5d)
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let cloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        print("CloudURL: \(String(describing: cloudURL?.absoluteString))")
        
        
//        print("測試\(RecordName)")
        setupMainView()
        setupCalendarView()
        
        personCellView.delegate = personCVCoorinator
        personCellView.dataSource = personCVCoorinator
        
        formatter.dateFormat = "yyyy"
        let thisYear = formatter.string(from: Date())
        formatter.dateFormat = "MM"
        let thisMonth = formatter.string(from: Date())
        formatter.dateFormat = "yyyy MM dd"
        guard let thisMonthMiddle = formatter.date(from: "\(thisYear) \(thisMonth) 15") else { return }
        
        //let it always scroll to the correct month
        calendarView.scrollToDate(thisMonthMiddle)
        currentFormatter.dateFormat = "yyyy MM dd"
        currentFormatter.timeZone = Calendar.current.timeZone
        currentFormatter.locale = Calendar.current.locale
        
      //  add longpress and setup
        longPress.addTarget(self, action: #selector(longPressGestureRecognized(_:)))
        longPress.minimumPressDuration = 0.1
        mainUIView.addGestureRecognizer(longPress)
        
        //NotificationCenter
        NotificationCenter.default.addObserver(
                                                        self,
                                                        selector: #selector(refreshPersonCell(object:)),
                                                        name: NSNotification.Name(rawValue: "RefreshTheCell"),
                                                        object: nil)
        NotificationCenter.default.addObserver(
                                                        self,
                                                        selector: #selector(refreshPersonCellView),
                                                        name: NSNotification.Name(rawValue: "RefreshAllCell"),
                                                        object: nil )
        NotificationCenter.default.addObserver(
                                                        self, selector: #selector(refreshCalendarCell(object:)),
                                                        name: NSNotification.Name(rawValue: "RefreshCalendarCell"),
                                                        object: nil)
       
        
         }//viewDidLoad here
     
    func setupMainView(){
        //Setup all border
        year.layer.borderWidth = 1.0
        year.layer.borderColor = UIColor.gray.cgColor
        month.layer.borderWidth = 1.0
        month.layer.borderColor = UIColor.gray.cgColor
        weekBar.layer.borderWidth = 1.0
        weekBar.layer.borderColor = UIColor.gray.cgColor
        classTypeIBOut.layer.borderWidth = 1.0
        classTypeIBOut.layer.borderColor = UIColor.gray.cgColor
        personIBOut.layer.borderWidth = 1.0
        personIBOut.layer.borderColor = UIColor.gray.cgColor
        settingIBOut.layer.borderWidth = 1.0
        settingIBOut.layer.borderColor = UIColor.gray.cgColor
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "star.jpg")!)
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background.jpg")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
    }
    //MARK: - Calender setup start here
    func setupCalendarView(){
        //Setup calendar space
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
         calendarView.visibleDates { visibleDates in
             //Setup labels
         self.setupViewOfCalendar(from: visibleDates)
        }
      
    }
    func handleCellTextColor(view : JTAppleCell? ,
                                                cellState : CellState){
        
        guard let validCell = view as? CustomCell else{ return }
        
        if validCell.isSelected{
//            validCell.dateLabel.textColor = selectedMonthColor //Change date color when selected
        }else{
            if cellState.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = monthColor
            }else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
                validCell.selectedView.isHidden = true
        }
    }
    func handleCellSelected(view : JTAppleCell? ,
                                              cellState : CellState){
        
        guard let validCell = view as? CustomCell else{ return }
        let stateDate = currentFormatter.string(from: cellState.date)
        let currenteDate = currentFormatter.string(from: currentDate)
//                  print("firstShow:\(stateDate) and \(currenteDate)")
        if(stateDate == currenteDate){
            validCell.currentView.isHidden = false
//            validCell.dateLabel.textColor = selectedMonthColor
        }else{
            validCell.currentView.isHidden = true
        }
        
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
    func setupViewOfCalendar(from visibleDates : DateSegmentInfo){
            let date = visibleDates.monthDates.first!.date
            self.formatter.dateFormat = "yyyy"
            self.year.text = self.formatter.string(from: date)
        
            BaseSetup.currentCalendarYear = self.year.text //To save year and month
            self.formatter.dateFormat = "MMMM"
            self.month.text = self.formatter.string(from: date)
            self.formatter.dateFormat = "MM"
            BaseSetup.currentCalendarMonth = self.formatter.string(from: date)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Description
    ///
    /// - Parameter longPress: longPress description
    func longPressGestureRecognized(_ gestureRecognizer: UILongPressGestureRecognizer){
        
        gsManager.longPressOnView(
                                                            gestureRecognizer: gestureRecognizer,
                                                            mainUIView: mainUIView,
                                                            calendarView: calendarView,
                                                            personCellView: personCellView) { (indexPath, isSame) in
            if isSame == false{
            //create popup view 
                self.createPopupView()
                guard let item = personCDManager.fetchedResultsController.object(at: indexPath) as? PersonData else { return }
                print("Test  \(String(describing: item.name)) : overtime \(item.overtime) \n")
            }else{
                let alert = UIAlertController(title: nil,
                                                               message: "該人員這天已安排過班別囉!!",
                                                               preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok",
                                                      style: .default,
                                                      handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
           
        }
    }//longpress func here
    
    //MARK: - createPopoverView
    func createPopupView(){
        
            let popupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupMenu") as! PopupMenuViewController
            popupVC.modalPresentationStyle = .popover
        
            let popover = popupVC.popoverPresentationController!
            popover.delegate = self //as? UIPopoverPresentationControllerDelegate
            popover.permittedArrowDirections.remove(.any)
            popover.sourceView = self.view
        
            let mainViewX = self.mainUIView.center.x
            let mainViewY = self.mainUIView.center.y
            let width = self.view.frame.width/5
            let height = self.view.frame.height/4
        
            popover.sourceRect = CGRect(
                                                x: mainViewX-width/2,
                                                y: mainViewY-height/2,
                                                width: width,
                                                height: height)
            present(popupVC, animated: true, completion: nil)

        }
    //MARK: - Create PersonSetupView
    func showView( whichShow : WhichViewShow, sender : Any? ){
        
        var willShowVC : UIViewController?
        
        switch whichShow {
        case .person:
            
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonSetupView") as? SetupPersonViewController
            guard let willShowVC = willShowVC else { return }
            setupThePersonVC(showVC: willShowVC, sender: sender)
            
        case .classType :
            
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetupClassType") as? SetupClassTypeViewController
            guard let willShowVC = willShowVC else { return }
            setupTheClassTypeVC(showVC: willShowVC , sender: sender)
            
        case .calendarDetail :
            
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarDetailView") as? CalendarDetailViewController
            guard let willShowVC = willShowVC else { return }
            setupOtherVC(showVC: willShowVC)
            
        case .settingView :
            
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController
            guard let willShowVC = willShowVC else { return }
//            setupOtherVC(showVC: willShowVC)
            setupSettingVC(showVC: willShowVC, sender: sender)
            
        }
       
    
//        self.addChildViewController(showVC) 可將底部透明化的
//        let testViewFrame = showVC.view.frame
//        let testView = UIView(frame: testViewFrame)
//        self.view.addSubview(testView)
//        testView.addSubview(showVC.view)
//        showVC.didMove(toParentViewController: self)
//        self.view.addSubview(testView)

    }
    
    
    
    //MARK: - Setup Every popup VC 
    func setupTheClassTypeVC(showVC : UIViewController , sender : Any? ) {
        
        guard let sender = sender as? UIButton else { return }
        let senderRect = sender.bounds
        
        showVC.modalPresentationStyle = .popover
        guard let popover =  showVC.popoverPresentationController else { return }
        popover.delegate = self //as? UIPopoverPresentationControllerDelegate
        popover.permittedArrowDirections = .up
        popover.sourceView = classTypeIBOut
        popover.sourceRect = senderRect
        showVC.preferredContentSize = CGSize(width: sender.frame.width, height: sender.frame.width*1.5)
        self.present(showVC, animated: true, completion: nil)
    }
    
    func setupThePersonVC(showVC : UIViewController , sender : Any?){
        
        guard let sender = sender as? UIButton else { return }
        let senderRect = sender.bounds
        
        showVC.modalPresentationStyle = .popover
        guard let popover =  showVC.popoverPresentationController else { return }
        popover.delegate = self //as? UIPopoverPresentationControllerDelegate
        popover.permittedArrowDirections = .up
        popover.sourceView = personIBOut
        popover.sourceRect = senderRect
        showVC.preferredContentSize = CGSize(width: mainUIView.frame.width*3/4 ,
                                                                            height: mainUIView.frame.height*3/4)
        self.present(showVC, animated: true, completion: nil)
        
    }
    
    func setupSettingVC(showVC : UIViewController , sender : Any? ){
        guard let sender = sender as? UIButton else { return }
        let senderRect = sender.bounds
        
        showVC.modalPresentationStyle = .popover
        guard let popover =  showVC.popoverPresentationController else { return }
        popover.delegate = self //as? UIPopoverPresentationControllerDelegate
        popover.permittedArrowDirections = .up
        popover.sourceView = settingIBOut
        popover.sourceRect = senderRect
        self.preferredContentSize = CGSize(width: sender.frame.width,
                                                                    height: sender.frame.width*0.8)
        self.present(showVC, animated: true, completion: nil)
    }
    
    func setupOtherVC( showVC : UIViewController ){
        
//        guard let showVC = willShowVC else { return }
        showVC.modalPresentationStyle = .popover
        guard let popover =  showVC.popoverPresentationController else { return }
        popover.delegate = self //as? UIPopoverPresentationControllerDelegate
        popover.permittedArrowDirections.remove(.any)
        popover.sourceView = self.view
        let calendarViewX = self.mainUIView.center.x
        let calendarViewY = self.mainUIView.center.y
        let width = self.calendarView.frame.width
        let height = self.calendarView.frame.height
        
        
        
        popover.sourceRect = CGRect(
                                                            x: calendarViewX-width/2,
                                                            y: calendarViewY-height/2,
                                                            width: width,
                                                            height: height)
        
        showVC.preferredContentSize = CGSize(width: mainUIView.frame.width*3/4 ,
                                                                            height: mainUIView.frame.height*3/4)
        present(showVC, animated: true, completion: nil)
    }
    
    
   //MARK: - refresh the cell
    func refreshPersonCell( object : Notification){
        let indexPath = object.object as! [IndexPath]
        self.personCellView.reloadItems(at: indexPath )
        print("Test refresh happen?")
    }
    func refreshPersonCellView(){
        self.personCellView.reloadData()
        
    }
    func refreshCalendarCell( object : Notification){
        let indexPath = object.object as! [IndexPath]
        calendarView.reloadItems(at: indexPath)
    }
//    func refreshCalendarDate( object : Notification){
//        let date = object.object as! [Date]
//        
//        DispatchQueue.main.async {
//             self.calendarView.reloadDates(date)
//        }
//       
//        print("refreshCalendarDate 成功?")
//    }
    
    
    //MARK: - Set cell's classType amount
    func setHowMuchPersonOfTypeClass(with cell : CustomCell){
        
        guard let cellsDate = cell.date else { return }
        
        formatter.dateFormat = "yyyy MM dd"
        let thisDate = formatter.string(from: cellsDate)
        var calendarItemArray = [CalendarData]()
        var classTypeItemArray = [ClassTypeData]()
        
        for i in 0..<calendarCDManager.count(){
            let item = calendarCDManager.itemWithIndex(index: i)
            if item.date == thisDate {
                calendarItemArray.append(item)
            }
        }// Get all calendarDataItem
        
        for i in 0..<classTypeCDManager.count(){
            let classTypeItem = classTypeCDManager.itemWithIndex(index: i)
            classTypeItemArray.append(classTypeItem)
        }//Get all classTypeItem
        
//        var indexArray = [Int?].init(repeating: nil, count: classTypeItemArray.count)
        var indexArray = [(String , Int)?].init(repeating: nil, count: classTypeItemArray.count)
        
        for ( index , classTypeItem) in classTypeItemArray.enumerated(){
            guard let typeName = classTypeItem.typeName else { return }
            
            var howMuchNumber = 0
            for calendarItem in calendarItemArray {
                if calendarItem.typeName == classTypeItem.typeName{
                    howMuchNumber += 1
                }
            }
             indexArray[index] = ( typeName , howMuchNumber)
        }
//        print("測試裝一下索引陣列\(indexArray)")//////
        
        containWhichClassType(cell: cell, indexArray: indexArray)
//        
//        if calendarItemArray.count > 0 {
//            cell.howManyPerson.text  = String(calendarItemArray.count)
//            cell.howManyPerson.layer.borderWidth = 2
//            //            cell.howManyPerson.layer.cornerRadius = 5
//            cell.howManyPerson.layer.borderColor = UIColor.white.cgColor
//            cell.howManyPerson.isHidden = false
//        }else if calendarItemArray.count == 0{
//            cell.howManyPerson.isHidden = true
//        }
    }
    
//    typealias HandleCompletion = (_ success : Bool ) -> Void
    //MARK: - To contain Which classType of person amount
    func containWhichClassType( cell : CustomCell ,
                                                       indexArray : [(String, Int)?]) {
        cell.classType1Person.isHidden = true
        cell.classType2Person.isHidden = true
        cell.classType3Person.isHidden = true
        cell.classType4Person.isHidden = true
        cell.howManyPerson.isHidden = true
//        let indexCount = indexArray.count
        
        for (index, element ) in indexArray.enumerated() {  // element : (typeName ,  howManyPerson)
            
            guard let element = element else { return }
            
            if element.1 != 0 {
                
                switch index {
                case 0:
                    cell.classType1Person.text = String(element.1)
                    cell.classType1Person.layer.borderWidth = 1
                    cell.classType1Person.layer.borderColor = UIColor.white.cgColor
                    cell.classType1Person.backgroundColor = UIColor.init(colorWithHexValue: colorArray[index])
                    cell.classType1Person.isHidden = false
                case 1:
                    cell.classType2Person.text = String(element.1)
                    cell.classType2Person.layer.borderWidth = 1
                    cell.classType2Person.layer.borderColor = UIColor.white.cgColor
                    cell.classType2Person.backgroundColor = UIColor.init(colorWithHexValue: colorArray[index])
                    cell.classType2Person.isHidden = false
                case 2:
                    cell.classType3Person.text = String(element.1)
                    cell.classType3Person.layer.borderWidth = 1
                    cell.classType3Person.layer.borderColor = UIColor.white.cgColor
                    cell.classType3Person.backgroundColor = UIColor.init(colorWithHexValue: colorArray[index])
                    cell.classType3Person.isHidden = false
                case 3:
                    cell.classType4Person.text = String(element.1)
                    cell.classType4Person.layer.borderWidth = 1
                    cell.classType4Person.layer.borderColor = UIColor.white.cgColor
                    cell.classType4Person.backgroundColor = UIColor.init(colorWithHexValue: colorArray[index])
                    cell.classType4Person.isHidden = false
                case 4:
                    cell.howManyPerson.text = String(element.1)
                    cell.howManyPerson.layer.borderWidth = 1
                    cell.howManyPerson.layer.borderColor = UIColor.white.cgColor
                    cell.howManyPerson.backgroundColor = UIColor.init(colorWithHexValue: colorArray[index])
                    cell.howManyPerson.isHidden = false
                default:
                    break
                }
            }else {// Will Fix hidden to opacity 
            }
        }
        
    }
    
//MARK: - IBAction here
    @IBAction func personDetailButton(_ sender: UIButton) {
        showView(whichShow: .person, sender: sender)
    }
    @IBAction func classTypeDetail(_ sender: UIButton) {
        showView(whichShow: .classType, sender: sender)
    }
    @IBAction func settingViewBtn(_ sender: UIButton) {
        showView(whichShow: .settingView, sender: sender)
    }
    


    
}//class out

// MARK: - JTAppleCalendarViewDataSource
extension ViewController:JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
       
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate,
                                                                              endDate: endDate)
        
        return parameters
    }
   
}
// MARK: - JTAppleCalendarViewDelegate
extension ViewController:JTAppleCalendarViewDelegate{
    //Display the cell
    func calendar(_ calendar: JTAppleCalendarView,
                                           cellForItemAt date: Date,
                                                    cellState: CellState,
                                                indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell",
                                                                                         for: indexPath) as! CustomCell
                        
        cell.date = date
        
        formatter.dateFormat = "dd"
        cell.dateLabel.text = formatter.string(from: cellState.date)
        //        cell.selectedView.layer.cornerRadius = cell.selectedView.frame.size.width/2
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor
        setHowMuchPersonOfTypeClass(with: cell)
        
       return cell
    }
    //Didselect
    func calendar(_ calendar: JTAppleCalendarView,
                            didSelectDate date: Date,
                            cell: JTAppleCell?,
                            cellState: CellState) {
        
        BaseSetup.selectedDay = date
//        BaseSetup.refreshDate = cellState.date
        guard let cell = cell else { return }
        BaseSetup.refreshCellOfIndexPath = calendar.indexPath(for: cell)
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        showView(whichShow: .calendarDetail, sender: nil)
        print("Cellstate is \n: \(cellState.row())\n and  \n and other \(cellState.date)\n and \(cellState.text)\n ")
        
    }
    func calendar(_ calendar: JTAppleCalendarView,
                            didDeselectDate date: Date,
                            cell: JTAppleCell?,
                            cellState: CellState) {
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                            didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setupViewOfCalendar(from: visibleDates)
    }
}

// MARK: - UIColor convenience init
extension UIColor{
    //針對UIColor進行擴充
    convenience init(colorWithHexValue value : Int , alpha : CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green : CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue : CGFloat((value & 0x0000FF)) / 255.0,
            alpha : alpha
        )
    }
}

//MARK: - Popover delegate methods 
extension ViewController : UIPopoverPresentationControllerDelegate {
    
    
}
