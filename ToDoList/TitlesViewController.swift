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
    private var selectedTitle : Title?
    
    private var dataService  = DataService.instance
    let realm = try! Realm()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setUp()
        bindObservers()
    }
    
    private func setUp() {
        //tableView
        self.tableView.register(UINib(nibName: "TitleTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.titleCell)
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        //Add Button
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.dropShadow()
    }
    
    private func bindObservers() {
        self.viewModel.$titles.sink { [weak self] titles in
            guard let self else {return}
            self.titles = titles
            self.tableView.reloadData()
        }
        .store(in: &cancellables)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.listViewSegueIdentifier {
            let destVC = segue.destination as! ListViewController
            destVC.title = selectedTitle?.titleName
            destVC.selectedTitle = selectedTitle
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "New List Name", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField() { alertTextField in
            
            alertTextField.placeholder = "Type List Title"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Title", style: .cancel) { [weak self] action in
            let newTitle = Title()
            newTitle.titleName = textField.text ?? ""
            self?.viewModel.addNewTitle(newTitle)
        }
        
        alert.addAction(action)
        alert.view.tintColor = UIColor.theme.primary
       
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
            self.tableView.backgroundView = Helper.instance.emptyTableViewBGImage()
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.titleCell, for: indexPath) as! TitleTableViewCell
        cell.titleImageView.image = UIImage(systemName: titles[indexPath.row].titleImage ?? "list.clipboard")
        cell.titleLabel.text = titles[indexPath.row].titleName
        return cell
    }
}

//MARK: - Tableview Delegate Methods
extension TitlesViewController : UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        selectedTitle = titles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: Constants.listViewSegueIdentifier, sender: self)
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
