//
//  ThemeManager.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit

class ThemeManager {
    
    static func setup() {
        
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.9759346843, green: 0.5839473009, blue: 0.02618087828, alpha: 1)
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.9759346843, green: 0.5839473009, blue: 0.02618087828, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        
    }
    
}
