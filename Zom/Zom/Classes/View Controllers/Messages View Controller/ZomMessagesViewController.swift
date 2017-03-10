//
//  ZomMessagesViewController.swift
//  Zom
//
//  Created by N-Pex on 2015-11-11.
//
//

import UIKit
import JSQMessagesViewController
import OTRAssets
import BButton

var ZomMessagesViewController_associatedObject1: UInt8 = 0

extension OTRMessagesViewController {
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== OTRMessagesViewController.self {
            return
        }
        
        dispatch_once(&Static.token) {
            ZomUtil.swizzle(self, originalSelector: #selector(OTRMessagesViewController.collectionView(_:messageDataForItemAtIndexPath:)), swizzledSelector:#selector(OTRMessagesViewController.zom_collectionView(_:messageDataForItemAtIndexPath:)))
            ZomUtil.swizzle(self, originalSelector: #selector(OTRMessagesViewController.collectionView(_:attributedTextForCellBottomLabelAtIndexPath:)), swizzledSelector: #selector(OTRMessagesViewController.zom_collectionView(_:attributedTextForCellBottomLabelAtIndexPath:)))
        }
    }
    
    var shieldIcon:UIImage? {
        get {
            return objc_getAssociatedObject(self, &ZomMessagesViewController_associatedObject1) as? UIImage ?? nil
        }
        set {
            objc_setAssociatedObject(self, &ZomMessagesViewController_associatedObject1, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func zom_collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> ChatSecureCore.JSQMessageData! {
        let ret = self.zom_collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
        if (ret != nil && ZomStickerMessage.isValidStickerShortCode(ret.text!())) {
            return ZomStickerMessage(message: ret)
        }
        return ret
    }
    
    public func zom_collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let string:NSMutableAttributedString = self.zom_collectionView(collectionView, attributedTextForCellBottomLabelAtIndexPath: indexPath) as! NSMutableAttributedString
        
        let lock = NSString.fa_stringForFontAwesomeIcon(FAIcon.FALock);
        let unlock = NSString.fa_stringForFontAwesomeIcon(FAIcon.FAUnlock);
        
        let asd:NSString = string.string
        
        let rangeLock:NSRange = asd.rangeOfString(lock);
        if (rangeLock.location != NSNotFound) {
            let attachment = textAttachment(12)
            let newLock = NSAttributedString.init(attachment: attachment);
            string.replaceCharactersInRange(rangeLock, withAttributedString: newLock)
        }
        
        let rangeUnLock:NSRange = asd.rangeOfString(unlock);
        if (rangeUnLock.location != NSNotFound) {
            let nothing = NSAttributedString.init(string: "");
            string.replaceCharactersInRange(rangeUnLock, withAttributedString: nothing)
        }
        return string;
    }
    
    
    func textAttachment(fontSize: CGFloat) -> NSTextAttachment {
        var font:UIFont? = UIFont(name: kFontAwesomeFont, size: fontSize)
        if (font == nil) {
            font = UIFont.systemFontOfSize(fontSize)
        }
        let textAttachment = NSTextAttachment()
        let image = getTintedShieldIcon()
        textAttachment.image = image
        let aspect = image.size.width / image.size.height
        let height = font?.capHeight
        textAttachment.bounds = CGRectIntegral(CGRect(x:0,y:0,width:(height! * aspect),height:height!))
        return textAttachment
    }
    
    func getTintedShieldIcon() -> UIImage {
        if (self.shieldIcon == nil) {
            let image = UIImage.init(named: "ic_security_white_36pt")
            self.shieldIcon = image?.tint(UIColor.lightGrayColor(), blendMode: CGBlendMode.Multiply)
        }
        return shieldIcon!
    }
}

public class ZomMessagesViewController: OTRMessagesHoldTalkViewController, UIGestureRecognizerDelegate, ZomPickStickerViewControllerDelegate {
    
    private var hasFixedTitleViewConstraints:Bool = false
    private var attachmentPickerController:OTRAttachmentPicker? = nil
    private var attachmentPickerView:AttachmentPicker? = nil
    private var attachmentPickerTapRecognizer:UITapGestureRecognizer? = nil
    
    var outgoingImage: JSQMessagesBubbleImage? = nil
    var incomingImage: JSQMessagesBubbleImage? = nil

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.cameraButton?.setTitle(NSString.fa_stringForFontAwesomeIcon(FAIcon.FAPlusSquareO), forState: UIControlState.Normal)
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let greenColor = ZomTheme.colorWithHexString(DEFAULT_ZOM_COLOR)
        outgoingImage = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(greenColor)
        incomingImage = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        self.collectionView.collectionViewLayout.messageBubbleFont = UIFont.init(name: "Calibri", size: self.collectionView.collectionViewLayout.messageBubbleFont.pointSize + 2)
        
        self.collectionView.loadEarlierMessagesHeaderTextColor = greenColor
        self.collectionView.typingIndicatorEllipsisColor = UIColor.whiteColor()
        self.collectionView.typingIndicatorMessageBubbleColor = greenColor
        self.inputToolbar.contentView.textView.layer.cornerRadius = self.inputToolbar.contentView.textView.frame.height/2
        if let font = self.inputToolbar.contentView.textView.font {
            self.inputToolbar.contentView.textView.font = UIFont.init(name: "Calibri", size: font.pointSize)
        }
        if let font = self.sendButton?.titleLabel?.font {
            self.sendButton?.titleLabel?.font = UIFont.init(name: "Calibri", size: font.pointSize)
        }
        
    }
    
    public override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messageAtIndexPath(indexPath)
        return message?.messageIncoming() == true ? incomingImage : outgoingImage
    }

    public override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messageAtIndexPath(indexPath)
        let timestampFormatter = JSQMessagesTimestampFormatter.sharedFormatter()
        timestampFormatter.dateTextAttributes[NSFontAttributeName] = UIFont.init(name: "Calibri", size: 12)!
        timestampFormatter.timeTextAttributes[NSFontAttributeName] = UIFont.init(name: "Calibri", size: 12)!
        return timestampFormatter.attributedTimestampForDate(message?.date())
    }
    
    
    public func attachmentPicker(attachmentPicker: OTRAttachmentPicker!, addAdditionalOptions alertController: UIAlertController!) {
        
        let sendStickerAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Sticker", comment: "Label for button to open up sticker library and choose sticker"), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            let storyboard = UIStoryboard(name: "StickerShare", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateInitialViewController()
            self.presentViewController(vc!, animated: true, completion: nil)
        })
        alertController.addAction(sendStickerAction)
    }
    
    @IBAction func unwindPickSticker(unwindSegue: UIStoryboardSegue) {
    }
    
    public func didPickSticker(sticker: String, inPack pack: String) {
        super.didPressSendButton(super.sendButton, withMessageText: ":" + pack + "-" + sticker + ":", senderId: super.senderId, senderDisplayName: super.senderDisplayName, date: NSDate())
    }
    
    override public func refreshTitleView() -> Void {
        super.refreshTitleView()
        if (OTRAccountsManager.allAccountsAbleToAddBuddies().count < 2) {
            // Hide the account name if only one
            if let view = self.navigationItem.titleView as? OTRTitleSubtitleView {
                view.subtitleLabel.hidden = true
                view.subtitleImageView.hidden = true
                if (!hasFixedTitleViewConstraints && view.constraints.count > 0) {
                    var removeThese:[NSLayoutConstraint] = [NSLayoutConstraint]()
                    for constraint:NSLayoutConstraint in view.constraints {
                        if ((constraint.firstItem as? NSObject != nil && constraint.firstItem as! NSObject == view.titleLabel) || (constraint.secondItem as? NSObject != nil && constraint.secondItem as! NSObject == view.titleLabel)) {
                            if (constraint.active && (constraint.firstAttribute == NSLayoutAttribute.Top || constraint.firstAttribute == NSLayoutAttribute.Bottom)) {
                                removeThese.append(constraint)
                            }
                        }
                    }
                    view.removeConstraints(removeThese)
                    let c:NSLayoutConstraint = NSLayoutConstraint(item: view.titleLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view.titleLabel.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                    view.addConstraint(c);
                    hasFixedTitleViewConstraints = true
                }
            }
        }
    }
    
    override public func setupDefaultSendButton() {
        // Override this to always show Camera and Mic icons. We never get here
        // in a "knock" scenario.
        self.inputToolbar?.contentView?.leftBarButtonItem = self.cameraButton
        self.inputToolbar?.contentView?.leftBarButtonItem.enabled = false
        if (self.state.hasText) {
            self.inputToolbar?.contentView?.rightBarButtonItem = self.sendButton
            self.inputToolbar?.sendButtonLocation = JSQMessagesInputSendButtonLocation.Right
            self.inputToolbar?.contentView?.rightBarButtonItem.enabled = self.state.isThreadOnline
        } else {
            self.inputToolbar?.contentView?.rightBarButtonItem = self.microphoneButton
            self.inputToolbar?.contentView?.rightBarButtonItem.enabled = false
        }
    }
    
    override public func didPressAccessoryButton(sender: UIButton!) {
        if (sender == self.cameraButton) {
            let pickerView = getPickerView()
            self.view.addSubview(pickerView)
            var newFrame = pickerView.frame;
            let toolbarBottom = self.inputToolbar.frame.origin.y + self.inputToolbar.frame.size.height
            newFrame.origin.y = toolbarBottom - newFrame.size.height;
            UIView.animateWithDuration(0.3) {
                pickerView.frame = newFrame;
            }
        } else {
            super.didPressAccessoryButton(sender)
        }
    }
    
    func getPickerView() -> UIView {
        if (self.attachmentPickerView == nil) {
            self.attachmentPickerView = UINib(nibName: "AttachmentPicker", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? AttachmentPicker
            self.attachmentPickerView!.frame.size.width = self.view.frame.width
            self.attachmentPickerView!.frame.size.height = 100
            let toolbarBottom = self.inputToolbar.frame.origin.y + self.inputToolbar.frame.size.height
            self.attachmentPickerView!.frame.origin.y = toolbarBottom // Start hidden (below screen)
         
            if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
                self.attachmentPickerView!.removePhotoButton()
            }
            if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                self.attachmentPickerView!.removeCameraButton()
            }
            
            self.attachmentPickerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            self.attachmentPickerTapRecognizer!.cancelsTouchesInView = true
            self.attachmentPickerTapRecognizer!.delegate = self
            self.view.addGestureRecognizer(self.attachmentPickerTapRecognizer!)
        }
        return self.attachmentPickerView!
    }
    
    func onTap(sender: UIGestureRecognizer) {
        closePickerView()
    }
    
    func closePickerView() {
        // Tapped outside attachment picker. Close it.
        if (self.attachmentPickerTapRecognizer != nil) {
            self.view.removeGestureRecognizer(self.attachmentPickerTapRecognizer!)
            self.attachmentPickerTapRecognizer = nil
        }
        if (self.attachmentPickerView != nil) {
            var newFrame = self.attachmentPickerView!.frame;
            let toolbarBottom = self.inputToolbar.frame.origin.y + self.inputToolbar.frame.size.height
            newFrame.origin.y = toolbarBottom
            UIView.animateWithDuration(0.3, animations: {
                    self.attachmentPickerView!.frame = newFrame;
                },
                                       completion: { (success) in
                                        self.attachmentPickerView?.removeFromSuperview()
                                        self.attachmentPickerView = nil
            })
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func attachmentPickerSelectPhotoWithSender(sender: AnyObject) {
        closePickerView()
        attachmentPicker().showImagePickerForSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func attachmentPickerTakePhotoWithSender(sender: AnyObject) {
        closePickerView()
        attachmentPicker().showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
    }
    
    func attachmentPicker() -> OTRAttachmentPicker {
        if (self.attachmentPickerController == nil) {
            self.attachmentPickerController = OTRAttachmentPicker(parentViewController: self.parentViewController?.parentViewController, delegate: (self as! OTRAttachmentPickerDelegate))
        }
        return self.attachmentPickerController!
    }
    
    @IBAction func attachmentPickerStickerWithSender(sender: AnyObject) {
        closePickerView()
        let storyboard = UIStoryboard(name: "StickerShare", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    public func setupInfoButton() {
        let image = UIImage(named: "OTRInfoIcon", inBundle: OTRAssets.resourcesBundle(), compatibleWithTraitCollection: nil)
        let item = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(infoButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = item
    }
    
    
    @objc public override func infoButtonPressed(sender: AnyObject?) {

        var threadOwner: OTRThreadOwner? = nil
        var _account: OTRAccount? = nil
        self.readOnlyDatabaseConnection.readWithBlock { (t) in
            threadOwner = self.threadObjectWithTransaction(t)
            _account = self.accountWithTransaction(t)
        }
        guard let buddy = threadOwner as? OTRBuddy, account = _account else {
            return
        }
        let profileVC = ZomProfileViewController(nibName: nil, bundle: nil)
        let otrKit = OTRProtocolManager.sharedInstance().encryptionManager.otrKit
        profileVC.info = ZomProfileViewControllerInfo.createInfo(buddy, accountName: account.username, protocolString: account.protocolTypeString(), otrKit: otrKit, qrAction: profileVC.qrAction!, shareAction: profileVC.shareAction, hasSession: true)

        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension UIImage
{
    func tint(color: UIColor, blendMode: CGBlendMode) -> UIImage
    {
        let drawRect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context!, 1.0, -1.0)
        CGContextTranslateCTM(context!, 0.0, -self.size.height)
        CGContextClipToMask(context!, drawRect, CGImage!)
        color.setFill()
        UIRectFill(drawRect)
        drawInRect(drawRect, blendMode: blendMode, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}

