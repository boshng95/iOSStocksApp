//
//  TabBarController.swift
//  DTask
//
//  Created by Tammy Sim on 08/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit
import UserNotifications

class TabBarController: UITabBarController {
    
    var favourite = [[String]]()
    var notification = [[String]]()
    var publicCompanies = Companies()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for viewController in self.viewControllers!{
            _ = viewController.view
        }
        
        guard let x = UserDefaults.standard.object(forKey: "favourite") as? [[String]] else {return}
        favourite = x
        
        
        for i in favourite{
            if i.indices.contains(3){
                notification.append(i)
            }
        }
        UserDefaults.standard.set(notification, forKey: "notify")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
