//
//  CustomTableCell.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 03.10.2022.
//

import UIKit
import Cosmos
class CustomTableCell: UITableViewCell {

    @IBOutlet weak var TypeLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension CustomTableCell {
    func setupCell() {
//        LocationLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
    }
}
