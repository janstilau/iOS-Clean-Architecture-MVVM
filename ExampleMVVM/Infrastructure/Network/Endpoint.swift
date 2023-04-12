//
//  Endpoint.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

public enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public enum BodyEncoding {
    case jsonSerializationData
    case stringEncodingAscii
}

// Endpoint 中的 R, 是调用者确定的.
public class Endpoint<R>: ResponseRequestable {
    
    public typealias Response = R
    
    public let path: String
    public let isFullPath: Bool
    public let method: HTTPMethodType
    public let headerParamaters: [String: String]
    public let queryParametersEncodable: Encodable?
    public let queryParameters: [String: Any]
    public let bodyParamatersEncodable: Encodable?
    public let bodyParamaters: [String: Any]
    public let bodyEncoding: BodyEncoding
    public let responseDecoder: ResponseDecoder
    
    init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParamaters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParamatersEncodable: Encodable? = nil,
         bodyParamaters: [String: Any] = [:],
         bodyEncoding: BodyEncoding = .jsonSerializationData,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParamaters = headerParamaters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParamatersEncodable = bodyParamatersEncodable
        self.bodyParamaters = bodyParamaters
        self.bodyEncoding = bodyEncoding
        self.responseDecoder = responseDecoder
    }
}

// 对于 Request 对象的抽象.
// 最有价值的, 就是 urlRequest 这个方法了. 给出了默认的实现.
// 是根据 Requestable 中各个属性, 完成的最终的 URLRequest 的构建.
public protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    
    var method: HTTPMethodType { get }
    var headerParamaters: [String: String] { get }
    
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    
    var bodyParamatersEncodable: Encodable? { get }
    var bodyParamaters: [String: Any] { get }
    
    var bodyEncoding: BodyEncoding { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

enum RequestGenerationError: Error {
    case components
}

/*
 Requestable 代表的是单个 Request.
 有着自己业务的一些信息.
 但是他并不知道接口的实际路径. 所以, 需要 NetworkConfigurable 来完成最终的填充.
 
 而 NetworkConfigurable 这个对象, 是由 Service 一层进行的保管.
 */
extension Requestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {
        
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestGenerationError.components }
        var urlQueryItems = [URLQueryItem]()
        
        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        // 使用 URLComponents 和 URLQueryItem 这两个类型, 来完成最终的 URL 拼接.
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        return url
    }
    
    public func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        
        // config 中的 Header, 被当做了默认的值.
        var allHeaders: [String: String] = config.headers
        headerParamaters.forEach { allHeaders.updateValue($1, forKey: $0) }
        
        let bodyParamaters = try bodyParamatersEncodable?.toDictionary() ?? self.bodyParamaters
        if !bodyParamaters.isEmpty {
            urlRequest.httpBody = encodeBody(bodyParamaters: bodyParamaters, bodyEncoding: bodyEncoding)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        return urlRequest
    }
    
    private func encodeBody(bodyParamaters: [String: Any], bodyEncoding: BodyEncoding) -> Data? {
        switch bodyEncoding {
        case .jsonSerializationData:
            return try? JSONSerialization.data(withJSONObject: bodyParamaters)
        case .stringEncodingAscii:
            return bodyParamaters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        }
    }
}

// Form 表单形式的拼接.
private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let josnData = try JSONSerialization.jsonObject(with: data)
        return josnData as? [String : Any]
    }
}
