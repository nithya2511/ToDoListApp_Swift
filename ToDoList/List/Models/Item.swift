//
//  Item.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var isCompleted : Bool = false
    @objc dynamic var details : String?
    @objc dynamic var isEditing : Bool = false

    var parentCategory = LinkingObjects(fromType: Title.self, property: "items")
}
