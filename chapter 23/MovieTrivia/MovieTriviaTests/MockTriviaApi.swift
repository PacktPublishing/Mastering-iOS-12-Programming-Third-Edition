//
//  MockTriviaApi.swift
//  MovieTriviaTests
//
//  Created by Donny Wals on 02/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import Foundation
@testable import MovieTrivia

struct MockTriviaAPI: TriviaAPIProviding {
  func loadTriviaQuestions(callback: @escaping QuestionsFetchedCallback) {

    guard let filename = Bundle(for: LoadQuestionsTest.self).path(forResource: "TriviaQuestions", ofType: "json"),
      let triviaString = try? String(contentsOfFile: filename),
      let triviaData = triviaString.data(using: .utf8)
      else { return }

    callback(triviaData)
  }
}
