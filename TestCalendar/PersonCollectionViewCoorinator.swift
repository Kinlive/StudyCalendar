//
//  PersonCollectionViewCoorinator.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/18.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit


var numberItem : [Int]{
    var array = [Int]()
    for i in 0...25 { array.append(i) }// for how much person
    return array
}//FIXME: numberArray here
let spacing :CGFloat = 3
let itemCount :CGFloat = 2

let baseSetup = BaseSetup()

class PersonCollectionViewCoorinator: NSObject,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    //MARK: - UICollectionViewDelegate & DataSource
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
        return baseSetup.personCount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //..
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as! PersonCell
        cell.personName.text = String(baseSetup.personCount[indexPath.item])
        cell.layer.cornerRadius = cell.frame.size.width / 2
        cell.layer.borderWidth = 2
        //person hours setup ,之後要將時數一開始初始化的部分丟在[name : hours],並在建立人員時加入,並能存入資料庫
        cell.personDetail.hours = baseSetup.hoursOfMonth
        //放這不妥, cell的資料應該要從資料庫取出才是準的
        cell.personDetail.overHours = baseSetup.overHoursOfMonth
        //hourBar setup
//        cell.hourBar.layer.cornerRadius = 20
//        cell.hourBar.layer.borderWidth = 3.0
//        cell.hourBar.isHidden = true
//        let circularProgress = createProgressBar(cell: cell)
//        cell.addSubview(circularProgress)
        cell.addSubview(createProgressBar(cell: cell))

//        let barWidth = cell.hourBar.frame.width
//        let barHeight = cell.hourBar.frame.height
//        let gradientview = GradientView.init(frame: CGRect(x: 0, y: 0, width: barWidth*3/5 , height: barHeight/1.45))
//        gradientview.layer.cornerRadius = 20
//        cell.hourBar.addSubview(gradientview)
        
        return cell
    }
    
    func createProgressBar(cell : PersonCell) -> KDCircularProgress{
        let progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 1.0
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = false
        progress.glowMode = .forward
        progress.glowAmount = 0.9
        progress.set(colors: UIColor.red ,UIColor.white, UIColor.orange, UIColor.white, UIColor.green)
        progress.animate(fromAngle: -50.0 , toAngle: 310.0, duration: 1.5, completion: nil)
        //cell.center.y + 25
        //        progress.center = CGPoint(x: cell.center.x, y: cell.center.y)
        //        cell.addSubview(progress)
        return progress
    }

}
