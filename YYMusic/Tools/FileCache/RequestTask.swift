//
//  RequestTask.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/9.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

@objc protocol RequestTaskDelegate: NSObjectProtocol {
    func requestTaskDidUpdateCache() //更新缓冲进度代理方法
    @objc optional func requestTaskDidReceiveResponse()
    @objc optional func requestTaskDidFinishLoading(with cache: Bool)
    @objc optional func requestTaskDidFail(with error: Error?)
}

class RequestTask: NSObject, URLSessionDataDelegate {
    
    weak var delegate: RequestTaskDelegate?
    var requestURL: URL?//请求网址
    var requestOffset: Int64? = 0 //请求起始位置
    var fileLength: Int64? = 0 //文件长度
    var cacheLength: Int = 0 //缓冲长度
    var cache: Bool = true {
        didSet {
            self.task?.cancel()
            self.session?.invalidateAndCancel()
        }
    } //是否缓存
    var cancel: Bool = false //是否取消请求
    
    fileprivate var session: URLSession? //会话对象
    fileprivate var task: URLSessionDataTask? //任务
    
    override init() {
        super.init()
        CacheFileHandle.createTempFile()
    }
    /**
    *  开始请求
    */
    func start() {
        guard let url = self.requestURL?.originalSchemeURL() else {
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        if self.requestOffset! > 0 {
            let value = "bytes=\(self.requestOffset!)-\(self.fileLength!-1)"
            request.addValue(value, forHTTPHeaderField: "Range")
        }
        
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        self.task = session?.dataTask(with: request)
        self.task?.resume()
    }
    
    //MARK:-URLSessionDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if self.cancel { return }
        completionHandler(.allow)
        if let httpResponse = response as? HTTPURLResponse {
            let contentRange = httpResponse.allHeaderFields["Content-Range"] as? String
            let fileLength = contentRange?.components(separatedBy: "/").last ?? ""
            self.fileLength = (Int64(fileLength) ?? 0) > 0 ? Int64(fileLength)! : response.expectedContentLength
            if self.delegate != nil && self.delegate!.responds(to: #selector(delegate!.requestTaskDidReceiveResponse)) {
                self.delegate?.requestTaskDidReceiveResponse?()
            }
        }
    }
    //服务器返回数据,可能会调用多次
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.cancel { return }
        CacheFileHandle.writeTempFile(data: data)
        self.cacheLength += data.count
        if self.delegate != nil && self.delegate!.responds(to: #selector(delegate!.requestTaskDidUpdateCache)) {
            self.delegate?.requestTaskDidUpdateCache()
        }
    }
    //请求完成会调用该方法，请求失败则error有值
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if self.cancel {
            print("取消下载")
        } else {
            if error != nil {
                if self.delegate != nil && self.delegate!.responds(to: #selector(delegate!.requestTaskDidFail(with:))) {
                    self.delegate?.requestTaskDidFail?(with: error)
                }
            } else {
                //可以缓存则保存文件
                if self.cache {
                    if let url = self.requestURL {
                        CacheFileHandle.cacheTempFile(with: String.fileName(with: url)!)
                    }
                    if self.delegate != nil && self.delegate!.responds(to: #selector(delegate!.requestTaskDidFinishLoading(with:))) {
                        self.delegate?.requestTaskDidFinishLoading?(with: self.cache)
                    }
                }
            }
        }
    }
}
