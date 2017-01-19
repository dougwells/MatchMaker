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
    
    var imageArr = [PFFile]()
    
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
        let query = PFUser.query()  //get all data rows
        
        query?.findObjectsInBackground(block: { (objects, error) in
            print("findObjectsInBackround returned")
            
            if error != nil {
                
                print("Error getting users", error)
                
            } else if let users = objects {
                
                //imageArr starts empty
                    self.imageArr.removeAll()
                    print("Arrays start empty")
                
                for object in users {
                    if let user = object as? PFObject {
                        self.imageArr.append((user["userImage"] as? PFFile)!)
                    }
                }
                
            }
            print("image array complete", self.imageArr)
        })
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
