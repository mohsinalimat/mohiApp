//
//  SearchRequest.swift
//  Mohi
//
//  Created by Consagous on 30/11/17.
//  Copyright © 2017 Consagous. All rights reserved.
//

import Foundation
import Foundation
import SwiftEventBus

class SearchRequest:  BaseRequest<APIResponseParam.Product> {
    private var productData:APIRequestParam.Product?
    private var callBackSuccess:((_ response:APIResponseParam.Product)->Void)?
    private var callBackError:((_ response:ErrorModel)->Void)?
    
    init(productData:APIRequestParam.Product, onSuccess:((_ response:APIResponseParam.Product)->Void)?, onError:((_ response:ErrorModel)->Void)?){
        self.productData = productData
        self.callBackSuccess = onSuccess
        self.callBackError = onError
    }
    
    override func main() {
        //        let authApi = AuthApi()
        //        self.request = authApi.loginUser(loginUser: loginData)
        
        //        //Prepare URL String
        let urlParameter = String(format:APIParamConstants.kGetProduct)
        urlString = BaseApi().urlEncodedString(nil, restUrl: urlParameter, baseUrl: APIParamConstants.kSERVER_END_POINT_PRODUCT_API)
        
        //Get Header Parameters
        header = BaseApi().getDefaultHeaders() as? [String : String]
        
        //Conver data to JSON String
        let validateOtpReqViewStr = productData?.toJSONString()
        
        //Set Method Type
        methodType = .POST
        
        //Set Post Data
        postData = validateOtpReqViewStr!.data(using: String.Encoding.utf8)!
        super.main()
    }
    
    override func onSuccess(_ responseView:APIResponseParam.Product?){
        AppConstant.kLogString(responseView ?? "")
        if(responseView != nil && responseView?.productData != nil) {
            SwiftEventBus.unregister(self)
            SwiftEventBus.post(APIConfigConstants.kRequestOtpSuccess, sender: responseView)
        }else{
            SwiftEventBus.post(APIConfigConstants.kRequestOtpFailure)
        }
        
        if(callBackSuccess != nil){
            callBackSuccess!(responseView!)
        }
    }
    
    override func onError(_ response:ErrorModel) {
        AppConstant.kLogString(response)
        SwiftEventBus.post(APIConfigConstants.kRequestOtpFailure, sender: response)
        
        if(callBackError != nil){
            callBackError!(response)
        }
    }
}
