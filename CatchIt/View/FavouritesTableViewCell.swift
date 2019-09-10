//
//  FavouriteDogTableViewCell.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

class FavouriteDogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet var favDogImageView: UIImageView!
    @IBOutlet var favDogBreedLbl: UILabel!
    
    
    func cardViewConfig() {
 
        cardView.layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 7.0
    }
    
}
