import Alamofire

enum RequestHelper {
    static let baseURL = "http://mobile.ximalaya.com"
    case getMusicList([String: Any])
    fileprivate func extend(_ params: [String: Any]) -> [String: Any] {
        let extendParams = params
//        extendParams["os_type"] = 1
//        extendParams["version"] = RequestHelper.apiVerion
//        extendParams["timestamp"] = Int(Date().timeIntervalSince1970)
        return extendParams
    }
    
    func generate() -> (url:String, params:Dictionary<String, Any>?, headers: HTTPHeaders?) {
        var params = [String: Any]()
        var url = RequestHelper.baseURL
        switch self {
        case .getMusicList(let tmp):
            let page = tmp["pageId"]
            let size = tmp["pageSize"]
            url += "/mobile/others/ca/album/track/5541/true/\(page ?? 1)/\(size ?? 15)"
            params = tmp
        }
        
        return (url, extend(params), nil)
    }
}

