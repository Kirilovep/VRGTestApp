//
//  NetworkManager.swift
//  VRGTestApp
//
//  Created by shizo663 on 23.03.2021.
//

import Foundation
import Alamofire

final class NetworkManager {
    
    static func fetchData(_ filter: String,_ completionHandler: @escaping (NewsModel?) -> Void) {
        
        let request = AF.request("\(Urls.basicUrl.rawValue)\(filter)\(Urls.api.rawValue)")
        
        request.responseJSON { (responce) in
            switch responce.result {
            case .success(_):
                if let data = responce.data {
                    let objects = try? JSONDecoder().decode(NewsModel.self, from: data)
                    completionHandler(objects)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
