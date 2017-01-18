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
            
        } else {
            startSpinner()
            if signupMode {
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
                        
                    } else {
                        if error != nil {
                            print("Error saving user")
                            var displayErrorMessage = "Please try again later ..."
                            if let errorMessage = error as NSError? {
                                displayErrorMessage = errorMessage.userInfo["error"] as! String
                            }
                            self.createAlert(title: "Signup Error", message: displayErrorMessage)
                        }
                    }
                }
            } else {    // Signin mode
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    self.stopSpinner()

                    if error != nil {
                        print("Error logging in existing user", error)
                        var displayErrorMessage = "Please try again later ..."
                        if let errorMessage = error as NSError? {
                            displayErrorMessage = errorMessage.userInfo["error"] as! String
                        }
                        self.createAlert(title: "Login Error", message: displayErrorMessage)
                        
                    } else {
                        
                        self.performSegue(withIdentifier: "showProfile", sender: self)
                        
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
            //seedDB()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func seedDB(){
        // Seed Database
        
        let urlArray = ["http://www.mytinyphone.com/uploads/users/whytchocolate30/400357.jpg", "http://3.bp.blogspot.com/_do469iTlR78/SnNtkgOnDZI/AAAAAAAAABU/pLVl94AS6Ts/s400/simpsons_marge.widec.jpg", "http://worldlistz.com/wp-content/uploads/2016/03/Pocahontas.jpg", "http://www.telegraph.co.uk/content/dam/films/2016/04/12/FC_Thelma_2752282k-xlarge_trans++omrcOiT85RE0j6CJOJxR6t9PX9lkYkyuoFX1iM1UJCE.jpg", "http://www.clipartkid.com/images/811/wonder-woman-by-chazzyllama-fan-art-cartoons-comics-traditional-other-hziNSw-clipart.png", "https://s-media-cache-ak0.pinimg.com/236x/a4/ab/4f/a4ab4f4031017c75ed3d572a6d97d024.jpg", "http://dy6g3i6a1660s.cloudfront.net/dzhU0pveErDcQMZZnrea_wQABAA/lb-ad/favorite-female-cartoons.jpg", "http://images6.fanpop.com/image/polls/1288000/1288040_1381018719559_full.jpg?v=1381019042"]
        
        var counter = 100
        
        for urlString in urlArray {
            let url = URL(string: urlString)
            
            do {
                let seedUser = PFUser()
                let data = try Data(contentsOf: url!)
                let imageFile = PFFile(name: "image.jpeg", data: data)
                seedUser["userImage"] = imageFile
                seedUser.username = String(counter)
                seedUser.password = "password"
                seedUser["interestMale"] = true
                seedUser["genderMale"] = false
                seedUser["isGay"] = false
                
                // Allow editing of user record
                let acl = PFACL()
                acl.getPublicWriteAccess = true
                seedUser.acl = acl
                
                //save seedUser
                seedUser.signUpInBackground(block: { (success, error) in
                    if error != nil {
                        print("Error saving seed DB user", counter)
                    } else {
                        print("Saved seed DB user", counter)
                    }
                })
                
                
            } catch {
                print("Error getting data from url", urlString)
            }
            counter += 1
        }
        } //end func seedDB
}


