import Foundation
import Combine


/*
 
// MARK: example
 
```
  Extensoes
 extension DirectusClient {
     func getFaces(page: Int, perPage: Int = 10, selectedTag: Tag? = nil) -> AnyPublisher<DirectusResults<[Watchface]>, Error> {
         let endPoint = "/items/watchfaces"
         let request = URLRequest(url: getBaseURL(endPoint: endPoint, customParams: "?fields=*,tags.tags_id&filter[_and][0][status][_eq]=published&filter[_and][1][faceModel][_in]=\(AuthViewModel.shared.getCurrentWatchModelCompatibles)&limit=\(perPage)&page=\(page)\(selectedTag != nil ? "&filter[_and][2][_and][2][tags][tags_id][id][_in]=\(selectedTag!.id)" : "")"))

         print("request: \(String(describing: request.url))")

         return agent.run(request)
             .map(\.value)
             .eraseToAnyPublisher()
     }

     func getTags(page: Int, perPage: Int = 10) -> AnyPublisher<DirectusResults<[Tag]>, Error> {
         let endPoint = "/items/tags"
         let request = URLRequest(url: getBaseURL(endPoint: endPoint, customParams: "?fields=id,name&filter[_and][0][status][_eq]=published&limit=\(perPage)&page=\(page)&sort=sort"))

         print("request: \(String(describing: request.url))")

         return agent.run(request)
             .map(\.value)
             .eraseToAnyPublisher()
     }
 }

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
