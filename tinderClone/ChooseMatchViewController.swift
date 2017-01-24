//
//  ChooseMatchViewController.swift
//  tinderClone
//
//  Created by Doug Wells on 1/18/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class ChooseMatchViewController: UIViewController {
    
    @IBOutlet weak var mateImage: UIImageView!
    
    @IBOutlet weak var rejectAcceptLabel: UILabel!
    
    var currentMateId = ""
    var imageArr = [PFFile]()
    var userIdArr = [String]()
    var acceptedArr = [String]()
    var rejectedArr = [String]()
    var counter = 0
    
    @IBAction func goToUpdateProfile(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "matchToUpdate", sender: self)
        
    }
    
    
    @IBAction func matchToLogin(_ sender: Any) {
        
        PFUser.logOutInBackground { (error) in
            if error != nil {
                print("Error logging user out")
            } else {
                print("Existing user logged out")
                self.performSegue(withIdentifier: "matchToLogin", sender: self)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveCurrUserLocation()
        getMateImages()
        moveToNextImage()
        

        
            //Recognize user gesture "pan"/swipe & run fn "wasDragged"
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
            
            //Make image interactive (by default an image is not)
            mateImage.isUserInteractionEnabled = true
            mateImage.addGestureRecognizer(gesture)
        
        } //end viewDidLoad
        
        func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
            
            //Move label center to where user drags.
            //translation: location user drag stops relative to start
            let translation = gestureRecognizer.translation(in: view)
            
            //Define label (on gestureRecognizer passed in) & move label
            let mateImage = gestureRecognizer.view!
            mateImage.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
            
            //Add label transformation as user drags (radians, 2pi per 360)
            
            let xFromCenter = translation.x
            let scale = min(25/abs(xFromCenter), 1)
            
            var rotation = CGAffineTransform(rotationAngle: xFromCenter/100)
            var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
            
            mateImage.transform = stretchAndRotation
            
            //Do diff actions if label moved left vs right
            if gestureRecognizer.state == UIGestureRecognizerState.ended {
                
                //Chosen = drag right.  Reject = drag left
                //15 pixels before actions kick in
                if translation.x < -15 {
                    
                    if acceptedArr.contains(currentMateId) {
                        acceptedArr = acceptedArr.filter{$0 != currentMateId}
                    }
                    
                    if !rejectedArr.contains(currentMateId) && currentMateId != "" {
                        rejectedArr.append(currentMateId)
                        print("rejected", currentMateId)
                    } else {
                        print ("Previously rejected", currentMateId)
                    }
                    
                    moveToNextImage()
                    PFUser.current()?["rejectedArr"] = rejectedArr
                    PFUser.current()?.saveInBackground()
                    
                    
                    
                } else if translation.x > 15 {
                    
                    if rejectedArr.contains(currentMateId) {
                        rejectedArr = rejectedArr.filter{$0 != currentMateId}
                    }
                    
                    if !acceptedArr.contains(currentMateId) && currentMateId != "" {
                        acceptedArr.append(currentMateId)
                        print("Accepted", currentMateId)
                    } else {
                        print ("Previously chosen", currentMateId)
                    }

                    moveToNextImage()
                    PFUser.current()?["acceptedArr"] = acceptedArr
                    PFUser.current()?.saveInBackground()

                }
                
                //Reset size, rotation and location of label at swipe end
                mateImage.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                mateImage.transform = stretchAndRotation
            }
            
        } //end func wasDragged
    
    func getMateImages(){
        let query = PFUser.query()  //get all data rows in User
        
        query?.whereKey("interestMale", equalTo: PFUser.current()?["genderMale"]!)
        query?.whereKey("genderMale", equalTo: PFUser.current()?["interestMale"]!)
        query?.whereKey("objectId", notContainedIn: PFUser.current()?["rejectedArr"]! as! [Any])
        
        query?.whereKey("location", nearGeoPoint: PFUser.current()?["location"]! as! PFGeoPoint, withinMiles: 1000000)
        
        
        
        query?.findObjectsInBackground(block: { (objects, error) in
            print("findObjectsInBackround returned")
            
            //imageArr starts empty
                self.imageArr.removeAll()
            
            //set rejected and accepted array to user history
                self.acceptedArr = PFUser.current()?["acceptedArr"] as! [String]
                self.rejectedArr = PFUser.current()?["rejectedArr"] as! [String]
            
            if error != nil {
                
                print("Error getting users", error)
                
            } else if let users = objects {

                for object in users {
                    
                    if let user = object as? PFObject {
                        
                        if user["userImage"] != nil {
                            self.imageArr.append(user["userImage"] as! PFFile)
                            self.userIdArr.append(user.objectId!)
                        }
                        
                    }
                }
            }
            print("--- image array complete ---")
        })
    } //end function getMateImages
    
    func moveToNextImage(){
        if self.counter > self.imageArr.count - 1 {
            //self.counter = 0
            self.mateImage.image = #imageLiteral(resourceName: "Done.jpg")
            return
        }
        
            // move to next image in array...
        
            self.currentMateId = userIdArr[self.counter]
            self.imageArr[self.counter].getDataInBackground { (data, error) in
                
                if let imageData = data {
                    if let downloadedImage = UIImage(data: imageData) {
                        self.mateImage.image = downloadedImage
                        self.counter = self.counter + 1
                        
                    }
                }
            }
    }
    
    func saveCurrUserLocation() {
        //find user location (need to add "Privacy - Location when in use in plist for PFGeopoint to work
        
        PFGeoPoint.geoPointForCurrentLocation { (geopoint, error) in
            print(geopoint)
            if let geopoint = geopoint {
                
            }
        }
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
