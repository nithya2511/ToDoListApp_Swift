//
//  TitlesViewModel.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation

class TitlesViewModel : ObservableObject {
    
    @Published var titles : [Title]? = []
    
    init() {
        self.fetchTitles()
    }
    
    private func fetchTitles() {
        
            let title = Title(titleImage: "Hello", titleName: "World")
            self.titles?.append(title)
            self.titles?.append(title)
            self.titles?.append(title)
    }
}
