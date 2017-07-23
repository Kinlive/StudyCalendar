//
//  SetupPersonViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class SetupPersonViewController: UIViewController {
    var personArray = [PersonData]()
    var personCDManager : CoreDataManager<PersonData>!

    
//MARK : - IBOutlet here
    @IBOutlet weak var showPersonDetail: UIView!
   
    @IBOutlet weak var showDetailOfLabel: UILabel!
    
    @IBOutlet weak var showHoursOfLabel: UILabel!
    
    @IBOutlet weak var SetupPersonTableView: UITableView!
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 800, height: 600)
//         self.preferredContentSize = CGSizeMake(200, 200);
        // Do any additional setup after loading the view.
        SetupPersonTableView.delegate = self
        SetupPersonTableView.dataSource = self
        
        //Init personCoreData
        personCDManager = CoreDataManager(
            initWithModel: "DataBase",
            dbFileName: "personData.sqlite",
            dbPathURL: nil,
            sortKey: "name",
            entityName: "PersonData")
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        createAlertView()
        
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
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
        
        self.showDetailOfLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        self.showHoursOfLabel.text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
    }
    
    
}
