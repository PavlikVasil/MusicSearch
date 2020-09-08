//
//  TableViewCell.swift
//  MusicSearch
//
//  Created by Павел on 9/8/20.
//  Copyright © 2020 Павел. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var trackNumber: UILabel!
    
    @IBOutlet weak var trackName: UILabel!
    
}
