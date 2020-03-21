//
//  PriorityQueue.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 3/20/20.
//

import Foundation

/// The value of an element in a `PriorityQueue`. Stores the index the element is at. The owner is responsible for updating the index.
fileprivate class PriorityQueueNode<Value>: CustomStringConvertible {
    fileprivate var value:Value
    fileprivate var index:Int

    fileprivate var description: String { return "PriorityQueueNode(\(value)@\(index))" }

    fileprivate init(value:Value, index:Int) {
        self.value = value
        self.index = index
    }
}

/// Maintains a list of elements. Inserting, updating, and accessing the head are all `O(log(n))`.
internal class PriorityQueue<Key: Hashable, Value>: CustomStringConvertible {
    /// The elements in the queue, arranged as a heap.
    private var heap:[Key] = []
    /// Maps the elements in `heap` to their index. This allows updating to occur in `O(log(n))` at the cost of `O(n)` extra space.
    private var heapIndices:[Key:PriorityQueueNode<Value>] = [:]
    /// Returns true if the first argument has higher priority than the second argument, false otherwise.
    private let comparator:(Value, Value) -> Bool

    internal var description: String { return "\(self.heap)" }

    internal init(comparator:@escaping (Value, Value) -> Bool) {
        self.comparator = comparator
    }

    internal func insert(element:Key, value:Value) {
        self.heap.append(element)
        self.heapIndices[element] = PriorityQueueNode(value: value, index: self.heap.count - 1)
        self.heapifyUp(at: self.heap.count - 1)
    }

    internal func peek() -> Key? {
        return self.heap.first
    }

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

    private func swap(index index1:Int, withIndex index2:Int) {
        guard let node1 = self.heapIndices[self.heap[index1]], let node2 = self.heapIndices[self.heap[index2]] else {
            return
        }
        let temp = self.heap[index1]
        self.set(key: self.heap[node2.index], value: node2.value, at: index1)
        self.set(key: temp, value: node1.value, at: index2)
    }

    private func set(key:Key, value:Value, at index:Int) {
        self.heap[index] = key
        self.heapIndices[key]?.value = value
        self.heapIndices[key]?.index = index
    }

    private func value(at index:Int) -> Value? {
        guard index < self.heap.count else {
            return nil
        }
        return self.heapIndices[self.heap[index]]?.value
    }

    private func parentIndex(of index:Int) -> Int {
        return (index - 1) / 2
    }

    private func leftIndex(of index:Int) -> Int {
        return index * 2 + 1
    }

    private func rightIndex(of index:Int) -> Int {
        return index * 2 + 2
    }

}
