
import UIKit
import SwiftUI
import AnimalWordsVicoeTnaud
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        
        let ryts = UIHostingController(rootView: AnimalWordsContentView())
        AnimalWordsGoyunahMterin.animalWordsShared.animalWordsQoinMayew(ryts)
        
        return true
    }

}

