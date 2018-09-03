//
//  Question.swift
//  MovieTrivia
//
//  Created by Donny Wals on 02/08/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import Foundation

struct Question: Codable {
  let title: String
  let answerA: String
  let answerB: String
  let answerC: String
  let correctAnswer: Int
}

struct QuestionsFetchResponse: Codable {
  let questions: [Question]
}
