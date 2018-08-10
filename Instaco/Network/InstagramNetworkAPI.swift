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
import UIKit

class InstagramAPI {
    
    let API_URL = "https://i.instagram.com/api/v1/"
    let IG_SIG_KEY = "4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
    var headers = ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
                   "User-Agent": "Instagram 11.0.0.21.20 (iPhone5,2; iPhone OS 9_0_2; zh_CN; zh-Hans-CN; scale=2.00; gamut=normal; 640x1136) AppleWebKit/420+",
                   "X-FB-HTTP-Engine": "Liger",
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
    var error: String
    
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
        self.error = ""
    }
    
    func set_auth(username: String, password: String) {
        self.setUser(username: username, password: password)
//        self.device_id = self.generateDeviceId(seed: (username+password).md5())
        self.device_id = uuid
    }
    
    private func generateSignature(data: String) -> String {
        
        var parsedData: String
        parsedData = data.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        parsedData = parsedData.replacingOccurrences(of: ",", with: "%2C")
        
        return data.hmac(algorithm: .SHA256, key: self.IG_SIG_KEY) + "." + parsedData
    }
    
    private func generateDeviceId(seed: String) -> String {
        let volatile_seed = "12345"
        return "iphone-" + (seed + volatile_seed).md5().prefix(16)
    }
    
    private func generateUUID(type: Bool) -> String {
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
    
    func saveOp(type: Bool, media_id: String) {
        let data = ["module_name": "photo_view_other",
                    "_csrftoken": self.csrftoken,
                    "radio_type": "wifi-none",
                    "_uid": self.username_id,
                    "_uuid": self.uuid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        let sign_body = generateSignature(data: jsonString)
        
        if type {
            SendRequestViaHttpBody(URI: "media/" + media_id + "/save/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body,
                                   success: { (JSONResponse) -> Void in
                                    print(JSONResponse)
            },
                                   failure: {(error) -> Void in
                                    print(error)})
        } else {
            SendRequestViaHttpBody(URI: "media/" + media_id + "/unsave/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: {(JSONResponse) -> Void in
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
        // get reels tray
        self.reels_tray(success: {_ in}, failure: {_ in})
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
    
    func searchUsers(exclude_list: JSON? = nil, q: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        var params: [String: Any]
        if exclude_list == nil {
            params = ["timezone_offset": -14400,
                     "q": q,
                     "count": 30,
                     "rank_token": insta.uuid]
        } else {
            params = ["exclude_list": exclude_list?.rawString() ?? "",
                     "timezone_offset": -14400,
                     "q": q,
                     "count": 30,
            "rank_token": insta.uuid]
        }
        SendRequest(URI: "users/search/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func searchSuggested(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let params: [String: Any] = ["type": "blended", "rank_token": insta.uuid]
        SendRequest(URI: "fbsearch/suggested_searches/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func getUserFriendshipFollowing(user_id: Int, next_max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        var params: [String: Any] = ["rank_token": insta.uuid]
        if next_max_id != "" {
            params = ["rank_token": insta.uuid, "max_id": next_max_id!]
        }
        SendRequest(URI: "friendships/" + String(user_id) + "/following/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func getUserFriendshipFollower(user_id: Int, next_max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        var params: [String: Any] = ["rank_token": insta.uuid]
        if next_max_id != "" {
            params = ["rank_token": insta.uuid, "max_id": next_max_id!]
        }
        SendRequest(URI: "friendships/" + String(user_id) + "/followers/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func searchUserFriendshipFollowing(query: String, user_id: Int, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let params: [String: Any] = ["rank_token": insta.uuid, "query": query]
        SendRequest(URI: "friendships/" + String(user_id) + "/following/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func searchUserFriendshipFollower(query: String, user_id: Int, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let params: [String: Any] = ["rank_token": insta.uuid, "query": query]
        SendRequest(URI: "friendships/" + String(user_id) + "/followers/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
    func getFeedSaved(max_id: String? = "", success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if max_id == "" {
            SendRequest(URI: "feed/saved/", method: .get, encoding: URLEncoding.default, success: success, failure: failure)
        } else {
            let parameters: Parameters = ["max_id": max_id!]
            SendRequest(URI: "feed/saved/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
        }
    }
    
    func read_msisdn_header(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let data = ["_uid": insta.username_id,
                    "device_id": insta.device_id,
                    "_uuid": self.uuid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        let sign_body = generateSignature(data: jsonString)
        
        SendRequestViaHttpBody(URI: "accounts/read_msisdn_header/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: success, failure: failure)
    }
    
    private func direct_v2_ranked_recipients(mode: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let parameters: Parameters = ["mode": mode, "show_threads": true, "use_unified_inbox": true]
        SendRequest(URI: "direct_v2/ranked_recipients/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
    }
    
    private func direct_v2_inbox(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let parameters: Parameters = ["persistentBadging": true, "use_unified_inbox": true]
        SendRequest(URI: "direct_v2/inbox/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
    }
    
    private func users_profile_notice(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        SendRequest(URI: "users/profile_notice/", method: .get, encoding: URLEncoding(destination: .queryString), success: success, failure: failure)
    }
    
    private func qp_fetch(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let data: [String: Any] = ["vc_policy": "photo_view_other",
                    "_csrftoken": self.csrftoken,
                    "_uid": self.username_id,
                    "_uuid": self.uuid,
                    "query": EXPERIMENTS_QP,
                    "version": 1,
                    "surface_param": "4715"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        let sign_body = generateSignature(data: jsonString)
        
        SendRequestViaHttpBody(URI: "qp/fetch/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: success, failure: failure)
    }
    
    func reels_tray(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let parameters: Parameters = ["_csrftoken": self.csrftoken, "_uuid": self.uuid]
        SendRequest(URI: "feed/reels_tray/", method: .post, encoding: URLEncoding.httpBody, params: parameters, success: success, failure: failure)
    }
    
    func getFeedStory(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        SendRequest(URI: "feed/user/" + insta.username_id + "/", method: .get, encoding: URLEncoding(destination: .queryString), success: success, failure: failure)
    }
    
    private func qe_sync(id: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let data: [String: Any] = ["_uuid": self.uuid,
                                   "id": id,
                                   "_uid": self.username_id,
                                   "_csrftoken": self.csrftoken,
                                   "experiments": EXPERIMENTS_QE]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        let sign_body = generateSignature(data: jsonString)
        
        SendRequestViaHttpBody(URI: "qe/sync/", method: .post, httpbody: "ig_sig_key_version=4&signed_body=" + sign_body, success: success, failure: failure)
    }
    
    func getDiscover(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let parameters: Parameters = ["is_prefetch": true,
                                      "is_from_promote": false,
                                      "max_id": 0,
                                      "timezone_offset": -14400,
                                      "session_id": self.uuid]
        SendRequest(URI: "discover/explore/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
    }
    
    func facebookOTA(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let parameters: Parameters = ["version_name": 11.0  ,
                                      "custom_user_id": insta.username_id,
                                      "fields": "update{download_uri,file_size,uncompressed_size,version_code,resources_checksum,ota_update_policy,download_uri_delta,file_size_delta,fallback_to_full_update,download_uri_delta_base,version_code_delta_base}",
                                      "version_code": 68662588,
                                      "custom_app_id": 1464225827161561]
        SendRequest(URI: "facebook_ota/", method: .get, encoding: URLEncoding(destination: .queryString), params: parameters, success: success, failure: failure)
    }
    
    func simulation() {
        
        // Flume
        self.read_msisdn_header(success: {_ in}, failure: {_ in})
        
        // feed
        self.getFeedStory(success: {_ in}, failure: {_ in})
        
        // direct_v2
        self.direct_v2_ranked_recipients(mode: "raven", success: {_ in}, failure: {_ in})
        self.direct_v2_ranked_recipients(mode: "reshare", success: {_ in}, failure: {_ in})
        self.direct_v2_inbox(success: {_ in}, failure: {_ in})
        
        // qp
        self.qp_fetch(success: {_ in}, failure: {_ in})
        
        // news
        self.getNewsInbox(success: {_ in}, failure: {_ in})
        
        // qe
        self.qe_sync(id: insta.uuid, success: {_ in}, failure: {_ in})
        self.qe_sync(id: insta.username_id, success: {_ in}, failure: {_ in})
        
        // discover
        self.getDiscover(success: {_ in}, failure: {_ in})
        
        // ota
        self.facebookOTA(success: {_ in}, failure: {_ in})
        
        // users
        self.users_profile_notice(success: {_ in}, failure: {_ in})
        self.getUserInfo(userid: insta.username_id, success: {_ in}, failure: {_ in})
    }
    
    func logout(success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) throws {
        let params: [String: Any] = ["device_id": insta.device_id]
        SendRequest(URI: "accounts/logout/", method: .post, encoding: URLEncoding.httpBody, params: params, success: success, failure: failure)
    }
    
    func getLikers(media_id: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let params = ["rank_token": self.uuid]
        SendRequest(URI: "media/" + media_id + "/likers/", method: .post, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
    }
    
//    func searchLikers(media_id: String, query: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
//        let params: [String: Any] = ["rank_token": insta.uuid, "query": query]
//        SendRequest(URI: "media/" + media_id + "/likers/", method: .get, encoding: URLEncoding(destination: .queryString), params: params, success: success, failure: failure)
//    }
//
    private func SendRequestViaHttpBody(URI: String, method: HTTPMethod, httpbody: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        let requestConfig = RequestConfiguration(url: API_URL)
        let baseNetworkService = BaseNetworkService.init(config: requestConfig)
        let request: URLRequest = baseNetworkService.buildRequestViaSettingHttpBody(path: URI, method: .post, httpbody: httpbody, headers: self.headers)
        
        baseNetworkService.execute(request: request).responseJSON { responseObject in
            if responseObject.result.isSuccess {
                print(responseObject.request.debugDescription)
                let resJson = JSON(responseObject.result.value!)
//                print(resJson)
                success(resJson)
            }
            if responseObject.result.isFailure {
                print("Requesting \(String(describing: responseObject.request?.description)) ERROR!")
                if let data = responseObject.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print(utf8Text)
                    self.error = utf8Text
                }
                let error: Error = responseObject.result.error!
                failure(error)
                
            }
        }
    }
    
    private func SendRequest(URI: String, method: HTTPMethod, encoding: ParameterEncoding, params: Parameters? = nil, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        let request: URLRequest = baseNetworkService.buildRequest(path: URI, method: method, encoding: encoding, params: params, headers: self.headers)
        
        baseNetworkService.execute(request: request).responseJSON { responseObject in
            if responseObject.result.isSuccess {
                print(responseObject.request.debugDescription)
                let resJson = JSON(responseObject.result.value!)
//                print(resJson)
                success(resJson)
            }
            if responseObject.result.isFailure {
                print("Requesting \(String(describing: responseObject.request?.description)) ERROR!")
                if let data = responseObject.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print(utf8Text)
                    self.error = utf8Text
                }
                let error: Error = responseObject.result.error!
                failure(error)
            }
        }
    }
}
