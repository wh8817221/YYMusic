import Alamofire

enum RequestHelper {
//    static let baseURL = "http://mobile.ximalaya.com"
    static let baseURL = "https://musicapi.qianqian.com"
    case getMusicList([String: Any])
    case getCommonList([String: Any])
    fileprivate func extend(_ params: [String: Any]) -> [String: Any] {
        var extendParams = params
        extendParams["from"] = "ios"
        extendParams["format"] = "json"
        extendParams["channel"] = "appstore"
        extendParams["version"] = "6.2.0"
        return extendParams
    }
    
    func generate() -> (url:String, params:Dictionary<String, Any>?, headers: HTTPHeaders?) {
        var params = [String: Any]()
        var url = RequestHelper.baseURL
        switch self {
        case .getCommonList(let tmp):
            let param = tmp
            url += "/v1/restserver/ting"
            params = param
        case .getMusicList(let tmp):
            let page = tmp["pageId"]
            let size = tmp["pageSize"]
            url = "http://mobile.ximalaya.com"
            url += "/mobile/others/ca/album/track/5541/true/\(page ?? 1)/\(size ?? 15)"
            params = tmp
        }
        
        return (url, extend(params), nil)
    }
}

