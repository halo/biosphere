import Foundation
import os.log

class JSONReader {

  private var path: String
  
  private var url: URL {
    return URL(fileURLWithPath: path)
  }

  var success: Bool {
    return data != nil
  }

  var failure: Bool {
    return !success
  }

  init(filePath: String) {
    self.path = filePath
  }

  lazy var data: Data? = {
    do {
      Log.debug("Reading \(self.path)")
      let result = try Data(contentsOf: self.url)
      Log.debug("Content: \(result)")
      Log.debug("Successfuly read it")
      return result
    } catch let error as NSError {
      Log.debug(error.localizedDescription)
      return nil
    }
  }()

  lazy var dictionary: [String: Any] = {
    guard let jsonData = self.data else {
      Log.error("Missing JSON data to parse.")
      return [String: Any]()
    }

    do {
      let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
      if let object = json as? [String: Any] {
        return object
      } else {
        Log.debug("JSON is not a Key-Value object")
      }
    } catch let error as NSError {
      Log.error(error.localizedDescription)
    }
    return [String: Any]()
  }()

}
