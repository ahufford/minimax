//
//  GameScene.swift
//  MiniMax
//
//  Created by Alec on 5/11/20.
//  Copyright © 2020 Huff Limitied. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    enum Player {
        case one
        case two
        case tie

        func value() -> Int {
            if self == .one {
                return 1
            } else if self == .two {
                return -1
            } else {
                return 0
            }
        }
    }

    var you: Player!
    var computer: Player!

    var viewController: GameViewController!
    var touchPos: CGPoint?
    var screenBounds: CGRect = CGRect.zero
    var boardOrigin: CGPoint!

    let cellSize: CGFloat = 100.0

    var board = [0,0,0,0,0,0,0,0,0]

    override func didMove(to view: SKView) {
        screenBounds = view.bounds
        touchPos = nil

        boardOrigin = CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2) + CGPoint(x: cellSize * -1.5, y: cellSize * -1.5)

        restartPressed()
    }

    func restartPressed() {

        board = [0,0,0,0,0,0,0,0,0]
        scene?.removeAllChildren()
        gameOver = false
        drawGrid()
        viewController.label.text = ""

        let rand = Int.random(in: 0...1)
        if rand == 0 {
            you = Player.one
            computer = Player.two
        } else {
            you = Player.two
            computer = Player.one
            //computerEasyTurn()
            computerHardTurn()
        }

    }

    func drawGrid() {
        for _ in 0...2 {
            for _ in 0...2 {
                let yourline = SKShapeNode()
                let pathToDraw = CGMutablePath()
                let center = CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2)
                pathToDraw.move(to: center + CGPoint(x: cellSize * -1.5, y: cellSize * 0.5))
                pathToDraw.addLine(to: CGPoint(x: pathToDraw.currentPoint.x + cellSize * 3, y: pathToDraw.currentPoint.y))

                pathToDraw.move(to: center + CGPoint(x: cellSize * -1.5, y: cellSize * -0.5))
                pathToDraw.addLine(to: CGPoint(x: pathToDraw.currentPoint.x + cellSize * 3, y: pathToDraw.currentPoint.y))

                pathToDraw.move(to: center + CGPoint(x: cellSize * 0.5, y: cellSize * -1.5))
                pathToDraw.addLine(to: CGPoint(x: pathToDraw.currentPoint.x, y: pathToDraw.currentPoint.y + cellSize * 3 ))

                pathToDraw.move(to: center + CGPoint(x: cellSize * -0.5, y: cellSize * -1.5))
                pathToDraw.addLine(to: CGPoint(x: pathToDraw.currentPoint.x, y: pathToDraw.currentPoint.y + cellSize * 3 ))
                yourline.path = pathToDraw
                yourline.strokeColor = SKColor.red
                addChild(yourline)
            }
        }
    }

    var gameOver = false

    func checkWin() -> Player? {
        // check horizontal wins
        var totals: [Int] = []
        var lineTotal = 0
        for y in 0...2 {
            for x in 0...2 {
                lineTotal += board[(x + (y * 3))]
            }
            totals.append(lineTotal)
            lineTotal = 0
        }
        lineTotal = 0
        for x in 0...2 {
            for y in 0...2 {
                lineTotal += board[(x + (y * 3))]
            }
            totals.append(lineTotal)
            lineTotal = 0
        }
        totals.append(board[0] + board[4] + board[8])
        totals.append(board[2] + board[4] + board[6])
        print(totals)
        if totals.contains(3) {
            gameOver = true
            return Player.one
        } else if totals.contains(-3) {
            gameOver = true
            return Player.two
        }

        // check cats
        // no 0s means cats game
        if !board.contains(0) {
            gameOver = true
            return Player.tie
        }
        return nil

    }

    func touchTrigger(pos: CGPoint) {
        if gameOver {
            return
        }
        guard let tapIndex = getIndex(pos: pos) else {
            return
        }
        if board[tapIndex] == 0 {
            board[tapIndex] = you.value()
        } else {
            return
        }
        updateBoard()
        checkWin()
        //computerEasyTurn()
        computerHardTurn()
    }

    func computerEasyTurn() {
        if gameOver {
            return
        }
        var computerTurn = true
        var tries = 1000
        while computerTurn {
            let rand = Int.random(in: 0...8)
            if board[rand] == 0 {
                board[rand] = computer.value()
                computerTurn = false
            }
            tries -= 1
            if tries <= 0 {
                computerTurn = false
            }
        }
        updateBoard()
        checkWin()
    }

    func computerHardTurn() {
        if gameOver {
            return
        }
        var bestScore = -Int.max
        var bestMove = -1
        for y in 0...2 {
            for x in 0...2  {
                // Check if available
                if board[x + (y * 3)] == 0 {

                    //Do the move, check it, undo it
                    board[x + (y * 3)] = computer.value()
                    let score = minimax(board: board, depth: 0, isMaximizing: true)
                    board[x + (y * 3)] = 0

                    if score > bestScore {
                        bestScore = score
                        bestMove = x + (y * 3)
                    }

                 }
             }
         }
        board[bestMove] = -1
        updateBoard()
        checkWin()

     }

    func minimax(board: [Int], depth: Int, isMaximizing: Bool) -> Int {
        // Base Case (TERMINAL STATES)
        let result = checkWin()
        if result != nil {
            var score = 0
            if computer.value() == result?.value() {
                score += 1
            } else if you.value() == result?.value() {
                score -= 1
            }
            return score
        }
        return 1
     }



    func updateBoard() {
        for y in 0...2 {
            for x in 0...2  {
                let centerPoint = CGPoint(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize) + boardOrigin + CGPoint(x: cellSize / 2, y: cellSize / 2)
                if board[x + (y * 3)] == 1 {
                    let sprite = SKSpriteNode(imageNamed: "X.png")
                    sprite.size = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
                    sprite.position = centerPoint
                    addChild(sprite)
                } else if board[x + (y * 3)] == -1 {
                    let sprite = SKSpriteNode(imageNamed: "O.png")
                    sprite.size = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
                    sprite.position = centerPoint
                    addChild(sprite)
                }
            }
        }
    }

    func getIndex(pos: CGPoint) -> Int? {

        var checkOrigin = boardOrigin!
        for y in 0...2 {
            for x in 0...2  {
                if CGRect(x: checkOrigin.x, y: checkOrigin.y, width: cellSize, height: cellSize).contains(pos) {
                    return x + (y * 3)
                }
                checkOrigin.x += cellSize
            }
            checkOrigin.x = boardOrigin.x
            checkOrigin.y += cellSize
        }
        return nil
    }

    func touchDown(atPoint pos : CGPoint) {
        touchPos = pos
        touchTrigger(pos: pos)

    }
    
    func touchMoved(toPoint pos : CGPoint) {
        touchPos = pos

    }
    
    func touchUp(atPoint pos : CGPoint) {
        touchPos = nil

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
