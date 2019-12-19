//
//  GameScene.swift
//  Snake
//
//  Created by Furkan Celik on 21.01.2019.
//  Copyright © 2019 Furkan Celik. All rights reserved.
//

import SpriteKit
import GameplayKit
import Skillz

class GameScene: SKScene {
    
    var gameLogo : SKLabelNode!
    var playButton : SKShapeNode!
    var pauseButton : SKSpriteNode!
    var unPauseButton : SKSpriteNode!
    var game: GameManager!
    var currentScore: SKLabelNode!
    var currentTime: SKLabelNode!
    var abortButton: SKLabelNode!
    var playerPositions: [(Int, Int)] = []
    var enemySnakes: [EnemySnake] = []
    var gameBG: SKShapeNode!
    var gameArray: [(name: SKShapeNode, x: Int, y: Int)] = []
    var scorePos: CGPoint?
    var portalPos: (CGPoint?, CGPoint?)
    var timer: Timer? = nil
    var timeRemaining: Int = 0
    var isGamePaused: Bool = false
    var isPlaying: Bool = false
    
    static var instance: GameScene?;
    
    @objc func swipeL() {
        if !self.isGamePaused {
            game.swipe(ID: 1)
        }
    }
    
    @objc func swipeU() {
        if !self.isGamePaused {
            game.swipe(ID: 2)
        }
    }
    
    @objc func swipeR() {
        if !self.isGamePaused {
            game.swipe(ID: 3)
        }
    }
    
    @objc func swipeD() {
        if !self.isGamePaused {
            game.swipe(ID: 4)
        }
    }
    
    override func didMove(to view: SKView) {
        InitializeMenu()
        game = GameManager(scene: self)
        InitializeGameView()
        
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    GameScene.instance = self;
                    launchSkillz()
                    //startGame()
                } else if node.name == "pause_button" {
                    togglePause(isPaused: true)
                } else if node.name == "unpause_button" {
                    togglePause(isPaused: false)
                } else if node.name == "quit_button" {
                    showQuitAlert()
                }
            }
        }
    }
    
    private func showQuitAlert() {
        togglePause(isPaused: true)
        let alert = UIAlertController(title: "Quit game?", message: "Do you want to quit? This will report the current score and end the match for you.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alert: UIAlertAction!) in self.togglePause(isPaused: false)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
            self.togglePause(isPaused: false)
            self.timeRemaining = 0
        }))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func launchSkillz() {
        Skillz.skillzInstance().launch();
    }
    
    class func startSkillzGame(gameParameters: [AnyHashable : Any]!, with matchInfo: SKZMatchInfo!) {
        GameScene.instance?.startGame();
    }
    
    override init() {
        super.init();
        GameScene.instance = self;
    }
    
    override init(size: CGSize) {
        super.init(size:size);
        GameScene.instance = self;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder);
        GameScene.instance = self;
    }
    
    private func startGame() {
        print("start game")
        isPlaying = true
        timeRemaining = 120;
        if timer != nil {
            timer?.invalidate()
            timer = nil;
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            if !self.isGamePaused {
                self.timeRemaining -= 1
                if self.timeRemaining < 0 {
                    self.timeRemaining = 0;
                }
                let minutes = Int(self.timeRemaining) / 60 % 60
                let seconds = Int(self.timeRemaining) % 60
                self.currentTime.text = String(format:"%02i:%02i", minutes, seconds)
            }
        })

        gameLogo.run(SKAction.move(by: CGVector(dx: -100, dy: 600), duration: 0.5)) {
            self.gameLogo.isHidden = true
        }
        
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.gameLogo.isHidden = true
        }
        
        self.currentTime.setScale(0)
        self.currentTime.isHidden = false
        self.currentTime.run(SKAction.scale(to: 1, duration: 0.4)) {
            self.gameBG.setScale(0)
            self.currentScore.setScale(0)
            self.pauseButton.setScale(0)
            self.abortButton.setScale(0)
            self.pauseButton.isHidden = false
            self.gameBG.isHidden = false
            self.currentScore.isHidden = false
            self.abortButton.isHidden = false
            self.gameBG.run(SKAction.scale(to: 1, duration: 0))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
            self.pauseButton.run(SKAction.scale(to: 1, duration: 0.4))
            self.abortButton.run(SKAction.scale(to: 1, duration: 0.4))
            self.game.InitGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isGamePaused {
            self.isPaused = true
        } else {
            game.Update(time: currentTime)
        }
    }
    
    private func InitializeMenu() {
        //Game title
        gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "SNAKE"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        
        //Play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 400)
        playButton.fillColor = SKColor.cyan
        let topCorner = CGPoint(x: -100, y: 100), bottomCorner = CGPoint(x: -100, y: -100), middle = CGPoint(x: 100, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
        
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.name = "pause_button"
        pauseButton.zPosition = 1
        pauseButton.position = CGPoint(x:-200, y: (frame.size.height / -2) + 75)
        pauseButton.isHidden = true
        self.addChild(pauseButton)
        
        unPauseButton = SKSpriteNode(imageNamed: "play")
        unPauseButton.name = "unpause_button"
        unPauseButton.zPosition = 1
        unPauseButton.position = CGPoint(x:-200, y: (frame.size.height / -2) + 75)
        unPauseButton.isHidden = true
        self.addChild(unPauseButton)
        
        abortButton = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        abortButton.text = "Quit?"
        abortButton.name = "quit_button"
        abortButton.zPosition = 1
        abortButton.position = CGPoint(x:200, y: (frame.size.height / -2) + 60)
        abortButton.isHidden = true
        self.addChild(abortButton)
    }
    
    private func InitializeGameView() {
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
        
        currentTime = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentTime.zPosition = 1
        currentTime.position = CGPoint(x: 0, y: (frame.size.height / 2) - 100)
        currentTime.fontSize = 40
        currentTime.isHidden = true
        currentTime.text = "2:00"
        currentTime.fontColor = SKColor.white
        self.addChild(currentTime)
        
        let width = frame.size.width - 200
        let height = frame.size.height - 236
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = -2
        gameBG.isHidden = true
        self.addChild(gameBG)
        
        CreateGameBoard(width: width, height: height)
    }
    
    private func CreateGameBoard(width: CGFloat, height: CGFloat){
        let cellWidth: CGFloat = 27.5
        let numRows = 40
        let numCols = 20
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        
        for i in 0...numRows-1 {
            for j in 0...numCols-1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                gameArray.append((name: cellNode, x: i, y: j))
                gameBG.addChild(cellNode)
                x += cellWidth
            }
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
    
    func Contains(a: [(Int, Int)], v: (Int, Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a {
            if v1 == c1 && v2 == c2 {
                return true
            }
        }
        return false
    }
    
    func togglePause(isPaused: Bool) {
        if isPlaying {
            self.isGamePaused = isPaused
            self.pauseButton.isHidden = isPaused
            self.unPauseButton.isHidden = !isPaused
            self.isPaused = isPaused
        }
    }
    
    func isTimeOver() -> Bool {
        return timeRemaining <= 0
    }
}
