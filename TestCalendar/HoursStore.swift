//
//  HoursStore.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import Foundation
public enum WhichViewShow : Int{
    case person = 0 , classType , calendarDetail
}


public struct BaseSetup{
    
     static var saveFirstIndexPath : IndexPath? //On begin drag the personCell indexPath
    
    static var moveOverIndexPath : IndexPath?//To highlight cell on move over cell 

    static var dropEndCalendarDate : String? // when drop end the date
    
    static var selectedDay : String? // for calendar selected date
    
    static var currentCalendarYear : String?
    
    static var currentCalendarMonth : String?
    
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


