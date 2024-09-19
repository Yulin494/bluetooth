//
//  MainTableViewCell.swift
//  Bluetooth
//
//  Created by imac-1681 on 2024/9/18.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    
    @IBOutlet var NameLb: UILabel!
    
    static let indentifile = "MainTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
