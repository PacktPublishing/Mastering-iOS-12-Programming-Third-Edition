//
//  TriviaAPIProviding.swift
//  MovieTrivia
//
//  Created by Donny Wals on 02/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import Foundation

typealias QuestionsFetchedCallback = (Data) -> Void

protocol TriviaAPIProviding {
  func loadTriviaQuestions(callback: @escaping QuestionsFetchedCallback)
}
