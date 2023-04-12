//
//  AppConfiguration.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.02.19.
//

import Foundation

/*
 这些值都是通过 InfoPlist 文件里面获取到的.
 而 InfoPlist 文件里面, 又是读取的 BuildSettings 里面的内容.
 
 不管怎么说, 使用一个专门的类型, 来进行常量的管理是正确的. 
 */
final class AppConfiguration {
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            fatalError("ApiKey must not be empty in plist")
        }
        return apiKey
    }()
    
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("ApiBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()
    
    lazy var imagesBaseURL: String = {
        guard let imageBaseURL = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as? String else {
            fatalError("ApiBaseURL must not be empty in plist")
        }
        return imageBaseURL
    }()
}
