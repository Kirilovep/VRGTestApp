//
//  Connectivity.swift
//  VRGTestApp
//
//  Created by shizo663 on 24.03.2021.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
