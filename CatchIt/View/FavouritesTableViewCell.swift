//
//  FavouritesTableViewCell.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

class FavoriteDogTableViewCell: UITableViewCell {
    
    @IBOutlet var favoriteDogImageView: UIImageView!
    @IBOutlet var favoriteDogBreedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
