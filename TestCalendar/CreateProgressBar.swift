//
//  CreateProgressBar.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class CreateProgressBar: UIView {
    let progressView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
    let progressLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 50, height: 50))
    var currentProgress: CGFloat = 0
//    label.text = String(currentProgress)
    
//    progressView.backgroundColor = .blue
    
    
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
    
    func setProgress(_ progress: CGFloat) {
        let fullWidth: CGFloat = 200
        let newWidth = progress/100*fullWidth
        UIView.animate(withDuration: 1.5) {
            self.progressView.frame.size = CGSize(width: newWidth, height: self.progressView.frame.height)
        }
    }
    func setLabelProgress(initialValue: CGFloat, targetValue: CGFloat) {
        
        guard currentProgress != targetValue else { return }
        
        let range = targetValue - initialValue
        let increment = range/CGFloat(abs(range))
        let duration: TimeInterval = 1.5
        let delay = duration/TimeInterval(range)
        currentProgress += increment
        progressLabel.text = String(describing: currentProgress)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.setLabelProgress(initialValue: initialValue, targetValue: targetValue)
        }
    }
    
}
