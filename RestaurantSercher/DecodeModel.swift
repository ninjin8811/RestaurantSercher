import Foundation

class ErrorCode: Codable {
    var error: [ErrorMessage]
}

class ErrorMessage: Codable {
    let code: Int
    let message: String
}

class GnaviData: Codable {
    let totalHitCount: Int
    let hitPerPage: Int
    var rest: [Restaurant]
}

class Restaurant: Codable {
    let name: String
    let address: String
    let url: String
    let tel: String
    let latitude: String
    let longitude: String
    let opentime: String
    let holiday: String
    let budget: Int
    let access: Access
    let imageUrl: RestImage
    let pr: PRData
    let code: Code
}

class Access: Codable {
    let line: String
    let station: String
    let stationExit: String
    let walk: String
    let note: String
}

class RestImage: Codable {
    let shopImage1: String
    let shopImage2: String
}

class PRData: Codable {
    let prShort: String
    let prLong: String
}

class Code: Codable {
    let categoryNameL: [String]
}
