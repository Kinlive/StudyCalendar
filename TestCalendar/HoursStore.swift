//
//  HoursStore.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import Foundation
var howMuchType : Int?

let cellCache = NSCache<NSString, AnyObject>()

public enum WhichViewShow : Int{
    case person = 0 , classType , calendarDetail , settingView
}

public enum WhichTypeAddNumber : Int {
    
    case type
}

public struct BaseSetup{
    
    static var saveFirstIndexPath : IndexPath? //On begin drag the personCell indexPath
    
    static var moveOverIndexPath : IndexPath?//To highlight cell on move over cell 
    
    static var saveEndIndexPath : IndexPath? // On drag end the calendarCell indexPath

    static var dropEndCalendarDate : String? // when drop end the date
    
    static var selectedDay : Date? // for calendar selected date
    
    static var refreshCellOfIndexPath : IndexPath?//refresh calendarCell for calendarDetailVC on delete one person
    
    static var currentCalendarYear : String?
    
    static var currentCalendarMonth : String?
    
    static var saveCalendarCellsDate : Date?
    
    static let hoursOfMonth = 240.0
    static let overHoursOfMonth = 46.0
  
}
public struct SetupOnStartData{
    var name :[String]?
    var hours: Int?
    var overHours : Int?
    init() {
        
    }
    init(
         name :[String]?,
         hours: Int?,
        overHours : Int?
        ) {
        self.name = name
        self.hours = hours
        self.overHours = overHours
    }
    
}

public struct PersonDetail{
    var name : String?
    var hours : Int?
    var overHours : Int?
//    init(
//        hours : Int?,
//        overHours : Int?
//        ) {
//        
//        self.hours = hours
//        self.overHours = overHours
//    }
}


