//
//  Color.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 26.03.24.
//

import UIKit

extension UIColor {
 
    static let theme = ColorTheme()
}

struct ColorTheme  {
    
    let primary = UIColor(named: "PrimaryColor")
    let secondary = UIColor(named: "SecondaryColor")
    let inversePrimary = UIColor(named: "InversePrimary")
    
}
