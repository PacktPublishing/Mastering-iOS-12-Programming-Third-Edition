//
//  HairdressersDataSource.swift
//  Hairdressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import Foundation

struct HairdressersDataSource {
  static var hairdressers: [String] = {
    let fileUrl = Bundle.main.url(forResource: "Hairdressers", withExtension: "plist")!
    let data = try! Data(contentsOf: fileUrl)
    let decoder = PropertyListDecoder()
    return try! decoder.decode([String].self, from: data)
  }()
}
