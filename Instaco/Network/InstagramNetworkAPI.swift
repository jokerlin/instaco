//
//  InstagramNetworkAPI.swift
//  Instaco
//
//  Created by Henry Lin on 7/10/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class InstagramAPI {
    
    let API_URL = "https://i.instagram.com/api/v1/"
    let IG_SIG_KEY = "4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
    let headers = ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
                   "User-Agent": "Instagram 19.1.0.31.91 Android (23/6.0.1; 515dpi; 1440x2416; huawei/google; Nexus 6P; angler; angler; en_US)",
                   "X-Ads-Opt-Out": "1",
                   "X-DEVICE-ID": "android-04bb78408befb7b3",
                   "X-FB-HTTP-Engine": "Liger",
                   "X-Google-AD-ID": "446104a7-9ff2-4338-add1-ccab3003253e",
                   "X-IG-App-ID": "567067343352427",
                   "X-IG-Bandwidth-Speed-KBPS": "117,000",
                   "X-IG-Bandwidth-TotalBytes-B": "0",
                   "X-IG-Bandwidth-TotalTime-MS": "0",
                   "X-IG-Capabilities": "3boDAA==",
                   "X-IG-Connection-Speed": "117kbps",
                   "X-IG-Connection-Type": "WIFI"]
    
    var isLoggedIn: Bool = false
    var username: String
    var password: String
    var uuid: String
    var device_id: String
    var csrftoken: String
    var username_id: String
    
    var LastJson: JSON
    var baseNetworkService: BaseNetworkService
    
    init() {
        let requestConfig = RequestConfiguration(url: API_URL)
        baseNetworkService = BaseNetworkService.init(config: requestConfig)
        
        self.isLoggedIn = false
        self.username = ""
        self.password = ""
        self.uuid = ""
        self.device_id = ""
        self.csrftoken = ""
        self.username_id = ""
        self.username = ""
        self.password = ""
        self.LastJson = JSON()
    }
    
    func set_auth(username: String, password: String) {
        self.setUser(username: username, password: password)
        self.device_id = self.generateDeviceId(seed: (username+password).md5())
    }
    
    func generateSignature(data: String) -> String {
        
        var parsedData: String
        parsedData = data.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        parsedData = parsedData.replacingOccurrences(of: ",", with: "%2C")
        
        return data.hmac(algorithm: .SHA256, key: self.IG_SIG_KEY) + "." + parsedData
    }
    
    func generateDeviceId(seed: String) -> String {
        let volatile_seed = "12345"
        return "android-" + (seed + volatile_seed).md5().prefix(16)
    }
    
    func generateUUID(type: Bool) -> String {
        let generated_uuid = UUID().uuidString
        if type {
            return generated_uuid
        } else {
            return generated_uuid.replacingOccurrences(of: "-", with: "")
        }
    }
    
    func setUser(username: String, password: String) {
        self.username = username
        self.password = password
        self.uuid = generateUUID(type: true)
    }
    
    func generatePostParamsTest() -> [String: Any] {
        return ["is_prefetch": 0,
                "feed_view_info": "",
                "latest_story_pk": "",
                "is_feed_visible": 1,
                "seen_posts": "",
                "phone_id": self.device_id,
                "reson": "warm_start_fetch",
                "battery_level": 100,
                "timezone_offset": -14400,
                "_csrftoken": self.csrftoken,
                "is_pull_to_refresh": 0,
                "_uuid": self.uuid,
                "unseen_posts": "",
                "is_charging": 1,
                "is_async_ads": 0,
                "will_sound_on": 0,
                "is_async_ads_rti": 0]
    }
    
    func paginationTimelineTest(next_max_id: String) -> [String: Any] {
        return ["is_prefetch": 0,
                "feed_view_info": "",
                "latest_story_pk": "",
                "is_feed_visible": 1,
                "seen_posts": "",
                "phone_id": self.device_id,
                "reson": "pagination",
                "max_id": next_max_id,
                "battery_level": 100,
                "timezone_offset": -14400,
                "_csrftoken": self.csrftoken,
                "is_pull_to_refresh": 0,
                "_uuid": self.uuid,
                "unseen_posts": "",
                "is_charging": 1,
                "is_async_ads": 0,
                "will_sound_on": 0,
                "is_async_ads_rti": 0]
    }
    
    func likeOp(type: Bool, media_id: String, username: String, user_id: Int) {
        let data = ["module_name": "photo_view_profile",
                    "media_id": media_id,
                    "_csrftoken": self.csrftoken,
                    "username": username,
                    "user_id": String(user_id),
                    "radio_type": "wifi-none",
                    "_uid": self.username_id,
                    "_uuid": self.uuid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        let sign_body = generateSignature(data: jsonString)
        
        if type {
            SendRequestViaHttpBody(URI: "media/" + media_id + "/like/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body,
                                   success: { (JSONResponse) -> Void in
                                    print(JSONResponse)
                                    },
                                   failure: {(error) -> Void in
                                    print(error)})
        } else {
            SendRequestViaHttpBody(URI: "media/" + media_id + "/unlike/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: {(JSONResponse) -> Void in
                                    print(JSONResponse)
                                    },
                                   failure: {(error) -> Void in
                                    print(error)
                                    })
        }
    }
    
    func FollowOp(type: Bool, user_id: String) {
        let data = ["_csrftoken": self.csrftoken,
                    "user_id": user_id,
                    "radio_type": "wifi-none",
                    "_uid": self.username_id,
                    "_uuid": self.uuid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        let sign_body = generateSignature(data: jsonString)
        
        if type {
            SendRequestViaHttpBody(URI: "friendships/create/" + user_id + "/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body,
                                   success: { (JSONResponse) -> Void in
                                    print(JSONResponse)
            },
                                   failure: {(error) -> Void in
                                    print(error)})
        } else {
            SendRequestViaHttpBody(URI: "friendships/destroy/" + user_id + "/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: {(JSONResponse) -> Void in
                print(JSONResponse)
            },
                                   failure: {(error) -> Void in
                                    print(error)
            })
        }
    }
    
    func login(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        // Get Request for csrftoken
        SendRequest(URI: "si/fetch_headers/", method: .get, encoding: URLEncoding.queryString, params: ["challenge_type": "signup", "guid": generateUUID(type: false)],
                        success: { _ -> Void in // (JSONResponse) -> Void in
//                            print(JSONResponse)
                            print("Fetch Header Successfully")
                            
                            // Login Request
                            let cookie = HTTPCookieStorage.shared.cookies
                            for c in cookie! where c.name == "csrftoken" {
                                self.csrftoken = c.value
                            }
                            
                            let data = ["phone_id": self.generateUUID(type: true),
                                        "_csrf_token": self.csrftoken,
                                        "username": self.username,
                                        "guid": self.uuid,
                                        "device_id": self.device_id,
                                        "password": self.password,
                                        "login_attempt_count": "0"]
                            
                            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                            let jsonString = String(data: jsonData!, encoding: .utf8)!
                            let sign_body = self.generateSignature(data: jsonString)
                            
                            self.SendRequestViaHttpBody(URI: "accounts/login/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: success, failure: failure)
                        },
                        failure: { (error) -> Void in
                            print("Fetch Header Failed")
                            print(error)})
    }
    
    func timelineFeed(params: [String: Any], success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        SendRequest(URI: "feed/timeline/", method: .post, encoding: URLEncoding.httpBody, params: params, success: success, failure: failure)
    }
    
    func getUserInfo(userid: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        SendRequest(URI: "users/" + userid + "/info/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
    }
    
    func getUserFriendship(userid: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        SendRequest(URI: "friendships/show/" + userid + "/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
    }
    
    func getUserFeed(userid: String, max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if max_id == "" {
            SendRequest(URI: "feed/user/" + userid + "/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
        } else {
            let parameters: Parameters = ["max_id": max_id!]
            SendRequest(URI: "feed/user/" + userid + "/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
        }
    }
    
    func getMediaInfo(id: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        SendRequest(URI: "media/" + id + "/info/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
    }
    
    func getNewsInbox(max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if max_id == "" {
            SendRequest(URI: "news/inbox/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
        } else {
            let parameters: Parameters = ["max_id": max_id!]
            SendRequest(URI: "news/inbox/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
        }
    }
    
    func getNews(max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if max_id == "" {
            SendRequest(URI: "news/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
        } else {
            let parameters: Parameters = ["max_id": max_id!]
            SendRequest(URI: "news/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
        }
    }
    
    func getFeedLiked(max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if max_id == "" {
            SendRequest(URI: "feed/liked/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
        } else {
            let parameters: Parameters = ["max_id": max_id!]
            SendRequest(URI: "feed/liked/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
        }
    }
    
    func searchUsers(q: String, rank_token: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let params: [String: Any] = ["timezone_offset": -14400,
                                     "q": q,
                                     "count": 30,
                                     "rank_token": insta.uuid]
        SendRequest(URI: "users/search/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func searchSuggested(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let params: [String: Any] = ["type": "blended", "rank_token": insta.uuid]
        SendRequest(URI: "fbsearch/suggested_searches/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func getFeedSaved(max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if max_id == "" {
            SendRequest(URI: "feed/saved/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
        } else {
            let parameters: Parameters = ["max_id": max_id!]
            SendRequest(URI: "feed/saved/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
        }
    }
    
    func SendRequestViaHttpBody(URI: String, method: HTTPMethod, httpbody: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        let requestConfig = RequestConfiguration(url: API_URL)
        let baseNetworkService = BaseNetworkService.init(config: requestConfig)
        let request: URLRequest = baseNetworkService.buildRequestViaSettingHttpBody(path: URI, method: .post, httpbody: httpbody, headers: self.headers)
        
        baseNetworkService.execute(request: request).responseJSON { responseObject in
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
                print(responseObject.request.debugDescription)
            }
            if responseObject.result.isFailure {
                let error: Error = responseObject.result.error!
                failure(error)
                print(responseObject.request.debugDescription)
            }
        }
    }
    
    func SendRequest(URI: String, method: HTTPMethod, encoding: ParameterEncoding, params: Parameters? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        let request: URLRequest = baseNetworkService.buildRequest(path: URI, method: method, encoding: encoding, params: params, headers: self.headers)
        
        baseNetworkService.execute(request: request).responseJSON { responseObject in
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
                print(responseObject.request.debugDescription)
            }
            if responseObject.result.isFailure {
                let error: Error = responseObject.result.error!
                failure(error)
                print(responseObject.request.debugDescription)
            }
        }
    }
    
}
