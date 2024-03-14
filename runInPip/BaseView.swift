//
//  BaseView.swift
//  FuncTest-swift
//
//  Created by admin on 2022/2/26.
//  Copyright © 2022 AppCoco. All rights reserved.
//

import Foundation
import UIKit

class BaseView: UIView {
    
    var selected: Bool = false {
        didSet {
            setSelectedState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    internal func initView() {
        
    }
    
    internal func setSelectedState() {
        
    }
}
