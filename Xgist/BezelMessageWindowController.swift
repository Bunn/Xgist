//
//  BezelMessageWindowController.swift
//  Xgist
//
//  Created by Guilherme Rambo on 15/03/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

extension BezelMessage {
    
    fileprivate var image: NSImage? {
        return NSImage(named: imageName)
    }
    
}

final class BezelMessageWindowController: NSWindowController {
    
    private struct Metrics {
        static let defaultY: CGFloat = 280.0
        static let size = NSSize(width: 200, height: 200)
        static let cornerRadius: CGFloat = 18.0
        static let iconSize: CGFloat = 82.0
    }
    
    var status: BezelMessage {
        didSet {
            updateUI()
        }
    }
    
    init(status: BezelMessage) {
        self.status = status
        
        let rect = NSRect(origin: .zero, size: Metrics.size)
        let window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
                
        super.init(window: window)
        
        position(window)
        
        windowDidLoad()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func position(_ window: NSWindow) {
        let offset: CGFloat
        
        if let screen = NSScreen.main() {
            offset = screen.frame.height - screen.visibleFrame.height
        } else {
            offset = 0
        }
        
        window.center()
        
        var adjustedRect = window.frame
        adjustedRect.origin.y = Metrics.defaultY - offset / 2 - window.frame.height / 2
        window.setFrame(adjustedRect, display: false)
    }
    
    private var backgroundMaterial: NSVisualEffectMaterial {
        guard let systemTheme = UserDefaults.standard.object(forKey: "AppleInterfaceStyle") as? String else { return .mediumLight }
        
        return (systemTheme == "Dark") ? .dark : .mediumLight
    }
    
    private var appearance: NSAppearance? {
        let name = backgroundMaterial == .dark ? NSAppearanceNameVibrantDark : NSAppearanceNameAqua
        
        return NSAppearance(named: name)
    }
    
    private lazy var vfxView: NSVisualEffectView = {
        let v = NSVisualEffectView(frame: .zero)
        
        v.state = .active
        v.blendingMode = .behindWindow
        v.material = self.backgroundMaterial
        v.appearance = self.appearance
        v.maskImage = self.maskImage(with: Metrics.cornerRadius)
        
        return v
    }()
    
    private lazy var imageView: NSImageView = {
        let v = NSImageView(frame: .zero)
        
        v.heightAnchor.constraint(equalToConstant: Metrics.iconSize).isActive = true
        v.widthAnchor.constraint(equalToConstant: Metrics.iconSize).isActive = true
        
        return v
    }()
    
    private lazy var label: NSTextField = {
        let f = NSTextField(frame: .zero)
        
        f.isEditable = false
        f.drawsBackground = false
        f.isBezeled = false
        f.isBordered = false
        f.isSelectable = false
        f.textColor = .labelColor
        f.font = NSFont.systemFont(ofSize: 18.0)
        f.alignment = .center
        f.lineBreakMode = .byWordWrapping
        f.setContentHuggingPriority(NSLayoutPriorityRequired, for: .horizontal)
        f.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, for: .horizontal)
        
        return f
    }()
    
    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.imageView, self.label])
        
        v.orientation = .vertical
        v.spacing = 18
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private func maskImage(with cornerRadius: CGFloat) -> NSImage {
        let edgeLength = 2.0 * cornerRadius + 1.0
        let size = NSSize(width: edgeLength, height: edgeLength)
        
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.set()
            
            let bezierPath = NSBezierPath(roundedRect: rect,
                                          xRadius: cornerRadius,
                                          yRadius: cornerRadius)
            
            bezierPath.fill()
            
            return true
        }
        
        image.capInsets = EdgeInsets(top: cornerRadius,
                                     left: cornerRadius,
                                     bottom: cornerRadius,
                                     right: cornerRadius)
        image.resizingMode = .stretch
        
        return image
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = window else { return }
        
        window.isOpaque = false
        window.backgroundColor = .clear
        
        window.level = Int(CGWindowLevelForKey(.popUpMenuWindow))
        window.collectionBehavior = [.moveToActiveSpace, .ignoresCycle, .stationary]
        
        window.contentView = vfxView
        
        vfxView.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: vfxView.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: vfxView.leadingAnchor, constant: 22.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: vfxView.trailingAnchor, constant: -22.0).isActive = true
    }
    
    func show(for duration: TimeInterval, completion: (() -> Void)? = nil) {
        vfxView.material = backgroundMaterial
        vfxView.appearance = appearance
        
        guard let window = window else { return }
        
        window.alphaValue = 0
        
        showWindow(nil)
        
        window.animator().alphaValue = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            NSAnimationContext.runAnimationGroup({ _ in
                window.animator().alphaValue = 0
            }, completionHandler: {
                self.close()
                completion?()
            })
        }
    }
    
    private func updateUI() {
        imageView.image = status.image
        label.stringValue = status.title
    }
    
}
