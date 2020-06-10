//
//  ResourceLoader.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/9.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol ResourceLoaderDelegate: NSObjectProtocol {
    func loader(_ loader: ResourceLoader, cache progress: CGFloat)
    @objc optional func loader(_ loader: ResourceLoader, failLoading error: Error)
}


class ResourceLoader: NSObject, AVAssetResourceLoaderDelegate, RequestTaskDelegate {
    
    weak var delegate: ResourceLoaderDelegate?
    var seekRquired: Bool = false //Seek标识
    var cacheFinished: Bool = false
    
    fileprivate var requestList: [AVAssetResourceLoadingRequest] = []
    fileprivate var requestTask: RequestTask?
    
    func stopLoading() {
        self.requestTask?.cancel = true
    }
    
    func finishLoading(with loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        //填充信息
        loadingRequest.contentInformationRequest?.contentType = "video/mp4"
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = self.requestTask?.fileLength ?? 0
        let cacheLength = self.requestTask?.cacheLength
        var requestedOffset = loadingRequest.dataRequest?.requestedOffset
        if loadingRequest.dataRequest?.currentOffset != 0 {
            requestedOffset = loadingRequest.dataRequest?.currentOffset
        }
        let canReadLength = Int64(cacheLength!) - requestedOffset! - (self.requestTask?.requestOffset)!
        let respondLength = min(canReadLength, Int64(loadingRequest.dataRequest!.requestedLength))
        if let data = CacheFileHandle.readTempFileData(with: UInt64(requestedOffset! - (self.requestTask?.requestOffset)!), length: Int(respondLength)) {
            loadingRequest.dataRequest?.respond(with: data)
        }
        //如果完全响应了所需要的数据，则完成
        let nowendOffset = requestedOffset! + canReadLength
        let rl = loadingRequest.dataRequest?.requestedLength ?? 0
        let rs = loadingRequest.dataRequest?.requestedOffset ?? 0
        let reqEndOffset = rs + Int64(rl)
        if nowendOffset >= reqEndOffset {
            loadingRequest.finishLoading()
            return true
        }
        return false
    }
    
    func processRequestList() {
        var finishRequestList: [AVAssetResourceLoadingRequest] = []
        for request in self.requestList {
            if self.finishLoading(with: request) {
                finishRequestList.append(request)
            }
        }

        self.requestList = intersectSorted(self.requestList, finishRequestList)
//        let temp = NSMutableArray(array: self.requestList)
//        temp.removeObjects(in: finishRequestList)
    
    }
    
    func newTask(with loadingRequest: AVAssetResourceLoadingRequest, cache: Bool) {
        var fileLength: Int64 = 0
        if self.requestTask != nil {
            fileLength = self.requestTask!.fileLength!
            self.requestTask!.cancel = true
        }
        self.requestTask = RequestTask()
        self.requestTask?.requestURL = loadingRequest.request.url
        self.requestTask?.requestOffset = loadingRequest.dataRequest?.requestedOffset
        self.requestTask?.cache = cache
        if  fileLength > 0 {
            self.requestTask?.fileLength = fileLength
        }
        self.requestTask?.delegate = self
        self.requestTask?.start()
        self.seekRquired = false
    }
    
    func addLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        self.requestList.append(loadingRequest)
        if self.requestTask != nil {
            let requestedOffset = loadingRequest.dataRequest?.requestedOffset ?? 0
            let tOffset = self.requestTask!.requestOffset!
            let cacheLength = Int64(self.requestTask!.cacheLength)
            let total = tOffset+cacheLength
            if (requestedOffset >= tOffset &&
                requestedOffset <= total) {
                print("数据已经缓存，则直接完成")
                self.processRequestList()
            } else {
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
                if self.seekRquired {
                    self.newTask(with: loadingRequest, cache: false)
                }
            }
        } else {
            self.newTask(with: loadingRequest, cache: true)
        }
    }
    
    func removeLoadingRequest(loadingRequest: AVAssetResourceLoadingRequest) {
        self.requestList = self.requestList.filter({$0 == loadingRequest})
    }
    
    //MARK:-AVAssetResourceLoaderDelegate
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("WaitingLoadingRequest < requestedOffset = \(loadingRequest.dataRequest?.requestedOffset ?? 0), currentOffset = \(loadingRequest.dataRequest?.currentOffset ?? 0), requestedLength = \(loadingRequest.dataRequest?.requestedLength ?? 0) >")
        self.addLoadingRequest(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        self.removeLoadingRequest(loadingRequest: loadingRequest)
    }
    
    //MARK:- RequestTaskDelegate
    func requestTaskDidUpdateCache() {
        self.processRequestList()
        if self.delegate != nil && self.delegate!.responds(to: #selector(delegate?.loader(_:cache:))) {
            let cacheLength = self.requestTask?.cacheLength
            let fileLength = self.requestTask?.fileLength
            let requestOffset = self.requestTask?.requestOffset
            let cacheProgress: CGFloat = CGFloat(Int64(cacheLength!)/(fileLength!-requestOffset!))
            self.delegate?.loader(self, cache: cacheProgress)
        }
    }
    func requestTaskDidFinishLoading(with cache: Bool) {
        self.cacheFinished = cache
    }
    
    func requestTaskDidFail(with error: Error?) {
        //加载数据错误的处理
    }
}
