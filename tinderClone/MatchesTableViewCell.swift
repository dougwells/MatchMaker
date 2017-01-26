//
//  MatchesTableViewCell.swift
//  tinderClone
//
//  Created by Doug Wells on 1/25/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class MatchesTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    @IBOutlet weak var messagesTextField: UITextField!
    
    @IBOutlet weak var userIdLabel: UILabel!
    
    
    @IBAction func send(_ sender: Any) {
        print(messagesTextField.text)
        print(userIdLabel.text)
        
        let messageDB = PFObject(className: "Message")
        
        messageDB["sender"] = PFUser.current()?.objectId
        
        messageDB["recipient"] = userIdLabel.text
        
        messageDB["content"] = messagesTextField.text
        
        print("saving new message \(userIdLabel.text)")
        messageDB.saveInBackground()
        messagesTextField.text = ""
        
        retrieveMessages(senderId: userIdLabel.text!)
    }
    
    func retrieveMessages(senderId: String) {
        
        let messageQuery = PFQuery(className: "Message")
        
        messageQuery.whereKey("sender", contains: senderId)
    
        messageQuery.whereKey("recipient", contains: PFUser.current()?.objectId!)
        
        messageQuery.limit = 1
        
        messageQuery.findObjectsInBackground { (objects, error) in
            
            if let messages = objects {
                for object in messages {
                    if let message = object as? PFObject {
                        self.messagesLabel.text = message["content"] as! String?
                        
                        print("Retrieve message complete", message["content"])
                        
                    }
                }
            }
        }
        
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
