import Foundation
import Combine

public class DirectusClient {
    public static let shared = DirectusClient() // Singleton instance
    
    public let agent = Agent()
    public var baseURL: URL?
    public var debugLevel: DebugLevel?
    public let accessTokenDidChangeNotification = Notification.Name("AccessTokenDidChangeNotification")
    
    private var accessToken: AccessTokenModel? {
        didSet {
            // Notify observers when the access token changes
            NotificationCenter.default.post(name: self.accessTokenDidChangeNotification, object: accessToken)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "AccessTokenKey"

    // 1. Private initializer
    private init() {}

    // 2. Configure method
    public func configure(baseURL: URL, debugLevel: DebugLevel = .none) {
        self.baseURL = baseURL
        self.debugLevel = debugLevel
    }
    
    
    /// Example of use for pagination
    /// =========
    ///```getBaseURL(endPoint: endPoint, customParams: "?fields=id,name&filter[_and][0][status][_eq]=published&limit=\(perPage)&page=\(page)&sort=sort")```
    /// =================
    ///
    ///```
    ///  .tryMap { url -> URLRequest in
    ///    var request = URLRequest(url: url)
    ///    request.httpMethod = "GET"
    ///    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    ///
    ///         return request
    ///     }
    ///     .flatMap { request in
    ///     return self.agent.run(request)
    ///        .map(\.value)
    ///        .eraseToAnyPublisher()
    /// }
    /// ```
    ///
    ///  Exemplo de uso for POST with Custom body data
    ///  ```
    ///  .tryMap { url -> URLRequest in
    ///    var request = URLRequest(url: url)
    ///    request.httpMethod = "POST"
    ///    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    ///    let encoder = JSONEncoder()
    ///    let data = try encoder.encode(login)
    ///    request.httpBody = data
    ///
    ///         return request
    ///     }
    ///     .flatMap { request in
    ///     return self.agent.run(request)
    ///        .map(\.value)
    ///        .eraseToAnyPublisher()
    /// }
    /// ```
    ///
    ///  Exemplo de uso for GET with Custom body data
    ///  ```
    ///  .tryMap { url -> URLRequest in
    ///    var request = URLRequest(url: url)
    ///    request.httpMethod = "GET"
    ///    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    ///
    ///         return request
    ///     }
    ///     .flatMap { request in
    ///     return self.agent.run(request)
    ///        .map(\.value)
    ///        .eraseToAnyPublisher()
    /// }
    /// ```
    public func getBaseURL(endPoint: String, customParams: String = "") -> AnyPublisher<URL, Error> {
        guard let baseURL = self.baseURL, let url = URL(string: "\(baseURL.absoluteString + endPoint)\(customParams)") else {
            return Fail(error: DirectusError.invalidUrl).eraseToAnyPublisher()
        }
        
        return Just(url).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    public func registerWithEmailAndPassword(_ login: LoginModel) -> AnyPublisher<Data, Error> {
        return getBaseURL(endPoint: "/users")
            .tryMap { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                let data = try encoder.encode(login)
                request.httpBody = data
                
                return request
            }
            .flatMap { request in
                return self.agent.run(request)
                    .map(\.value)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func loginWithEmailAndPassword(_ login: LoginModel) -> AnyPublisher<DirectusResults<AccessTokenModel>, Error> {
        return getBaseURL(endPoint: "/auth/login")
            .tryMap { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoder = JSONEncoder()
                let data = try encoder.encode(login)
                request.httpBody = data
                
                return request
            }
            .flatMap { request in
                return self.agent.run(request)
                    .map(\.value)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// how to use refreshAndRetry
    /// It is necessary to handle the error in the function before eraseToAnyPublisher of its method, e.g. the .catch to be used:
    /// ```
    ///.catch { error -> AnyPublisher<DirectusResults<[FriendModel]>, Error> in
    ///    if case DirectusError.unauthorized = error {
    ///        print("===> token error \(error)")
    ///        return self.refreshAndRetry(request)
    ///    } else {
    ///        return Fail(error: error).eraseToAnyPublisher()
    ///    }
    ///}
    ///```
    public func refreshAndRetry<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return getBaseURL(endPoint: "/auth/refresh")
            .tryMap { url -> URLRequest in
                var mutableRequest = request

                guard let refreshToken = self.getAccessToken()?.refreshToken else {
                    throw DirectusError.other(NSError())
                }

                let encoder = JSONEncoder()
                let data = try encoder.encode(RefreshTokenModel(refreshToken: refreshToken))
                mutableRequest.httpBody = data
                mutableRequest.httpMethod = "POST"
                mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

                return mutableRequest
            }
            .flatMap { mutableRequest in
                return self.agent.run(mutableRequest)
                    .map(\.value)
                    .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<DirectusResults<AccessTokenModel>, Error> in
                if case DirectusError.unauthorized = error {
                    print("token catch if ")
                    self.removeAccessToken()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .flatMap { [weak self] accessTokenModel -> AnyPublisher<T, Error> in
                print("===> flatMap")

                guard let self = self else {
                    return Fail(error: NSError()).eraseToAnyPublisher()
                }

                self.saveAccessToken(accessTokenModel.data)
                var mutableRequest = request
                mutableRequest.setValue("Bearer \(accessTokenModel.data.accessToken)", forHTTPHeaderField: "Authorization")

                return self.agent.run(mutableRequest)
                    .map(\.value)
                    .catch { error -> AnyPublisher<T, Error> in
                        if case DirectusError.unauthorized = error {
                            self.removeAccessToken()
                        }
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func refreshToken() -> AnyPublisher<DirectusResults<AccessTokenModel>, Error> {
        return getBaseURL(endPoint: "/auth/refresh")
            .tryMap { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                guard let refreshToken = self.getAccessToken()?.refreshToken else {
                    throw DirectusError.other(NSError())
                }

                let encoder = JSONEncoder()
                let data = try encoder.encode(RefreshTokenModel(refreshToken: refreshToken))
                request.httpBody = data

                return request
            }
            .flatMap { request in
                return self.agent.run(request)
                    .map(\.value)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    
    public func saveAccessToken(_ token: AccessTokenModel) {
        if let encodedToken = try? JSONEncoder().encode(token) {
            userDefaults.set(encodedToken, forKey: accessTokenKey)
            
            // saveLocally token for notify all observers
            DirectusClient.shared.accessToken = token
        }
    }

    public func getAccessToken() -> AccessTokenModel? {
        if let tokenData = userDefaults.data(forKey: accessTokenKey),
           let token = try? JSONDecoder().decode(AccessTokenModel.self, from: tokenData) {
            print("refresh_token: \(token.refreshToken)")
            return token
        }
        return nil
    }

    public func removeAccessToken() {
        userDefaults.removeObject(forKey: accessTokenKey)
        
        // remove token locally for notify all observers
        self.accessToken = nil
    }
}


