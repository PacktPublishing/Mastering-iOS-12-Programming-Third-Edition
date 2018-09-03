//
//  CloudStore.swift
//  MustC
//
//  Created by Donny Wals on 29/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import CloudKit
import CoreData

class CloudStore {
  let persistentContainer: NSPersistentContainer

  private var privateDatabase: CKDatabase {
    return CKContainer.default().privateCloudDatabase
  }
  
  init(persistentContainer: NSPersistentContainer) {
    self.persistentContainer = persistentContainer
  }
}
