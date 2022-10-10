//
//  MainTableViewController.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 04.10.2022.
//

import UIKit
import RealmSwift
import Cosmos

@IBDesignable class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var isEmptySearchBar: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !isEmptySearchBar
    }
    @IBOutlet weak var reverseLeftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleOfNavigationController()
        places = realm.objects(Place.self)
        
        
////         MARK: - setup searchcontroller
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Поиск"
//
////        navigationItem.searchController = searchController
//
//        definesPresentationContext = true
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if isFiltering {
             return filteredPlaces.count
         }
        return places.isEmpty ? 0 : places.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell
 
         
         let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
         
        cell.nameLabel.text = place.name
        cell.TypeLabel.text = place.type
        cell.LocationLabel.text = place.location
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
//        cell.imageOfPlace.image = UIImage(named: places[indexPath.row].restorantImage!)
         cell.cosmosView.rating = place.rating
        return cell
    }
    // MARK: - setup Search Controller 2
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if navigationItem.searchController == nil {
//            navigationItem.searchController = searchController
//        }
//    }
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
  
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = CGFloat(80)
        return size
    }
    func setupTitleOfNavigationController() {
        let titleLabel = UILabel()

                let titleText = NSAttributedString(string: "Мои рестораны", attributes: [
                    NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 25) as Any])

                titleLabel.attributedText = titleText
                titleLabel.sizeToFit()
                navigationItem.titleView = titleLabel
    }
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVc = segue.source as? NewPlaceTableViewController else { return }
        newPlaceVc.savePlace()
//        places.append(newPlaceVc.newPlace!)
        tableView?.reloadData()
    }
    
    @IBAction func sortingAction(_ sender: UISegmentedControl) {
        
      sorting()
        
    }
    
    
    @IBAction func reversingSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reverseLeftBarButtonItem.image = UIImage(imageLiteralResourceName: "AZ")
        } else {
            reverseLeftBarButtonItem.image = UIImage(imageLiteralResourceName: "ZA")
        }
        
        sorting()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
           
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVc = segue.destination as! NewPlaceTableViewController
            newPlaceVc.currentPlace = place
        }
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
}


extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_ searchtext: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchtext, searchtext)
        tableView.reloadData()
    }
}
