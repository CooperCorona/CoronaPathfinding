//
//  Pathfinding.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 3/21/20.
//

import Foundation

/// Errors occurring when calculating a path.
public enum PathfindingError: Error {
    /// A path could not be found with the given constraints.
    case impossiblePath
}

/// Can calculate the a path between two states of a given type.
public protocol Pathfinding {
    /// The type to find paths between.
    associatedtype State

    /// Determines a path from `fromState` to `toState`. Throws a `PathfindingError.impossiblePath` exception if no path is found.
    func findPath(from fromState:State, to finalState:State) throws -> [State]
}
