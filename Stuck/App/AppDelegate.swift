import UIKit
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let locationManager = CLLocationManager()

    private func requestLocationIfNeeded() {
        guard CLLocationManager.authorizationStatus() == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        requestLocationIfNeeded()
        #if !targetEnvironment(simulator)
        AchievementService.shared.authenticate()
        if FileManager.default.ubiquityIdentityToken != nil {
            PastLifeStore.synchronize()
        }
        #endif
        let wasFirstLaunch = GameStorage.createdAt == nil
        PersonalityService.initializeIfNeeded()
        if wasFirstLaunch {
            AchievementService.shared.reportFirstMeet()
        }
        AchievementTracker.shared.recordDailyOpen()
        AchievementTracker.shared.checkLifespanAchievements()

        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            WeatherService.shared.refresh()
            #if !targetEnvironment(simulator)
            if FileManager.default.ubiquityIdentityToken != nil {
                PastLifeStore.saveCurrentSnapshot()
            }
            #endif
        }
        WeatherService.shared.refresh()

        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = SceneDelegate.self
        return config
    }
}
