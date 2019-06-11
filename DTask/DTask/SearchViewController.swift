//
//  SearchViewController.swift
//  DTask
//
//  Created by Tammy Sim on 07/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var companyInformation = [[String]]()
    var filterCompanies = [[String]]()
    var page = "search"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        grabAllCompanyData()
        filterCompanies = companyInformation
        // Do any additional setup after loading the view.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            filterCompanies = companyInformation
            tableView.reloadData()
        }else{
            filterCompanies = companyInformation.filter({ company -> Bool in
                guard let text = searchBar.text else {return false}
                if text.count <= 3 {
                    return company[1].lowercased().contains(text.lowercased())
                }else{
                    return company[0].lowercased().contains(text.lowercased())
                }
            })
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCompanies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchViewCell
        cell.name.text = filterCompanies[indexPath.row][0]
        cell.name.numberOfLines = 2
        cell.name.lineBreakMode = .byWordWrapping
        
        cell.code.text = filterCompanies[indexPath.row][1]
        cell.industry.text = filterCompanies[indexPath.row][2]
        return cell
    }
    
    func grabAllCompanyData(){
        guard let path = Bundle.main.path(forResource: "companies", ofType: "json")else {return}
        let url = URL(fileURLWithPath: path)
        do{
            let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard let array = json as? [Any] else { return }
            
            for company in array {
                guard let companyDict = company as? [String: Any] else { return }
                guard let name = companyDict["Company name"] as? String else { return }
                guard let code = companyDict["ASX code"] as? String else { return }
                guard let ind = companyDict["GICS industry group"] as? String else { return }
                
                companyInformation.append([name, code, ind])
            }
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let companyViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "companyView") as! CompanyController
        companyViewController.info[0] = filterCompanies[indexPath.row][0]
        companyViewController.info[1] = filterCompanies[indexPath.row][1]
        companyViewController.info[2] = filterCompanies[indexPath.row][2]
        companyViewController.page = page
        self.present(companyViewController, animated: true, completion: nil)
    }

}
