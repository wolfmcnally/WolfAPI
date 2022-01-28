import XCTest
import WolfAPI

final class WolfAPITests: XCTestCase {
    let api = RandomDataAPI()
    let errorAPI = TransportErrorAPI()

    func testNilInPath() {
        let b: Int? = nil
        let c: Int? = 3
        let urlComponents = URLComponents(scheme: .http, host: "example.com", port: 123, basePath: "api", pathComponents: ["a", b as Any, c as Any, "d"])
        XCTAssertEqual(urlComponents.path, "/api/a/3/d")
    }
    
    func testRandomNation() async throws {
        _ = try await api.randomNation()
        //print(nation)
    }
    
    func testTransportError() async throws {
        do {
            try await errorAPI.transportError()
            XCTFail("Should throw.")
        } catch {
            //print(error.localizedDescription)
        }
    }

    func testServerSideError() async throws {
        do {
            _ = try await api.serverSideError()
            XCTFail("Should throw.")
        } catch {
            //print(error.localizedDescription)
        }
    }
}

// https://random-data-api.com/documentation
class RandomDataAPI: API {
    init() {
        super.init(endpoint: .init(host: "random-data-api.com", basePath: "api"))
    }
    
    func randomNation() async throws -> Nation {
        try await call(
            returning: Nation.self,
            path: ["nation", "random_nation"]
        )
    }
    
    func serverSideError() async throws -> Data {
        try await call(
            path: ["foo", "bar"]
        )
    }
}

class TransportErrorAPI: API {
    init() {
        super.init(endpoint: .init(host: "electrum.blockstream.info", port: 50002))
    }
    
    func transportError() async throws {
        _ = try await call(
            path: ["foo", "bar"]
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
