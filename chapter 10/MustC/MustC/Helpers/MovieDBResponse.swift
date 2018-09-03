//
//  MovieDBResponse.swift
//  MustC
//
//  Created by Donny Wals on 05/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import Foundation

struct MovieDBLookupResponse: Codable {
  
  struct MovieDBMovie: Codable {
    let popularity: Double?
    let id: Int?
  }
  
  let results: [MovieDBMovie]
}
