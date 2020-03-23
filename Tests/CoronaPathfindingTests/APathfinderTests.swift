//
//  APathfinderTests.swift
//  CoronaPathfindingTests
//
//  Created by Cooper Knaak on 3/21/20.
//

import XCTest
@testable import CoronaPathfinding

struct IntPoint: Hashable {
    var x:Int
    var y:Int

    func hash(into hasher:inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

func ==(lhs:IntPoint, rhs:IntPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

class GridDataSource: APathfinderDataSource, CustomStringConvertible {

    let width:Int
    let height:Int
    private var walls = Set<IntPoint>()

    var description: String {
        var description = ""
        for y in (0..<height).reversed() {
            for x in 0..<width {
                description += self.walls.contains(IntPoint(x: x, y: y)) ? "#" : "."
            }
            if y != 0 {
                description += "\n"
            }
        }
        return description
    }

    init(width:Int, height:Int) {
        self.width = width
        self.height = height
    }

    private subscript(x:Int, y:Int) -> Bool {
        guard 0 <= x && x < self.width && 0 <= y && y < self.height else {
            return false
        }
        return !self.walls.contains(IntPoint(x: x, y: y))
    }

    func adjacentStates(to state:IntPoint) -> [StateTransition<IntPoint>] {
        var adjacentStates:[StateTransition<IntPoint>] = []
        if self[state.x - 1, state.y] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x - 1, y: state.y), moveCost: 1))
        }
        if self[state.x + 1, state.y] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x + 1, y: state.y), moveCost: 1))
        }
        if self[state.x, state.y - 1] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x, y: state.y - 1), moveCost: 1))
        }
        if self[state.x, state.y + 1] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x, y: state.y + 1), moveCost: 1))
        }
        if self[state.x - 1, state.y - 1] && self[state.x - 1, state.y] && self[state.x, state.y - 1] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x - 1, y: state.y - 1), moveCost: 1.414))
        }
        if self[state.x + 1, state.y - 1] && self[state.x + 1, state.y] && self[state.x, state.y - 1] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x + 1, y: state.y - 1), moveCost: 1.414))
        }
        if self[state.x - 1, state.y + 1] && self[state.x - 1, state.y] && self[state.x, state.y + 1] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x - 1, y: state.y + 1), moveCost: 1.414))
        }
        if self[state.x + 1, state.y + 1] && self[state.x + 1, state.y] && self[state.x, state.y + 1] {
            adjacentStates.append(StateTransition(state: IntPoint(x: state.x + 1, y: state.y + 1), moveCost: 1.414))
        }
        return adjacentStates.filter() { p in
            return !self.walls.contains(p.state)
        }
    }

    func addWall(x:Int, y:Int) {
        self.walls.insert(IntPoint(x: x, y: y))
    }

    func distance(between firstState:IntPoint, and secondState:IntPoint) -> Double {
        return Double(abs(secondState.x - firstState.x) + abs(secondState.y - firstState.y))
    }

    func describe(path:[IntPoint]) -> String {
        var description = ""
        for y in (0..<height).reversed() {
            for x in 0..<width {
                let p = IntPoint(x: x, y: y)
                if path.contains(p) {
                    for (i, s) in path.enumerated() {
                        if s == p {
                            if i == 0 || i == path.count - 1 {
                                description += "!"
                            } else {
                                description += "\(i % 10)"
                            }
                            break
                        }
                    }
                } else {
                    description += self.walls.contains(p) ? "#" : "."
                }
            }
            if y != 0 {
                description += "\n"
            }
        }
        return description
    }

}

final class APathfinderTests: XCTestCase {

    func testAPathfinderWithWallsAndDiagonalMovement() {
        let dataSource = GridDataSource(width: 10, height: 10)
        dataSource.addWall(x: 7, y: 3)
        dataSource.addWall(x: 6, y: 4)
        dataSource.addWall(x: 5, y: 5)
        dataSource.addWall(x: 4, y: 6)
        dataSource.addWall(x: 3, y: 7)
        let pathfinder = APathfinder(dataSource: dataSource)
        do {
            let start = IntPoint(x: 3, y: 3)
            let end = IntPoint(x: 7, y: 7)
            let path = try pathfinder.findPath(from: start, to: end)
            XCTAssertEqual(path.count, 11)
            for (i, point) in path.enumerated().dropLast() {
                let nextPoint = path[i + 1]
                XCTAssertLessThanOrEqual(abs(nextPoint.x - point.x), 1)
                XCTAssertLessThanOrEqual(abs(nextPoint.y - point.y), 1)
            }
        } catch {
            XCTFail("Caught error: \(error)")
        }
    }

}
