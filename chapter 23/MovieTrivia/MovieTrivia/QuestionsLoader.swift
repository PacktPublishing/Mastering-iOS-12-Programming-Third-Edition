//
//  QuestionsLoader.swift
//  MovieTrivia
//
//  Created by Donny Wals on 01/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import Foundation

typealias QuestionsLoadedCallback = ([Question]) -> Void

struct QuestionsLoader {
  let apiProvider: TriviaAPIProviding

  func loadQuestions(callback: @escaping QuestionsLoadedCallback) {
    apiProvider.loadTriviaQuestions { data in
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      guard let questionsResponse = try? decoder.decode(QuestionsFetchResponse.self, from: data)
        else { return }

      callback(questionsResponse.questions)
    }
  }
}
