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
    /// ```public func example(page: Int, perPage: Int = 10) -> AnyPublisher<DirectusResults<[Example]>, Error> {
    ///        let endPoint = "/items/example"
    ///         let request = URLRequest(url: getBaseURL(endPoint: endPoint, customParams: "?fields=id,name&filter[_and][0][status][_eq]=published&limit=\(perPage)&page=\(page)&sort=sort"))

    ///         print("request: \(String(describing: request.url))")

    ///         return agent.run(request)
    ///         .map(\.value)
    ///         .eraseToAnyPublisher()
    ///     }
    ///     ```
    public func getBaseURL(endPoint: String, customParams: String = "") -> URL?  {
        guard let baseURL = self.baseURL else {
            return nil
        }
        
        return URL(string: "\(baseURL.absoluteString + endPoint)\(customParams)")!
    }
    
    func registerWithEmailAndPassword(_ login: LoginModel) -> AnyPublisher<Data, Error> {
        guard let url = getBaseURL(endPoint: "/users") else { return Fail(error: DirectusError.invalidUrl).eraseToAnyPublisher() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(login)
            request.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    func loginWithEmailAndPassword(_ login: LoginModel) -> AnyPublisher<DirectusResults<AccessTokenModel>, Error> {
        guard let url = getBaseURL(endPoint: "/auth/login") else { return Fail(error: DirectusError.invalidUrl).eraseToAnyPublisher() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(login)
            request.httpBody = data
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    /// To use refreshToken
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
    ///
    func refreshToken() -> AnyPublisher<DirectusResults<AccessTokenModel>, Error> {
        guard let url = getBaseURL(endPoint: "/auth/refresh") else { return Fail(error: DirectusError.invalidUrl).eraseToAnyPublisher() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        if let refreshToken = getAccessToken()?.refreshToken {
            do {
                let data = try encoder.encode(RefreshTokenModel(refreshToken: refreshToken))
                request.httpBody = data
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
            
            return agent.run(request)
                .map(\.value)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError()).eraseToAnyPublisher()
        }
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


