import Foundation
import Combine


/*
 
// MARK: example
 
```

  Exemplo de uso:
 let directusClient = DirectusClient(baseURL: URL(string: AppConfig.urlDirectus)!)

 directusClient.getFaces(page: 1)
     .sink(receiveCompletion: { completion in
         switch completion {
         case .failure(let error):
             print("Error: \(error)")
         case .finished:
             print("Finished")
         }
     }, receiveValue: { result in
         print("Result: \(result)")
     })
     .store(in: &cancellables)
 ```
 
 
 */

public class DirectusClient {
    private let agent = Agent()
    let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func getBaseURL(endPoint: String, customParams: String) -> URL {
        return URL(string: "\(baseURL.absoluteString + endPoint)\(customParams)")!
    }
    
    
    /// only example
    public func example(page: Int, perPage: Int = 10) -> AnyPublisher<DirectusResults<[Example]>, Error> {
        let endPoint = "/items/example"
        let request = URLRequest(url: getBaseURL(endPoint: endPoint, customParams: "?fields=id,name&filter[_and][0][status][_eq]=published&limit=\(perPage)&page=\(page)&sort=sort"))

        print("request: \(String(describing: request.url))")

        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

/// only example
public struct Example: Codable {
    
}


public struct Agent {
    // 1
    public struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    // 2
    public func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request) // 3
            .tryMap { result -> Response<T> in
                // print("kellvem 1", result)
                let value = try decoder.decode(T.self, from: result.data) // 4
                // print("kellvem 2", value)
                return Response(value: value, response: result.response) // 5
            }
            .receive(on: DispatchQueue.main) // 6
            .eraseToAnyPublisher() // 7
    }
}

public struct DirectusResults <T: Codable>: Codable {
    public let data: T
}


public struct StateAPI <T: Codable> {
    public var items: T
    public var page: Int = 1
    public var canLoadNextPage = true
}
