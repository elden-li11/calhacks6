//
//  TableViewCell.swift
//  CalHacks6
//
//  Created by Arman Vaziri on 10/26/19.
//  Copyright © 2019 ArmanVaziri. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellDeleteButton: UIButton!
    @IBOutlet weak var cellPauseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
