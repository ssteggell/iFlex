//
//  NSFetchedResultsController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/23/24.
//

import CoreData


//Adding indexpath extension to FetchedResults
extension NSFetchedResultsController where ResultType == FitnessAlbum {
    func indexPaths(for objects: [FitnessAlbum]) -> [IndexPath]? {
        var indexPaths: [IndexPath] = []
        for object in objects {
            if let indexPath = indexPath(forObject: object) {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths.isEmpty ? nil : indexPaths
    }
}
