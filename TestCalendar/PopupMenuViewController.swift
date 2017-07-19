//
//  PopupMenuViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/19.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class PopupMenuViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
//    let menuTableViewCoorinator = MenuTableViewCoorinator()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.menuView.layer.cornerRadius = 25
        showAnimate()
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    @IBAction func closePopup(_ sender: Any) {
        self.removeAnimate()
    }
    
    //view Animate func
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: { 
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }) { (finished) in
            if finished {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            }
        }
        
    }
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if finished {
                self.view.removeFromSuperview()
            }
        }
    }

    
}
extension PopupMenuViewController: UITableViewDataSource,UITableViewDelegate{
    //MARK: - tableView Delegate & Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        //..
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //..how much cells
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeCell", for: indexPath)
        cell.textLabel?.text = "5566"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.removeFromSuperview()
    }

}
