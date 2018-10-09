import Foundation
import CoreData
import CloudKit

extension Movie {
  func recordIDForZone(_ zone: CKRecordZone.ID) -> CKRecord.ID {
    return CKRecord.ID(recordName: self.recordName!, zoneID: zone)
  }

  func recordForZone(_ zone: CKRecordZone.ID) -> CKRecord {
    let record: CKRecord

    if let data = cloudKitData, let coder = try? NSKeyedUnarchiver(forReadingFrom: data) {
      coder.requiresSecureCoding = true
      record = CKRecord(coder: coder)!
    } else {
      record = CKRecord(recordType: "Movie", recordID: recordIDForZone(zone))
    }

    record["title"] = title!
    record["rating"] = popularity
    record["remoteId"] = remoteId

    return record
  }

  static func find(byIdentifier recordName: String, in moc: NSManagedObjectContext) -> Movie? {
    let predicate = NSPredicate(format: "recordName == %@", recordName)
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.predicate = predicate

    guard let result = try? moc.fetch(request)
      else { return nil }
    
    return result.first
  }

  static func find(byIdentifiers recordNames: [String], in moc: NSManagedObjectContext) -> [Movie] {
    let predicate = NSPredicate(format: "ANY recordName IN %@", recordNames)
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.predicate = predicate
    
    guard let result = try? moc.fetch(request)
      else { return [] }
    
    return result
  }
  
  static func find(byName name: String, inContext moc: NSManagedObjectContext) -> Movie? {
    let predicate = NSPredicate(format: "name ==[dc] %@", name)
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.predicate = predicate
    
    guard let result = try? moc.fetch(request)
      else { return nil }
    
    return result.first
  }

  static func find(byName name: String, orCreateIn moc: NSManagedObjectContext) -> Movie {
    let predicate = NSPredicate(format: "title ==[dc] %@", name)
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.predicate = predicate

    guard let result = try? moc.fetch(request)
      else { return Movie(context: moc) }

    return result.first ?? Movie(context: moc)
  }
}

