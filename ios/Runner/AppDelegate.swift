import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configura background fetch
    UIApplication.shared.setMinimumBackgroundFetchInterval(
      UIApplication.backgroundFetchIntervalMinimum
    )
    
    // Solicita permissão para notificações
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            print("[AppDelegate] ✅ Permissão de notificações concedida")
          } else {
            print("[AppDelegate] ❌ Permissão de notificações negada")
          }
        }
      )
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Background fetch
  override func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    print("[AppDelegate] 🔄 Background fetch executado pelo iOS")
    
    // Aqui o WorkManager irá executar as tarefas pendentes
    completionHandler(.newData)
  }
  
  //  Lifecycle - Background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    print("[AppDelegate] 📱 App entrando em background")
    super.applicationDidEnterBackground(application)
  }
  
  // Lifecycle - Foreground
  override func applicationWillEnterForeground(_ application: UIApplication) {
    print("[AppDelegate] 📱 App voltando ao foreground")
    super.applicationWillEnterForeground(application)
  }
  
  //  Push Notifications - Device Token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("[AppDelegate] 📲 Device Token: \(token)")
  }
  
  //  Push Notifications - Error
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[AppDelegate] ❌ Erro ao registrar push: \(error.localizedDescription)")
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    print("[AppDelegate] 🔔 Notificação recebida em foreground")
    
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  //  Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("[AppDelegate] 👆 Notificação tocada")
    print("[AppDelegate] Payload: \(response.notification.request.content.userInfo)")
    
    completionHandler()
  }
}