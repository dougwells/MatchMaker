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
    
    @IBOutlet weak var tableView: UITableView!
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MatchesTableViewCell
        
            cell.userImageView.image = images[indexPath.row] as! UIImage
        
            cell.messagesLabel.text = "No messages yet"
        
        cell.userIdLabel.text = userIdArr[indexPath.row]
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //arrays start empty
        images.removeAll()
        userIdArr.removeAll()
        
        let query = PFUser.query()
        
        query?.whereKey("acceptedArr", contains: PFUser.current()?.objectId)
        
        query?.whereKey("objectId", containedIn: PFUser.current()?["acceptedArr"] as! [String])
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        
                        if let imageFile = user["userImage"] as? PFFile {
                            
                            imageFile.getDataInBackground { (data, error) in
                                if let imageData = data {
                                    if let downloadedImage = UIImage(data: imageData) {
                                        
                                        self.images.append(downloadedImage)
                                        
                            self.userIdArr.append(user.objectId!)
                                        
                                        self.tableView.reloadData()
                                        
                                    }
                                }
                            }
                            
                        }
                        

                        
                        
                    }
                }
            }
        
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
