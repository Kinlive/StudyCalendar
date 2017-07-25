//
//  SetupPersonViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit
 let years = ["2017","2018","2019","2020","2021","2022","2023","2024","2025","2026"]
class SetupPersonViewController: UIViewController {
    var personArray = [PersonData]()
    var personCDManager : CoreDataManager<PersonData>!
    let formatter = DateFormatter()
    
    
//MARK : - IBOutlet here
    @IBOutlet weak var showPersonDetail: UIView!
   
    @IBOutlet weak var showDetailOfLabel: UILabel! //person name
    
    @IBOutlet weak var showHoursOfLabel: UILabel!
    
    @IBOutlet weak var SetupPersonTableView: UITableView!
    
    @IBOutlet weak var showDate: UIPickerView!

    @IBOutlet weak var editStatusButton: UIBarButtonItem!
    // test textFields?
    @IBOutlet weak var nameTextFieldStatus: UITextField!
    
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 900, height: 600)
//         self.preferredContentSize = CGSizeMake(200, 200);
        // Do any additional setup after loading the view.
        SetupPersonTableView.delegate = self
        SetupPersonTableView.dataSource = self
//        showDate.delegate = self as? UIPickerViewDelegate
//        showDate.dataSource = self as? UIPickerViewDataSource
//        formatter.dateFormat = "yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
//        let month = formatter.monthSymbols 月份
       
    
//        let year1 = formatter.calendar.dateComponents(year, from: date)
//        print("Day \(String(describing: year)))")
        //Init personCoreData
        personCDManager = CoreDataManager(
            initWithModel: "DataBase",
            dbFileName: "personData.sqlite",
            dbPathURL: nil,
            sortKey: "name",
            entityName: "PersonData")
        //nameTextField test 
//        nameTextFieldStatus.isHidden = true
        showDetailOfLabel.isHidden = true
        showHoursOfLabel.isHidden = true
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        createAlertView()
        
    }
  

    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        showDetailOfLabel.isHidden = true
        showHoursOfLabel.isHidden = true
        nameTextFieldStatus.isHidden = false
//        editStatusButton.isEnabled = false
//        editStatusButton.title = "Edit"
    }
    //MARK : - CreatAlert method
    func createAlertView(){
        let alert = UIAlertController.init(title: nil, message: "Please key in Name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            let item = self.personCDManager.createItem()
            item.name = alert.textFields?[0].text
            item.overtime = Double(baseSetup.overHoursOfMonth)
            self.personCDManager.saveContexWithCompletion(completion: { (success) in
                if(success){
                    self.personArray.append(item)
                    self.SetupPersonTableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
                }
            })
        }//ok action block here
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func callOtherControllerUpdate(){
        //通知中心
    }
}
//MARK: - TableView Delegate & DataSource
extension SetupPersonViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetupPersonTableViewCell", for: indexPath) as! SetupPersonTableViewCell
        let item = personCDManager.itemWithIndex(index: indexPath.item)
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(item.overtime)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //..
        self.nameTextFieldStatus.isHidden = true
        self.showDetailOfLabel.isHidden = false
        self.showHoursOfLabel.isHidden = false
        self.showDetailOfLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        self.showHoursOfLabel.text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
        //Set edit button 
        editStatusButton.isEnabled = true
//        editStatusButton.title = "Save"
        
    }
}
//MARK: - PickerView protocol method
extension SetupPersonViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count : Int?
        if component == 0{
            count = years.count
        }else {
            count =  BaseSetup.monthly.count
        }
        return count!
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title : String?
        if component == 0 {
            title =  years[row]
        }else {
            title = BaseSetup.monthly[row]
        }
        
        return title!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //..
    }
}
