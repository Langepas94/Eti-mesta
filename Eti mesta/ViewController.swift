////
////  ViewController.swift
////  My Places (with comments)
////
////  Created by Артём Тюрморезов on 01.10.2022.
////a
//
//import UIKit
//
//class ViewController: UIViewController {
//
////    var places = Place.getPlace()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTitleOfNavigationController()
//
//    }
//
//}
//
//extension ViewController: UITableViewDataSource, UITableViewDelegate {
//    
//
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return places.count
////    }
//    
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell
////
////        let place = places[indexPath.row]
////
////        cell.nameLabel.text = place.name
////
////        cell.TypeLabel.text = place.type
////        cell.LocationLabel.text = place.place
////
////        if place.image == nil {
////            cell.imageOfPlace.image = UIImage(named: place.restorantImage!)
////        } else {
////            cell.imageOfPlace.image = place.image
////        }
////
//////        cell.imageOfPlace.image = UIImage(named: places[indexPath.row].restorantImage!)
////        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
////        cell.imageOfPlace.clipsToBounds = true
////
////        return cell
////    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let size = CGFloat(80)
//        return size
//    }
//    
//}
//
//// MARK: - Navigation title
//extension ViewController {
//    func setupTitleOfNavigationController() {
//        let titleLabel = UILabel()
//
//                let titleText = NSAttributedString(string: "Мои рестораны", attributes: [
//                    NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 25) as Any])
//
//                titleLabel.attributedText = titleText
//                titleLabel.sizeToFit()
//                navigationItem.titleView = titleLabel
//    }
//}
//
//
//extension ViewController {
//    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
//        guard let newPlaceVc = segue.source as? NewPlaceTableViewController else { return }
//        newPlaceVc.saveNewPlace()
////        places.append(newPlaceVc.newPlace!)
//    }
//}
//
//
//
