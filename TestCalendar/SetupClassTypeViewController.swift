//
//  SetupClassTypeViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class SetupClassTypeViewController: UIViewController {
    var classTypeArray = [String]()
//    var classTypeCDManager : CoreDataManager<ClassTypeData>!
    var indexPathOnEdit : IndexPath?

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var classTypeTableView: UITableView!
    @IBOutlet weak var showClassType: UILabel!
    
  
    @IBOutlet weak var startTimeKeyIn: UITextField!
    
    @IBOutlet weak var workingHoursKeyIn: UITextField!
    
    @IBOutlet weak var overtimeKeyIn: UITextField!
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.classTypeTableView.delegate = self
        self.classTypeTableView.dataSource = self
//        classTypeCDManager = CoreDataManager(
//                                                initWithModel: "DataBase",
//                                                dbFileName: "classTypeData.sqlite",
//                                                dbPathURL: nil,
//                                                sortKey: "startTime",
//                                                entityName: "ClassTypeData")
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAlertView(){
        let alert = UIAlertController.init(title: nil, message: "Please Key In ClassType", preferredStyle: .alert)
        alert.addTextField { (classType) in
            classType.placeholder = "Key in ClassType..."
        }
        alert.addTextField { (startTime) in
            startTime.placeholder = "Key in Start Time..."
            
        }
        alert.addTextField { (workingTime) in
            workingTime.placeholder = "Key in  Working Time..."
        }
        alert.addTextField { (overtime) in
            overtime.placeholder = "Key in overtime..."
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            //SavaData to classType
            let item = classTypeCDManager.createItem()
            item.typeName = alert.textFields?[0].text
            item.startTime = alert.textFields?[1].text
            item.workingHours = alert.textFields?[2].text
            item.overtime = alert.textFields?[3].text
            classTypeCDManager.saveContexWithCompletion(completion: { (success) in
                if(success){
                    self.classTypeArray.append((alert.textFields?[0].text)!)
                   self.classTypeTableView.reloadData()
                }
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    
    
    
    @IBAction func addClassType(_ sender: UIBarButtonItem) {
        createAlertView()
    }
    @IBAction func whenOnEdit(_ sender: UIBarButtonItem) {
        guard let indexPathOnEdit = indexPathOnEdit else { return}
        let item = classTypeCDManager.itemWithIndex(index: indexPathOnEdit.row )
        item.typeName = showClassType.text
        item.startTime =  startTimeKeyIn.text
        item.workingHours = workingHoursKeyIn.text
        item.overtime = overtimeKeyIn.text
        classTypeCDManager.saveContexWithCompletion { (success) in
            if success {
                self.indexPathOnEdit = nil
                self.classTypeTableView.reloadData()
            }
        }
    }
    
    
 
    
    
    
   
}

extension SetupClassTypeViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        //..
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //..
        if classTypeCDManager.count() == 0{
            let displayLabel = UILabel(frame:
                CGRect( x: tableView.frame.width/4, y: 0,
                        width: tableView.frame.width/2,
                        height: tableView.frame.height))
            displayLabel.text = "Tap plus to add ClassType"
            displayLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            displayLabel.textAlignment = .center
            displayLabel.numberOfLines = 4
            tableView.backgroundView = displayLabel
            tableView.separatorStyle = .none
        }else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .none
//            tableView.separatorColor = UIColor(colorWithHexValue: 0x3399ff)
        }
        return classTypeCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeTableViewCell", for: indexPath) as! ClassTypeTableViewCell
        let item = classTypeCDManager.itemWithIndex(index: indexPath.row)
        cell.textLabel?.text = item.typeName
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return tableView.frame.height/7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //..
        indexPathOnEdit = indexPath
        let item = classTypeCDManager.itemWithIndex(index: indexPath.row)
        showClassType.text = item.typeName
        startTimeKeyIn.text = item.startTime
        workingHoursKeyIn.text = item.workingHours
        overtimeKeyIn.text = item.overtime
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = classTypeCDManager.itemWithIndex(index: indexPath.item)
            classTypeCDManager.deleteItem(item: item)
            classTypeCDManager.saveContexWithCompletion(completion: { (success) in
                if success {
                    self.classTypeTableView.reloadData()
                }
            })
        }
    }
}
