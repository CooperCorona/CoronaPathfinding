//
//  PriorityQueue.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 3/20/20.
//

import Foundation

/// The value of an element in a `PriorityQueue`. Stores the index the element is at.
/// The owner is responsible for updating the index.
fileprivate class PriorityQueueNode<Value>: CustomStringConvertible {
    /// The priority of the element at `index` in the priority queue.
    fileprivate var value:Value
    /// The current index of the element in the priority queue.
    fileprivate var index:Int

    /// A textual description of this element.
    fileprivate var description: String { return "PriorityQueueNode(\(value)@\(index))" }

    /// Initializes a `PriorityQueueNode` with the given priority and current index in the queue.
    ///
    /// - Parameter value: The priority of the element in the queue.
    /// - Parameter index: The current index of the element in the queue.
    fileprivate init(value:Value, index:Int) {
        self.value = value
        self.index = index
    }
}

/// Maintains a list of elements. Inserting, updating, and accessing the head are all `O(log(n))`.
/// Elements in a `PriorityQueue` must be unique. After any queue operation, the head of
/// the queue remains the highest priority element.
internal class PriorityQueue<Key: Hashable, Value>: CustomStringConvertible {
    /// The elements in the queue, arranged as a heap.
    private var heap:[Key] = []
    /// Maps the elements in `heap` to their index and value. This allows updating to occur in `O(log(n))`
    /// at the cost of `O(n)` extra space.
    private var heapIndices:[Key:PriorityQueueNode<Value>] = [:]
    /// Returns true if the first argument has higher priority than the second argument, false otherwise.
    private let comparator:(Value, Value) -> Bool
    /// DIsplays the underlying heap as a string.
    internal var description: String { return "\(self.heap)" }

    /// Initializes a `PriorityQueue` with the given comparator.
    ///
    /// - Parameter comparator: Determines which elements are higher priority. Returns `true`
    /// if the first value has higher priority than the second element, `false` otherwise.
    internal init(comparator:@escaping (Value, Value) -> Bool) {
        self.comparator = comparator
    }

    /// Inserts `element` into the priority queue with priority `value`. `element` must not already be in the queue.
    ///
    /// - Parameter element: The element to insert into the queue. Cannot already be in the queue.
    internal func insert(element:Key, value:Value) {
        self.heap.append(element)
        self.heapIndices[element] = PriorityQueueNode(value: value, index: self.heap.count - 1)
        self.heapifyUp(at: self.heap.count - 1)
    }

    /// - Returns: The highest priority element in the queue, or `nil` if the queue is empty.
    internal func peek() -> Key? {
        return self.heap.first
    }

    /// Removes the highest priority element in the queue.
    ///
    /// - Returns: The highest priority element in the queue, or `nil` if the queue is empty.
    internal func pop() -> Key? {
        guard self.heap.count > 0 else {
            return nil
        }
        self.swap(index: 0, withIndex: self.heap.count - 1)
        let element = self.heap.popLast()
        if let element = element {
            self.heapIndices[element] = nil
        }
        self.heapifyDown(at: 0)
        return element
    }

    /// Updates the priority of `element`. If `element` is not in the queue, does nothing.
    ///
    /// - Parameter element: The element to update.
    /// - Parameter value: The new priority of the element.
    internal func update(element:Key, value:Value) {
        guard let node = self.heapIndices[element] else {
            return
        }
        node.value = value
        let index = node.index
        // After a single heapify call, either nothing will happen or the heap will
        // be in a correct configuration, causing the next call to do nothing.
        self.heapifyUp(at: node.index)
        self.heapifyDown(at: index)
    }

    /// Gets the element in the queue equal to `element`. This is useful when `Key` is a class it is important
    /// that instances are identical instead of just equal.
    ///
    /// - Parameter element: The element to find in the queue, by equality.
    /// - Returns: The element in the queue equal to `element`, or `nil` if `element` is  not in the queue.
    internal func element(for element:Key) -> Key? {
        guard let index = self.heapIndices.index(forKey: element) else {
            return nil
        }
        return self.heapIndices[index].0
    }

    /// Moves the element at `index` up the queue until the heap property is restored.
    ///
    /// - Parameter index: The index of the element to heapify up.
    private func heapifyUp(at index:Int) {
        guard index > 0 else {
            return
        }
        let parentIndex = self.parentIndex(of: index)
        guard let currentValue = self.value(at: index), let parentValue = self.value(at: parentIndex) else {
            return
        }
        if self.comparator(currentValue, parentValue) {
            self.swap(index: index, withIndex: parentIndex)
            self.heapifyUp(at: parentIndex)
        }
    }

    /// Moves the element at `index` down the queue until the heap property is restored.
    ///
    /// - Parameter index: The index of the element to heapify down.
    private func heapifyDown(at index:Int) {
        guard let currentValue = self.value(at: index) else {
            return
        }
        let leftIndex = self.leftIndex(of: index)
        let rightIndex = self.rightIndex(of: index)
        let lowestIndex:Int
        let lowestValue:Value
        switch (self.value(at: leftIndex), self.value(at: rightIndex)) {
        case (let leftValue?, let rightValue?):
            if self.comparator(leftValue, rightValue) {
                lowestIndex = leftIndex
                lowestValue = leftValue
            } else {
                lowestIndex = rightIndex
                lowestValue = rightValue
            }
        case (let leftValue?, nil):
            lowestIndex = leftIndex
            lowestValue = leftValue
        case (nil, let rightValue?):
            lowestIndex = rightIndex
            lowestValue = rightValue
        default:
            return
        }
        if self.comparator(lowestValue, currentValue) {
            self.swap(index: index, withIndex: lowestIndex)
            self.heapifyDown(at: lowestIndex)
        }
    }

    /// Swaps the elements at `index1` and `index2` in the queue.
    ///
    /// - Parameter index1: The index of the first element to swap.
    /// - Parameter index2: The index of the second element to swap.
    private func swap(index index1:Int, withIndex index2:Int) {
        guard let node1 = self.heapIndices[self.heap[index1]], let node2 = self.heapIndices[self.heap[index2]] else {
            return
        }
        let temp = self.heap[index1]
        self.set(key: self.heap[node2.index], value: node2.value, at: index1)
        self.set(key: temp, value: node1.value, at: index2)
    }

    /// Sets the element at `index` to `key` and sets the priority to `value`.
    ///
    /// - Parameter key: The element to set at `index`.
    /// - Parameter value: The priority of `key`.
    /// - Parameter index: The index in the heap to set to `key`.
    private func set(key:Key, value:Value, at index:Int) {
        self.heap[index] = key
        self.heapIndices[key]?.value = value
        self.heapIndices[key]?.index = index
    }

    /// Returns the value of the element at `index` or `nil` if `index` is out of bounds.
    ///
    /// - Parameter index: The index of the element to find the value of.
    /// - Returns: The value of the element at `index` or `nil` if the `index` is out of bounds.
    private func value(at index:Int) -> Value? {
        guard index < self.heap.count else {
            return nil
        }
        return self.heapIndices[self.heap[index]]?.value
    }

    /// Returns the index of the parent element to the element at `index`. The caller is responsible
    /// for checking if the index is valid.
    ///
    /// - Parameter index: The index to find the parent of.
    /// - Returns: The index of the parent element to the element at `index`.
    private func parentIndex(of index:Int) -> Int {
        return (index - 1) / 2
    }

    /// Returns the index of the left child to the element at `index`. The caller is responsible
    /// for checking if the index is valid.
    ///
    /// - Parameter index: The index to find the left child of.
    /// - Returns: The index of the left child to the element at `index`.
    private func leftIndex(of index:Int) -> Int {
        return index * 2 + 1
    }

    /// Returns the index of the right child to the element at `index`. The caller is responsible
    /// for checking if the index is valid.
    ///
    /// - Parameter index: The index to find the right child of.
    /// - Returns: The index of the right child to the element at `index`.
    private func rightIndex(of index:Int) -> Int {
        return index * 2 + 2
    }

}
