//
//  NotificationCell.swift
//  DTask
//
//  Created by Tammy Sim on 08/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var companySymbol: UILabel!
    
    
    @IBOutlet weak var notificationSettings: UILabel!
    
    var publicCompanies = Companies()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow, error in
            
        })
    }
    
    func loadNotification(symbol: String, name: String, minutes: String){
        
        publicCompanies.requestOneCompany(symbol: symbol){(results: (Company)) -> () in
            DispatchQueue.main.async {
                let content = UNMutableNotificationContent()
                content.title = name
                content.subtitle = symbol
                content.body = "Have a quick check on "+symbol+" !!!"
                content.badge = 1
                content.sound = UNNotificationSound.default
                
                let time = Double(minutes)!*60
                //print(time)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: true)
                let request = UNNotificationRequest(identifier: symbol, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
