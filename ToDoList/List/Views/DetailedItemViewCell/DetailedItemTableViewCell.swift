//
//  DetailedItemTableViewCell.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 24.03.24.
//

import UIKit
import RSKPlaceholderTextView

protocol DetailedItemTableViewCellDelegate : AnyObject {
    func toggleItemState(sender : UITableViewCell)
    func updateItemData(title : String, details : String, sender : UITableViewCell)
}

class DetailedItemTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: - Outlet Declaration
    @IBOutlet weak var itemImageView: UIButton!
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemNotesTextView: RSKPlaceholderTextView!
    @IBOutlet weak var stackView: UIStackView!
    
    //MARK: - Variable Declaration
    weak var delegate : DetailedItemTableViewCellDelegate?
    var enteredTitle : String = ""
    var enteredDetails : String = ""
    var isItemToggled : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        self.stackView.dropShadow()
        self.itemTitleTextField.delegate = self
        self.itemNotesTextView.delegate = self
        self.itemTitleTextField.placeholder = "New To-do Item"
        self.itemNotesTextView.placeholder = "Add Notes"
        self.itemNotesTextView.placeholderColor = UIColor.lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func itemImageViewPressed(_ sender: UIButton) {
        delegate?.toggleItemState(sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enteredTitle = textField.text!
        updateValues()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        enteredTitle = textField.text!
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        enteredDetails = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == Constants.newLine {
            enteredDetails = textView.text
            updateValues()
            return false
        }
        return true
    }
    
    func updateValues() {
        delegate?.updateItemData(title: enteredTitle, details: enteredDetails, sender: self)
    }
}
