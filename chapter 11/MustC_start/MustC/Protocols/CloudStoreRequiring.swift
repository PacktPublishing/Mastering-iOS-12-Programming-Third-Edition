//
//  CloudStoreRequiring.swift
//  MustC
//
//  Created by Donny Wals on 05/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import Foundation

protocol CloudStoreRequiring {
  var cloudStore: CloudStore! { get set }
}
