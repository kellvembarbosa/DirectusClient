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
    public let agent = Agent()
    public let baseURL: URL

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


