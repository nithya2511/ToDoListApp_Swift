//
//  TitlesViewController.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import UIKit
import Combine
import RealmSwift
import RealmSwift


class TitlesViewController: UIViewController {
    
    //MARK: - Outlets declaration
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    //MARK: - Variable Declaration
    private var viewModel = TitlesViewModel()
    private var titles : [Title] = []
    private var cancellables = Set<AnyCancellable>()
    private var listViewSegueIdentifier = "showListView"
    private var selectedTitle : Title?
    private var dataService  = DataService.instance
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setUp()
        bindObservers()
        print("Realm is located at:", realm.configuration.fileURL!)
        
    }
    
    private func setUp() {
        addButton.layer.cornerRadius = 35 // change this to dynamic change
        self.tableView.register(UINib(nibName: "TitleTableViewCell", bundle: .main), forCellReuseIdentifier: "titleCell")
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        addButton.dropShadow()
    }
    
    private func bindObservers() {
        self.viewModel.$titles.sink { [weak self] titles in
            self?.titles = titles
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == listViewSegueIdentifier {
            let destVC = segue.destination as! ListViewController
            destVC.title = selectedTitle?.titleName
            destVC.selectedTitle = selectedTitle
            destVC.saveDataCompletionHandler = { items in
                
                do {
                    try self.realm.write {
//                        self.selectedTitle?.items = self.dataService.convertToList(itemArray: items)
//                        self.viewModel.updateTitles(titles: self.titles)
                    }
                } catch {
                    print("Error in encoding items \(error)")
                }
               
               
            self.dataService.saveData(self.titles)
            }
        }
    }
    
   
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField() { alertTextField in
            
            alertTextField.placeholder = "Type List Title"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self] action in
            
            //add new category to category array
            let newTitle = Title()
            newTitle.titleName = textField.text!
            self?.viewModel.addNewTitle(newTitle)
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

//MARK: - Table View Data Source methods
extension TitlesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if titles.count > 0 {
                self.tableView.backgroundView = nil
                return titles.count
                
            } else {
                let imageView = UIImageView(image: UIImage(systemName: "text.badge.plus"))
                imageView.contentMode = .center
                imageView.transform = imageView.transform.scaledBy(x: 5, y: 5)
                
                imageView.layer.opacity = 0.2
                self.tableView.backgroundView = imageView
                
                
                return 0
            }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleTableViewCell
        cell.titleImageView.image = UIImage(systemName: titles[indexPath.row].titleImage ?? "list.clipboard")
        cell.titleLabel.text = titles[indexPath.row].titleName
        return cell
    }
    
    
}

extension TitlesViewController : UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        selectedTitle = titles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: listViewSegueIdentifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else {return}
            
            self.titles.remove(at: indexPath.row)
            viewModel.updateTitles(titles : self.titles)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }

}
