//
//  HomePageCell.swift
//  DTask
//
//  Created by Tammy Sim on 06/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit
import Charts

class HomePageCell: UITableViewCell {
    
    
    @IBOutlet weak var marketSymbol: UILabel!
    @IBOutlet weak var marketName: UILabel!
    @IBOutlet weak var marketOpen: UILabel!
    @IBOutlet weak var marketHigh: UILabel!
    @IBOutlet weak var marketLow: UILabel!
    @IBOutlet weak var marketClose: UILabel!
    
    @IBOutlet weak var marketView: LineChartView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
