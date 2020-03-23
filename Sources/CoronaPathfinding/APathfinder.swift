

/// Uses A* pathfinding to calculate the optimal path between two states in a graph, providing by `dataSource`.
public class APathfinder<DataSource: APathfinderDataSource>: Pathfinding {

    /// The state the pathfinding operates on.
    public typealias State = DataSource.State

    /// Provides information about the graph to the pathfinder.
    private let dataSource:DataSource

    /// Initializes an `APathfinder` with the given data source.
    ///
    /// - Parameter dataSource: Provides information on states to the pathfinder.
    public init(dataSource:DataSource) {
        self.dataSource = dataSource
    }

    /// Calculates the optimal path between `initialState` and `finalState`. `findPath` may
    /// be called with different states, even while another invocation is running, without interfering
    /// with calls.
    ///
    /// - Parameter initialState: The initial state.
    /// - Parameter finalState: The state to reach from `initialState`.
    /// - Returns: An array of states representing the optimal path from `initialState` to `toState`, in order.
    /// The first element is `initialState` and the last element is `finalState`.
    /// - Throws: `PathfindingError.impossiblePath` if there is no path from `initialState` to `finalState`.
    public func findPath(from initialState: State, to finalState: State) throws -> [State] {
        let stateProcessor = APathfinderList<State>()
        let distance = self.dataSource.distance(between: initialState, and: finalState)
        stateProcessor.insert(state: initialState, distance: distance, moveCost: 0, parent: nil)
        while let top = stateProcessor.nextState() {
            if top.state == finalState {
                return self.constructPath(from: top)
            }
            self.process(node: top, finalState: finalState, stateProcessor: stateProcessor)
        }
        throw PathfindingError.impossiblePath
    }

    /// Constructs a path to `state` to the ancestor of `state` with no parent.
    ///
    /// - Parameter state: The final state in the path.
    /// - Returns: The path from the initial state to `state`, in order.
    private func constructPath(from state:APathfinderNode<State>) -> [State] {
        var state = state
        var path = [state.state]
        while let parent = state.parent {
            path.append(parent.state)
            state = parent
        }
        return path.reversed()
    }

    /// Processes the neighbors to `node`, adding them or updating them as necessary.
    ///
    /// - Parameters:
    ///     - node: The node wrapping the state to process.
    ///     - finalState: The state to find a path to.
    ///     - stateProcessor: Contains the processed and unprocessed states.
    private func process(node:APathfinderNode<State>, finalState:State, stateProcessor:APathfinderList<State>) {
        let adjacentStates = self.dataSource.adjacentStates(to: node.state)
        for adjacentState in adjacentStates {
            let distance = self.dataSource.distance(between: adjacentState.state, and: finalState)
            let newCost = node.moveCost + adjacentState.moveCost
            stateProcessor.updateOrInsertIfLower(state: adjacentState.state, newMoveCost: newCost, distance: distance, from: node)
        }
    }

}
