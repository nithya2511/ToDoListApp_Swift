//
//  ListViewModel.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation

class ListViewModel : ObservableObject {
    
    @Published var items : [Item]? = []
    
    init(title : Title) {
        fetchItems(for: title)
    }
    
    private func fetchItems(for list : Title) {
        var item = Item(name: "1", isCompleted: true, details: "Hello World!", isEditing:  false)
        items?.append(item)
        let item1 = Item(name: "2", isCompleted: false, details: "Hello World!", isEditing:  false)
        items?.append(item1)
        
    }
    
    func updateItems(items : [Item]){
        self.items = items
    }
    
    func addNewItem() {
        
        let item1 = Item(name: "", isCompleted: false, details: "Hello World!", isEditing : true)
        items?.append(item1)
        
    }
}
