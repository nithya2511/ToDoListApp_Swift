//
//  ListViewController.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import UIKit
import Combine
import RealmSwift


class ListViewController: UIViewController {
    
    //MARK: - Outlets declaration
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    //MARK: - Variable declaration
    var selectedTitle : Title?
    private var viewModel : ListViewModel?
    private var openItems : [Item] = []
    private var closedItems : [Item] = []
    private let openItemSection : Int = 0
    private let closedItemSection : Int = 1 // Using enum for section number seemed like over-engineering for two permanent sections in a permanent order
    private var cancellables = Set<AnyCancellable>()
    let realm = try! Realm()
    let dataService = DataService.instance
    private var tap : UITapGestureRecognizer?
    
    var saveDataCompletionHandler: (([Item]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        loadListItemData()
        bindObservers()
    }
    
    private func setUp() {
        //Table View
        self.tableView.register(UINib(nibName: "ItemTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.itemCell)
        self.tableView.register(UINib(nibName: "DetailedItemTableViewCell", bundle: .main), forCellReuseIdentifier: Constants.detailedItemCell)
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        //Add button
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.dropShadow()
    }
    
    private func loadListItemData() {
        guard let listName = selectedTitle else {return}
        viewModel = ListViewModel()
        viewModel?.updateItems(items: Array(listName.items))
    }

    private func bindObservers() {
        self.viewModel?.$items.sink(receiveValue: { [weak self] items  in
            guard let self,
                  let items else { return }
            self.openItems = items.filter({$0.isCompleted == false})
            self.closedItems = items.filter({$0.isCompleted == true})
            self.tableView.reloadData()
        })
        .store(in: &cancellables)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        stopEditing()
        viewModel?.addNewItem()
    }
}

//MARK: - TableView Data Source
extension ListViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (openItems + closedItems).count > 0 {
            self.tableView.backgroundView = nil
            switch section {
            case openItemSection:
                return openItems.count
            case closedItemSection :
                return closedItems.count
            default:
                return 0
            }
        }
        else {
            self.tableView.backgroundView = Helper.instance.emptyTableViewBGImage()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case openItemSection:
            if openItems[indexPath.row].isEditing == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.detailedItemCell, for: indexPath) as! DetailedItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: openItems[indexPath.row]), for: .normal)
                cell.itemTitleTextField.text = openItems[indexPath.row].name
                cell.itemNotesTextView.text = openItems[indexPath.row].details
                cell.enteredTitle = openItems[indexPath.row].name
                cell.enteredDetails = openItems[indexPath.row].details ?? ""
                cell.itemTitleTextField.becomeFirstResponder()
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.itemCell, for: indexPath) as! ItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: openItems[indexPath.row]), for: .normal)
                cell.itemNameLabel.text = openItems[indexPath.row].name
                cell.delegate = self
                return cell
            }
            
        case closedItemSection:
            if closedItems[indexPath.row].isEditing == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.detailedItemCell, for: indexPath) as! DetailedItemTableViewCell
                cell.delegate = self
                cell.itemTitleTextField.text = closedItems[indexPath.row].name
                cell.itemNotesTextView.text = closedItems[indexPath.row].details
                cell.itemImageView.setImage(imageForItem(item: closedItems[indexPath.row]), for: .normal)
                cell.enteredTitle = closedItems[indexPath.row].name
                cell.enteredDetails = closedItems[indexPath.row].details ?? ""
                cell.itemTitleTextField.becomeFirstResponder()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.itemCell, for: indexPath) as! ItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: closedItems[indexPath.row]), for: .normal)
                cell.itemNameLabel.text = closedItems[indexPath.row].name
                cell.delegate = self
                return cell
            }
        default:
            return UITableViewCell()
        }
    }

    private func imageForItem(item : Item) -> UIImage {
        
        item.isCompleted ? UIImage(systemName: "checkmark")! : UIImage(systemName: "square")!
    }
}

//MARK: - Table View Delegate
extension ListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        stopEditing()
        switch indexPath.section {
        case openItemSection :
            openItems[indexPath.row].isEditing = true
        case closedItemSection :
            closedItems[indexPath.row].isEditing = true
        default : break
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else {return}
            switch indexPath.section {
            case self.openItemSection :
                self.openItems.remove(at: indexPath.row)
            case self.closedItemSection:
                self.closedItems.remove(at: indexPath.row)
            default: break
            }
            viewModel?.updateItems(items: self.openItems + self.closedItems)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
    private func stopEditing() {
        openItems.indices.forEach {
            openItems[$0].isEditing = false
        }
        closedItems.indices.forEach {
            closedItems[$0].isEditing = false
        }
    }
}

//MARK: - Section headers
extension ListViewController  {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case openItemSection:
            return nil
        case closedItemSection :
            return "Completed Section"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case openItemSection:
            return CGFloat(Constants.openItemSectionHeaderHeight)
        case closedItemSection :
            return CGFloat(Constants.closedItemSectionHeaderHeight)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case openItemSection :
            if openItems[indexPath.row].isEditing == true {
                return CGFloat(Constants.detailedItemRowHeight)
            } else {
                return CGFloat(Constants.itemRowHeight)
            }
        case closedItemSection :
            if closedItems[indexPath.row].isEditing == true {
                return CGFloat(Constants.detailedItemRowHeight)
            } else {
                return CGFloat(Constants.itemRowHeight)
            }
        default : return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 10))
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        label.text = "Completed"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        headerView.addSubview(label)
        return headerView
    }
}

extension ListViewController : DetailedItemTableViewCellDelegate, ItemTableViewCellDelegate {
    func updateItemData(title: String, details: String, sender: UITableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            switch selectedIndexPath.section {
            case openItemSection:
                openItems[selectedIndexPath.row].name = title
                openItems[selectedIndexPath.row].details = details
                openItems[selectedIndexPath.row].isEditing = false
                
            case closedItemSection:
                closedItems[selectedIndexPath.row].name = title
                closedItems[selectedIndexPath.row].details = details
                closedItems[selectedIndexPath.row].isEditing = false
                
            default: break
            }
            
            viewModel?.updateItems(items: openItems + closedItems )
            selectedTitle?.items = self.dataService.convertToList(itemArray: openItems + closedItems)
        }
    }
    
    func toggleItemState(sender: UITableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender){
            switch selectedIndexPath.section {
            case openItemSection :
                openItems[selectedIndexPath.row].isCompleted = !openItems[selectedIndexPath.row].isCompleted
            case closedItemSection :
                closedItems[selectedIndexPath.row].isCompleted = !closedItems[selectedIndexPath.row].isCompleted
            default:
                break
            }
        }
        
        viewModel?.updateItems(items: openItems + closedItems )
    }
    
    func textViewIsEditing() {
        tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        guard let tap else { return }
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.addGestureRecognizer(tap)
    }
    
    @objc func backgroundTapped() {
        stopEditing()
        guard let tap else { return }
        self.tableView.backgroundView?.removeGestureRecognizer(tap)
        tableView.reloadData()
    }
    
}

