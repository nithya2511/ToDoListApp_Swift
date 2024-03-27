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
    @IBOutlet weak var addButton: UIButton!
    
    //MARK: - Variable declaration
    var selectedTitle : Title?
    private var viewModel : ListViewModel?
    private var openItems : [Item] = []
    private var closedItems : [Item] = []
    private let openItemSection : Int = 0
    private let closedItemSection : Int = 1 // Using enum for section number seemed like over-engineering for two permanent sections in a permanent order
    private var cancellables = Set<AnyCancellable>()
    
    var saveDataCompletionHandler: (([Item]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        bindObservers()
        
    }
    
    private func setUp() {
        addButton.layer.cornerRadius = 35
        guard let listName = selectedTitle else {return}
        viewModel = ListViewModel()
        viewModel?.updateItems(items: Array(listName.items))
        self.tableView.register(UINib(nibName: "ItemTableViewCell", bundle: .main), forCellReuseIdentifier: "itemCell")
        self.tableView.register(UINib(nibName: "DetailedItemTableViewCell", bundle: .main), forCellReuseIdentifier: "detailedItemCell")
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
//        self.view.isUserInteractionEnabled = true
//        tableView.backgroundView = UIView()
//        tap.cancelsTouchesInView = false
//        tap.delegate = self
       
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        
        self.tableView.addGestureRecognizer(tap)
        
        addButton.dropShadow()
//        self.hideKeyboardWhenTappedAround()
    }
    
    @objc private func backgroundTapped() {
        
        
        for (i,_) in openItems.enumerated(){
            openItems[i].isEditing = false
        }
        
        for (i,_) in closedItems.enumerated(){
            closedItems[i].isEditing = false
        }
        tableView.reloadData()
        view.endEditing(true)
    }
    
    
    private func bindObservers() {
        self.viewModel?.$items.sink(receiveValue: { [weak self] items  in
            guard let self,
                  let items else { return }
            self.openItems = items.filter({$0.isCompleted == false})
            self.closedItems = items.filter({$0.isCompleted == true})
            self.saveDataCompletionHandler?(self.openItems + self.closedItems)
            self.tableView.reloadData()
        })
        .store(in: &cancellables)
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        stopEditing()
        viewModel?.addNewItem()
    }
    
}

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
                return 0 // Should never reach here
            }
            
        }
        else {
            let imageView = UIImageView(image: UIImage(systemName: "text.badge.plus"))
            imageView.contentMode = .center
            imageView.transform = imageView.transform.scaledBy(x: 5, y: 5)
            
            imageView.layer.opacity = 0.2
            self.tableView.backgroundView = imageView
            
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
        case openItemSection :
            if openItems[indexPath.row].isEditing == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailedItemCell", for: indexPath) as! DetailedItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: openItems[indexPath.row]), for: .normal)
                cell.itemTitleTextField.text = openItems[indexPath.row].name
                cell.itemNotesTextView.text = openItems[indexPath.row].details
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: openItems[indexPath.row]), for: .normal)
                cell.itemNameLabel.text = openItems[indexPath.row].name
                cell.delegate = self
                return cell
            }
            
        case closedItemSection :
            if closedItems[indexPath.row].isEditing == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailedItemCell", for: indexPath) as! DetailedItemTableViewCell
                cell.delegate = self
                cell.itemTitleTextField.text = closedItems[indexPath.row].name
                cell.itemNotesTextView.text = closedItems[indexPath.row].details
                cell.itemImageView.setImage(imageForItem(item: closedItems[indexPath.row]), for: .normal)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
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
            return nil // Should never reach here
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case openItemSection:
            return 0
        case closedItemSection :
            return 30
        default:
            return 0 // Should never reach here
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case openItemSection :
            if openItems[indexPath.row].isEditing == true {
                return 140
            } else {
                return 40
            }
        case closedItemSection :
            if closedItems[indexPath.row].isEditing == true {
                return 140
            } else {
                return 40
            }
        default : return 40
        }
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
    
    
}

extension ListViewController : DetailedItemTableViewCellDelegate, ItemTableViewCellDelegate, UIGestureRecognizerDelegate {
    
    //Hnadle possible index out of bounds here
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
            updateItems()
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
        
        updateItems()
    }
    
    private func updateItems() {
        let allItems = openItems + closedItems
        viewModel?.updateItems(items: allItems )
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let location = touch.location(in: self.tableView)
            let path = self.tableView.indexPathForRow(at: location)
            if let indexPathForRow = path {
//                self.tableView(self.tableView, didSelectRowAt: indexPathForRow)
                return false
            } else {
                // handle tap on empty space below existing rows however you want
                print("here")
                return true
            }
    }
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return gestureRecognizer.view == tableView
//    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

