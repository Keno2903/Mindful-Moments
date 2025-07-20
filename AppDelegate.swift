import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Hier könnten weitere Initialisierungen beim App-Start erfolgen
        // z.B. das Planen von Benachrichtigungen basierend auf gespeicherten Einstellungen,
        // aber es ist oft besser, dies im MeditationDataStore zu tun, sobald dieser initialisiert ist.
        
        return true
    }
    
    // Diese Methode wird aufgerufen, wenn eine Benachrichtigung eintrifft, während die App im Vordergrund ist.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Hier entscheiden, wie die Benachrichtigung angezeigt werden soll (Banner, Ton, Badge)
        // Für eine Meditations-App ist es oft sinnvoll, sie dezent anzuzeigen oder dem Nutzer die Wahl zu lassen.
        completionHandler([.banner, .sound, .badge])
    }
    
    // Diese Methode wird aufgerufen, wenn der Benutzer auf eine Benachrichtigung tippt.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Hier auf die Interaktion des Benutzers reagieren
        // z.B. die App öffnen und zu einem bestimmten Bildschirm navigieren.
        
        // Beispiel: Wenn die Benachrichtigung eine bestimmte Aktion hat
        // if response.actionIdentifier == "myActionIdentifier" { ... }
        
        completionHandler()
    }
}
