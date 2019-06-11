//
//  HomePageController.swift
//  DTask
//
//  Created by Tammy Sim on 07/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit
import Charts

class HomePageController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var publicCompanies = Companies()
    var allCompanies = [Company]()
    var listofSymbols = ["^AXJO","^AFLI","^ATLI"]//,"^AORD","^ATOI"]
    var companyNames: [String] = []
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refresher.addTarget(self, action: #selector(HomePageController.reloadData), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
        
        requestMarketNameCountry(quotes: self.listofSymbols){(names:[String]) -> () in
            DispatchQueue.main.async {
                self.companyNames = names
                self.tableView.reloadData()
            }
            
        }
        allCompanies = publicCompanies.searchJSONCompanyPrices(symbol: listofSymbols)
        
        publicCompanies.performRequest(marketSymbols: listofSymbols){(results:[Company]) -> () in
            DispatchQueue.main.async {
                self.allCompanies = self.publicCompanies.searchJSONCompanyPrices(symbol: self.listofSymbols)
                self.tableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func reloadData(){
        var arraySymbol = [String]()
        for c in allCompanies{
            arraySymbol.append(c.companySymbol)
        }
        requestMarketNameCountry(quotes: self.listofSymbols){(names:[String]) -> () in
            DispatchQueue.main.async {
                self.companyNames = names
                self.tableView.reloadData()
            }
            
        }
        allCompanies = publicCompanies.searchJSONCompanyPrices(symbol: arraySymbol)
        publicCompanies.performRequest(marketSymbols: listofSymbols){(results:[Company]) -> () in
            DispatchQueue.main.async {
                if(results[0].companySymbol == "Limit"){
                    let errorAlert = UIAlertController(title: "Due to API limitation reach, Please refresh", message: nil, preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    errorAlert.addAction(okay)
                    self.present(errorAlert, animated: true)
                }else{
                    self.allCompanies = self.publicCompanies.searchJSONCompanyPrices(symbol: self.listofSymbols)
                    self.tableView.reloadData()
                }
            }
        }
        if !Connection.isConnectedToNetwork(){
            let errorAlert = UIAlertController(title: "Internet Connection Failed", message: nil, preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlert.addAction(okay)
            present(errorAlert, animated: true, completion: nil)
        }
        refresher.endRefreshing()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCompanies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "marketCell", for: indexPath) as! HomePageCell
        cell.marketSymbol.text = allCompanies[indexPath.row].companySymbol
        cell.marketOpen.text = String(allCompanies[indexPath.row].companyDailyStockPrice[allCompanies[indexPath.row].companyDailyStockPrice.endIndex-1].dailyOpen)
        cell.marketHigh.text = String(allCompanies[indexPath.row].companyDailyStockPrice[allCompanies[indexPath.row].companyDailyStockPrice.endIndex-1].dailyHigh)
        cell.marketLow.text = String(allCompanies[indexPath.row].companyDailyStockPrice[allCompanies[indexPath.row].companyDailyStockPrice.endIndex-1].dailyLow)
        cell.marketClose.text = String(allCompanies[indexPath.row].companyDailyStockPrice[allCompanies[indexPath.row].companyDailyStockPrice.endIndex-1].dailyClose)
        if !companyNames.indices.contains(indexPath.row){
            cell.marketName.text = "nil"
        }else{
            cell.marketName.text = companyNames[indexPath.row]
        }
        
        var dataEntries: [ChartDataEntry] = []
        var date = [String]()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd"
        
        date.append("")
        for i in 0..<allCompanies[indexPath.row].companyDailyStockPrice.count{
            
            let dataEntry = ChartDataEntry(x: Double(i) , y: allCompanies[indexPath.row].companyDailyStockPrice[i].dailyClose)
            let dailyDate = dateFormater.date(from: allCompanies[indexPath.row].companyDailyStockPrice[i].dailyDate)!
            let format = DateFormatter()
            format.dateFormat = "dd/MMM/yyyy"
            let daily = format.string(from: dailyDate)
            
            date.append(daily)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Price")
        lineChartDataSet.circleColors = [UIColor.black]
        lineChartDataSet.circleRadius = 0.1
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.colors = [UIColor.black]
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        cell.marketView.data = lineChartData
        cell.marketView.leftAxis.enabled = false
        cell.marketView.xAxis.labelPosition = .bottom
        cell.marketView.xAxis.valueFormatter = IndexAxisValueFormatter(values: date)
        cell.marketView.maxVisibleCount = 6
        cell.marketView.xAxis.labelRotationAngle = CGFloat(10)
        //cell.marketView.xAxis.labelHeight = CGFloat(1)
        cell.marketView.drawGridBackgroundEnabled = true
        
        cell.marketView.fitScreen()
        cell.selectionStyle = .none
        return cell
    }
    
    func requestMarketNameCountry(quotes: [String], completion: @escaping ([String]) -> ()){
        for quote in quotes{
            var symbol = quote
            var companyName = ""
            if let range = symbol.range(of: ":"){
                symbol = String(symbol[range.upperBound...])
            }
            let jsonUrlString="http://d.yimg.com/autoc.finance.yahoo.com/autoc?query="+symbol+"&region=1&lang=en"
            
            guard let myURL = jsonUrlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return  }
            guard let url = URL(string: myURL) else {return}
            
            URLSession.shared.dataTask(with: url){ (data, response, err) in
                guard let data = data else{return}
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                    
                    if let information = json["ResultSet"] as? NSDictionary{
                        if let query = information["Result"] as? [[String: String]]{
                            if let name = query[0]["name"]{
                                companyName = name
                            }
                        }
                    }
                    self.companyNames.append(companyName)
                    completion(self.companyNames)
                }catch let error{
                    print(error)
                }
                }.resume()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Connection.isConnectedToNetwork(){
            let errorAlert = UIAlertController(title: "Internet Connection Failed", message: nil, preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlert.addAction(okay)
            present(errorAlert, animated: true, completion: nil)
        }
    }
}
