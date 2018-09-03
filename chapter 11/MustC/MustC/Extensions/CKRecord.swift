//
//  CKRecord.swift
//  MustC
//
//  Created by Donny Wals on 08/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import CloudKit

extension CKRecord {
  var encodedSystemFields: Data {
    let coder = NSKeyedArchiver(requiringSecureCoding: true)
    self.encodeSystemFields(with: coder)
    coder.finishEncoding()
    
    return coder.encodedData
  }
}
