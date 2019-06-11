//
//  FavouriteController.swift
//  DTask
//
//  Created by Tammy Sim on 08/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit

class FavouriteController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var page = "favourite"
    var favourite = [[String]]()
    var allCompany = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabAllCompanyData()
        
        guard let x = UserDefaults.standard.object(forKey: "favourite") as? [[String]] else {return}
        favourite = x
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourite.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath) as! FavouriteViewCell
        cell.companyName.text = favourite[indexPath.row][0]
        cell.companyName.numberOfLines = 2
        cell.companyName.lineBreakMode = .byWordWrapping
        cell.companySymbol.text = favourite[indexPath.row][1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let companyViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "companyView") as! CompanyController
        companyViewController.info[0] = favourite[indexPath.row][0]
        companyViewController.info[1] = favourite[indexPath.row][1]
        companyViewController.info[2] = favourite[indexPath.row][2]
        companyViewController.page = page
        self.present(companyViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = favourite[sourceIndexPath.row]
        favourite.remove(at: sourceIndexPath.row)
        favourite.insert(item, at: destinationIndexPath.row)
        UserDefaults.standard.set(favourite, forKey: "favourite")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            favourite.remove(at: indexPath.row)
            UserDefaults.standard.set(favourite, forKey: "favourite")
            NotificationCenter.default.post(name: NSNotification.Name("refresh"), object: nil)
            tableView.reloadData()
        }
    }

    @IBAction func editTableView(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        switch tableView.isEditing{
        case true: editButton.setTitle("Done", for: .normal)
        case false: editButton.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func addCompany(_ sender: Any) {
        var detected=false
        let alert = UIAlertController(title: "Add Company Symbol", message: nil, preferredStyle: .alert)
        alert.addTextField{ (symbol) in
            symbol.placeholder = "Add Company Symbol - e.g: ANZ"
        }
        let action = UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let symbol = alert.textFields?.first?.text else {return}
            
            for i in self.allCompany{
                if symbol.uppercased() == i[1]{
                    self.add(company: i)
                    detected = true
                }
            }
            if detected == false{
                let errorAlert = UIAlertController(title: "No such Australian Company", message: nil, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
                errorAlert.addAction(okay)
                self.present(errorAlert, animated: true)
            }
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
        
    }
    
    func add (company: [String]){
        var detected = false
        for i in favourite {
            if company[1] == i[1]{
                detected = true
            }
        }
        if detected == true{
            let errorAlert = UIAlertController(title: "Company Existed in the list", message: nil, preferredStyle: .alert)
            let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
            errorAlert.addAction(okay)
            self.present(errorAlert, animated: true)
        }else{
            favourite.append(company)
            UserDefaults.standard.set(favourite, forKey: "favourite")
            NotificationCenter.default.post(name: NSNotification.Name("refresh"), object: nil)
            tableView.reloadData()
        }
    }
    
    func grabAllCompanyData(){
        guard let path = Bundle.main.path(forResource: "companies", ofType: "json")else {return}
        let url = URL(fileURLWithPath: path)
        do{
            let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            //print(json)
            
            guard let array = json as? [Any] else { return }
            
            for company in array {
                guard let companyDict = company as? [String: Any] else { return }
                guard let name = companyDict["Company name"] as? String else { return }
                guard let code = companyDict["ASX code"] as? String else { return }
                guard let ind = companyDict["GICS industry group"] as? String else { return }
                
                allCompany.append([name, code, ind])
                //print(companyInformation.count)
            }
        }catch{
            print(error)
        }
    }
}
