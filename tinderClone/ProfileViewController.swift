//
//  ProfileViewController.swift
//  tinderClone
//
//  Created by Doug Wells on 1/16/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let user = PFUser.current()
    var genderMale = true
    var interestMale = false
    var isGay = false
    var defaultImage = true
    var maleImage = UIImage(named: "cruiseCartoon.jpg")
    var femaleImage = UIImage(named: "megCartoon.jpg")

    
    //declare activityIndicator (needed for functions start/stop spinner)
    var activityIndicator = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 300, width: 100, height: 100))
    
    @IBOutlet weak var imageToPost: UIImageView!
    
    
    @IBAction func genderMaleSwitch(_ sender: UISwitch) {
        if sender.isOn {
            genderMale = false
            print("user is a woman")
            if defaultImage {
                imageToPost.image = femaleImage
            }
            
        } else {
            
            genderMale = true
            print("user is man")
            if defaultImage {
               imageToPost.image = maleImage
            }
            
        }
        gay()
    }

    @IBAction func genderInterestSwitch(_ sender: UISwitch) {
        if sender.isOn {
            interestMale = false
            print("user likes women")
        } else {
            interestMale = true
            print("user likes men")
        }
        gay()
    }
    
    func gay () {
        if  ((genderMale && interestMale) ||
            (!genderMale && !interestMale)) {
            isGay = true
            print("user is gay")
            
        } else {
            isGay = false
            print("user is heterosexual")
        }
    }


    
    @IBAction func importImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        
        //gives ViewController control of imagePickerController
        imagePickerController.delegate = self
        
        //can set imagePicker to camera or photo library
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imagePickerController.allowsEditing = false
        
        //present imagePicker's image
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // function passes us an object "info" on user selected image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //Updates imageView on Main.storyboard (see IBOutlet below)
            imageToPost.image = image
            defaultImage = false
            
        } else {
            print("There was a problem getting the image")
        }
        
        //closes our function "imagePickerController"
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func updateProfile(_ sender: UIButton) {
        
        self.startSpinner()
        let tinderProfiles = PFObject(className: "tinderProfiles")
        tinderProfiles["userid"] = user?.objectId
        tinderProfiles["genderMale"] = genderMale
        tinderProfiles["interestMale"] = interestMale
        tinderProfiles["isGay"] = isGay
        
        
        let imageData = UIImageJPEGRepresentation(imageToPost.image!, 0.5)
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        tinderProfiles["userImage"] = imageFile
        
        tinderProfiles.saveInBackground { (success, error) in
            self.stopSpinner()
            if error != nil {
                self.createAlert(title: "Error Saving Image", message: "Please try again later.  Thanks")
            } else {
                
                self.createAlert(title: "Successfull", message: "Your image profile has been saved")
                
                self.defaultImage = true
                
                if self.genderMale {
                    
                  self.imageToPost.image = self.maleImage
                    
                } else {
                    
                    self.imageToPost.image = self.femaleImage
                    
                }
                
            }
        }
    } //end updateProfile
    
    
    
    func createAlert(title: String, message: String ) {
        //creat alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //add button to alert
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        //present alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func startSpinner(){
        
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    func stopSpinner(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }



    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
