import UIKit
import CloudKit
import CoreData

class CloudStore {
  let persistentContainer: NSPersistentContainer
  
  var isSubscribedToDatabase: Bool {
    get { return UserDefaults.standard.bool(forKey: "CloudStore.isSubscribedToDatabase") }
    set { UserDefaults.standard.set(newValue, forKey: "CloudStore.isSubscribedToDatabase") }
  }

  var privateDatabaseChangeToken: CKServerChangeToken? {
    get { return UserDefaults.standard.serverChangeToken(forKey: "CloudStore.privateDatabaseChangeToken") }
    set { UserDefaults.standard.set(newValue, forKey: "CloudStore.privateDatabaseChangeToken") }
  }

  private var privateDatabase: CKDatabase {
    return CKContainer.default().privateCloudDatabase
  }

  init(persistentContainer: NSPersistentContainer) {
    self.persistentContainer = persistentContainer
  }
}

extension CloudStore {
  func subscribeToChangesIfNeeded(_ completion: @escaping (Error?) -> Void) {
    guard isSubscribedToDatabase == false else {
      completion(nil)
      return
    }
    
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true

    let subscription = CKDatabaseSubscription(subscriptionID: "private-changes")
    subscription.notificationInfo = notificationInfo

    let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])

    operation.modifySubscriptionsCompletionBlock = { [unowned self] subscriptions, subscriptionIDs, error in
      if error == nil {
        self.isSubscribedToDatabase = true
      }
      
      completion(error)
    }

    privateDatabase.add(operation)
  }
}

extension CloudStore {
  func handleNotification(_ dict: [String: AnyObject], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let notification = CKNotification(fromRemoteNotificationDictionary: dict)
    
    if notification.subscriptionID == "private-changes" {
      fetchDatabaseChanges { error in
        if error == nil {
          completionHandler(.newData)
        } else {
          completionHandler(.failed)
        }
      }
    }
  }
}

extension CloudStore {
  func fetchDatabaseChanges(_ completionHandler: @escaping (Error?) -> Void) {
    let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: privateDatabaseChangeToken)
    
    var zoneIds = [CKRecordZone.ID]()
    operation.recordZoneWithIDChangedBlock = { zoneId in
      zoneIds.append(zoneId)
    }

    operation.changeTokenUpdatedBlock = { [weak self] changeToken in
      self?.privateDatabaseChangeToken = changeToken
    }

    operation.fetchDatabaseChangesCompletionBlock = { [weak self] changeToken, success, error in
      self?.privateDatabaseChangeToken = changeToken

      if zoneIds.count > 0 && error == nil {
        self?.fetchZoneChangesInZones(zoneIds, completionHandler)
      } else {
        completionHandler(error)
      }
    }

    privateDatabase.add(operation)
  }
}

extension CloudStore {
  func importMovie(withRecord record: CKRecord, withContext moc: NSManagedObjectContext) {
    moc.persist {
      let identifier = record.recordID.recordName
      let movie = Movie.find(byIdentifier: identifier, in: moc) ?? Movie(context: moc)
      movie.title = record["title"] ?? "unkown-title"
      movie.remoteId = record["remoteId"] ?? 0
      movie.popularity = record["rating"] ?? 0.0
      movie.cloudKitData = record.encodedSystemFields
      movie.recordName = identifier
    }
  }
  
  func importFamilyMember(withRecord record: CKRecord, withContext moc: NSManagedObjectContext) {
    moc.persist {
      let identifier = record.recordID.recordName
      let familyMember = FamilyMember.find(byIdentifier: identifier, in: moc) ?? FamilyMember(context: moc)
      familyMember.name = record["name"] ?? "unkown-name"
      familyMember.cloudKitData = record.encodedSystemFields
      familyMember.recordName = identifier
      
      if let movieReferences = record["movies"] as? [CKRecord.Reference] {
        let movieIds = movieReferences.map { reference in
          return reference.recordID.recordName
        }
        
        familyMember.movies = NSSet(array: Movie.find(byIdentifiers: movieIds, in: moc))
      }
    }
  }
}

extension CloudStore {
  func fetchZoneChangesInZones(_ zones: [CKRecordZone.ID], _ completionHandler: @escaping (Error?) -> Void) {
    var fetchConfigurations = [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration]()
    for zone in zones {
      if let changeToken = UserDefaults.standard.zoneChangeToken(forZone: zone) {
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: changeToken, resultsLimit: nil, desiredKeys: nil)
        fetchConfigurations[zone] = configuration
      }
    }
    
    let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zones, configurationsByRecordZoneID: fetchConfigurations)
    let backgroundContext = persistentContainer.newBackgroundContext()
    var changedMovies = [CKRecord]()
    var changedFamilyMembers = [CKRecord]()
    
    operation.recordChangedBlock = { record in
      if record.recordType == "Movie" {
        changedMovies.append(record)
      } else if record.recordType == "FamilyMember" {
        changedFamilyMembers.append(record)
      }
    }

    operation.fetchRecordZoneChangesCompletionBlock = { [weak self] error in
      for record in changedMovies {
        self?.importMovie(withRecord: record, withContext: backgroundContext)
      }
      
      for record in changedFamilyMembers {
        self?.importFamilyMember(withRecord: record, withContext: backgroundContext)
      }
      
      completionHandler(error)
    }
    
    operation.recordZoneFetchCompletionBlock = { recordZone, changeToken, data, moreComing, error in
      UserDefaults.standard.set(changeToken, forZone: recordZone)
    }

    privateDatabase.add(operation)
  }
}

extension CloudStore {
  func storeFamilyMember(_ familyMember: FamilyMember, _ completionHandler: @escaping (Error?) -> Void) {
    guard let movies = familyMember.movies as? Set<Movie> else {
      completionHandler(nil)
      return
    }

    let defaultZoneId = CKRecordZone.ID(zoneName: "moviesZone", ownerName: CKCurrentUserDefaultName)

    var recordsToSave = movies.map { movie in
      movie.recordForZone(defaultZoneId)
    }
    recordsToSave.append(familyMember.recordForZone(defaultZoneId))

    let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
    operation.modifyRecordsCompletionBlock = { records, recordIds, error in
      
      guard let records = records, error == nil else {
        completionHandler(error)
        return
      }
      
      for record in records {
        if record.recordType == "FamilyMember" {
          familyMember.managedObjectContext?.persist {
            familyMember.cloudKitData = record.encodedSystemFields
          }
        } else if record.recordType == "Movie",
          let movie = movies.first(where: { $0.recordName == record.recordID.recordName }) {

          familyMember.managedObjectContext?.persist {
            movie.cloudKitData = record.encodedSystemFields
          }
        }
      }
      completionHandler(error)
    }

    privateDatabase.add(operation)
  }
}
