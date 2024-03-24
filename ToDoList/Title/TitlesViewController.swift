//
//  TitlesViewController.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import UIKit
import Combine


class TitlesViewController: UIViewController {
    
    //MARK: - Outlets declaration
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variable Declaration
    private var viewModel = TitlesViewModel()
    private var titles : [Title]?
    private var cancellables = Set<AnyCancellable>()
    private var listViewSegueIdentifier = "showListView"
    private var selectedTitle : Title?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setUp()
        bindObservers()
        
    }
    
    private func setUp() {
        self.tableView.register(UINib(nibName: "TitleTableViewCell", bundle: .main), forCellReuseIdentifier: "titleCell")
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
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
            destVC.list = selectedTitle
        }
    }
    
}

//MARK: - Table View Data Source methods
extension TitlesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleTableViewCell
        cell.titleImageView.image = UIImage(systemName: "heart")
        cell.titleLabel.text = "World"
        return cell
    }
    
    
}

extension TitlesViewController : UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let titles = titles else {return}
        
        selectedTitle = titles[indexPath.row]
        self.performSegue(withIdentifier: listViewSegueIdentifier, sender: self)
    }
}
