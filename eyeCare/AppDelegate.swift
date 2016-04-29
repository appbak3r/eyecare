//
//  AppDelegate.swift
//  eyeCare
//
//  Created by Alexey Dmitriev on 26/04/16.
//  Copyright © 2016 IonCloud. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var aboutWindow: NSWindow!
    @IBOutlet weak var exampleWindow: NSWindow!


    @IBOutlet weak var launchAtStartupCheckbox: NSButtonCell!
    @IBOutlet weak var timeToNextBreak: NSMenuItem!

    @IBOutlet weak var breakCountDownLabel: NSTextField!
    @IBOutlet weak var breakCountDownText: NSTextFieldCell!
    
    @IBOutlet weak var BreakIntervalTextField: ICTextField!
  
    
    @IBOutlet weak var breakIntervalTextCell: NSTextFieldCell!
    @IBOutlet weak var BreakForTextField: ICTextField!
    
    @IBOutlet weak var breakForTextCell: NSTextFieldCell!
      
    
    @IBOutlet weak var preferencesWindow: NSWindow!
    private let changeImageInterval:NSTimeInterval = 10
  
    private var breakTimeInSeconds:NSTimeInterval = 5*60
    private var breakTimeout:NSTimeInterval = 25*60
    
    private var breakTimeCountDown = 5*60
    private var breakTimeoutCountDown = 25*60
    
    private var timer: NSTimer?
    private var breakTimer: NSTimer?
    private var countDownTimer: NSTimer?
    private var breakCountDownTimer: NSTimer?

    @IBOutlet weak var skipBreakMenuItem: NSMenuItem!
    @IBOutlet weak var skipButton: NSButton!
    @IBOutlet weak var breakMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    let overlayWindow = NSWindow()

    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBAction func launchAtStartupCheckboxClicked(sender: AnyObject) {
        if launchAtStartupCheckbox.state == NSOnState {
            StartupLaunch.setLaunchOnLogin(true)
        } else {
            StartupLaunch.setLaunchOnLogin(false)
        }
    }
    
    @IBAction func skipBreakButtonClicked(sender: AnyObject) {
       resetBreakTimer()
    }
    @IBAction func skipBreakClicked(sender: AnyObject) {
       resetBreakTimer()
    }
    @IBAction func preferencesClicked(sender: AnyObject) {
        let scrn: NSScreen = NSScreen.mainScreen()!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width

        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        preferencesWindow.setFrameOrigin(NSPoint(x: width/2 - 230/2, y: height/2 - 145/2))
        preferencesWindow.makeKeyAndOrderFront(exampleWindow)
    }
    @IBAction func aboutClicked(sender: AnyObject) {
        let scrn: NSScreen = NSScreen.mainScreen()!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        aboutWindow.setFrameOrigin(NSPoint(x: width/2 - 254/2, y: height/2 - 150/2))
        aboutWindow.makeKeyAndOrderFront(aboutWindow)
    }

    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func breakClicked(sender: AnyObject) {
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        statusMenu.cancelTracking()
        
        let scrn: NSScreen = NSScreen.mainScreen()!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width
    
        var frame = overlayWindow.frame
        frame.size = NSMakeSize(width, height)
        overlayWindow.setFrame(frame, display: true)
        overlayWindow.makeKeyAndOrderFront(overlayWindow)
        
        overlayWindow.setIsVisible(true)
        skipButton.setFrameOrigin(NSPoint(x: width/2 - 75, y: 150))
        breakCountDownLabel.setFrameOrigin(NSPoint(x: width/2 - 87, y: 220))

        self.timer = NSTimer.scheduledTimerWithTimeInterval(changeImageInterval,
                                                            target:self,
                                                            selector:#selector(AppDelegate.changeImage),
                                                            userInfo:nil,
                                                            repeats:true)
        
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)

        skipBreakMenuItem.hidden = false
        breakMenuItem.hidden = true
        
        self.breakTimer = NSTimer.scheduledTimerWithTimeInterval(breakTimeInSeconds,
                                                            target:self,
                                                            selector:#selector(AppDelegate.resetBreakTimer),
                                                            userInfo:nil,
                                                            repeats:false)
        
        breakTimeoutCountDown = Int(breakTimeInSeconds)
      
        breakCountDownText.title = secondsToFormat(breakTimeoutCountDown)
        
        self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                                 target:self,
                                                                 selector:#selector(AppDelegate.updateText),
                                                                 userInfo:nil,
                                                                 repeats:true)
        NSRunLoop.currentRunLoop().addTimer(countDownTimer!, forMode: NSRunLoopCommonModes)

    }
    
    func updateText(){
        breakTimeoutCountDown = breakTimeoutCountDown - 1
        breakCountDownText.title = secondsToFormat(breakTimeoutCountDown)
    }
    
    func updateLabel(){
        breakTimeCountDown = breakTimeCountDown - 1
        timeToNextBreak.title = secondsToFormat(breakTimeCountDown)
    }
    
    func secondsToFormat(num: Int) -> String {
        var minutes = String(num / 60)
        var seconds = String(num - Int(minutes)! * 60)
        if (minutes.characters.count == 1){
            minutes = "0" + minutes
        }
        if (seconds.characters.count == 1){
            seconds = "0" + seconds
        }
        return minutes + " : " + seconds;
    }
    
    func resetBreakTimer(){
        self.timer!.invalidate()
        self.countDownTimer!.invalidate()
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        overlayWindow.setIsVisible(false)
        skipBreakMenuItem.hidden = true
        breakMenuItem.hidden = false
        setBreakTimer()
        setBreakCountDownTimer()
    }
    
    func changeImage(){
        let scrn: NSScreen = NSScreen.mainScreen()!
        let rect: NSRect = scrn.frame
        let height = rect.size.height
        let width = rect.size.width
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let url = "https://source.unsplash.com/random/"+String(Int(width))+"x"+String(Int(height))
            let data = NSData(contentsOfURL: NSURL(string: url)!)
            if (data !== nil){
                let imageFromUrl =  NSImage(data: data!)
                self.overlayWindow.backgroundColor = NSColor (patternImage: imageFromUrl!)
            }
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.overlayWindow.collectionBehavior = NSWindowCollectionBehavior.CanJoinAllSpaces
        
        let icon = NSImage(named: "StatusBarIcon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        overlayWindow.level = Int(CGWindowLevelForKey(.StatusWindowLevelKey))
        
        
        overlayWindow.titlebarAppearsTransparent  =   true
        overlayWindow.titleVisibility             =   .Hidden
        overlayWindow.styleMask = NSBorderlessWindowMask
        
        overlayWindow.setFrameOrigin(NSPoint(x: 0, y: 0))
        
        overlayWindow.titleVisibility = NSWindowTitleVisibility.Hidden;
        overlayWindow.titlebarAppearsTransparent = true
        
        skipBreakMenuItem.hidden = true
        overlayWindow.contentView?.addSubview(skipButton)
        overlayWindow.contentView?.addSubview(breakCountDownLabel)
        breakCountDownLabel.cell?.backgroundStyle = NSBackgroundStyle.Raised
        getPreferences()
        changeImage()
        setBreakTimer()
        setBreakCountDownTimer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.breakForTextDidChange), name: "ICTextFieldDidChange", object: BreakForTextField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.breakIntrevalTextDidChange), name: "ICTextFieldDidChange", object: BreakIntervalTextField)


    }
    
    func breakForTextDidChange(notification: NSNotification){
        var value = Int(breakForTextCell.title)
        if !(value > 0){
            value = 5
        }
        
        value = value! * 60
        breakTimeCountDown = value!

        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(value!, forKey: "BreakTime")
        
        breakTimeInSeconds = NSTimeInterval(breakTimeCountDown)
        breakMenuItem.title = "Break for " + String(breakTimeCountDown/60) + " min"
        
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        setBreakTimer()
        setBreakCountDownTimer()
    }
    
    func breakIntrevalTextDidChange(notification: NSNotification){
        var value = Int(breakIntervalTextCell.title)
        if !(value > 0){
            value = 30
        }
        
        value = value! * 60
        
        breakTimeoutCountDown = value!
        
        breakTimeout = NSTimeInterval(breakTimeoutCountDown)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(value!, forKey: "BreakTimeout")
        
        self.breakTimer!.invalidate()
        self.breakCountDownTimer!.invalidate()
        setBreakTimer()
        setBreakCountDownTimer()
    }
    
    
    func getPreferences(){
        if StartupLaunch.isAppLoginItem() {
            launchAtStartupCheckbox.state = NSOnState
        } else {
            launchAtStartupCheckbox.state = NSOffState
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let breakTimeoutCountDownStored = defaults.integerForKey("BreakTimeout")
        let breakTimeCountDownStored = defaults.integerForKey("BreakTime")
        
        if (breakTimeoutCountDownStored == 0){
            breakTimeoutCountDown = 25*60
        } else {
            breakTimeoutCountDown = breakTimeoutCountDownStored
        }
        
        if (breakTimeCountDownStored == 0){
            breakTimeCountDown = 5*60
        } else {
            breakTimeCountDown = breakTimeCountDownStored
        }
        
        breakTimeout = NSTimeInterval(breakTimeoutCountDown)
        breakTimeInSeconds = NSTimeInterval(breakTimeCountDown)
        breakMenuItem.title = "Break for " + String(breakTimeCountDown/60) + " min"
        
        breakForTextCell.title = String(breakTimeCountDown/60)
        breakIntervalTextCell.title = String(breakTimeoutCountDown/60)

    }
    
    func setBreakCountDownTimer(){
        breakTimeCountDown = Int(breakTimeout)
        
        timeToNextBreak.title = secondsToFormat(breakTimeCountDown)
        
        self.breakCountDownTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                                          target:self,
                                                                          
                                                                          selector:#selector(AppDelegate.updateLabel),
                                                                          userInfo:nil,
                                                                          repeats:true)
        NSRunLoop.currentRunLoop().addTimer(breakCountDownTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func setBreakTimer(){
        self.breakTimer = NSTimer.scheduledTimerWithTimeInterval(breakTimeout,
                                                                 target:self,
                                                            selector:#selector(AppDelegate.breakClicked),
                                                                 userInfo:nil,
                                                                 repeats:false)
        NSRunLoop.currentRunLoop().addTimer(breakTimer!, forMode: NSRunLoopCommonModes)
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

