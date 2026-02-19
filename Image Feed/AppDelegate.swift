import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // ПРОВЕРКА ФЛАГА ИЗ ТЕСТА
        if CommandLine.arguments.contains("RESET_APP") {
            // 1. Сброс токена через ваш существующий класс
            OAuth2TokenStorage.shared.token = nil
            
            // 2. Сброс кук WebView (чтобы Unsplash забыл логин)
            let datastore = WKWebsiteDataStore.default()
            datastore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                datastore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {})
            }
        }

        return true
    }


    // MARK: UISceneSession Lifecycle

    func application(
       _ application: UIApplication,
       configurationForConnecting connectingSceneSession: UISceneSession,
       options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
       let sceneConfiguration = UISceneConfiguration(         
           name: "Main",
           sessionRole: connectingSceneSession.role
       )
       sceneConfiguration.delegateClass = SceneDelegate.self
       return sceneConfiguration
    }


}

