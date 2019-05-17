//
//  SignUpVC.swift
//  FaceLogin
//
//  Created by William Huang on 9/14/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func signUpPressed(_ sender: Any) {
        
        guard emailField.text != "", passwordField.text != "", passwordConField.text != "" else {
            return
        }
        
        if passwordField.text == passwordConField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    return
                }else {
                    print("CAMERA")
                    let cameraVC = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! CameraVC
                    
                    cameraVC.photoType = PhotoType.signup
                    self.present(cameraVC, animated: true, completion: nil)
                }
            })
        }else {
            let alert = UIAlertController(title: "Password doens't match", message: "please put correct password on the field", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
        }
        
    }
}

