//
//  CompanyController.swift
//  DTask
//
//  Created by Tammy Sim on 08/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit
import Charts

class CompanyController: UIViewController {

    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var industry: UILabel!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var companyPrices: LineChartView!
    
    
    var publicCompanies = Companies()
    var company = Company(symbol: "", dailyPrices: [DailyPrice(date: "", open: 0, high: 0, low: 0, close: 0, volume: 0)])
    var page = ""
    var info = ["","",""]
    var favourite = [[String]]()
    var refresher: UIRefreshControl!
    @IBOutlet weak var scrollRefresh: UIScrollView!
    
    @IBOutlet weak var oneMonth: UIButton!
    @IBOutlet weak var threeMonth: UIButton!
    @IBOutlet weak var fiveMonth: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refresher.addTarget(self, action: #selector(CompanyController.reloadData), for: UIControl.Event.valueChanged)
        scrollRefresh.addSubview(refresher)
        
        symbol.text = info[1]
        
        name.text = info[0]
        name.numberOfLines = 2
        name.lineBreakMode = .byTruncatingTail
        
        industry.text = self.info[2]
        industry.numberOfLines = 2
        industry.lineBreakMode = .byTruncatingTail
        
        if !publicCompanies.searchJSONCompanyPrices(symbol: [info[1]]).indices.contains(0){
            open.text = "0.00"
            high.text = "0.00"
            low.text = "0.00"
            close.text = "0.00"
            volume.text = "0"
        }else{
            company = publicCompanies.searchJSONCompanyPrices(symbol: [info[1]])[0]
            setUpView(company: company, range: company.companyDailyStockPrice.count)
        }
        
        
        publicCompanies.requestOneCompany(symbol: info[1]){(results: (Company)) -> () in
            DispatchQueue.main.async {
                if results.companySymbol == "Limit"{
                    let errorAlert = UIAlertController(title: "Due to API limitation reach, Please refresh", message: nil, preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    errorAlert.addAction(okay)
                    self.present(errorAlert, animated: true)
                }else{
                    self.company = results
                    self.setUpView(company: results, range: results.companyDailyStockPrice.count)
                }
            }
        }
    }
    
    @objc func reloadData(){
        if !Connection.isConnectedToNetwork(){
            let errorAlert = UIAlertController(title: "Internet Connection Failed", message: nil, preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlert.addAction(okay)
            present(errorAlert, animated: true, completion: nil)
            
        }else{
            if publicCompanies.searchJSONCompanyPrices(symbol: [info[1]]).indices.contains(0){
                company = publicCompanies.searchJSONCompanyPrices(symbol: [info[1]])[0]
            }
            
            publicCompanies.requestOneCompany(symbol: info[1]){(results: (Company)) -> () in
                DispatchQueue.main.async {
                    if results.companySymbol == "Limit"{
                        let errorAlert = UIAlertController(title: "Due to API limitation reach, Please refresh", message: nil, preferredStyle: .alert)
                        let okay = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        errorAlert.addAction(okay)
                        self.present(errorAlert, animated: true)
                    }else{
                        self.company = results
                        self.setUpView(company: results, range: results.companyDailyStockPrice.count)
                        self.oneMonth.isSelected = false
                        self.threeMonth.isSelected = false
                        self.fiveMonth.isSelected = false
                    }
                }
            }
            //refresher.endRefreshing()
        }
        refresher.endRefreshing()
        
    }
    
    func setUpView(company: Company, range: Int){
        
        open.text = String(company.companyDailyStockPrice[company.companyDailyStockPrice.endIndex-1].dailyOpen)
        high.text = String(company.companyDailyStockPrice[company.companyDailyStockPrice.endIndex-1].dailyHigh)
        low.text = String(company.companyDailyStockPrice[company.companyDailyStockPrice.endIndex-1].dailyLow)
        close.text = String(company.companyDailyStockPrice[company.companyDailyStockPrice.endIndex-1].dailyClose)
        volume.text = String(company.companyDailyStockPrice[company.companyDailyStockPrice.endIndex-1].dailyVolume)
        
        var dataEntries: [ChartDataEntry] = []
        var date = [String]()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd"
        var companyFilter = company.companyDailyStockPrice
        
        if (range != company.companyDailyStockPrice.count){
            for _ in 0..<companyFilter.count-range{
                companyFilter.remove(at: 0)
            }
        }
        
        date.append("")
        for i in 0..<companyFilter.count{
            
            let dataEntry = ChartDataEntry(x: Double(i) , y: companyFilter[i].dailyClose)
            let dailyDate = dateFormater.date(from: companyFilter[i].dailyDate)!
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
        
        
        
        companyPrices.data = lineChartData
        companyPrices.leftAxis.enabled = false
        companyPrices.xAxis.labelPosition = .bottom
        companyPrices.xAxis.valueFormatter = IndexAxisValueFormatter(values: date)
        companyPrices.xAxis.labelRotationAngle = CGFloat(10)
        //cell.marketView.xAxis.labelHeight = CGFloat(1)
        companyPrices.drawGridBackgroundEnabled = false
        companyPrices.fitScreen()
    }
    
    @IBAction func backButton(_ sender: Any) {
        let tabBar = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! TabBarController
        if(page == "search"){
            tabBar.selectedIndex = 1
            self.present(tabBar, animated: true, completion: nil)
        }else if (page == "favourite") {
            tabBar.selectedIndex = 2
            self.present(tabBar, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func saveCompany(_ sender: Any) {
        var detected = false
        
        if let x = UserDefaults.standard.object(forKey: "favourite") as? [[String]] {
            favourite = x
        }
        print(favourite)
        for i in favourite{
            if(i[0] == info[0]){
                detected = true
            }
        }
        if detected == true {
            let errorAlert = UIAlertController(title: "Company Existed in Favourite List", message: nil, preferredStyle: .alert)
             let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
             errorAlert.addAction(okay)
             self.present(errorAlert, animated: true, completion: nil)
        }else {
            favourite.append(info)
            UserDefaults.standard.set(favourite, forKey: "favourite")
            let addedAlert = UIAlertController(title: "Company Addeed in Favourite List", message: nil, preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            addedAlert.addAction(okay)
            self.present(addedAlert, animated: true, completion: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name("refresh"), object: nil)
            
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
    
    @IBAction func changePriceView(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            oneMonth.isSelected = true
            threeMonth.isSelected = false
            fiveMonth.isSelected = false
            setUpView(company: company, range: 30)
        case 2:
            oneMonth.isSelected = false
            threeMonth.isSelected = true
            fiveMonth.isSelected = false
            setUpView(company: company, range: 60)
        case 3:
            oneMonth.isSelected = false
            threeMonth.isSelected = false
            fiveMonth.isSelected = true
            setUpView(company: company, range: company.companyDailyStockPrice.count)
        default: print("Error")
        }
        
        
    }
    
    
}
