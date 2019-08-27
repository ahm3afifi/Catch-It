//
//  FavouritesTableVC.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import CoreData

class FavouritesTableVC: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController<FavouriteDog>!
    var dataController: DataController!
    
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        tableView.reloadData()
        
        //add reachability observer
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier: \(error.localizedDescription)")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        
        switch reachability.connection {
        case .wifi:
            self.view.alpha = 1.0
        case .cellular:
            self.view.alpha = 1.0
        case .none:
            let ac = UIAlertController(title: "Network Error", message: "Your phone has lost its connection", preferredStyle: .alert)
            ac.addAction(okAction)
            
            self.view.alpha = 0.25
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: - CORE DATA
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<FavouriteDog> = FavouriteDog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("error fetching favorites in FavTableVC: \(error.localizedDescription)")
        }
    }
    
    // MARK: - TABLEVIEW
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! FavouriteDogTableViewCell
        cell.favDogImageView.image = nil
        
        // CONFIGURE THE CELL VIEW
        cell.cardViewConfig()
        
        let dog = fetchedResultsController.fetchedObjects![indexPath.row]
        
        // CONFIGURE THE CELL FROM CORE DATA
        cell.favDogBreedLbl.text = "\(dog.breed ?? "No Breed Info Available")"
        
        if dog.imageData != nil {
            let dogImage = UIImage(data: dog.imageData!)
            cell.favDogImageView.image = dogImage
            return cell
        } else {
            print("no dog image present")
            cell.favDogImageView.image = #imageLiteral(resourceName: "shiba-8.JPG")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // DELETE OBJECT FROM CORE DATA
            let dog = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(dog)
            
            // SAVE CONTEXT
            do {
                try dataController.viewContext.save()
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("could not delete Dog entity: \(error.localizedDescription)")
            }
            // DELETE THE ROW
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // TABLE VIEW CELLS ANIMATION
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.75) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
        
        tableView.allowsSelection = false
    }
    
}
