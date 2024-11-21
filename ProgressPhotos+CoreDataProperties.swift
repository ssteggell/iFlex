//
//  ProgressPhotos+CoreDataProperties.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/7/24.
//
//

import Foundation
import CoreData


extension ProgressPhotos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProgressPhotos> {
        return NSFetchRequest<ProgressPhotos>(entityName: "ProgressPhotos")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var imageData: Data?
    @NSManaged public var album: FitnessAlbum?

}

extension ProgressPhotos : Identifiable {

}
