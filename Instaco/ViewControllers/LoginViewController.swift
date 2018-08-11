//
//  LoginViewController.swift
//  Instaco
//
//  Created by Henry Lin on 7/19/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import KeychainAccess
import SwiftyJSON

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "InstacoLoginImage"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255)
        return view
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()
        hideKeyboardWhenTappedAround()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField, loginButton])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignup), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignup() {
        let keychain = Keychain(service: "com.instacoapp")
        try! keychain.removeAll()
        if let link = URL(string: "https://www.instagram.com/accounts/emailsignup/?hl=en") {
            UIApplication.shared.open(link)
        }
    }
    
    @objc func handleLogin() {
        guard let username = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        insta.set_auth(username: username, password: password)
        insta.login(
            success: { (JSONResponse) in
//                print(JSONResponse)
                print("Login Success")
                
                // Store in Keychain
                let keychain = Keychain(service: "com.instacoapp")
                try! keychain.removeAll()
                keychain["username"] = username
                keychain["password"] = password
                keychain["username_id"] = JSONResponse["logged_in_user"]["pk"].stringValue
                keychain["device_id"] = insta.device_id
                keychain["uuid"] = insta.uuid
                keychain["csrftoken"] = insta.csrftoken
                keychain["version"] = INSTACOAPPVERSION
                
                // Set insta object
                insta.isLoggedIn = true
                insta.username_id = JSONResponse["logged_in_user"]["pk"].stringValue
                insta.error = ""
                
                // Do something like an official client, for future use at the same time
                insta.simulation()
                
                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                mainTabBarController.setupViewControllers()
                self.dismiss(animated: true, completion: nil)
        },
            failure: { JSONResponse in
                print(JSONResponse)
                print("Login Failed")
                var title = "Oops, an error occurred."
                var json = JSON.init(parseJSON: insta.error)
                title = json["message"].string ?? title
                if title.contains("checkpoint") {
                    // DO SOMETHING ELSE for checkpoint in the future
                    let alertController = UIAlertController(title: title, message: JSONResponse.localizedDescription, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                } else {
                    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                }
                
        })
    }
}
