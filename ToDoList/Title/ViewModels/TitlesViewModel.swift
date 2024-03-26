//
//  TitlesViewModel.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation

class TitlesViewModel : ObservableObject {
    
    @Published var titles : [Title] = []
    
    init() {
        self.fetchTitles()
    }
    
    private func fetchTitles() {
        
//        let title = Title(titleImage: "heart", titleName: "World", items: [Item]())
//        self.titles?.append(title)
//        self.titles?.append(title)
//        self.titles?.append(title)
    }
    
    func addNewTitle(_ title : Title) {
        self.titles.append(title)
    }
    
    func updatetTitles(titles : [Title]) {
        self.titles = titles
    }
}
