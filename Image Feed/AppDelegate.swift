import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if ProcessInfo.processInfo.arguments.contains("--isResetData") {
            
            OAuth2TokenStorage.shared.token = nil
            
            ProfileLogoutService.shared.logout()
            
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
