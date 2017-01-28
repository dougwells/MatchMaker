/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse    

class ViewController: UIViewController {
    
    var signupMode = true
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var changeSignupModeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var signupOrLoginButton: UIButton!
    
    let activityIndicator = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    
    @IBAction func changeSignupMode(_ sender: Any) {
        
        if signupMode {
            //Change layout to login
            
            signupOrLoginButton.setTitle("Log In", for: [])
            messageLabel.text = "Don't have an account?"
            changeSignupModeButton.setTitle("Sign Up", for: [])
            
        } else {
            signupOrLoginButton.setTitle("Sign Up", for: [])
            messageLabel.text = "Already have an account?"
            changeSignupModeButton.setTitle("Log In", for: [])
        }
        signupMode = !signupMode
        
    }
    
    @IBAction func signupOrLogin(_ sender: Any) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            createAlert(title: "Error in form", message: "Please enter both username and password")
            
            return
            
        } else {
            startSpinner()
            if signupMode {  //signup Mode
                // Save user in Parse
                let user = PFUser()
                user.username = emailTextField.text
                user.password = passwordTextField.text
                
                
                //Let public write to User field (ACL)
                let acl = PFACL()
                acl.getPublicWriteAccess = true
                user.acl = acl
                
                
                user.signUpInBackground { (success, error) -> Void in
                    self.stopSpinner()
                    if success {
                        print("New user \(user.username!) saved")
                        
                        self.performSegue(withIdentifier: "showProfile", sender: self)
                        return
                        
                    } else {
                        if error != nil {
                            print("Error saving user")
                            var displayErrorMessage = "Please try again later ..."
                            if let errorMessage = error as NSError? {
                                displayErrorMessage = errorMessage.userInfo["error"] as! String
                            }
                            self.createAlert(title: "Signup Error", message: displayErrorMessage)
                        }
                        return
                    }
                }
            } else {    // Login mode
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    self.stopSpinner()

                    if error != nil {
                        print("Error logging in existing user", error)
                        var displayErrorMessage = "Please try again later ..."
                        if let errorMessage = error as NSError? {
                            displayErrorMessage = errorMessage.userInfo["error"] as! String
                        }
                        self.createAlert(title: "Login Error", message: displayErrorMessage)
                        return
                        
                    } else {
                        
                        if user?["genderMale"] != nil
                            && user?["interestMale"] != nil
                            && user?["userImage"] != nil {
                            self.performSegue(withIdentifier: "showMatchesFromLogin", sender: self)
                            
                        } else {
                        
                            self.performSegue(withIdentifier: "showProfile", sender: self)
                        }
                        return
                    }
                })
            }
            
        }
    }
    
    
    
    
    func startSpinner(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }  //End startSpinner
    
    func stopSpinner(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func createAlert(title: String, message: String ) {
        //creat alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //add button to alert
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        //present alert
        self.present(alert, animated: true, completion: nil)
    }  //End createAlert
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        
        //Seed Database if needed
            seedDB(imageArray: maleUrlArray, nameArray: maleNameArray, genderMale: true, interestMale: false)
        
            seedDB(imageArray: femaleUrlArray, nameArray: femaleNameArray, genderMale: false, interestMale: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

        // Seed Database
        
        //let urlArray = ["http://www.mytinyphone.com/uploads/users/whytchocolate30/400357.jpg", "http://3.bp.blogspot.com/_do469iTlR78/SnNtkgOnDZI/AAAAAAAAABU/pLVl94AS6Ts/s400/simpsons_marge.widec.jpg", "http://worldlistz.com/wp-content/uploads/2016/03/Pocahontas.jpg", "http://www.telegraph.co.uk/content/dam/films/2016/04/12/FC_Thelma_2752282k-xlarge_trans++omrcOiT85RE0j6CJOJxR6t9PX9lkYkyuoFX1iM1UJCE.jpg", "http://www.clipartkid.com/images/811/wonder-woman-by-chazzyllama-fan-art-cartoons-comics-traditional-other-hziNSw-clipart.png", "https://s-media-cache-ak0.pinimg.com/236x/a4/ab/4f/a4ab4f4031017c75ed3d572a6d97d024.jpg", "http://dy6g3i6a1660s.cloudfront.net/dzhU0pveErDcQMZZnrea_wQABAA/lb-ad/favorite-female-cartoons.jpg", "http://images6.fanpop.com/image/polls/1288000/1288040_1381018719559_full.jpg?v=1381019042", "https://s-media-cache-ak0.pinimg.com/736x/ac/7b/56/ac7b56dc0fec98cb27befd7842876369.jpg", "https://s-media-cache-ak0.pinimg.com/564x/2b/54/70/2b54704a5228f30be69fad8185a6c43d.jpg"]
        
        let maleUrlArray = ["https://s-media-cache-ak0.pinimg.com/736x/ac/7b/56/ac7b56dc0fec98cb27befd7842876369.jpg", "https://s-media-cache-ak0.pinimg.com/originals/5c/a6/4d/5ca64d21b4057551c594c8e69b942efb.jpg", "https://s-media-cache-ak0.pinimg.com/564x/3e/a2/4b/3ea24b0ef72031c80ea464ca02b9f803.jpg", "http://www.gannett-cdn.com/-mm-/87fb71e345ef0e6194cb09c15a6219589042cb45/c=2443-57-4792-1381&r=x329&c=580x326/local/-/media/USATODAY/popcandy/2013/08/29/1377791479000-bacon.jpg", "https://s-media-cache-ak0.pinimg.com/564x/bc/83/64/bc8364b6ab38e99e0dae99aa42f2570f.jpg","https://s-media-cache-ak0.pinimg.com/236x/6b/21/b8/6b21b84d4c5c44b7b20bf72dcbe0c87e.jpg", "http://68.media.tumblr.com/6d0cd9fd8e4d604a8fb50000a8de9bc8/tumblr_o4lgmy1wO51r1pw6lo1_1280.jpg"]
    
        let maleNameArray = ["dwayneJohnson", "underDog", "uncleJeb", "kevinBacon", "robertDowney", "dougWells", "caseyNeistat"]
        
        let femaleUrlArray = ["http://images.fanpop.com/images/image_uploads/Reese-Witherspoon--reese-witherspoon-79941_1024_768.jpg", "http://orig14.deviantart.net/78ab/f/2013/309/6/c/audrey_hepburn_by_kewlgrl11396-d6t7ncp.jpg", "http://www.thewallpapers.org/photo/6797/Meg-Ryan-009.jpg", "https://s-media-cache-ak0.pinimg.com/736x/8b/9a/9d/8b9a9d5bc0c7a10bbab86e22513cc266.jpg", "https://s-media-cache-ak0.pinimg.com/originals/29/22/c5/2922c555a055272a0cbcbeadb0057452.jpg", "http://i.imgur.com/nrBMnaB.png"]
    
        let femaleNameArray = ["reeseWitherspoon", "audreyHepburn", "lindaWells", "crystal", "jessicaRabbit", "margeSimpson"]
    
    func seedDB(imageArray:[String], nameArray: [String], genderMale: Bool, interestMale: Bool){
        
        var counter = 0
        
        for urlString in imageArray {
            let url = URL(string: urlString)
            
            do {
                let seedUser = PFUser()
                let data = try Data(contentsOf: url!)
                let imageFile = PFFile(name: "image.jpeg", data: data)
                seedUser["userImage"] = imageFile
                seedUser.username = nameArray[counter]
                seedUser.password = "password"
                seedUser["interestMale"] = interestMale
                seedUser["genderMale"] = genderMale
                seedUser["isGay"] = false
                seedUser["acceptedArr"] = [String]()
                seedUser["rejectedArr"] = [String]()
                
                // Allow editing of user record
                let acl = PFACL()
                acl.getPublicWriteAccess = true
                acl.getPublicReadAccess = true
                seedUser.acl = acl
                
                //Save default location for seed users
                    
                    PFGeoPoint.geoPointForCurrentLocation { (geopoint, error) in
                        print("saveCurrUserLocation returned")
                        if let geopoint = geopoint {
                            
                            seedUser["location"] = geopoint
                            
                            //save seedUser
                            seedUser.signUpInBackground(block: { (success, error) in
                                if error != nil {
                                    print("Error saving seed DB user", seedUser.username)
                                } else {
                                    print("Saved seed DB user", seedUser.username)
                                }
                            })
                            
                        }
                    }
                

                
                
            } catch {
                print("Error getting data from url", urlString)
            }
            counter += 1
        }
        } //end func seedDB
}


