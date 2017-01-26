//
//  MatchesViewController.swift
//  tinderClone
//
//  Created by Doug Wells on 1/23/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var images = [UIImage]()
    var userIdArr = [String]()
    var messages = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MatchesTableViewCell
        
            cell.userImageView.image = images[indexPath.row] as! UIImage
        
            cell.messagesLabel.text = messages[indexPath.row]
        
            cell.userIdLabel.text = userIdArr[indexPath.row]
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //arrays start empty
        images.removeAll()
        userIdArr.removeAll()
        messages.removeAll()
        
        findMatches()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findMatches() {
        let imageQuery = PFUser.query()
        
        imageQuery?.whereKey("acceptedArr", contains: PFUser.current()?.objectId)
        
        imageQuery?.whereKey("objectId", containedIn: PFUser.current()?["acceptedArr"] as! [String])
        
        imageQuery?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        
                        if let imageFile = user["userImage"] as? PFFile {
                            
                            imageFile.getDataInBackground { (data, error) in
                                if let imageData = data {
                                    if let downloadedImage = UIImage(data: imageData) {
                                        
                                        
                                        let messageQuery = PFQuery(className: "Message")
                                        
                                        messageQuery.whereKey("recipient", equalTo: PFUser.current()?.objectId)
                                        
                                        messageQuery.whereKey("sender", equalTo: user.objectId!)
                                        
                                        messageQuery.findObjectsInBackground(block: { (objects, error) in
                                            
                                            var messageText = "No messages yet. Please check back later"
                                            
                                            if let messages = objects {
                                                
                                                for object in messages {
                                                    
                                                    if let message = object as? PFObject {
                                                        
                                                        if let messageContent = message["content"] as? String {
                                                                messageText = messageContent
                                                        }
                                                        
                                                    }
                                                }
                                                
                                            } //end get msgs (if let messages=objects)
                                            
                                            self.messages.append(messageText)
                                            
                                            self.images.append(downloadedImage)
                                            
                                            self.userIdArr.append(user.objectId!)
                                            
                                            self.tableView.reloadData()
                                            
                                            
                                            
                                        })
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                        
                    }
                }
            }
            
        })

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
