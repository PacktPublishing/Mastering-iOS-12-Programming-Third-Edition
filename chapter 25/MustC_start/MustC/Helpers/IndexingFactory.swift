import Foundation
import CoreSpotlight

struct IndexingFactory {
  enum ActivityType: String {
    case openTab = "com.familymovies.openTab"
    case familyMemberDetailView = "com.familymovies.familyMemberDetailView"
    case movieDetailView = "com.familymovies.movieDetailView"
  }
  
  static func activity(withType type: ActivityType, name: String, makePublic: Bool) -> NSUserActivity {
    let userActivity = NSUserActivity(activityType: type.rawValue)
    userActivity.title = name
    userActivity.isEligibleForSearch = true
    userActivity.isEligibleForPublicIndexing = makePublic
    
    return userActivity
  }
  
  static func searchableAttributes(forMovie movie: Movie) -> CSSearchableItemAttributeSet {
    do {
      try movie.managedObjectContext?.obtainPermanentIDs(for: [movie])
    } catch {
      print("could not obtain permanent movie id")
    }
    
    let attributes = CSSearchableItemAttributeSet(itemContentType: ActivityType.movieDetailView.rawValue)
    attributes.title = movie.title
    attributes.contentDescription = "A movie that is favorited by (movie.familyMembers?.count ?? 0) family members"
    attributes.rating = NSNumber(value: movie.popularity)
    attributes.identifier = "(movie.objectID.uriRepresentation().absoluteString)"
    attributes.relatedUniqueIdentifier = "(movie.objectID.uriRepresentation().absoluteString)"
    
    return attributes
  }

  static func searchableAttributes(forFamilyMember familyMember: FamilyMember) -> CSSearchableItemAttributeSet {
    do {
      try familyMember.managedObjectContext?.obtainPermanentIDs(for: [familyMember])
    } catch {
      print("could not obtain permanent family member id")
    }
    
    let attributes = CSSearchableItemAttributeSet(itemContentType: ActivityType.familyMemberDetailView.rawValue)
    attributes.title = familyMember.name
    attributes.identifier = "(familyMember.objectID.uriRepresentation().absoluteString)"
    attributes.contentDescription = "Family Member with (familyMember.favoriteMovies?.count ?? 0) listed movies"
    attributes.relatedUniqueIdentifier = "(familyMember.objectID.uriRepresentation().absoluteString)"
    
    return attributes
  }
  
  enum DomainIdentifier: String {
    case familyMember = "FamilyMember"
    case movie = "Movie"
  }

  static func searchableItem(forMovie movie: Movie) -> CSSearchableItem {
    let attributes = searchableAttributes(forMovie: movie)
    
    return searachbleItem(withIdentifier: "(movie.objectID.uriRepresentation().absoluteString)", domain: .movie, attributes: attributes)
  }

  static func searchableItem(forFamilyMember familyMember: FamilyMember) -> CSSearchableItem {
    let attributes = searchableAttributes(forFamilyMember: familyMember)
    
    return searachbleItem(withIdentifier: "(familyMember.objectID)", domain: .familyMember, attributes: attributes)
  }

  private static func searachbleItem(withIdentifier identifier: String, domain: DomainIdentifier, attributes: CSSearchableItemAttributeSet) -> CSSearchableItem {
    let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: domain.rawValue, attributeSet: attributes)
    
    return item
  }
  
  static func activity(forMovie movie: Movie) -> NSUserActivity {
    let activityItem = activity(withType: .movieDetailView, name: movie.title!, makePublic: false)
    let attributes = searchableAttributes(forMovie: movie)
    attributes.domainIdentifier = DomainIdentifier.movie.rawValue
    activityItem.contentAttributeSet = attributes
    
    return activityItem
  }

  static func activity(forFamilyMember familyMember: FamilyMember) -> NSUserActivity {
    let activityItem = activity(withType: .movieDetailView, name: familyMember.name!, makePublic: false)
    let attributes = searchableAttributes(forFamilyMember: familyMember)
    attributes.domainIdentifier = DomainIdentifier.familyMember.rawValue
    activityItem.contentAttributeSet = attributes
    
    return activityItem
  }
}
