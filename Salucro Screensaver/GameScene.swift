//
//  GameScene.swift
//  Salucro Screensaver
//
//  Created by Lee Bradley on 9/21/18.
//  Copyright © 2018 Lee Bradley. All rights reserved.
//

import Foundation
import AppKit
import SpriteKit
import ScreenSaver

class GameScene: SKScene {
    
    private var headBone : SKSpriteNode!
    
    private var nyan : SpriteSheet = SpriteSheet(texture: SKTexture(imageNamed: GameScene.getPath(forPng: "NyanCatSprite")), rows: 1, columns: 6, spacing: 0, margin: 0)
    
    private var startburst : SpriteSheet = SpriteSheet(texture: SKTexture(imageNamed: GameScene.getPath(forPng: "Starburst")), rows: 1, columns: 6, spacing: 0, margin: 0)
    private var startburst2 : SpriteSheet = SpriteSheet(texture: SKTexture(imageNamed: GameScene.getPath(forPng: "Starburst2")), rows: 1, columns: 6, spacing: 0, margin: 0)
    
    private var textures : [SKTexture] = []
    private var texturesStartburst : [SKTexture] = []
    private var texturesStartburst2 : [SKTexture] = []
    
    private var asherSprite : SKSpriteNode = SKSpriteNode()
    private var asherSpriteContainer : SKSpriteNode = SKSpriteNode()
    private let cameraNode = SKCameraNode()
    private let movementSpeed: CGFloat = 120.0
    
    private let rainbowLines: [SKShapeNode] = [
        SKShapeNode(),
        SKShapeNode(),
        SKShapeNode(),
        SKShapeNode(),
        SKShapeNode(),
        SKShapeNode()
    ];
    private var rainbowPoints: [CGPoint] = []
    
    // This is a fix for a bug that caused me a lot of pain.
    // Unlike most apps, screensavers do not have default access
    // to their own resources. This is because they are a "plugin"
    // To obtain the correct resource path, you must first find
    // the bundle, and then run .path() with the resource name and type.
    // It's frustrating! But works.
    static func getPath(forPng: String) -> String {
        let salucroBundle = Bundle(for: SwiftSS.self)
        let path = salucroBundle.path(forResource: forPng, ofType: "png")
        return path!
    }
    
    override func didMove(to view: SKView) {
        for i in 0...5 {
            textures.append(nyan.textureForColumn(column: i, row: 0)!)
            texturesStartburst.append(startburst.textureForColumn(column: i, row: 0)!)
            texturesStartburst2.append(startburst2.textureForColumn(column: i, row: 0)!)
        }
        
        let animSpeed = 8.0 / 60.0
        let animTotal = animSpeed * 6.0
        
        self.addChild(asherSpriteContainer)
        asherSpriteContainer.addChild(asherSprite)
        
        let path = GameScene.getPath(forPng: "asher")
        let headBone = SKSpriteNode(imageNamed: path)
        asherSprite.addChild(headBone)
        asherSprite.zPosition = 100
        headBone.alpha = 1
        headBone.zPosition = 100
        headBone.position.x = headBone.position.x + 90
        headBone.position.y = headBone.position.y + 30
        let moveBackForth = SKAction.sequence([
            .moveBy(x: 10, y: 0, duration: animTotal / 2.0),
            .moveBy(x: -10, y: 0, duration: animTotal / 2.0)
            ])
        headBone.run(.repeatForever(moveBackForth))
        
        let sprite = SKSpriteNode(texture: textures[0])
        sprite.setScale(10)
        sprite.texture?.filteringMode = SKTextureFilteringMode.nearest
        asherSprite.addChild(sprite)
        
        let textureAnim = SKAction.animate(with: textures, timePerFrame: animSpeed, resize: false, restore: false)
        sprite.run(.repeatForever(textureAnim))
        
        // Create line with SKShapeNode
        //rainbowPath.move(to: startPoint)
        //rainbowLine.path = rainbowPath
        addRainbowSpot()
        rainbowLines[0].strokeColor = SKColor.init(red:0.90, green:0.21, blue:0.16, alpha:1.0)
        rainbowLines[1].strokeColor = SKColor.init(red:0.94, green:0.65, blue:0.24, alpha:1.0)
        rainbowLines[2].strokeColor = SKColor.init(red:0.99, green:0.99, blue:0.33, alpha:1.0)
        rainbowLines[3].strokeColor = SKColor.init(red:0.51, green:0.98, blue:0.30, alpha:1.0)
        rainbowLines[4].strokeColor = SKColor.init(red:0.30, green:0.66, blue:0.97, alpha:1.0)
        rainbowLines[5].strokeColor = SKColor.init(red:0.42, green:0.31, blue:0.96, alpha:1.0)
        
        for line in rainbowLines {
            line.lineWidth = 20
            self.addChild(line)
        }
        
        let customAction = SKAction.run({
            self.addRainbowSpot()
        })
        
        let moveUpDown = SKAction.sequence([
            .moveBy(x: 0, y: -5, duration: animTotal / 2.0),
            customAction,
            .moveBy(x: 0, y: 5, duration: animTotal / 2.0),
            customAction
            ])
        asherSprite.run(.repeatForever(moveUpDown))
        
        let moveForward = SKAction.sequence([.moveBy(x: movementSpeed, y: 0, duration: animTotal)])
        asherSpriteContainer.run(.repeatForever(moveForward))
        
        self.addChild(cameraNode)
        self.camera = cameraNode
    }
    
    private func addRainbowSpot() {
        let newPoint = CGPoint(x: self.asherSpriteContainer.position.x, y: self.asherSpriteContainer.position.y + self.asherSprite.position.y)
        rainbowPoints.append(newPoint)
        
        if (rainbowPoints.count > 20) {
            rainbowPoints.remove(at: 0)
        }
        
        var i = 0
        for line in rainbowLines.reversed() {
            let offset: CGFloat = CGFloat(i * 19 - 35)
            let rainbowPath = CGMutablePath()
            
            let firstPoint = rainbowPoints[0]
            rainbowPath.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y + offset))
            
            for point in rainbowPoints {
                let newPoint = CGPoint(x: point.x, y: point.y + offset)
                rainbowPath.addLine(to: newPoint)
            }
            line.path = rainbowPath
            i = i + 1
        }
    }
    
    override func didSimulatePhysics() {
        // Updates to camera position must happen here, not update()
        // Otherwise the result looks jittery...
        cameraNode.position = CGPoint(x: asherSpriteContainer.position.x, y: asherSpriteContainer.position.y)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}

class SpriteSheet {
    let texture: SKTexture
    let rows: Int
    let columns: Int
    var margin: CGFloat=0
    var spacing: CGFloat=0
    var frameSize: CGSize {
        return CGSize(width: (self.texture.size().width-(self.margin*2+self.spacing*CGFloat(self.columns-1)))/CGFloat(self.columns),
                      height: (self.texture.size().height-(self.margin*2+self.spacing*CGFloat(self.rows-1)))/CGFloat(self.rows))
    }
    
    init(texture: SKTexture, rows: Int, columns: Int, spacing: CGFloat, margin: CGFloat) {
        self.texture=texture
        self.rows=rows
        self.columns=columns
        self.spacing=spacing
        self.margin=margin
        
    }
    
    convenience init(texture: SKTexture, rows: Int, columns: Int) {
        self.init(texture: texture, rows: rows, columns: columns, spacing: 0, margin: 0)
    }
    
    func textureForColumn(column: Int, row: Int)->SKTexture? {
        if !(0...self.rows ~= row && 0...self.columns ~= column) {
            //location is out of bounds
            return nil
        }
        
        var textureRect=CGRect(x: self.margin+CGFloat(column)*(self.frameSize.width+self.spacing)-self.spacing,
                               y: self.margin+CGFloat(row)*(self.frameSize.width+self.spacing)-self.spacing,
                               width: self.frameSize.width,
                               height: self.frameSize.height)
        
        textureRect=CGRect(x: textureRect.origin.x/self.texture.size().width, y: textureRect.origin.y/self.texture.size().height,
                           width: textureRect.size.width/self.texture.size().width, height: textureRect.size.height/self.texture.size().height)
        return SKTexture(rect: textureRect, in: self.texture)
    }
    
}

class DefaultsManager {
    var defaults: UserDefaults
    
    init() {
        let identifier = Bundle(for: DefaultsManager.self).bundleIdentifier
        defaults = ScreenSaverDefaults.init(forModuleWithName: identifier!)!
    }
    
    var canvasColor: NSColor {
        set(newColor) {
            setColor(newColor, key: "CanvasColor")
        }
        get {
            return getColor("CanvasColor") ?? NSColor(red: 1, green: 0.0, blue: 0.5, alpha: 1.0)
        }
    }
    
    @objc func setColor(_ color: NSColor, key: String) {
        do {
            try defaults.set(NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true), forKey: key)
        } catch _ {
            fatalError("something bad happened")
        }
        
        defaults.synchronize()
    }
    
    @objc func getColor(_ key: String) -> NSColor? {
        if let canvasColorData = defaults.object(forKey: key) as? Data {
            // TODO this one still needs to be fixed
            return NSKeyedUnarchiver.unarchiveObject(with: canvasColorData) as? NSColor
        }
        return nil;
    }
}


class ConfigureSheetController: NSWindowController {
    
    //----------------------------
    // MARK: Properties
    //----------------------------
    
    /// The defaults object instantiated by the nib.
    //@IBOutlet weak var defaults: DefaultsManager?
    
    /// Controls the list of objects to display in the main popup.
    @IBOutlet weak var mainLabelArrayController: NSArrayController?
    
    /// Controls the list of objects to display in the secondary popup.
    @IBOutlet weak var secondaryLabelArrayController: NSArrayController?
    
    /// The values to display in the array controllers.
    //@objc let options: [String] = WhatColorIsItLabelDisplayValue.allValues().map {$0.rawValue}
    /*
    /// Converts the value selected by the main popover button to the proper enum value, and sets it to the defaults.
    @objc var mainSelectionIndex: String {
        get {
            if let defaults = defaults {
                return defaults.mainLabelDisplayValue.rawValue
            }
            return WhatColorIsItLabelDisplayValue.None.rawValue
        }
        set(newValue) {
            if let value = WhatColorIsItLabelDisplayValue(rawValue: newValue) {
                defaults?.mainLabelDisplayValue = value
            }
        }
    }
    
    /// Converts the value selected by the secondary popover button to the proper enum value, and sets it to the defaults.
    @objc var secondarySelectionIndex: String {
        get {
            if let defaults = defaults {
                return defaults.secondaryLabelDisplayValue.rawValue
            }
            return WhatColorIsItLabelDisplayValue.None.rawValue
        }
        set(newValue) {
            if let value = WhatColorIsItLabelDisplayValue(rawValue: newValue) {
                defaults?.secondaryLabelDisplayValue = value
            }
        }
    }*/
    
    override var windowNibName: NSNib.Name {
        return NSNib.Name(rawValue: "ConfigureSheet")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    //----------------------------
    // MARK: Actions
    //----------------------------
    
    @IBAction func close(_ sender: AnyObject) {
        // Close
        if let window = window {
            window.sheetParent?.endSheet(window)
        }
    }
    
}
