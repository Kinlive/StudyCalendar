//
//  ViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/6.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar
class ViewController: UIViewController {
    let formatter = DateFormatter()
    let currentFormatter = DateFormatter()
    let currentDate = Date()
    var numberItem = [Int]() //FIXME: numberArray here
    let spacing :CGFloat = 3
    let itemCount :CGFloat = 2
    var longPress = UILongPressGestureRecognizer()
   
   
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var personCellView: UICollectionView!
    //Calendar color setup ..
    let outsideMonthColor = UIColor(colorWithHexValue : 0xcccccc)
    let monthColor = UIColor(colorWithHexValue: 0x000000)
    let selectedMonthColor = UIColor(colorWithHexValue : 0xffffff)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue : 0x4e3f5d)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        personCellView.delegate = self
        personCellView.dataSource = self
        
        for i in 0...25 {//
           numberItem.append(i)
        }
        calendarView.scrollToDate(currentDate)
        currentFormatter.dateFormat = "yyyy MM dd"
        currentFormatter.timeZone = Calendar.current.timeZone
        currentFormatter.locale = Calendar.current.locale
      // test add longpress 
        longPress.addTarget(self, action: #selector(longPressGestureRecognized(_:)))
        personCellView.addGestureRecognizer(longPress)
    }
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
//        let longPress = gestureRecognizer 
        gestureRecognizer.minimumPressDuration = 0.25
        let state = gestureRecognizer.state
        //longPress在CellView上的位置,得到CGPoint(x,y)
        let locationInView = gestureRecognizer.location(in: personCellView)
//        personCellView.indexPathForItem(at: CGPoint)
        //藉由 CGPoint(x,y)的點 找到對於personCellView內的索引路徑
        //可以得知長按的是第幾個section的第幾個item
        guard var indexPath = personCellView.indexPathForItem(at: locationInView) else {return}

        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path{
            static var initialIndexPath : IndexPath? = nil //FIXME: maybe to fix
        }
        //FIXME : switch something...
        switch state {
        case .began:
                Path.initialIndexPath = indexPath
                guard let cell = personCellView.cellForItem(at: indexPath) else {return}
                My.cellSnapshot = snapshopOfCell(inputView: cell)
                guard let cellSnapshot = My.cellSnapshot else {return}
                var center = cell.center
                cellSnapshot.center = center
                cellSnapshot.alpha = 0.0
                personCellView.addSubview(cellSnapshot)
                UIView.animate(withDuration: 0.1, animations: {
                    center.y = locationInView.y
                    cellSnapshot.center = center
                    cellSnapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    cellSnapshot.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { finished in
                    if finished{
                        cell.isHidden = true
                        NSLog("Case11111111")
                    }
                })
            break
            //case 2 
        case .changed :
            guard let cellSnapshot = My.cellSnapshot else {return}
             var center = cellSnapshot.center
            center.y = locationInView.y
           cellSnapshot.center = center
            if (indexPath != Path.initialIndexPath){
                //進行交換
                guard let initialIndexPath = Path.initialIndexPath else {return}
                swap(&numberItem[(indexPath.row)], &numberItem[(initialIndexPath.row)])
                personCellView.moveItem(at: initialIndexPath, to: indexPath)
                Path.initialIndexPath = indexPath
                NSLog("Case2222222")
            }
            break
        default:
            guard let initialIndexPath = Path.initialIndexPath else {return}
            guard let cell = personCellView.cellForItem(at: initialIndexPath)  else {return}
            cell.isHidden = false
            cell.alpha = 0.0
            guard let cellSnapshot = My.cellSnapshot else { return}
            UIView.animate(withDuration: 0.25, animations: { 
                cellSnapshot.center = (cell.center)
                cellSnapshot.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                cellSnapshot.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { finished in
                if finished {
                    Path.initialIndexPath = nil
                   cellSnapshot.removeFromSuperview()
                    My.cellSnapshot = nil
                   
                    NSLog("Case333333333")
                }
            })
            break
        }
        
    }//func longPress here 
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
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
// MARK: - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource
extension ViewController:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let personView = (UIScreen.main.bounds.size.width)/4
        let width = (personView-itemCount*spacing)/itemCount
        let size = CGSize(width: width, height: width)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //..
        return numberItem.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //..
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as! PersonCell
        cell.personName.text = String(numberItem[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
