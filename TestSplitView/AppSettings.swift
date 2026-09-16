import SwiftUI
import Combine

struct TimeSpan: Identifiable {
    let duration: Int
    let id = UUID()
}

final class AppSettings: ObservableObject {
    @Published var launchAtLogin = false
    @Published var mouseMoverEnabled = false
    @Published var usePopUpWindow = true
    @Published var timeSpans: [TimeSpan] = [
        TimeSpan(duration: 20),
        TimeSpan(duration: 30),
        TimeSpan(duration: 60),
        TimeSpan(duration: 300)
    ]

    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    private enum Keys {
        static let launchAtLogin = "settings.launchAtLogin"
        static let mouseMoverEnabled = "settings.mouseMoverEnabled"
        static let usePopUpWindow = "settings.usePopUpWindow"
        static let timeSpanDurations = "settings.timeSpanDurations"
    }

    init() {
        load()
        bindPersistence()
    }

    func addTimeSpan(_ value: Int) -> TimeSpan? {
        guard value > 0 else { return nil }
        let newItem = TimeSpan(duration: value)
        timeSpans.append(newItem)
        return newItem
    }

    func removeTimeSpan(id: TimeSpan.ID?) {
        guard let id else { return }
        timeSpans.removeAll { $0.id == id }
    }

    private func bindPersistence() {
        $launchAtLogin
            .sink { [weak self] in self?.defaults.set($0, forKey: Keys.launchAtLogin) }
            .store(in: &cancellables)

        $mouseMoverEnabled
            .sink { [weak self] in self?.defaults.set($0, forKey: Keys.mouseMoverEnabled) }
            .store(in: &cancellables)

        $usePopUpWindow
            .sink { [weak self] in self?.defaults.set($0, forKey: Keys.usePopUpWindow) }
            .store(in: &cancellables)

        $timeSpans
            .map { $0.map(\.duration) }
            .sink { [weak self] in self?.defaults.set($0, forKey: Keys.timeSpanDurations) }
            .store(in: &cancellables)
    }

    private func load() {
        if defaults.object(forKey: Keys.launchAtLogin) != nil {
            launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        }

        if defaults.object(forKey: Keys.mouseMoverEnabled) != nil {
            mouseMoverEnabled = defaults.bool(forKey: Keys.mouseMoverEnabled)
        }

        if defaults.object(forKey: Keys.usePopUpWindow) != nil {
            usePopUpWindow = defaults.bool(forKey: Keys.usePopUpWindow)
        }

        if let durations = defaults.array(forKey: Keys.timeSpanDurations) as? [Int], !durations.isEmpty {
            timeSpans = durations.map { TimeSpan(duration: $0) }
        }
    }
}
