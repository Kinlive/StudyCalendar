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
                                                sortKey: "typeName",
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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPersonCell(object:)), name: NSNotification.Name(rawValue: "RefreshTheCell"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPersonCellView), name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil )
        

         }//viewDidLoad here
    
    
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
    func handleCellTextColor(view : JTAppleCell? , cellState : CellState){
        guard let validCell = view as? CustomCell else{ return }
        if validCell.isSelected{
//            validCell.dateLabel.textColor = selectedMonthColor //Change date color when selected
        }else{
            if cellState.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = monthColor
            }else {
                validCell.dateLabel.textColor = outsideMonthColor
//                validCell.isUserInteractionEnabled = false
            }
                validCell.selectedView.isHidden = true
        }
    }
    func handleCellSelected(view : JTAppleCell? , cellState : CellState){
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
        //To save year and month 
            BaseSetup.currentCalendarYear = self.year.text
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
                let alert = UIAlertController(title: nil, message: "該人員這天已安排過班別囉!!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
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
            popover.delegate = self as? UIPopoverPresentationControllerDelegate
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
    func showView( whichShow : WhichViewShow ){
        var willShowVC : UIViewController?
        switch whichShow {
        case .person:
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonSetupView") as? SetupPersonViewController
        case .classType :
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetupClassType") as? SetupClassTypeViewController
        case .calendarDetail :
            willShowVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarDetailView") as? CalendarDetailViewController
        }
        guard let showVC = willShowVC else { return }
        showVC.modalPresentationStyle = .popover
        let popover =  showVC.popoverPresentationController!
        popover.delegate = self as? UIPopoverPresentationControllerDelegate
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
        showVC.preferredContentSize = CGSize(width: mainUIView.frame.width*3/4 , height: mainUIView.frame.height*3/4)
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
    
//MARK: - IBAction here
    @IBAction func personDetailButton(_ sender: UIButton) {
        showView(whichShow: .person)
    }
    @IBAction func classTypeDetail(_ sender: UIButton) {
        showView(whichShow: .classType)
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
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameters
    }
   
}
// MARK: - JTAppleCalendarViewDelegate
extension ViewController:JTAppleCalendarViewDelegate{
    //Display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        formatter.dateFormat = "dd"
        cell.dateLabel.text = formatter.string(from: cellState.date)
//        cell.selectedView.layer.cornerRadius = cell.selectedView.frame.size.width/2
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }
    //Didselect
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        formatter.dateFormat = "dd"
        BaseSetup.selectedDay = formatter.string(from: cellState.date)
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        showView(whichShow: .calendarDetail)
        print("Cellstate is \n: \(cellState.row())\n and \(cellState.dateSection().range) \n and other \(cellState.date)\n and \(cellState.text)\n ")
        
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
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

