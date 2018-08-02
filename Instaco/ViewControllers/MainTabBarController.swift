//
//  MainTabBarController.swift
//  Instaco
//
//  Created by Henry Lin on 7/24/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import UIKit
import KeychainAccess
import IGListKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let keychain = Keychain(service: "com.instacoapp")
        
//        try! keychain.removeAll()
        
        if keychain.allKeys() == [] {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        } else {
            print("Login by \(keychain.allKeys()[0])")
            
            insta.set_auth(username: keychain.allKeys()[0], password: keychain[keychain.allKeys()[0]]!)
            insta.login(
                success: { (JSONResponse) in
                    print("Login Success")
                    insta.LastJson = JSONResponse
                    insta.isLoggedIn = true
                    insta.username_id = insta.LastJson["logged_in_user"]["pk"].stringValue

                    self.setupViewControllers()
                    },
                failure: { _ in
                    print("Login Failed")
            })
        }
    }
    
    func setupViewControllers() {
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: TimelineViewController())
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchViewController())
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "notification"), selectedImage: #imageLiteral(resourceName: "notification"), rootViewController: NewsViewController())
        let likeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: FeedLikedViewController())
        let userProfileController = UserInfoViewController(username_id: insta.username_id)
        let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: userProfileController)
        
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavController,
                           userProfileNavController]
        
        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        
        self.selectedIndex = 0 
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
