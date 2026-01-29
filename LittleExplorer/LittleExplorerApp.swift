import SwiftUI

@main
struct LittleExplorerApp: App {
    @StateObject private var userProgress = UserProgress()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userProgress)
        }
    }
}
