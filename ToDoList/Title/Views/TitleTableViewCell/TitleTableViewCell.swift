//
//  TitleTableViewCell.swift
//  ToDoList
//
//  Created by Nithya Vasudevan on 23.03.24.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
