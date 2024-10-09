//
//  LoginViewController.swift
//  Flash Chat
//
//  Created by Adam Daris Ryadhi on 26/09/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    print(e)
                } else {
                    self?.performSegue(withIdentifier: Key.loginSegue, sender: self)
                }
            }
        }
    }
}
