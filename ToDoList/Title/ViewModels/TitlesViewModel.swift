//
//  TitlesViewModel.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import Foundation
import RealmSwift

class TitlesViewModel : ObservableObject {
    
    @Published var titles : [Title] = []
    private var dataService = DataService.instance
    
    let realm = try! Realm()
    
    init() {
        self.fetchTitles()
    }
    
    private func fetchTitles() {
        
        titles = dataService.loadData()
    }
    
    func addNewTitle(_ title : Title) {
        self.titles.append(title)
        dataService.saveData(self.titles)
    }
    
    func updateTitles(titles : [Title]) {
        self.titles = titles
        dataService.saveData(self.titles)
    }
    
    
}
