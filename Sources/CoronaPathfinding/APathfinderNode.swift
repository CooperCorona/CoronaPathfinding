//
//  APathfinderNode.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 3/22/20.
//

import Foundation

/// Wraps a state with metadata needed by `APathfinder` to calculate a path.
internal class APathfinderNode<State: Hashable>: Hashable {
    /// The state associated with this node.
    internal let state:State
    /// The distance between `state` and the desired final state.
    internal var distance:Double = 0.0
    /// The total cost of moving from the initial state to `state`.
    internal var moveCost:Double = 0.0
    /// The total cost of moving from `state` to the final state, including the distance needed to
    /// reach `state` from the initial state and the remaining distance needed to reach the final state.
    internal var totalCost:Double { return self.distance + self.moveCost }
    /// The state directly before this one in the path. If `nil`, this is the first state in the path.
    internal var parent:APathfinderNode<State>? = nil

    /// Initializes an `APathfinderNode` wrapping the given state.
    ///
    /// - Parameter state: The state associated with this node.
    internal init(state:State) {
        self.state = state
    }

    /// Computes the hash value of this node, based on `state`. No other properties
    /// are included in the hash.
    ///
    /// - Parameter hasher: The hasher to hash into.
    internal func hash(into hasher: inout Hasher) {
        self.state.hash(into: &hasher)
    }
}

/// Determines if two `APathfinderNode` instances refer to the same state. No other properties are considered.
///
/// - Parameter lhs: The argument on the left hand side of the operator.
/// - Parameter rhs: The argument on the right hand side of the operator.
/// - Returns; `true` if the underlying states are equal, `false` otherwise.
internal func ==<State: Hashable>(lhs:APathfinderNode<State>, rhs:APathfinderNode<State>) -> Bool {
    return lhs.state == rhs.state
}
