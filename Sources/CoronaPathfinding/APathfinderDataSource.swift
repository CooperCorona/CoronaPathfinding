
/// Represents moving from one state to `state` at the associated cost.
public struct StateTransition<State> {
    /// The state to move to.
    public let state:State
    /// The cost of moving to this state.
    public let moveCost:Double
}

/// Provides states and costs of moving between them to a `APathfinder` instance.
public protocol APathfinderDataSource {
    /// The type of state the pathfinder is traversing.
    associatedtype State: Hashable

    /// The states that can be reached from `state`. Must be deterministic. The same `state`
    /// must always return the same state transitions.
    ///
    /// - Parameter state: The state to find the neighboring states of.
    /// - Returns: An array of state transition objects. Each represents a state that can be
    /// accessed from `state` and the cost of moving from `state` to the new state.
    func adjacentStates(to state:State) -> [StateTransition<State>]

    /// The distance between `firstState` and `secondState`. May be approximate.
    ///
    /// - Parameter firstState: The first state to calculate the disatnce between.
    /// - Parameter secondState: The second state to calculate the distance between.
    /// - Returns: The approximate distance between `firstState` and `secondState`. If
    /// the distance is higher than the true distance, `APathfinder` approaches greedy best first search.
    /// If the distance is lower than the true distance, `APathfinder` approaches Dijkstra's algorithm.
    func distance(between firstState:State, and secondState:State) -> Double

}
