//
//  View-InlineExtension.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 6/20/24.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(iOS)
            navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }
}
