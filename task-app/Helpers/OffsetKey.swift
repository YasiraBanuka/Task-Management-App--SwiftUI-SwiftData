//
//  OffsetKey.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-04-21.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
