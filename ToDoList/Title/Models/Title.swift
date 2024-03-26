//
//  Title.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation
import RealmSwift

class Title : Object {
    
    @objc dynamic var titleImage : String?
    @objc dynamic var titleName : String = ""
    var items = List<Item>()
}
