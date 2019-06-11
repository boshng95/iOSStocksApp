//
//  Companies.swift
//  DTask
//
//  Created by Tammy Sim on 06/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import Foundation

class Companies{
    var listedCompanies = [Company]()
    let dateFormater = DateFormatter()
    
    func performRequest(marketSymbols:[String], completion: @escaping ([Company]) -> ()){
        
        dateFormater.dateFormat = "yyyy/MM/dd"
        
        for marketsymbol in marketSymbols{
            var arrangeDate = [[String]]()
            let jsonUrlStringPrice = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol="+marketsymbol+"&apikey=Y1RF7S39YRS6CQR2"
            //let jsonUrlStringName = "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=A2M.AX&region=1&lang=en"
            guard let myURL = jsonUrlStringPrice.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return  }
            guard let url = URL(string: myURL) else {return}
            
            URLSession.shared.dataTask(with: url){ (data, response, err) in
                guard let data = data else {return}
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                    var symbols = ""
                    if let _ = json["Note"] as? String{
                        
                        let newCompany = Company(symbol: "Limit", dailyPrices: [DailyPrice(date: "Limit", open: 0, high: 0, low: 0, close: 0, volume: 0)])
                        self.listedCompanies.append(newCompany)
                        completion(self.listedCompanies)
                        
                    }
                    else if let _ = json["Error Message"] as? String{
                        //print("No Such Company")
                        let newCompany = Company(symbol: "Error", dailyPrices: [DailyPrice(date: "Error", open: 0, high: 0, low: 0, close: 0, volume: 0)])
                        self.listedCompanies.append(newCompany)
                        completion(self.listedCompanies)
                        
                    }else if let information = json["Meta Data"] as? NSDictionary{
                        if let symbol = information["2. Symbol"]{
                            symbols = symbol as! String
                            if let range = symbols.range(of: ":"){
                                symbols = String(symbols[range.upperBound...])
                            }
                        }
                    }
                    
                    if let prices = json["Time Series (Daily)"] as? NSDictionary{
                        guard let priceArray = prices as? [String: AnyObject] else {return}
                        for (key, value) in priceArray{
                            guard let open = value["1. open"] as? String else {return}
                            guard let high = value["2. high"] as? String else {return}
                            guard let low = value["3. low"] as? String else {return}
                            guard let close = value["4. close"] as? String else {return}
                            guard let volume = value["5. volume"] as? String else {return}
                            arrangeDate.append([key, open, high, low, close, volume])
                        }
                    }
                    let sortedArray = arrangeDate.sorted(by: {left, right in
                        let leftDate = self.dateFormater.date(from: left[0])
                        let rightDate = self.dateFormater.date(from: right[0])
                        return leftDate!.compare(rightDate!) == .orderedAscending
                    })
                    var finalArray = [DailyPrice]()
                    for var data in sortedArray{
                        finalArray.append(DailyPrice(date: data[0], open: Double(data[1])!, high: Double(data[2])!, low: Double(data[3])!, close: Double(data[4])!, volume: Int(data[5])!))
                    }
                    
                    self.listedCompanies.append(Company(symbol: symbols, dailyPrices: finalArray))
                    completion(self.listedCompanies)
                    
                    let file = symbols+".json"
                    let jsonFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(file)
                    try? data.write(to: jsonFileUrl)
                    
                }catch let err{
                    print(err)
                }
                }.resume()
        }
    }
    
    func searchJSONCompanyPrices(symbol: [String]) -> [Company]{
        var companies = [Company]()
        
        for company in symbol{
            let file = company+".json"
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            
            let findURL = NSURL(fileURLWithPath: path)
            if let pathComponent = findURL.appendingPathComponent(file){
                let filePath = pathComponent.path
                let fm = FileManager.default
                if fm.fileExists(atPath: filePath){
                    
                    let jsonURL = URL(fileURLWithPath: filePath)
                    
                    companies.append(requestJsonFromLocal(url: jsonURL))
                }else{
                    print("File not available")
                    
                }
            }
        }
        return companies
    }
    
    func requestJsonFromLocal(url: URL) -> Company{
        var arrangeDate = [[String]]()
        dateFormater.dateFormat = "yyyy/MM/dd"
        var symbol = ""
        var eachCompany = Company(symbol: "", dailyPrices: [DailyPrice(date: "", open: 0, high: 0, low: 0, close: 0, volume: 0)])
        do{
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
            if let information = json["Meta Data"] as? NSDictionary{
                if let sym = information["2. Symbol"]{
                    symbol = sym as! String
                    //print(symbol)
                }
            }
            if let prices = json["Time Series (Daily)"] as? NSDictionary{
                let priceArray = prices as! [String: AnyObject] //else {return}
                for (key, value) in priceArray{
                    let open = value["1. open"] as! String //else {return}
                    let high = value["2. high"] as! String //else {return}
                    let low = value["3. low"] as! String //else {return}
                    let close = value["4. close"] as! String //else {return}
                    let volume = value["5. volume"] as! String //else {return}
                    arrangeDate.append([key, open, high, low, close, volume])
                }
            }
            
            let sortedArray = arrangeDate.sorted(by: {left, right in
                let leftDate = self.dateFormater.date(from: left[0])
                let rightDate = self.dateFormater.date(from: right[0])
                return leftDate!.compare(rightDate!) == .orderedAscending
            })
            var finalArray = [DailyPrice]()
            for var data in sortedArray{
                finalArray.append(DailyPrice(date: data[0], open: Double(data[1])!, high: Double(data[2])!, low: Double(data[3])!, close: Double(data[4])!, volume: Int(data[5])!))
            }
            eachCompany = Company(symbol: symbol, dailyPrices: finalArray)
            
        }catch let err{
            print(err)
        }
        return eachCompany
    }
    
    func requestOneCompany(symbol: String, completion: @escaping (Company) -> ()){
        dateFormater.dateFormat = "yyyy/MM/dd"
        var arrangeDate = [[String]]()
        let jsonUrlStringPrice = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=ASX:"+symbol+"&apikey=Y1RF7S39YRS6CQR2"
        
        guard let url = URL(string: jsonUrlStringPrice) else {return}
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            guard let data = data else {return}
            //let dataAsString = String(data: data, encoding: .utf8)
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                var symbols = ""
                if let info = json as? NSDictionary{
                    if let _ = info["Note"] as? String{
                        let newCompany = Company(symbol: "Limit", dailyPrices: [DailyPrice(date: "Limit", open: 0, high: 0, low: 0, close: 0, volume: 0)])
                        completion(newCompany)
                        
                    }
                    else if let _ = info["Error Message"] as? String{
                        let newCompany = Company(symbol: "Error", dailyPrices: [DailyPrice(date: "Error", open: 0, high: 0, low: 0, close: 0, volume: 0)])
                        completion(newCompany)
                        
                    }else{
                        if let information = json["Meta Data"] as? NSDictionary{
                            if let symbol = information["2. Symbol"]{
                                symbols = symbol as! String
                                if let range = symbols.range(of: ":"){
                                    symbols = String(symbols[range.upperBound...])
                                }
                            }
                        }
                        
                        if let prices = json["Time Series (Daily)"] as? NSDictionary{
                            guard let priceArray = prices as? [String: AnyObject] else {return}
                            for (key, value) in priceArray{
                                guard let open = value["1. open"] as? String else {return}
                                guard let high = value["2. high"] as? String else {return}
                                guard let low = value["3. low"] as? String else {return}
                                guard let close = value["4. close"] as? String else {return}
                                guard let volume = value["5. volume"] as? String else {return}
                                arrangeDate.append([key, open, high, low, close, volume])
                            }
                        }
                        
                        let sortedArray = arrangeDate.sorted(by: {left, right in
                            let leftDate = self.dateFormater.date(from: left[0])
                            let rightDate = self.dateFormater.date(from: right[0])
                            return leftDate!.compare(rightDate!) == .orderedAscending
                        })
                        
                        var finalArray = [DailyPrice]()
                        for var data in sortedArray{
                            finalArray.append(DailyPrice(date: data[0], open: Double(data[1])!, high: Double(data[2])!, low: Double(data[3])!, close: Double(data[4])!, volume: Int(data[5])!))
                        }
                        //print(symbols)
                        let newCompany = Company(symbol: symbols, dailyPrices: finalArray)
                        self.listedCompanies.append(newCompany)
                        completion(newCompany)
                        
                        let file = symbols+".json"
                        let jsonFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(file)
                        try? data.write(to: jsonFileUrl)
                    }
                }
                
            }catch let err{
                print(err)
            }
            }.resume()
    }
}
