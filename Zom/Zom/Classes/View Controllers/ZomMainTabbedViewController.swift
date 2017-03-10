//
//  ZomMainTabbedViewController.swift
//  Zom
//
//  Created by N-Pex on 2016-11-14.
//
//

import Foundation

public class ZomMainTabbedViewController: UITabBarController, OTRComposeViewControllerDelegate {
    
    private var chatsViewController:ZomConversationViewController? = nil
    private var friendsViewController:ZomComposeViewController? = nil
    private var meViewController:ZomProfileViewController? = nil
    private var observerContext = 0
    private var observersRegistered:Bool = false
//    private var barButtonSettings:UIBarButtonItem?
    private var barButtonAddChat:UIBarButtonItem?
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    public func createTabs() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? OTRAppDelegate {
            
            var newControllers:[UIViewController] = [];
            for child in childViewControllers {
                if (child.restorationIdentifier == "chats") {
                    chatsViewController = (appDelegate.conversationViewController as! ZomConversationViewController)
                    chatsViewController!.tabBarItem = child.tabBarItem
                    newControllers.append(chatsViewController!)
                } else if (child.restorationIdentifier == "friends") {
                    friendsViewController = ZomComposeViewController()
                    if (friendsViewController!.view != nil) {
                        friendsViewController!.tabBarItem = child.tabBarItem
                    }
                    friendsViewController?.delegate = self
                    newControllers.append(friendsViewController!)
                } else if (child.restorationIdentifier == "me") {
                    meViewController = ZomProfileViewController(nibName: nil, bundle: nil)
                    meViewController?.tabBarItem = child.tabBarItem
                    //meViewController = child as? ZomProfileViewController
                    newControllers.append(meViewController!)
                }
                else {
                    newControllers.append(child)
                }
            }
            setViewControllers(newControllers, animated: false)
        }
        
        // Create bar button items
//        self.barButtonSettings = UIBarButtonItem(image: UIImage(named: "14-gear"), style: .Plain, target: self, action: #selector(self.settingsButtonPressed(_:)))
        self.barButtonAddChat = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(self.didPressAddButton(_:)))
        
        // Hide the tab item text, but don't null it (we use it to build the top title)
        for item:UITabBarItem in self.tabBar.items! {
            item.selectedImage = item.selectedImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            item.image = item.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clearColor(),
                NSFontAttributeName:UIFont.systemFontOfSize(1)], forState: UIControlState.Normal)
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        // Show current tab by a small white top border
//        tabBar.selectionIndicatorImage = createSelectionIndicator(UIColor.whiteColor(), size: CGSizeMake(tabBar.frame.width/CGFloat(tabBar.items!.count), tabBar.frame.height), lineHeight: 3.0)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        updateRightButtons()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerObservers()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        registerObservers()
    }
    
    private func registerObservers() {
        if (!observersRegistered) {
            observersRegistered = true
            OTRProtocolManager.sharedInstance().addObserver(self, forKeyPath: "numberOfConnectedProtocols", options: NSKeyValueObservingOptions.New, context: &observerContext)
            OTRProtocolManager.sharedInstance().addObserver(self, forKeyPath: "numberOfConnectingProtocols", options: NSKeyValueObservingOptions.New, context: &observerContext)
            if (selectedViewController == meViewController) {
                populateMeTabController()
            }
        }
    }
    
    override public func viewWillDisappear(animated: Bool) {
        if (observersRegistered) {
            observersRegistered = false
            OTRProtocolManager.sharedInstance().removeObserver(self, forKeyPath: "numberOfConnectedProtocols", context: &observerContext)
            OTRProtocolManager.sharedInstance().removeObserver(self, forKeyPath: "numberOfConnectingProtocols", context: &observerContext)
            super.viewWillDisappear(animated)
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &observerContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if (selectedViewController == meViewController) {
            // Maybe we need to update this!
            populateMeTabController()
        }
    }
    
    override public var selectedViewController: UIViewController? {
        didSet {
            updateTitle()
            updateRightButtons()
        }
    }
    
    override public var selectedIndex: Int {
        didSet {
            updateTitle()
            updateRightButtons()
        }
    }
    
    private func updateTitle() {
        if (selectedViewController != nil) {
//            let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as! String
//            self.navigationItem.title = appName + " | " + selectedViewController!.tabBarItem.title!
            self.navigationItem.title = selectedViewController!.tabBarItem.title!
            if (selectedViewController == meViewController) {
                populateMeTabController()
            }
        }
    }
    
    private func updateRightButtons() {
        if let add = barButtonAddChat/*, settings = barButtonSettings*/ {
            if (selectedIndex == 0) {
                navigationItem.rightBarButtonItems = [/*settings,*/ add]
            }
            else {
                navigationItem.rightBarButtonItems = [/*settings*/]
            }
        }
    }
    
    private func createSelectionIndicator(color: UIColor, size: CGSize, lineHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, lineHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        self.chatsViewController?.settingsButtonPressed(sender)
    }
    
    @IBAction func didPressAddButton(sender: AnyObject) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? ZomAppDelegate {
            appDelegate.splitViewCoordinator.conversationViewController(appDelegate.conversationViewController, didSelectCompose: self)
        }
    }
    
    private func populateMeTabController() {
        if (meViewController != nil) {
            if let appDelegate = UIApplication.sharedApplication().delegate as? ZomAppDelegate,let account = appDelegate.getDefaultAccount() {
                let otrKit = OTRProtocolManager.sharedInstance().encryptionManager.otrKit
                self.meViewController?.info = ZomProfileViewControllerInfo.createInfo(account, protocolString: account.protocolTypeString(), otrKit: otrKit, qrAction: self.meViewController!.qrAction!, shareAction: self.meViewController!.shareAction)
            }
        }
    }
    
    // MARK: - OTRComposeViewControllerDelegate
    public func controller(viewController: OTRComposeViewController, didSelectBuddies buddies: [String]?, accountId: String?, name: String?) {
        if (buddies?.count == 1) {
            guard let buds = buddies,
                accountKey = accountId else {
                    return
            }
            
            if (buds.count == 1) {
                if let buddyKey = buds.first {
                    
                    var buddy:OTRBuddy? = nil
                    var account:OTRAccount? = nil
                    OTRDatabaseManager.sharedInstance().readOnlyDatabaseConnection?.readWithBlock { (transaction) -> Void in
                        buddy = OTRBuddy.fetchObjectWithUniqueID(buddyKey, transaction: transaction)
                        account = OTRAccount.fetchObjectWithUniqueID(accountKey, transaction: transaction)
                    }
                    if let b = buddy, a = account {
                        let profileVC = ZomProfileViewController(nibName: nil, bundle: nil)
                        let otrKit = OTRProtocolManager.sharedInstance().encryptionManager.otrKit
                        profileVC.info = ZomProfileViewControllerInfo.createInfo(b, accountName: a.username, protocolString: a.protocolTypeString(), otrKit: otrKit, qrAction: profileVC.qrAction!, shareAction: profileVC.shareAction, hasSession: false)
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                }
            }
        }
    }
    
    public func controllerDidCancel(viewController: OTRComposeViewController) {
        
    }
}
