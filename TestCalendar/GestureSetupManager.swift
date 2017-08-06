//
//  GestureSetupManager.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/18.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar

let snapshotScaleX : CGFloat = 0.7
let snapshotScaleY : CGFloat = 0.7

class GestureSetupManager: NSObject {
    var perPerson = [PersonDetail]()
    
    let firstIndexPathLock = NSLock()
    
    let moveOverLock = NSLock()
    
    var baseSetup = BaseSetup()
    
    struct My {
        static var cellSnapshot : UIView?
    }
    struct Path{
        //用來存放找到personCell的索引
        static var personCellIndexPath : IndexPath?
        static var calendarCellIndexPath : IndexPath?
        static var firstLongPressIndexPath : IndexPath?
        static var moveOverIndexPath : IndexPath?
    }
    
    //typealias HandlePersonDetail = (person
    typealias GestureEnd = ( IndexPath , Bool ) -> Void
    func longPressOnView(
                    gestureRecognizer: UILongPressGestureRecognizer,
                    mainUIView: UIView ,
                    calendarView:JTAppleCalendarView ,
                    personCellView:UICollectionView,
                    gestureEnd : @escaping GestureEnd =  { _  -> Void  in }
                    ) {
        
        let state = gestureRecognizer.state
        //longPress在CellView上的位置,得到CGPoint(x,y)
        let locationMainView = gestureRecognizer.location(in: mainUIView)
        //        let locationInView = gestureRecognizer.location(in: personCellView)
        
        let calendarLocation = gestureRecognizer.location(in: calendarView)
//        let fakeLocation = CGPoint(x: locationMainView.x-834, y: locationMainView.y)
        let personLocation = gestureRecognizer.location(in: personCellView)
//        NSLog(" TEST:finger \(locationMainView)  and calendar \(calendarLocation)")
        //藉由 CGPoint(x,y)的點 找到對於personCellView內的索引路徑
        //indexPath可以得知長按的是第幾個section的第幾個item
        //        guard let indexPath = personCellView.indexPathForItem(at: fakeLocation) else { return }
         let indexPath = personCellView.indexPathForItem(at: personLocation) //這裡要改成使用personLocation
        if (firstIndexPathLock.try() != false){
            BaseSetup.saveFirstIndexPath = indexPath
        }
        let calendarIndexPath = calendarView.indexPathForItem(at: calendarLocation)
        
               //FIXME : switch something...
        switch state {
        case .began:
            guard let indexPath = indexPath else {return}
            Path.personCellIndexPath = indexPath
            guard let cell = personCellView.cellForItem(at: indexPath) else {return}
            
            //將長按到的cell進行快照存入cellSnapshot內
            My.cellSnapshot = snapshopOfCell(inputView: cell)
            guard let cellSnapshot = My.cellSnapshot else {return}
            
            let center = CGPoint(x:  locationMainView.x, y:  locationMainView.y)

            My.cellSnapshot?.center = center
            cellSnapshot.center = center
            cellSnapshot.alpha = 0.0
            mainUIView.addSubview(cellSnapshot)
            UIView.animate(withDuration: 0.4, animations: {
                cellSnapshot.transform = CGAffineTransform(scaleX: snapshotScaleX, y: snapshotScaleY)
                cellSnapshot.alpha = 0.98
                cell.alpha = 0.0
                cell.isHidden = true
            }, completion: { finished in
                if finished{
//                    cell.isHidden = true
                    NSLog("Case drap .start")
                }
            })
        case .changed :
//            print("去哪了1111111")
            if calendarIndexPath != nil , moveOverLock.try() != false{
                    BaseSetup.moveOverIndexPath = calendarIndexPath
            }
            
            guard let cellSnapshot = My.cellSnapshot else {return}
            cellSnapshot.transform = CGAffineTransform(scaleX: snapshotScaleX, y: snapshotScaleY)
            var center = cellSnapshot.center
            center.y = locationMainView.y
            center.x = locationMainView.x
            cellSnapshot.center = center
            if calendarIndexPath != nil{
                guard let moveOverIndexPath = BaseSetup.moveOverIndexPath else {
                    print("被moveOverIndexPath 擋住了")
                    return }
                guard let calendarCell = calendarView.cellForItem(at: moveOverIndexPath) as? CustomCell else {
                    moveOverLock.unlock()
                    print("被calendarCell 擋住了")
                    return }
                if calendarIndexPath == BaseSetup.moveOverIndexPath {
                    calendarCell.selectedView.isHidden = false
                    UIView.animate(withDuration: 0.1, animations: {
                        calendarCell.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    })
                }else {
                    calendarCell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    calendarCell.selectedView.isHidden = true
                    moveOverLock.unlock()
                    Path.moveOverIndexPath = nil
                }
            }else {
                guard let moveOverIndexPath = BaseSetup.moveOverIndexPath else {return}
                guard let calendarCell = calendarView.cellForItem(at: moveOverIndexPath) as? CustomCell else { return}
                calendarCell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                calendarCell.selectedView.isHidden = true
            }
        case .ended:
            guard let cellSnapshot = My.cellSnapshot else { return}
            //判斷落下點是在月曆還是人員
            //將main計算寬度換成 personLocation.x >= 0 就不進入 ex: cellSnapshot.center.x <= mainUIView.frame.size.width*3/4
            //以及第二判斷條件可換乘 calendarLocation.y <0 就不進入  ex:cellSnapshot.center.y >= mainUIView.frame.size.height*1/5
            if personLocation.x < 0,cellSnapshot.center.y >= mainUIView.frame.size.height*1/5{
                guard let calendarIndexPath = calendarIndexPath else {return}
                ////==============Save drop.end calendarCell IndexPath
                BaseSetup.saveEndIndexPath = calendarIndexPath
                let calendarCell = calendarView.cellForItem(at: calendarIndexPath) as! CustomCell
                guard let personCellIndexPath = Path.personCellIndexPath else {return}
                let cell = personCellView.cellForItem(at: personCellIndexPath) as! PersonCell

                BaseSetup.dropEndCalendarDate = calendarCell.dateLabel.text
                cell.isHidden = false
                cell.alpha = 0.0
//                 self.createCancelView(mainUIView: mainUIView)
                UIView.animate(withDuration: 0.3, animations: {
                    //月曆cell放大
                    calendarCell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    //                calendarCell.backgroundColor = UIColor(colorWithHexValue: 0xaa66aa)
                    cellSnapshot.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    cellSnapshot.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { finished in
                    if finished {
                        calendarCell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        calendarCell.selectedView.isHidden = true  //控制月曆選擇顯示
                        Path.personCellIndexPath = nil
                        cellSnapshot.removeFromSuperview()
                        My.cellSnapshot = nil
                        NSLog("Case:Drag. end")
                       
                    }
                })
                let checkIsSamePerson = checkIsSamePersonOnCalendar(personIndexPath: personCellIndexPath)
                print("test checkIsSamePerson:\(checkIsSamePerson)")
                //test for hours pass to
                gestureEnd(personCellIndexPath , checkIsSamePerson)
                firstIndexPathLock.unlock()
            }else{
                guard let personCellIndexPath = Path.personCellIndexPath else {
                    return}
                guard let cell = personCellView.cellForItem(at: personCellIndexPath)  else {return}
                cell.isHidden = false
                cell.alpha = 1
                Path.personCellIndexPath = nil
                cellSnapshot.removeFromSuperview()
                My.cellSnapshot = nil
                firstIndexPathLock.unlock()
            }
        default:
            break
        }///switch end here
        
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
    
    func checkIsSamePersonOnCalendar(personIndexPath : IndexPath ) -> Bool{
        let personItem = personCDManager.itemWithIndex(index: personIndexPath.item)
//        let calendarItem = calendarCDManager.itemWithIndex(index: calendarIndexPath.item)
        //
        guard let dropEndDay = BaseSetup.dropEndCalendarDate else { return false}
        guard let currentYear = BaseSetup.currentCalendarYear else {
            print("被currentYear擋下")
            return false}
        guard let currentMonth = BaseSetup.currentCalendarMonth else {
            print("被currentMonth擋下")
            return false}
        let currentDate = "\(currentYear) \(currentMonth) \(dropEndDay)"
        var itemArray = [CalendarData]()
        
        for i in 0..<calendarCDManager.count(){
            let item = calendarCDManager.itemWithIndex(index: i)
            if item.date == currentDate{
                itemArray.append(item)
            }
        }
            for calendarItem in itemArray{
                if personItem.name == calendarItem.personName {
                    return true
                }
            }
        
        return false
        }
  
    
}//class out here
