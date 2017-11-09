//
//  FakeRequest.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import Foundation

struct FakeRequest {
    
    static func createMockData(forStartIndex start: Int, batchCount: Int = 10, callBack: @escaping ([Int]) -> (), delay: Double? = 1.0 ) {
        var dataArray: [Int] = []
        for i in start...(start + batchCount - 1) {
            dataArray.append(i)
        }
        
        if delay != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay!) {
                callBack(dataArray)
            }
        } else {
            callBack(dataArray)
        }
    }
    
}
