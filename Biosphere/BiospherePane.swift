import Cocoa
import PreferencePanes


class BiospherePane: NSPreferencePane {
  
  public var misingAutomationPermission: Bool = false
  
  @IBOutlet weak var container: NSView!

  override func mainViewDidLoad() {
    Log.debug("mainViewDidLoad...")
    NotificationCenter.default.addObserver(forName: .missingAutomationPermission, object: nil, queue: nil, using: missingAutomationPermissionNotification)
    NotificationCenter.default.addObserver(forName: .forgetAutomationPermission, object: nil, queue: nil, using: forgetAutomationPermissionNotification)
  }
  
  override func didSelect() {
    Log.debug("didSelect...")
    update()
  }
  
  private func update() {
    // Remembering current container height
    let currentContainerHeight = container.frame.height
    
    // Determining new container height
    let newView = recommendedView
    let newContainerHeight = newView.frame.height
    let heightDiff = newContainerHeight - currentContainerHeight
    Log.debug("New container height differs by \(heightDiff) pixels")

    // Get Window
    assert((mainView.window != nil))
    let window = mainView.window!

    // Adjusting window height
    var newWindowFrame = window.frame
    newWindowFrame.size.height += heightDiff
    newWindowFrame.origin.y -= heightDiff // If height increases, bottom goes down
    Log.debug("Changing window from \(window.frame) to \(newWindowFrame)")
    window.setFrame(newWindowFrame, display: true, animate: true)

    // Adjusting view height
    var newMainViewFrame = mainView.frame
    newMainViewFrame.size.height += heightDiff
    //newMainViewFrame.origin.y += heightDiff
    Log.debug("Changing mainView from \(mainView.frame) to \(newMainViewFrame)")
    mainView.frame = newMainViewFrame

    // Swapping container content
    container.subviews.forEach { $0.removeFromSuperview() }
    container.addSubview(newView)
  }
  
  private var recommendedView: NSView {
    if misingAutomationPermission {
      Log.debug("Currently missing automation permission, it should be displayed...")
      return automationController.view
    }
    
    guard omnibusController.satisfied else {
      Log.debug("Omnibus is not satisfied, it should be displayed...")
      return omnibusController.view
    }
    
    Log.debug("TODO: showing Default")
    return gitController.view
  }
  
  private func missingAutomationPermissionNotification(_ _: Notification) {
    Log.debug("I believe there is no automation access.")
    misingAutomationPermission = true
    update()
  }
  
  private func forgetAutomationPermissionNotification(_ _: Notification) {
    Log.debug("Maybe the user granted automation access by now.")
    misingAutomationPermission = false
    update()
  }
  
  private lazy var omnibusController: OmnibusController = {
    Log.debug("Initializing OmnibusController...")
    return OmnibusController.init(nibName: "InstallChef", bundle: bundle)
  }()

  private lazy var gitController: GitController = {
    Log.debug("Initializing GitController...")
    return GitController.init(nibName: "InstallGit", bundle: bundle)
  }()
  
  private lazy var automationController: AutomationController = {
    Log.debug("Initializing AutomationController...")
    return AutomationController.init(nibName: "AllowAutomation", bundle: bundle)
  }()
}
