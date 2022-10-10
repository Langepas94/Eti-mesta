//
//  NewPlaceTableViewController.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 03.10.2022.
//

import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    var currentPlace: Place!
    var imageIsChanged = false
    var currentRating = 0.0
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var cosmosSecondView: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // тут настройка футера чтобы убрать нижнюю полосу
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        setupEditScreen()
        setupNavigationBar()
        setupLabelOfNavigationController()
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        cosmosSecondView.settings.fillMode = .half
        cosmosSecondView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // MARK: - Если ячейка 0 индекс то выбрать фото, если нет то ничего
        if indexPath.row == 0 {
            
            let cameraPic = UIImage(imageLiteralResourceName: "camera")
        
            let photoPic = UIImage(imageLiteralResourceName: "photo")
            let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.setImage(source: .camera)
            }
            camera.setValue(cameraPic, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.setImage(source: .photoLibrary)
            }
            photo.setValue(photoPic, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            action.addAction(camera)
            action.addAction(photo)
            action.addAction(cancel)
            
            present(action, animated: true)
            
        }else {
            view.endEditing(true)
        }
    }
    
    func savePlace() {
        
       
        
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(imageLiteralResourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData, rating: currentRating)
        if currentPlace != nil{
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        
        
        //MARK: - Navigation
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier, let mapVC = segue.destination as? MapVCViewController else { return }
        
        mapVC.segueId = id
        mapVC.mapVcDelegate = self
        if id == "showMap" {
            
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeLocation.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension NewPlaceTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: - Работа с изображением

extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func setImage(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePick = UIImagePickerController()
            imagePick.delegate = self
            imagePick.allowsEditing = true
            imagePick.sourceType = source
            
            present(imagePick, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

extension NewPlaceTableViewController {
    private func setupEditScreen() {
        if currentPlace != nil {
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeType.text = currentPlace?.type
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            cosmosSecondView.rating = currentPlace.rating
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        
        navigationItem.leftBarButtonItem = nil
        
        saveButton.isEnabled = true
    }
    func setupLabelOfNavigationController() {
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: currentPlace?.name ?? "Мои рестораны", attributes: [
            NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy", size: 25) as Any])
        
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
}


extension NewPlaceTableViewController: MapVcDelegate {
    
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
