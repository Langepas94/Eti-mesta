//
//  StorageManager.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 04.10.2022.
//

import Foundation
import RealmSwift


let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
