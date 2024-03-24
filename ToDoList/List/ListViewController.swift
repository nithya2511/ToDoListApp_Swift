//
//  ListViewController.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import UIKit
import Combine

class ListViewController: UIViewController {
    
    //MARK: - Outlets declaration
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variable declaration
    var list : Title?
    private var viewModel : ListViewModel?
    private var items : [Item]?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        bindObservers()
        
    }
    
    private func setUp() {
        guard let listName = list else {return}
        viewModel = ListViewModel(title: listName)
        self.tableView.register(UINib(nibName: "ItemTableViewCell", bundle: .main), forCellReuseIdentifier: "itemCell")
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    private func bindObservers() {
        self.viewModel?.$items.sink(receiveValue: { [weak self] items in
            self?.items = items
            self?.tableView.reloadData()
        })
        .store(in: &cancellables)
    }
    
}

extension ListViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        cell.itemNameLabel.text = "Nithya"
        cell.itemDescriptionLabel.text = "Siddharth Chandrasekaran"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 10))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 0, width: headerView.frame.width-0, height: headerView.frame.height - 0)
        label.text = "Completed"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
}

extension ListViewController : UITableViewDelegate {
    
}
