//
//  DijkstraWeightfinder.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 9/28/20.
//

import Foundation

/// Calculates the minimum weights to move from one state to all other states.
public class DijkstraWeightfinder<DataSource: APathfinderDataSource> {

    /// The state the weightfinder operates on.
    public typealias State = DataSource.State

    /// Provides information about the graph to the pathfinder.
    private let dataSource:DataSource

    /// Initializes an `APathfinder` with the given data source.
    ///
    /// - Parameter dataSource: Provides information on states to the pathfinder.
    public init(dataSource:DataSource) {
        self.dataSource = dataSource
    }

    /// Calculates the minimum weights to move from `start` to all other states.
    /// If a valid state does not have an entry in the returned dictionary, it is impossible
    /// to reach (alternatively, its distance is infinity). `start` is not included in the return value.
    ///
    /// - Parameter start: The state to start at.
    /// - Returns: A dictionary mapping other states to the distance required to move from `start` to that state.
    public func findWeights(start:State) -> [State:Double] {
        var weights:[State:Double] = [:]
        let list = APathfinderList<State>()
        list.insert(state: start, distance: 0.0, moveCost: 0.0, parent: nil)
        while let top = list.nextState() {
            weights[top.state] = top.moveCost
            for adjacentState in self.dataSource.adjacentStates(to: top.state) {
                let moveCost = top.moveCost + adjacentState.moveCost
                list.updateOrInsertIfLower(state: adjacentState.state, newMoveCost: moveCost, distance: 0.0, from: top)
            }
        }
        // Remove the start weight, since it is the first node processed
        // in the while loop.
        weights[start] = nil
        return weights
    }
}
