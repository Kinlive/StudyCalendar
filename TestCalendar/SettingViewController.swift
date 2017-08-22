//
//  SettingViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/8/9.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
import CloudKit

//Prepare RecordContains
var recordName : String  {
    let formatterTest = DateFormatter()
    formatterTest.dateFormat = "yyyyMMddHHmmss"
    let dateString = formatterTest.string(from: Date())
    return dateString
}
let calendarRecordID = CKRecordID.init(recordName: "201708Test") //不能重複
var calendarRecord = CKRecord.init(recordType: "SaveCalendar",
                                                             recordID: calendarRecordID)
let calendarContainer = CKContainer.default()
let calendarDatabase = calendarContainer.publicCloudDatabase

class SettingViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredContentSize = CGSize(width: self.view.frame.width/3,
//                                                                    height: self.view.frame.height/2)
        //CloudKit use 
//        calendarRecord["Date"] = "106 08 09" as CKRecordValue
//        calendarRecord["PersonName"] = "Allen" as CKRecordValue
//        calendarRecord["ClassType"] = "常日班" as CKRecordValue
        
//        calendarRecord["Date"] = "106 08 14" as CKRecordValue
//        calendarRecord["PersonName"] = "Allen" as CKRecordValue
//        calendarRecord["ClassType"] = "常日班" as CKRecordValue
        
//        getCalendarDetailData { (success, calendarData) in
//            if success {
//                if let jsonData = toJson(dict: calendarData) {
//                    calendarRecord["AllDate"] = jsonData as CKRecordValue
//                }
//            }
//        }
       
        
//        fetchRecord()
  
    }//viewDidLoad here
    
    override func viewWillAppear(_ animated: Bool) {
        animateShowVC()
    }
    
    func animateShowVC() {
        self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.size.height)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 2.0,
                       delay: 0.05,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .transitionFlipFromTop  ,
                       animations: {
                        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        self.view.alpha = 1.0
        })
    }
   
 
    
    typealias HandleCompletion = (_ success : Bool ,
                                                         _ calendarData : [[ String : [CalendarData]]]? )
                                                -> Void
//MARK: - GetCalendarDetailData ( handleCompletion : HandleCompletion)
    func getCalendarDetailData( handleCompletion : @escaping HandleCompletion){
        
        var calendarData : [[ String : [CalendarData]]] = [[String : [CalendarData]]]()
        var howManyPerson : [CalendarData] = [CalendarData]() //all person in array
        var dateSet : Set<String> = Set<String>() //all the date in set and not repeat
        
        for index in 0..<calendarCDManager.count(){
            guard let calendarItem = calendarCDManager.itemWithIndex(index: index) else { return }
            guard let date = calendarItem.date else {
                 handleCompletion(false, nil)
                return
            }
            dateSet.insert(date)
            howManyPerson.append(calendarItem)
        }
//        print("測試測試\(dateSet)")
        var finalCalendarData = [CalendarData]()
        for (_,dateStr) in dateSet.enumerated(){
            for person in howManyPerson {
                guard let personDate = person.date else {
                     handleCompletion(false, nil)
                    return }
                if dateStr == personDate{
                    finalCalendarData.append(person)
                }
            }
            if finalCalendarData.count != 0 {
                calendarData.append([dateStr : finalCalendarData])
                finalCalendarData.removeAll()
            }
        }
//      print("測試測試\(calendarData)")
//        handleCompletion(true, calendarData)
//        guard let jsonData = toJson(dict: calendarData) else { return }
        toJson(dict: calendarData, handleCompletion: handleCompletion)
//        calendarRecord["AllDate"] = jsonData as CKRecordValue
        
    }
    
    //MARK: - toJson( dict : [[String:[CalendarData]]] ) -> Data?
    func toJson( dict : [[String:[CalendarData]]] ,
                          handleCompletion : @escaping HandleCompletion ) {
        
        var testDicOfArray : [Dictionary<String, String>] = [Dictionary<String,String>]()
        var testArrayOfDicKey : [String : [Dictionary<String,String>]] = [String : [Dictionary<String,String>]]()
        var finalArray : [[String:[Dictionary<String,String>]]] = [[String:[Dictionary<String,String>]]]()
        var testDic : [String: String] = [:]
        
        for oneDate in dict {
            for (key,value) in oneDate {
                for cData in value {
                    testDic["name"] = cData.personName
                    testDic["typeName"] = cData.typeName
                    testDic["date"] = cData.date
                    testDic["year"] = cData.year
                    testDic["month"] = cData.month
                    testDic["day"] = cData.day
                    testDicOfArray.append(testDic)
                }
                testArrayOfDicKey[key] = testDicOfArray
                testDicOfArray.removeAll()
            }
            finalArray.append(testArrayOfDicKey)
            testArrayOfDicKey.removeAll()
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: finalArray, options: .prettyPrinted) else {
            handleCompletion(false, nil)
            return
            }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        guard let dateID : Int64 = Int64(dateFormatter.string(from: Date())) else {
            handleCompletion(false,nil)
            return
        }
        calendarRecord["AllData"] = data as CKRecordValue
        calendarRecord["DateID"] = dateID as CKRecordValue
//        calendarRecord["TestItem"] = "test" as CKRecordValue
        createRecord(handleCompletion: handleCompletion)
    }
    
    //MARK: - createRecord()
    func createRecord(handleCompletion : @escaping HandleCompletion) {
        
        //將記錄保存在數據庫
        calendarDatabase.save(calendarRecord) { (artworkRecord, error) in
            if error != nil {
                handleCompletion(false, nil)
                print("Save failer and error \(String(describing: error))")
            }else {
                handleCompletion(true, nil)
                print("Save success!!\(String(describing: artworkRecord?.allKeys()))")
            }
        }
    }
    //MARK: - SaveRecord
    func saveRecord( record : CKRecord ) {
        calendarDatabase.save(record) { (_, error ) in
            if let error = error {
                print("Save failer and error \(error)")
            }else{
                print("Save Success 開香檳拉!!")
            }
        }
    }
    
    //MARK: - FetchRecord()
    func fetchRecord(){
//        calendarDatabase.fetchAllRecordZones { (recordZones, error) in
//            if let error = error {
//                 print("Fetch zone failer!!\(error.localizedDescription)")
//            }else{
//                 print("Fetch zone success !!")
//            }
//            if let recordZones = recordZones {
//                for recordZone in recordZones {
//                    print("測試zone有什麼\(recordZone.zoneID)")
//                }
//            }
//        }
        calendarDatabase.fetch(withRecordID: calendarRecordID) { (artworkRecord, error) in
            if let error = error  {
                print("Fetch data failer!! \(error.localizedDescription)")
                return
            }else {
                print("Fetch data success !!")
            }
            if let artworkRecord = artworkRecord {
//                guard let date = artworkRecord["Date"] else { return }
//                guard let personName = artworkRecord["PersonName"] else {return }
//                guard let classType = artworkRecord["ClassType"] else {return }
//                print("Fetch data is : date:\(date) personName\(personName) classType\(classType)")
//                guard let data = artworkRecord["AllData"] as? Data else { return } //額外取出資料
                
                artworkRecord["DateID"] = Int64(20170900) as CKRecordValue
                self.saveRecord(record: artworkRecord)
                
//                self.parseFetchData(data: data) 測試期間暫且隱藏
            }else {
                print("Fetch the data is empty!!")
                //是空的才用create Record方式
            }
            
        }
    }
    func parseFetchData( data : Data) {
//        guard let jsonString = String(data: data, encoding: .utf8) else {return }
//        print("第二次測試=======>\(jsonString)<=========")
        guard let dataToJson = try? JSONSerialization.jsonObject(with: data,
                                                                                                        options: .mutableContainers) as?
                                                                                                        [[String : [Dictionary<String,String>]]],
                  let parseEndArray = dataToJson else { return }
        
        print("測試測試\(parseEndArray)")
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func iCloudBtn(_ sender: UIButton) {
        
        fetchRecord()
//        creatRecord()
//        getCalendarDetailData { (success, _) in
//            if success {
//                print("開香檳慶祝拉!!!!!!!!!")
//            }else {
//                print("回家洗洗睡吧.....")
//            }
//        }
        
    }
    
    
    

}
