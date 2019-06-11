//
//  Company.swift
//  DTask
//
//  Created by Bosh Ng on 06/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import Foundation

class Company{
    let companySymbol: String
    var companyDailyStockPrice = [DailyPrice]()
    
    init(symbol: String, dailyPrices: [DailyPrice]){
        companySymbol = symbol
        companyDailyStockPrice = dailyPrices
    }
}
