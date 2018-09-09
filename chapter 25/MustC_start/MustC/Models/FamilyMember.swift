import CoreData
import CloudKit

extension FamilyMember {
  func recordIDForZone(_ zone: CKRecordZone.ID) -> CKRecord.ID {
    return CKRecord.ID(recordName: self.recordName!, zoneID: zone)
  }

  func recordForZone(_ zone: CKRecordZone.ID) -> CKRecord {
    let record: CKRecord

    if let data = cloudKitData, let coder = try? NSKeyedUnarchiver(forReadingFrom: data) {
      coder.requiresSecureCoding = true
      record = CKRecord(coder: coder)!
    } else {
      record = CKRecord(recordType: "FamilyMember", recordID: recordIDForZone(zone))
    }

    record["name"] = name!

    if let movies = self.movies as? Set<Movie> {
      let references: [CKRecord.Reference] = movies.map { movie in
        let movieRecord = movie.recordForZone(zone)
        return CKRecord.Reference(record: movieRecord, action: .none)
      }

      record["movies"] = references
    }

    return record
  }

  static func find(byIdentifier recordName: String, in moc: NSManagedObjectContext) -> FamilyMember? {
    let predicate = NSPredicate(format: "recordName == %@", recordName)
    let request: NSFetchRequest<FamilyMember> = FamilyMember.fetchRequest()
    request.predicate = predicate

    guard let result = try? moc.fetch(request)
      else { return nil }

    return result.first
  }
  
  static func find(byName name: String, inContext moc: NSManagedObjectContext) -> FamilyMember? {
    let predicate = NSPredicate(format: "name ==[dc] %@", name)
    let request: NSFetchRequest<FamilyMember> = FamilyMember.fetchRequest()
    request.predicate = predicate
    
    guard let result = try? moc.fetch(request)
      else { return nil }
    
    return result.first
  }
}
