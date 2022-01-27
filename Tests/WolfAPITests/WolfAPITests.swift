import XCTest
import WolfAPI

final class WolfAPITests: XCTestCase {
    func testNilInPath() {
        let b: Int? = nil
        let c: Int? = 3
        let urlComponents = URLComponents(scheme: .http, host: "example.com", port: 123, basePath: "api", pathComponents: ["a", b as Any, c as Any, "d"])
        XCTAssertEqual(urlComponents.path, "/api/a/3/d")
    }
    
    func testRandomNation() async throws {
        let api = RandomDataAPI()
        api.debugPrintRequests = true
        let nation = try await api.randomNation()
        dump(nation)
    }
}

// https://random-data-api.com/documentation
class RandomDataAPI: API {
    init() {
        super.init(endpoint: Endpoint(host: "random-data-api.com", basePath: "api"))
    }
    
    func randomNation() async throws -> Nation {
        try await call(
            returning: Nation.self,
            method: .get,
            path: ["nation", "random_nation"]
        )
    }
}

// https://random-data-api.com/api/nation/random_nation
// {"id":4174,"uid":"351b8cd5-9af2-4bac-946f-66bae74bbb27","nationality":"Finnish Swedish","language":"Arabic","capital":"Manama","national_sport":"cricket","flag":"🇳🇪"}

struct Nation: Codable {
    let id: Int
    let uid: String
    let nationality: String
    let language: String
    let capital: String
    let national_sport: String
    let flag: String
}
