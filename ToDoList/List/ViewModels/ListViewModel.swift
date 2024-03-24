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
        let item = Item(name: "Nithya", isCompleted: true, destails: "Hello World!")
        items?.append(item)
        items?.append(item)
        items?.append(item)
        items?.append(item)
        items?.append(item)
        items?.append(item)
    }
}
