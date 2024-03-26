//
//  DetailedItemTableViewCell.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 24.03.24.
//

import UIKit

protocol DetailedItemTableViewCellDelegate : AnyObject {
    
    func toggleItemState(sender : UITableViewCell)
    func updateItemData(title : String, details : String, sender : UITableViewCell)
}

class DetailedItemTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var itemImageView: UIButton!
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemNotesTextView: UITextView!
    
    weak var delegate : DetailedItemTableViewCellDelegate?
    
    var enteredTitle : String = "New Item"
    var enteredDetails : String = ""
    var isItemToggled : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.itemTitleTextField.delegate = self
        self.itemNotesTextView.delegate = self
        self.itemTitleTextField.placeholder = "New To-do Item"
        self.itemTitleTextField.becomeFirstResponder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func itemImageViewPressed(_ sender: UIButton) {
        
        delegate?.toggleItemState(sender: self)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateValues()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //pass the value to VC
        enteredTitle = textField.text!
        
        
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if (text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
       
        enteredDetails = textView.text
        itemNotesTextView.resignFirstResponder()
        updateValues()
    }
    
    func updateValues() {
        delegate?.updateItemData(title: enteredTitle, details: enteredDetails, sender: self)
    }
    
}
