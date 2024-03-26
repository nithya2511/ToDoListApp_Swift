//
//  ListViewModel.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation

class ListViewModel : ObservableObject {
    
    @Published var items : [Item]? = []
    
    func updateItems(items : [Item]){
        self.items = items
    }
    
    func addNewItem() {
        
        let newItem = Item()
        newItem.isEditing = true
        items?.append(newItem)
        
    }
    
    
}
