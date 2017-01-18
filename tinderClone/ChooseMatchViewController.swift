//
//  ChooseMatchViewController.swift
//  tinderClone
//
//  Created by Doug Wells on 1/18/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class ChooseMatchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
            
            //Add element to the screen programatically (w/o storyboard)
            let label = UILabel(frame: CGRect(x: self.view.bounds.width/2 - 100, y: self.view.bounds.height/2 - 50, width: 200, height: 100))
            
            label.text = "Drag me"
            label.textAlignment = NSTextAlignment.center
            
            view.addSubview(label)
            
            //Recognizer user gesture "pan"/swipe & run fn "wasDragged"
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
            
            //Make label interactive (by default a label is not)
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(gesture)
            
        }
        
        func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
            
            //Move label center to where user drags.
            //translation: location user drag stops relative to start
            let translation = gestureRecognizer.translation(in: view)
            
            //Define label (on gestureRecognizer passed in) & move label
            let label = gestureRecognizer.view!
            label.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
            
            //Add label transformation as user drags (radians, 2pi per 360)
            
            let xFromCenter = translation.x
            let scale = min(100/abs(xFromCenter), 1)
            
            var rotation = CGAffineTransform(rotationAngle: xFromCenter/100)
            var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
            
            label.transform = stretchAndRotation
            
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
                label.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                label.transform = stretchAndRotation
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
