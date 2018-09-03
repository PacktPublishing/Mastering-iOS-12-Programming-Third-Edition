//
//  NSManagedObjectContext.swift
//  Hairdressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
  func persist(_ block: @escaping () -> ()) {
    self.perform {
      block()
      
      do {
        try self.save()
      } catch {
        self.rollback()
      }
    }
  }
}
