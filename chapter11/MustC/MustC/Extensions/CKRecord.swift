import CloudKit

extension CKRecord {
  var encodedSystemFields: Data {
    let coder = NSKeyedArchiver(requiringSecureCoding: true)
    self.encodeSystemFields(with: coder)
    coder.finishEncoding()
    
    return coder.encodedData
  }
}
