//
//  AppDelegate.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/24/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "CatchIt")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ThemeManager.setup()
        dataController.load()
        
        // inject Data Controller into RandomDogVC
        let tabBarViewController = window?.rootViewController as? UITabBarController
        
        if let childViewControllers = tabBarViewController?.children as? [UINavigationController] {
            let firstChild = childViewControllers[0]
            let randomDogVC = firstChild.topViewController as! RandomDogVC
            randomDogVC.dataController = dataController
            
            let secondChild = childViewControllers[1]
            let favoritesTableVC = secondChild.topViewController as! FavouritesTableVC
            favoritesTableVC.dataController = dataController
        }
        
        
        return true
    }

    


}

