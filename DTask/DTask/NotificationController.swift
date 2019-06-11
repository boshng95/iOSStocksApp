//
//  NotificationController.swift
//  DTask
//
//  Created by Tammy Sim on 08/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var refresher: UIRefreshControl!
    var favourite = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notify = NSNotification.Name("refresh")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: notify, object: nil)
        
        
        guard let x = UserDefaults.standard.object(forKey: "favourite") as? [[String]] else {return}
        favourite = x
        // Do any additional setup after loading the view.
    }
    
    @objc func reloadTableView(){
        favourite = UserDefaults.standard.object(forKey: "favourite") as! [[String]]
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
        cell.companyName.text = favourite[indexPath.row][0]
        cell.companyName.numberOfLines = 2
        cell.companyName.lineBreakMode = .byWordWrapping
        cell.companySymbol.text = favourite[indexPath.row][1]
        if !favourite[indexPath.row].indices.contains(3){
            cell.notificationSettings.text = "No Settings"
        }else{
            if(favourite[indexPath.row][3] == "1"){
                cell.notificationSettings.text = favourite[indexPath.row][3] + " minute"
                cell.loadNotification(symbol: favourite[indexPath.row][1], name: favourite[indexPath.row][0], minutes: favourite[indexPath.row][3])
            }else{
                cell.notificationSettings.text = favourite[indexPath.row][3] + " minutes"
                cell.loadNotification(symbol: favourite[indexPath.row][1], name: favourite[indexPath.row][0], minutes: favourite[indexPath.row][3])
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Set Notification Minutes", message: nil, preferredStyle: .alert)
        alert.addTextField{ (placeholder) in
            placeholder.placeholder = "Please key in 1 - 60 (minutes)"
        }
        let action = UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let minutes = alert.textFields?.first?.text else {return}
            
            if Int(minutes) == nil{
                let errorAlert = UIAlertController(title: "Not a number\nPlease key in again", message: nil, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
                errorAlert.addAction(okay)
                self.present(errorAlert, animated: true)
                
            }else if 1...60 ~= Int(minutes)! {
                
                if self.favourite[indexPath.row].indices.contains(3){
                    self.favourite[indexPath.row][3] = minutes
                    
                }else{
                    self.favourite[indexPath.row].append(minutes)
                }
                UserDefaults.standard.set(self.favourite, forKey: "favourite")
                self.tableView.reloadData()
                
            }else{
                let errorAlert = UIAlertController(title: "Range minutes too long\nMaybe wait for next update\nRange only covers 1 - 60 minutes", message: nil, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
                errorAlert.addAction(okay)
                self.present(errorAlert, animated: true)
            }
            
        })
        let delete = UIAlertAction(title: "Delete Notification", style: .default, handler: {(_) in
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: self.favourite[indexPath.row])
            self.favourite[indexPath.row].remove(at: 3)
            UserDefaults.standard.set(self.favourite, forKey: "favourite")
            self.tableView.reloadData()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if(!favourite[indexPath.row].indices.contains(3)){
            alert.addAction(action)
            alert.addAction(cancel)
        }else{
            alert.addAction(action)
            alert.addAction(delete)
            alert.addAction(cancel)
        }
        present(alert, animated: true)
    }

}
