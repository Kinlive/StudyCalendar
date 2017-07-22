//
//  ViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/6.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar



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
  
    
  
    @IBOutlet var mainUIView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var personCellView: UICollectionView!
   //  personCellView: UICollectionView!
    //Calendar color setup ..
    let outsideMonthColor = UIColor(colorWithHexValue : 0xcccccc)
    let monthColor = UIColor(colorWithHexValue: 0x000000)
    let selectedMonthColor = UIColor(colorWithHexValue : 0xffffff)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue : 0x4e3f5d)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        
        personCellView.delegate = personCVCoorinator
        personCellView.dataSource = personCVCoorinator
      
        calendarView.scrollToDate(currentDate)
        currentFormatter.dateFormat = "yyyy MM dd"
        currentFormatter.timeZone = Calendar.current.timeZone
        currentFormatter.locale = Calendar.current.locale
        
      //  add longpress and setup
        longPress.addTarget(self, action: #selector(longPressGestureRecognized(_:)))
        longPress.minimumPressDuration = 0.25
        mainUIView.addGestureRecognizer(longPress)
    //        calendarView.addGestureRecognizer(longPress)
    //        personCellView.addGestureRecognizer(longPress)
        
//        for i in 0...5 {
//            perPerson.append(PersonDetail(hours: i, overHours: i*2))
//            NSLog("this array is \(perPerson[i].hours) and \(perPerson[i].overHours)")
//        }
//        NSLog(" this is struct in \(perPerson.count)" )
        
        
        for _ in baseSetup.personCount {
            let setupOnStart = SetupOnStartData(name: nil,
                                                hours: baseSetup.hoursOfMonth,
                                                overHours: baseSetup.overHoursOfMonth)
             print(setupOnStart.hours! ,setupOnStart.overHours!)
            perPerson.append(setupOnStart)
           
        }
            print("12111111")
            print(perPerson)
        
        
        
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
            validCell.dateLabel.textColor = selectedMonthColor
        }else{
            if cellState.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = monthColor
            }else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
                validCell.selectedView.isHidden = true
        }
    }
    func handleCellSelected(view : JTAppleCell? , cellState : CellState){
        guard let validCell = view as? CustomCell else{ return }
        let stateDate = currentFormatter.string(from: cellState.date)
        let currenteDate = currentFormatter.string(from: currentDate)
        //          print("firstShow:\(stateDate) and \(currenteDate)")
        if(stateDate == currenteDate){
            validCell.currentView.isHidden = false
//            validCell.dateLabel.textColor = selectedMonthColor
        }else{
            validCell.currentView.isHidden = true
        }

        if validCell.isSelected{
            validCell.selectedView.isHidden = false
        }else{
            validCell.selectedView.isHidden = true
        }
    }
    func setupViewOfCalendar(from visibleDates : DateSegmentInfo){
            let date = visibleDates.monthDates.first!.date
            self.formatter.dateFormat = "yyyy"
            self.year.text = self.formatter.string(from: date)
            self.formatter.dateFormat = "MMMM"
            self.month.text = self.formatter.string(from: date)
        
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
                                personCellView: personCellView) { indexPath in
            //create popup view 
                    self.createPopupView()
               //     let cell = self.personCellView.cellForItem(at: indexPath) as! PersonCell
            //        cell.removeFromSuperview()
//                    self.personCellView.reloadData()
                self.personCellView.reloadItems(at: [indexPath])
                                    
        }
    }
    //MARK: - createPopupView
        func createPopupView(){
            let popupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupMenu") as! PopupMenuViewController
            self.addChildViewController(popupVC)
            popupVC.view.frame = self.view.frame
            self.view.addSubview(popupVC.view)
            popupVC.didMove(toParentViewController: self)
        }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "ShowSetupPerson") {
//            let setupVC = segue.destination
//            let popoverVC = setupVC.popoverPresentationController
//            let mainViewRect = CGRect(x: 0, y: 0, width: self.view.frame.width*3/4, height: self.view.frame.height*3/4)
//            
//            popoverVC?.sourceRect = mainViewRect
//        }
//    }

    
    @IBAction func personDetailButton(_ sender: UIButton) {
        //...
        
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
      
        cell.dateLabel.text = cellState.text
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    //Didselect
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
         handleCellSelected(view: cell, cellState: cellState)
         handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewOfCalendar(from: visibleDates)
    }
//    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
////        let date1 = Date.init()
//        
//        return true;
//    }

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

