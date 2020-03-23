//
//  APathfinderList.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 3/22/20.
//

import Foundation

internal class APathfinderList<State: Hashable> {
    /// The states that have not yet been processed, in order of lowest cost to highest cost.
    private let openList = PriorityQueue<APathfinderNode<State>, Double>(comparator: <)
    /// The states that have already been processed and the optimal path determined.
    private var closedList = Set<State>()

    /// Returns the next state to process. This state is the closest of the states in the list to the goal.
    /// Marks the state as processed, so it cannot be processed again.
    ///
    /// - Returns: The next closest state to process, or `nil` if the list is empty.
    internal func nextState() -> APathfinderNode<State>? {
        guard let state = self.openList.pop() else {
            return nil
        }
        self.closedList.insert(state.state)
        return state
    }

    /// Adds a state to the open list if it has not already been processed.
    /// - Parameters:
    ///     - state: The state to add to the open list.
    ///     - distance: The estimated distance from `state` to the final state.
    ///     - moveCost: The total cost to move from the initial state to `state`.
    ///     - parent: The state to move to `state` from. `nil` if `state` is the initial state.
    internal func insert(state:State, distance:Double, moveCost:Double, parent:APathfinderNode<State>?) {
        guard !self.closedList.contains(state) else {
            return
        }
        let node = APathfinderNode(state: state)
        node.distance = distance
        node.moveCost = moveCost
        node.parent = parent
        self.openList.insert(element: node, value: node.totalCost)
    }

    /// Updates the value of `state` if it exists in the open list and `newMoveCost` is less than the current move cost.
    /// Otherwise, inserts it if it has not been processed.
    ///
    /// - Parameters:
    ///     - state: The state to update or insert.
    ///     - newMoveCost: The total cost to move from the initial state to `parentState` to `state`.
    ///     - distance: The estimated distance from `state` to the final state.
    ///     - parentState: The state to move to `state` from.
    internal func updateOrInsertIfLower(state:State, newMoveCost:Double, distance:Double, from parentState:APathfinderNode<State>?) {
        guard !self.closedList.contains(state) else {
            return
        }
        if let node = self.openList.element(for: APathfinderNode(state: state)) {
            if newMoveCost < node.moveCost {
                node.moveCost = newMoveCost
                node.parent = parentState
                self.openList.update(element: node, value: node.totalCost)
            }
        } else {
            self.insert(state: state, distance: distance, moveCost: newMoveCost, parent: parentState)
        }
    }
}
