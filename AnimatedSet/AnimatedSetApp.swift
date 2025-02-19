//
//  AnimatedSetApp.swift
//  AnimatedSet
//
//  Created by Jia Chen on 2025/1/7.
//

import SwiftUI

@main
struct AnimatedSetApp: App {
    @StateObject var game = SetGameViewModel()
    var body: some Scene {
        WindowGroup {
            SetGameView(viewModel: game)
        }
    }
}
