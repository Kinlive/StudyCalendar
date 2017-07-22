//
//  SetupPersonViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class SetupPersonViewController: UIViewController {
    var personNameArray = [String]()
    

    
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
//         self.personName = alert.textFields?[0].text
        self.personNameArray.append((alert.textFields?[0].text)!)
        self.SetupPersonTableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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
        return personNameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetupPersonTableViewCell", for: indexPath) as! SetupPersonTableViewCell
        
        cell.textLabel?.text = personNameArray[indexPath.row]
        cell.detailTextLabel?.text = String(BaseSetup().overHoursOfMonth)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //..
        self.showDetailOfLabel.text = personNameArray[indexPath.row]
        self.showHoursOfLabel.text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
    }
    
    
}
