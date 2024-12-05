//
//  FitnessAlbum+CoreDataProperties.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/7/24.
//
//

import Foundation
import CoreData


extension FitnessAlbum {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FitnessAlbum> {
        return NSFetchRequest<FitnessAlbum>(entityName: "FitnessAlbum")
    }

    @NSManaged public var coverPhoto: Data?
    @NSManaged public var creationDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var photos: NSSet?
    @NSManaged public var position: Int16

}

// MARK: Generated accessors for photos
extension FitnessAlbum {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: ProgressPhotos)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: ProgressPhotos)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
    

}

extension FitnessAlbum : Identifiable {

}
