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
    var list : Title?
    private var viewModel : ListViewModel?
    private var allItems : [Item]?
    private var openItems : [Item]?
    private var closedItems : [Item]?
    private var curItem : Item?
    private var cancellables = Set<AnyCancellable>()
    let openItemSection : Int = 0
    let closedItemSection : Int = 1 // Using enum for section number seemed like over-engineering for two permanent sections in a permanent order
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        bindObservers()
        
    }
    
    private func setUp() {
        guard let listName = list else {return}
        viewModel = ListViewModel(title: listName)
        self.tableView.register(UINib(nibName: "ItemTableViewCell", bundle: .main), forCellReuseIdentifier: "itemCell")
        self.tableView.register(UINib(nibName: "DetailedItemTableViewCell", bundle: .main), forCellReuseIdentifier: "detailedItemCell")
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.addGestureRecognizer(tap)
        //        self.hideKeyboardWhenTappedAround()
    }
    
    @objc private func backgroundTapped() {
        
        for (i,_) in openItems!.enumerated(){
            openItems?[i].isEditing = false
        }
        
        for (i,_) in closedItems!.enumerated(){
            closedItems?[i].isEditing = false
        }
        tableView.reloadData()
    }
    
    private func bindObservers() {
        self.viewModel?.$items.sink(receiveValue: { [weak self] items  in
            self?.allItems = items
            self?.openItems = items?.filter({$0.isCompleted == false})
            self?.closedItems = items?.filter({$0.isCompleted == true})
            //            self?.curItem = items?.filter({$0.isEditing == true}).first
            self?.tableView.reloadData()
        })
        .store(in: &cancellables)
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        viewModel?.addNewItem()
    }
    
}

extension ListViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case openItemSection:
            return openItems?.count ?? 0
        case closedItemSection :
            return closedItems?.count ?? 0
        default:
            return 0 // Should never reach here
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
        case openItemSection :
            if openItems?[indexPath.row].isEditing == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailedItemCell", for: indexPath) as! DetailedItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: openItems![indexPath.row]), for: .normal)
                cell.itemTitleTextField.text = openItems?[indexPath.row].name
                cell.itemNotesTextView.text = openItems?[indexPath.row].details
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: openItems![indexPath.row]), for: .normal)
                cell.itemNameLabel.text = openItems?[indexPath.row].name
                cell.delegate = self
                return cell
            }
            
        case closedItemSection :
            if closedItems?[indexPath.row].isEditing == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailedItemCell", for: indexPath) as! DetailedItemTableViewCell
                cell.delegate = self
                cell.itemTitleTextField.text = closedItems?[indexPath.row].name
                cell.itemNotesTextView.text = closedItems?[indexPath.row].details
                cell.itemImageView.setImage(imageForItem(item: closedItems![indexPath.row]), for: .normal)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
                cell.itemImageView.setImage(imageForItem(item: closedItems![indexPath.row]), for: .normal)
                cell.itemNameLabel.text = closedItems?[indexPath.row].name
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
            openItems?[indexPath.row].isEditing = true
        case closedItemSection :
            closedItems?[indexPath.row].isEditing = true
        default : break
        }
        tableView.reloadData()
    }
    
    private func stopEditing() {
        
        openItems?.indices.forEach {
            openItems?[$0].isEditing = false
        }
        closedItems?.indices.forEach {
            closedItems?[$0].isEditing = false
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
            if openItems?[indexPath.row].isEditing == true {
                return 110
            } else {
                return 40
            }
        case closedItemSection :
            if closedItems?[indexPath.row].isEditing == true {
                return 110
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
   
    func updateItemData(isToggled : Bool, title: String, details: String, sender: UITableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            switch selectedIndexPath.section {
            case openItemSection:
                openItems?[selectedIndexPath.row].name = title
                openItems?[selectedIndexPath.row].details = details
                openItems?[selectedIndexPath.row].isEditing = false
                
            case closedItemSection:
                 closedItems?[selectedIndexPath.row].name = title
                closedItems?[selectedIndexPath.row].details = details
                closedItems?[selectedIndexPath.row].isEditing = false
                
            default: break
                
            }
            viewModel?.updateItems(items: openItems! + closedItems!)
        
        }
    }
    
//    func updateItemName(with itemName: String, sender : UITableViewCell) {
//        if let selectedIndexPath = tableView.indexPath(for: sender){
//            switch selectedIndexPath.section {
//            case openItemSection :
//                if (openItems?[selectedIndexPath.row]) != nil{
//                    openItems?[selectedIndexPath.row].name = itemName
//                    openItems?[selectedIndexPath.row].isEditing = false
//                }
//            case closedItemSection :
//                if (closedItems?[selectedIndexPath.row]) != nil {
//                    closedItems?[selectedIndexPath.row].name = itemName
//                    closedItems?[selectedIndexPath.row].isEditing = false
//                }
//            default:
//                break
//            }
//        }
//        viewModel?.updateItems(items: openItems! + closedItems!)
////        tableView.reloadData()
//    }
    
//    func updateItemDetail(with details: String, sender : UITableViewCell) {
//        if let selectedIndexPath = tableView.indexPath(for: sender){
//            switch selectedIndexPath.section {
//            case openItemSection :
//                if (openItems?[selectedIndexPath.row]) != nil{
//                    openItems?[selectedIndexPath.row].details = details
//                    openItems?[selectedIndexPath.row].isEditing = false
//                }
//            case closedItemSection :
//                if (closedItems?[selectedIndexPath.row]) != nil {
//                    closedItems?[selectedIndexPath.row].details = details
//                    closedItems?[selectedIndexPath.row].isEditing = false
//                }
//            default:
//                break
//            }
//        }
//        viewModel?.updateItems(items: openItems! + closedItems!)
//    }
//    
//    
    func toggleItemState(sender: UITableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender){
            switch selectedIndexPath.section {
            case openItemSection :
                if let item = openItems?[selectedIndexPath.row]{
                    openItems?[selectedIndexPath.row].isCompleted = !item.isCompleted
                }
            case closedItemSection :
                if let item = closedItems?[selectedIndexPath.row] {
                    closedItems?[selectedIndexPath.row].isCompleted = !item.isCompleted
                }
            default:
                break
            }
        }
        
        viewModel?.updateItems(items: openItems! + closedItems!)
    }
    
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    //        gestureRecognizer.cancelsTouchesInView = false
    //        return false
    //    }
}
//
//extension UIViewController {
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}

