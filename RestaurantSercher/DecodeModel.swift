import Foundation

struct GnaviData: Codable {
    let totalHitCount: Int
    let hitPerPage: Int
    var rest: [Restaurant]
}

struct Restaurant: Codable {
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

struct Access: Codable {
    let line: String
    let station: String
    let stationExit: String
    let walk: String
    let note: String
}

struct RestImage: Codable {
    let shopImage1: String
}

struct PRData: Codable {
    let prShort: String
    let prLong: String
}

struct Code: Codable {
    let categoryNameL: [String]
}
