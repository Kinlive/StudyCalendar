//
//  GestureSetupManager.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/18.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import JTAppleCalendar

typealias GestureEnd = () -> Void
class GestureSetupManager: NSObject {

    struct My {
        static var cellSnapshot : UIView?
    }
    struct Path{
        //用來存放找到personCell的索引
        static var personCellIndexPath : IndexPath?
        static var calendarCellIndexPath : IndexPath? 
    }
    
    func longPressOnView(
                    gestureRecognizer: UILongPressGestureRecognizer,
                    mainUIView: UIView ,
                    calendarView:JTAppleCalendarView ,
                    personCellView:UICollectionView,
                    gestureEnd : @escaping GestureEnd =  { ()  -> Void  in }
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
        let indexPath = personCellView.indexPathForItem(at: personLocation)//這裡要改成使用personLocation
        let calendarIndexPath = calendarView.indexPathForItem(at: calendarLocation)
        //        guard var mainViewIndexPath = mainUIView
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
            //                center.x = locationMainView.x
            //                center.y = locationMainView.y
            My.cellSnapshot?.center = center
            cellSnapshot.center = center
            cellSnapshot.alpha = 0.0
            //                personCellView.addSubview(cellSnapshot)
            mainUIView.addSubview(cellSnapshot)
            UIView.animate(withDuration: 0.4, animations: {
                //                    center.y = locationInView.y
                cellSnapshot.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                cellSnapshot.alpha = 0.98
                cell.alpha = 0.0
            }, completion: { finished in
                if finished{
                    cell.isHidden = true
                    NSLog("Case11111111")
                }
            })
        case .changed :
            
            guard let cellSnapshot = My.cellSnapshot else {return}
            cellSnapshot.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            var center = cellSnapshot.center
            center.y = locationMainView.y
            center.x = locationMainView.x
            cellSnapshot.center = center
           
            //滑過calendar會顯示,若滑到空白處會crash待處理,用if避開
            //            guard let calendarIndexPath = calendarIndexPath else {return}
            //            let calendarCell = calendarView.cellForItem(at: calendarIndexPath) as! CustomCell
            //            calendarCell.selectedView.isHidden = false
            
//                        guard let indexPath = indexPath else {return}
//                        if (indexPath != Path.personCellIndexPath){
//                            //進行交換
//                            guard let personCellIndexPath = Path.personCellIndexPath else {return}
//                            swap(&numberItem[(indexPath.row)], &numberItem[(personCellIndexPath.row)])
//                            personCellView.moveItem(at: personCellIndexPath, to: indexPath)
//                            Path.personCellIndexPath = indexPath
//                            NSLog("Case2222222")
//                    }
        case .ended:
            guard let cellSnapshot = My.cellSnapshot else { return}
            //判斷落下點是在月曆還是人員
            //將main計算寬度換成 personLocation.x >= 0 就不進入 ex: cellSnapshot.center.x <= mainUIView.frame.size.width*3/4
            //以及第二判斷條件可換乘 calendarLocation.y <0 就不進入  ex:cellSnapshot.center.y >= mainUIView.frame.size.height*1/5
            if personLocation.x < 0,cellSnapshot.center.y >= mainUIView.frame.size.height*1/5{
                guard let calendarIndexPath = calendarIndexPath else {return}
                let calendarCell = calendarView.cellForItem(at: calendarIndexPath) as! CustomCell
                guard let personCellIndexPath = Path.personCellIndexPath else {return}
                guard let cell = personCellView.cellForItem(at: personCellIndexPath)  else {return}
                
                calendarCell.selectedView.isHidden = false  //控制月曆選擇顯示
                cell.isHidden = false
                cell.alpha = 0.0
//                 self.createCancelView(mainUIView: mainUIView)
                UIView.animate(withDuration: 0.5, animations: {
                    //月曆cell放大
                    calendarCell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    //                calendarCell.backgroundColor = UIColor(colorWithHexValue: 0xaa66aa)
                    cellSnapshot.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    cellSnapshot.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { finished in
                    if finished {
                        calendarCell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        Path.personCellIndexPath = nil
                        cellSnapshot.removeFromSuperview()
                        My.cellSnapshot = nil
                        NSLog("Case333333333")
                       
                    }
                })
                gestureEnd()
            }else{
                guard let personCellIndexPath = Path.personCellIndexPath else {
                    return}
                guard let cell = personCellView.cellForItem(at: personCellIndexPath)  else {return}
                cell.isHidden = false
                cell.alpha = 1
                Path.personCellIndexPath = nil
                cellSnapshot.removeFromSuperview()
                My.cellSnapshot = nil
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
    
    //為了屏除背後畫面功能做的
    func createCancelView(mainUIView : UIView) {
        let cancelView = UIView(frame: mainUIView.frame)
        
        mainUIView.addSubview(cancelView)
    }
}
