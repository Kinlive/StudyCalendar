//
//  HoursStore.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import Foundation

public struct BaseSetup{
    
     static var saveFirstIndexPath : IndexPath? //On begin drag the personCell indexPath

    static var dropEndCalendarDate : String? // when drop end the date
    
    static var selectedDate : String? // for calendar selected date
    
    static let monthly =
        ["January","Fabruary","March","April",
        "May","June","July","August",
        "September","October","November","December"]
    let hoursOfMonth = 168
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

public struct CalendarDetail{
    var date : String?
    var personCount : Int?
    var classType : Int?
    
//    init(
//        date : String?,
//        personCount : Int?,
//        classType : Int?
//        ) {
//        self.date = date
//        self.personCount = personCount
//        self.classType = classType
//    }
    
}
