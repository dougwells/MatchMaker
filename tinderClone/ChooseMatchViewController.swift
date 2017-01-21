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
    
    var imageArr = [PFFile]()
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
        
        //find user location (need to add "Privacy - Location when in use in plist for PFGeopoint to work
        
        PFGeoPoint.geoPointForCurrentLocation { (geopoint, error) in
            print(geopoint)
            if let geopoint = geopoint {
                PFUser.current()?["location"] = geopoint
                PFUser.current()?.saveInBackground()
            }
        }
        
            //Recognizer user gesture "pan"/swipe & run fn "wasDragged"
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
            
            //Make label interactive (by default a label is not)
            mateImage.isUserInteractionEnabled = true
            mateImage.addGestureRecognizer(gesture)
        
            getMateImages()
        
        
            
        }
        
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
                    
                    print ("Not chosen")
                    moveToNextImage()
                    
                    
                } else if translation.x > 15 {
                    print ("Chosen")

                    
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
        
        
        query?.findObjectsInBackground(block: { (objects, error) in
            print("findObjectsInBackround returned", objects?.count)
            
            //imageArr starts empty
                self.imageArr.removeAll()
                print("Arrays start empty")
            
            if error != nil {
                
                print("Error getting users", error)
                
            } else if let users = objects {

                for object in users {
                    
                    if let user = object as? PFObject {
                        print("username:", user["username"])
                        
                        if user["userImage"] != nil {
                            print("imagefile not nil", user["username"])
                            self.imageArr.append(user["userImage"] as! PFFile)
                        }
                        
                    }
                }
                
            }
            print("image array complete", self.imageArr)
        })
    }
    
    func moveToNextImage(){
        if self.counter > self.imageArr.count - 1 {
            self.counter = 0
        }
        
            // if rejected, go to next image in array...
            self.imageArr[self.counter].getDataInBackground { (data, error) in
                
                if let imageData = data {
                    if let downloadedImage = UIImage(data: imageData) {
                        self.mateImage.image = downloadedImage
                        self.counter = self.counter + 1
                        
                    }
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
