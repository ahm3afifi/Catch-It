//
//  RandomDogVC.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/24/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import CoreData

class RandomDogVC: UIViewController {

    // OUTLETS
    @IBOutlet var dogImageView: UIImageView!
    @IBOutlet var breedLbl: UILabel!
    @IBOutlet weak var breedSegControl: UISegmentedControl!
    @IBOutlet var reloadBtn: UIBarButtonItem!
    @IBOutlet weak var favouriteBtn: UIBarButtonItem!
    
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    let reachability = Reachability()!
    
    var fetchedResultsController: NSFetchedResultsController<FavouriteDog>!
    var dataController: DataController!
    
    var favouriteDogs = [[String: String]]()
    var tempDog: [String: String] = [:]
    var breedArray: [String]!
    var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        breedLbl.isHidden = true
        breedSegControl.isHidden = true
        randomDogButtonPressed(self)
        dogImageView.layer.cornerRadius = 20
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupFetchedResultsController()
        
        // ADD REACHABILITY OBSERVER
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("reachability error: \(error.localizedDescription)")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        
        switch reachability.connection {
        case .wifi:
            reloadBtn.isEnabled = true
            favouriteBtn.isEnabled = shouldEnable()
            self.view.alpha = 1.0
        case .cellular:
            reloadBtn.isEnabled = true
            favouriteBtn.isEnabled = shouldEnable()
            self.view.alpha = 1.0
        case .none:
            let ac = UIAlertController(title: "Network Error", message: "Your phone has lost its connection", preferredStyle: .alert)
            ac.addAction(okAction)
            reloadBtn.isEnabled = false
            favouriteBtn.isEnabled = false
            activityIndicator.stopAnimating()
            self.view.alpha = 0.25
            present(ac, animated: true, completion: nil)
        }
    }
    
    func isFavorite() -> Bool {
        if let fetchedDogs = fetchedResultsController.fetchedObjects {
            for dog in fetchedDogs {
                if tempDog.keys.contains(dog.photoURL!) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func shouldEnable() -> Bool {
        return !tempDog.isEmpty
    }
    
    
    // MARK: - CORE DATA RELATED
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<FavouriteDog> = FavouriteDog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func showBreedOrSubBreed(_ sender: UISegmentedControl) {
        switch breedSegControl.selectedSegmentIndex {
        case 1:
            if breedArray.count > 1 {
                breedLbl.text = "Sub-Breed: \(breedArray[1])"
            } else {
                breedLbl.text = "No Sub-Breed Found"
            }
        default:
            if breedLbl.text != breedArray[0] {
                breedLbl.text = "Breed: \(breedArray[0])"
            }
        }
    }
    
    @IBAction func randomDogButtonPressed(_ sender: Any) {
        favouriteBtn.isEnabled = false
        reloadBtn.isEnabled = false
        tempDog.removeAll()
        favouriteBtn.tintColor = nil
        breedSegControl.isEnabled = false
        activityIndicator.color = UIColor.blue
        activityIndicator.frame = dogImageView.bounds
        dogImageView.addSubview(activityIndicator)
        dogImageView.alpha = 0.5
        activityIndicator.startAnimating()
        breedSegControl.selectedSegmentIndex = 0
        
        DogClient.sharedInstance.getRandomDog { (image, imageData, urlString, error) in
            
            guard error == nil else {
                print("there was an error: \(error!)")
                return
            }
            
            guard let urlString = urlString else {
                print("no dogURL string returned from showRandomDog")
                return
            }
            
            guard let imageData = imageData else {
                print("no image data returned from showRandomDog")
                return
            }
            
            self.imageData = imageData
            
            guard let image = image else {
                print("no photo returned")
                
                DispatchQueue.main.async {
                    self.dogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
                    self.breedLbl.text = "No Photo Available"
                    self.breedLbl.isHidden = false
                    self.activityIndicator.stopAnimating()
                }
                
                return
            }
            
            self.breedArray = DogClient.sharedInstance.getBreedAndSubBreed(urlString: urlString)
            
            DispatchQueue.main.async {
                self.breedSegControl.isHidden = false
                self.breedSegControl.isEnabled = true
                self.dogImageView.image = image
                self.dogImageView.alpha = 1.0
                self.breedLbl.text = "Breed: \(self.breedArray[0])"
                self.breedLbl.isHidden = false
                
                if self.isFavorite() {
                    self.favouriteBtn.isEnabled = true
                    self.favouriteBtn.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                } else {
                    self.favouriteBtn.isEnabled = true
                    self.favouriteBtn.tintColor = nil
                }
                self.reloadBtn.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
            
            self.tempDog.updateValue(self.breedArray[0], forKey: urlString)
            
        }
    }
    
    func addDog(dogInfo: [String:String]) {

        var url: String!
        var breed: String!
        
        for (x, y) in dogInfo {
            url = x
            breed = y
        }
        
        // CREATE FavoriteDog ENTITY
        let dog = FavouriteDog(context: dataController.viewContext)
        
        // ASSIGN ATTRIBUTES
        dog.photoURL = url
        dog.breed = breed
        dog.imageData = imageData
        
        // SAVE CONTEXT
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("could not save Dog entity: \(error.localizedDescription)")
        }
    }
    
    func removeDog(dogInfo: [String:String]) {
        let favoriteDogs = fetchedResultsController.fetchedObjects!
        for (url, _) in dogInfo {
            for dog in favoriteDogs {
                if url == dog.photoURL {
                    dataController.viewContext.delete(dog)
                }
            }
            // SAVE CONTEXT
            do {
                try dataController.viewContext.save()
                
            } catch {
                fatalError("could not delete Dog entity: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        // IF tempDog IS ALREADY IN FAVOURITE
        if isFavorite() == true {
            // DELETE DOG FROM CORE DATA
            removeDog(dogInfo: tempDog)
            // TOGGLE TINT COLOR OFF
            favouriteBtn.tintColor = nil
            try? fetchedResultsController.performFetch()
        } else { // tempDog IS NOT IN THE FAVOURITES
            // THEN ADD DOG TO CORE DATA
            addDog(dogInfo: tempDog)
            // TOGGLE TINT TO RED
            favouriteBtn.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            try? fetchedResultsController.performFetch()
        }
    }
    
    
}

