import CloudKit

extension UserDefaults {
  func serverChangeToken(forKey key: String) -> CKServerChangeToken? {
    guard let data = UserDefaults.standard.data(forKey: key)
      else { return nil }
    
    guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
      else { return nil }
    
    return token
  }
  
  func set(_ changeToken: CKServerChangeToken?, forKey key: String) {
    guard let token = changeToken else {
      self.removeObject(forKey: key)
      return
    }
    
    let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
    self.set(data, forKey: key)
  }
  
  func zoneChangeToken(forZone zone: CKRecordZone.ID) -> CKServerChangeToken? {
    return serverChangeToken(forKey: "CloudStore.zoneChangeToken.\(zone.zoneName)")
  }
  
  func set(_ changeToken: CKServerChangeToken?, forZone zone: CKRecordZone.ID) {
    set(changeToken, forKey: "CloudStore.zoneChangeToken.\(zone.zoneName)")
  }
}
