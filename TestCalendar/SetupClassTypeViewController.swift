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
    var classTypeCDManager : CoreDataManager<ClassTypeData>!
    var indexPathOnEdit : IndexPath?

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var classTypeTableView: UITableView!
    @IBOutlet weak var showClassType: UILabel!
    
  
    @IBOutlet weak var startTimeKeyIn: UITextField!
    
    @IBOutlet weak var workingHoursKeyIn: UITextField!
    
    @IBOutlet weak var overtimeKeyIn: UITextField!
    
        override func viewDidLoad() {
        super.viewDidLoad()
             self.preferredContentSize = CGSize(width: 900, height: 600)
        // Do any additional setup after loading the view.
        self.classTypeTableView.delegate = self
        self.classTypeTableView.dataSource = self
        classTypeCDManager = CoreDataManager(
                                                initWithModel: "DataBase",
                                                dbFileName: "classTypeData.sqlite",
                                                dbPathURL: nil,
                                                sortKey: "startTime",
                                                entityName: "ClassTypeData")
        
        
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
            let item = self.classTypeCDManager.createItem()
            item.typeName = alert.textFields?[0].text
            item.startTime = alert.textFields?[1].text
            item.workingHours = alert.textFields?[2].text
            item.overtime = alert.textFields?[3].text
            self.classTypeCDManager.saveContexWithCompletion(completion: { (success) in
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
        return classTypeCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeTableViewCell", for: indexPath) as! ClassTypeTableViewCell
        let item = classTypeCDManager.itemWithIndex(index: indexPath.row)
        cell.textLabel?.text = item.typeName
        
        return cell
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
}
