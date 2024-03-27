//
//  Helper.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 27.03.24.
//

import Foundation
import UIKit

class Helper {
    
    static let instance = Helper()
    
    private init() {
        
    }
    
    func emptyTableViewBGImage() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "text.badge.plus"))
        imageView.contentMode = .center
        imageView.transform = imageView.transform.scaledBy(x: 5, y: 5)
        
        imageView.layer.opacity = 0.2
        return imageView
    }
}
