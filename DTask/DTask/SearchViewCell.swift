//
//  SearchViewCell.swift
//  DTask
//
//  Created by Tammy Sim on 07/05/2019.
//  Copyright © 2019 Bosh Ng. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var industry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
