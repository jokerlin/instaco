//
//  MD5.swift
//  Instaco
//
//  Created by Henry Lin on 7/12/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import Foundation

extension String {
    func md5() -> String {
        let str = self.cString(using: .utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        return String(format: hash as String)
    }
}
