//
//  MatchesTableViewCell.swift
//  tinderClone
//
//  Created by Doug Wells on 1/25/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    @IBOutlet weak var messagesTextField: UITextField!
    
    @IBAction func send(_ sender: Any) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
