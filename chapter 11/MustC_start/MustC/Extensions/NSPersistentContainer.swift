//
//  NSPersistentContainer.swift
//  MustC
//
//  Created by Donny Wals on 24/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
  func saveContextIfNeeded() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
