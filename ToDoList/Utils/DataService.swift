//
//  DataService.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 26.03.24.
//

import Foundation
import RealmSwift

class DataService {
    
    static let instance = DataService()
    
    private init() {}
    
    let realm = try! Realm()
    
    func loadData() -> [Title] {
        return Array(realm.objects(Title.self))
    }
    
    func saveData(_ titleList: [Title]){
        do {
            try realm.write {
                print("Writing all \(titleList)")
                realm.add(titleList)
            }
        } catch {
            print("Error while saving Lists \(error)")
        }
    }
    
    func convertToList(itemArray: [Item]) -> List<Item> {
        let itemList = List<Item>()
        itemArray.forEach { item in
            let curItem = Item()
            curItem.name = item.name
            curItem.details = item.details
            curItem.isCompleted = item.isCompleted
            curItem.isEditing = item.isEditing
            
            itemList.append(curItem)
        }
        return itemList
    }
    
    func printRealmLocation() {
        print("Realm is located at:", realm.configuration.fileURL!)
    }
}
