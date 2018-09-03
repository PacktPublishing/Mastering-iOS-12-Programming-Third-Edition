//
//  NSManagedObjectContext.swift
//  MustC
//
//  Created by Donny Wals on 24/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
  func persist(block: @escaping () -> Void) {
    perform {
      block()
      
      do {
        try self.save()
      } catch {
        self.rollback()
      }
    }
  }
}
