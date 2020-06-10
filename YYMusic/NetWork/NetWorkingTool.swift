//
//  NetWorkingTool.swift
//  OP
//
//  Created by 王浩 on 2018/11/12.
//  Copyright © 2018 haoge. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class NetWorkingTool: NSObject {
    static let shared = NetWorkingTool()
    fileprivate var sessionManager = AlamofireManager.sharedSessionManager
    //是否打印返回数据
    fileprivate var isPrint: Bool = false
    /**
     获取服务器数据，并转化为模型
     */
    func requestData<T: Mappable>(generate: (url:String, params: [String: Any]?, headers: HTTPHeaders?), isShowHUD: Bool = true, showText: String? = nil, method: HTTPMethod = .post, successCallback: @escaping (_ result: T?) -> Void, errorCallback: ((Result<T>) -> Void)? = nil, networkError: (() -> Void)? = nil, authCallback: ((Any?) -> Void)? = nil) {

        if isShowHUD {
            CustomHUD.showProgress()
        }
        
        self.sessionManager.request(generate.url, method: method, parameters: generate.params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: generate.headers).validate().responseJSON(completionHandler: { (response) in
            if let _ = response.error {
                if let _ = networkError {
                    networkError?()
                } else {
                    CustomHUD.showHideErrorHUD()
                }
            } else if let value = response.value {
                
                if self.isPrint {
                    debugPrint(value)
                }
                
                if let json = value as? [String: Any] {
                    let map = Map(mappingType: .toJSON, JSON: json)
                    let result = Result<T>(JSON: map.JSON)!
                    if result.ret == 0 {
                        if isShowHUD {
                            if let text = showText {
                                CustomHUD.showSuccessHUD(subtitle: text, completion: {
                                    successCallback(result.data)
                                })
                            } else {
                                CustomHUD.hideProgress()
                                successCallback(result.data)
                            }
                        } else {
                            successCallback(result.data)
                        }
                    } else {
                        if let _ = errorCallback {
                            if isShowHUD {
                               CustomHUD.hideProgress()
                            }
                            errorCallback?(result)
                        } else {
                           self.processResponseError(result.ret ?? 0, msg: result.msg, error: result.error)
                        }
                    }

                } else {
                    //返回json格式不正常
                    CustomHUD.showHideTextHUD("数据格式错误")
                }
            }
        })
    }
    
    func requestDataBD<T: BaseResult>(generate: (url:String, params: [String: Any]?, headers: HTTPHeaders?), isShowHUD: Bool = true, showText: String? = nil, method: HTTPMethod = .post, successCallback: @escaping (_ result: T?) -> Void, errorCallback: ((T) -> Void)? = nil, networkError: (() -> Void)? = nil, authCallback: ((Any?) -> Void)? = nil) {

        if isShowHUD {
            CustomHUD.showProgress()
        }
        
        self.sessionManager.request(generate.url, method: method, parameters: generate.params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: generate.headers).validate().responseJSON(completionHandler: { (response) in
            if let _ = response.error {
                if let _ = networkError {
                    networkError?()
                } else {
                    CustomHUD.showHideErrorHUD()
                }
            } else if let value = response.value {
                
                if self.isPrint {
                    debugPrint(value)
                }
                
                if let json = value as? [String: Any] {
                    let map = Map(mappingType: .toJSON, JSON: json)
                    let result = T(JSON: map.JSON)!
                    if result.error_code == 22000 {
                        if isShowHUD {
                            if let text = showText {
                                CustomHUD.showSuccessHUD(subtitle: text, completion: {
                                    successCallback(result)
                                })
                            } else {
                                CustomHUD.hideProgress()
                                successCallback(result)
                            }
                        } else {
                            successCallback(result)
                        }
                    } else {
                        if let _ = errorCallback {
                            if isShowHUD {
                               CustomHUD.hideProgress()
                            }
                            errorCallback?(result)
                        } else {
                           self.processResponseError(result.error_code ?? 0, msg: result.error_message, error: result.error)
                        }
                    }

                } else {
                    //返回json格式不正常
                    CustomHUD.showHideTextHUD("数据格式错误")
                }
            }
        })
    }

    /**
        下载文件
        */
    
   func downloadFile(fileURL: URL, method: HTTPMethod = .get, parameters: [String: Any]? = nil, isShowHUD: Bool = false, headers: HTTPHeaders? = nil, progressCallback: ((_ progress: Double) -> Void)? = nil, successCallback: @escaping (_ url: URL?) -> Void) {
    
       if isShowHUD {
          CustomHUD.showProgress()
       }
       
  
       let destination: DownloadRequest.Destination = { (url, response) in
           
           let fileManager = FileManager.default
           let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
           let pathComponent = response.suggestedFilename
           let fileURL = directoryURL.appendingPathComponent(pathComponent!)
           if fileManager.fileExists(atPath: fileURL.path) {
               try! fileManager.removeItem(at: fileURL)
           }
           return (destinationURL: fileURL, options: [.removePreviousFile, .createIntermediateDirectories])
       }

       let _ = AF.download(fileURL, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil, to: destination)
           .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
               progressCallback?(progress.fractionCompleted)
           }
           .response{ (defaultResponse) in
               if defaultResponse.error == nil {
                    if isShowHUD {
                       CustomHUD.hideProgress()
                    }
                    successCallback(defaultResponse.fileURL)
               } else {
                   CustomHUD.showHideErrorHUD()
               }
           }
   }
    
    func processResponseError(_ code: Int, msg: String?, error: Any?) {
        CustomHUD.showHideTextHUD(msg)
    }
}
