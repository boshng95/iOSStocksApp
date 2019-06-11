//
//  DailyPrice.swift
//  DTask
//
//  Created by Bosh Ng on 06/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import Foundation

class DailyPrice{
    let dailyDate: String
    let dailyOpen: Double
    let dailyHigh: Double
    let dailyLow: Double
    let dailyClose: Double
    let dailyVolume: Int
    
    init(date: String, open: Double, high: Double, low: Double, close: Double, volume: Int){
        dailyDate = date
        dailyOpen = open
        dailyHigh = high
        dailyLow = low
        dailyClose = close
        dailyVolume = volume
        
    }
}
