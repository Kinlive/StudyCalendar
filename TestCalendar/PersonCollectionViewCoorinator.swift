//
//  PersonCollectionViewCoorinator.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/18.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

//var dataManager:CoreDataManager<PersonData>!
var numberItem : [Int]{
    var array = [Int]()
    for i in 0...25 { array.append(i) }// for how much person
    return array
}//FIXME: numberArray here
let spacing :CGFloat = 3

let baseSetup = BaseSetup()
//let personCDManager = CoreDataManager<PersonData>(
//    initWithModel: "DataBase",
//    dbFileName: "personData.sqlite",
//    dbPathURL: nil,
//    sortKey: "name",
//    entityName: "PersonData")



class PersonCollectionViewCoorinator: NSObject,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    //when no data the table view display this
    var noDataView : UIView?
    
    //MARK: - UICollectionViewDelegate & DataSource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemCount :CGFloat = 2
//        if personCDManager.count() <= 6{
//            itemCount = 1
//        }
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
        
        guard let results = personCDManager.fetchedResultsController.fetchedObjects else { return 0}
        if results.count == 0 {
            let displayLabel = UILabel(frame:
                                                        CGRect( x: collectionView.frame.width/4, y: 0,
                                                                        width: collectionView.frame.width/2,
                                                                        height: collectionView.frame.height))
            displayLabel.text = "It's first to person page"
            displayLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            displayLabel.textAlignment = .center
            displayLabel.numberOfLines = 4
            collectionView.backgroundView = displayLabel
        }else {
            collectionView.backgroundView = nil
        }
        
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //..
//         let personCDManager = createCoreDataManager()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as! PersonCell
//        let item = personCDManager.itemWithIndex(index: indexPath.item)
//        personCDManager.managedObjectContext.refreshAllObjects()
        guard let item = personCDManager.fetchedResultsController.object(at: indexPath) as? PersonData else { return cell}
        cell.personWorkingHour.text = String(item.workingHours)
        cell.overHours = item.overtime
        cell.personName.text = item.name //item.name
        cell.personHour.text = String(item.overtime)
        cell.layer.cornerRadius = cell.frame.size.width / 2
        cell.layer.borderWidth = 2
        
               
        //person hours setup ,之後要將時數一開始初始化的部分丟在[name : hours],並在建立人員時加入,並能存入資料庫
//        cell.personDetail.hours = baseSetup.hoursOfMonth
        //放這不妥, cell的資料應該要從資料庫取出才是準的
//        cell.personDetail.overHours = (item.overtime)
        setupHourBar(cell: cell , indexPath: indexPath)
        
        
        return cell
    }
    
   
    
    func setupHourBar(cell : PersonCell ,indexPath : IndexPath) -> Void{
        guard let item = personCDManager.fetchedResultsController.object(at: indexPath) as? PersonData else { return }
        cell.hourBar.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.hourBar.startAngle = 90
        cell.hourBar.progressThickness = 1.0
        cell.hourBar.trackThickness = 1.0
        cell.hourBar.clockwise = false
        cell.hourBar.gradientRotateSpeed = 2
        cell.hourBar.roundedCorners = false
        cell.hourBar.glowMode = .forward
        cell.hourBar.glowAmount = 0.9
        cell.hourBar.trackColor = .clear
        cell.hourBar.set(colors:  UIColor.orange, UIColor.white)
//        cell.hourBar.animate(fromAngle: 50.0 , toAngle: (Double(cell.overHours)/46.0)*360.0, duration: 1.5, completion: nil)
        cell.hourBar.animate(toAngle: (item.overtime/BaseSetup.overHoursOfMonth)*180.0, duration: 1.5, completion: nil)
        //Under is workingBar Setup
        cell.workingBar.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.workingBar.startAngle = 90
        cell.workingBar.progressThickness = 1.0
        cell.workingBar.trackThickness = 1.0
        cell.workingBar.clockwise = true
        cell.workingBar.gradientRotateSpeed = 2
        cell.workingBar.roundedCorners = false
        cell.workingBar.glowMode = .forward
        cell.workingBar.glowAmount = 0.9
        cell.workingBar.trackColor = .clear
        cell.workingBar.set(colors:  UIColor.green , UIColor.white)
        //        cell.hourBar.animate(fromAngle: 50.0 , toAngle: (Double(cell.overHours)/46.0)*360.0, duration: 1.5, completion: nil)
        cell.workingBar.animate(toAngle: (item.workingHours/BaseSetup.hoursOfMonth*180), duration: 1.5, completion: nil)
    }

    
//    func createCoreDataManager() -> CoreDataManager<PersonData> {
//        let personCDManager = CoreDataManager<PersonData>(
//            initWithModel: "DataBase",
//            dbFileName: "personData.sqlite",
//            dbPathURL: nil,
//            sortKey: "name",
//            entityName: "PersonData")
//        return personCDManager
//    }
    
//    func createProgressBar(cell : PersonCell) -> KDCircularProgress{
//        let progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
//        progress.startAngle = -90
//        progress.progressThickness = 0.2
//        progress.trackThickness = 1.0
//        progress.clockwise = true
//        progress.gradientRotateSpeed = 2
//        progress.roundedCorners = false
//        progress.glowMode = .forward
//        progress.glowAmount = 0.9
//        progress.set(colors: UIColor.red ,UIColor.white, UIColor.orange, UIColor.white, UIColor.green)
//        progress.animate(fromAngle: 50.0 , toAngle: (Double(cell.overHours)/46.0)*360.0, duration: 1.5, completion: nil)
//        //cell.center.y + 25
//        //        progress.center = CGPoint(x: cell.center.x, y: cell.center.y)
//        //        cell.addSubview(progress)
//        return progress
//    }

}
