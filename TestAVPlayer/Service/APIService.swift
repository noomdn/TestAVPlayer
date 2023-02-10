//
//  APIService.swift
//  TestAVPlayer
//
//  Created by Kridsada Chardnin on 9/2/2566 BE.
//

import Foundation
import Alamofire

class APIService {
    
    static var shared = APIService()
    let url = "https://my-api-demo.cchiraayusmomri.repl.co/ListPlayer/List/Url"
    
    func onLoadVideoItem( complation:@escaping(Result<[VideoPlayer], AFError>) -> Void){
        AF.request(url,method:.get,encoding: JSONEncoding.default).responseDecodable(of:[VideoPlayer].self) { response in
            complation(response.result)
        }
    }
}
