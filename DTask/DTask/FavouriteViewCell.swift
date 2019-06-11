//
//  FavouriteViewCell.swift
//  DTask
//
//  Created by Tammy Sim on 08/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit

class FavouriteViewCell: UITableViewCell {
    
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var companySymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
