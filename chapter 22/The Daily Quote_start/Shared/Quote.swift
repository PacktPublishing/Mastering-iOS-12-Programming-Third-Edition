import Foundation

struct Quote {

  private static var userDefaults = UserDefaults(suiteName: "group.donnywals.quotetoday")!

  let text: String
  let creator: String

  private static var quotes = [
    Quote(text: "Life is about making an impact, not making an income.",
          creator: "Kevin Kruse"),
    Quote(text: "Whatever the mind of man can conceive and believe, it can achieve.",
          creator: "Napoleon Hill"),
    Quote(text: "You miss 100% of the shots you don’t take.",
          creator: "Wayne Gretzky"),
    Quote(text: "People often say that motivation doesn’t last. Well, neither does bathing.  That’s why we recommend it daily.",
          creator: "Zig Ziglar"),
    Quote(text: "If you hear a voice within you say “you cannot paint,” then by all means paint and that voice will be silenced.",
          creator: "Vincent Van Gogh"),
    Quote(text: "Optimism is the one quality more associated with success and happiness than any other.",
          creator: "Brian Tracy"),
    Quote(text: "Genius is 1% inspiration, 99% perspiration.",
          creator: "Thomas Edison"),
    Quote(text: "You must be the change you wish to see in the world.",
          creator: "Mahatma Ghandi"),
    Quote(text: "If it scares you, it might be a good thing to try.",
          creator: "Seth Godin"),
    Quote(text: "Sometimes you wake up. Sometimes the fall kills you. And sometimes, when you fall, you fly.",
          creator: "Neil Gaiman"),
    ]

  static var randomIndex: Int {
    let uint32Count = UInt32(quotes.count)
    return Int(arc4random_uniform(uint32Count))
  }

  static func quote(atIndex index: Int) -> Quote? {
    guard index < quotes.count
      else { return nil }

    return quotes[index]
  }

  static var current: Quote {
    if let lastQuoteDate = userDefaults.object(forKey: "lastQuoteDate") as? Date {
      if NSCalendar.current.compare(Date(), to: lastQuoteDate, toGranularity: .day) == .orderedDescending {
        setNewQuote()
      }
    } else {
      setNewQuote()
    }

    guard let quoteIndex = userDefaults.object(forKey: "quoteIndex") as? Int,
      let quote = Quote.quote(atIndex: quoteIndex)
      else { fatalError("Could not create a quote..") }

    return quote
  }

  static func setNewQuote() {
    let quoteIndex = Quote.randomIndex
    let date = Date()

    userDefaults.set(date, forKey: "lastQuoteDate")
    userDefaults.set(quoteIndex, forKey: "quoteIndex")
  }
}
