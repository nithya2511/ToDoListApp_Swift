//
//  ItemTableViewCell.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import UIKit

protocol ItemTableViewCellDelegate : AnyObject {
    func toggleItemState(sender : UITableViewCell)
}

class ItemTableViewCell: UITableViewCell {

 
    @IBOutlet weak var itemImageView: UIButton!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    weak var delegate : ItemTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func imageViewPressed(_ sender: Any) {
        delegate?.toggleItemState(sender: self)
    }
}
