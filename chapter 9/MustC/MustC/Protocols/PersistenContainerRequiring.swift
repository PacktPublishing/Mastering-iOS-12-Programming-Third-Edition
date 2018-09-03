//
//  PersistenContainerRequiring.swift
//  MustC
//
//  Created by Donny Wals on 24/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import CoreData

protocol PersistenContainerRequiring {
  var persistentContainer: NSPersistentContainer! { get set }
}
