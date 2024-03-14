//
//  Log.swift
//  FuncTest-swift
//
//  Created by admin on 2020/11/2.
//  Copyright © 2020 AppCoco. All rights reserved.
//

import Foundation
import WebKit

class Log {
    
    class func d(_ tag: String, info: String, enable: Bool = true) {
        guard enable else { return }
        print("\(tag):\(info)")
    }
    
    class func d(_ tag: String, msg: String, enable: Bool = true) {
        guard enable else { return }
        print("\(tag):\(msg)")
    }
    
    @available(iOS 11.0, *)
    class func printCookies(wkStorage: WKHTTPCookieStore?) {
        let httpBlock: () -> Void = {
            print("HTTPCookieStorage------------------------------------------------------------------------------------------------------------------------------------------------")
            let hcookies = HTTPCookieStorage.shared.cookies
            if let cookies = hcookies {
                for c in cookies {
                    print("\(c)")
                }
            }
        }
        
        if let wkStorage = wkStorage {
            wkStorage.getAllCookies({ cookies in
                print("WKHTTPCookieStore------------------------------------------------------------------------------------------------------------------------------------------------")
                for c in cookies {
                    print("\(c)")
                }
                httpBlock()
            })
        } else {
            httpBlock()
        }
    }
}


extension NSObject {
    
    var funcTag: String {
        return NSStringFromClass(type(of: self))
    }
    
}
