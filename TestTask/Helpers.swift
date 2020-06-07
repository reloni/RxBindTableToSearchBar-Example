//
//  Helpers.swift
//  TestTask
//
//  Created by Anton Efimenko on 07.06.2020.
//  Copyright © 2020 Anton Efimenko. All rights reserved.
//

import Foundation

public protocol Configure { }

extension Configure where Self: AnyObject {
    public func configure(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Configure { }

struct NewsResults: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let author: String?
    let title: String
}
