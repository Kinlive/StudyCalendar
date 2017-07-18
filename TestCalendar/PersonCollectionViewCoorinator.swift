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
        return numberItem.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //..
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as! PersonCell
        cell.personName.text = String(numberItem[indexPath.item])
        cell.layer.cornerRadius = 25
        cell.layer.borderWidth = 2
        //hourBar setup
        cell.hourBar.layer.cornerRadius = 20
        cell.hourBar.layer.borderWidth = 3.0
        let barWidth = cell.hourBar.frame.width
        let barHeight = cell.hourBar.frame.height
        let gradientview = GradientView.init(frame: CGRect(x: 0, y: 0, width: barWidth*3/5 , height: barHeight/1.45))
        gradientview.layer.cornerRadius = 20
        cell.hourBar.addSubview(gradientview)
        
        
        return cell
    }

    
}
