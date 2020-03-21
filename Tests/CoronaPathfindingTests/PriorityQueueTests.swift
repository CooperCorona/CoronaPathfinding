import XCTest
@testable import CoronaPathfinding

final class PriorityQueueTests: XCTestCase {

    func testEmpty() {
        let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
        XCTAssertEqual(priorityQueue.peek(), nil)
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testOne() {
        let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
        priorityQueue.insert(element: 1, value: 1)
        XCTAssertEqual(priorityQueue.peek(), 1)
        XCTAssertEqual(priorityQueue.pop(), 1)
        XCTAssertEqual(priorityQueue.peek(), nil)
    }

    func testTwoInOrder() {
        let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
        priorityQueue.insert(element: 1, value: 1)
        priorityQueue.insert(element: 2, value: 2)
        XCTAssertEqual(priorityQueue.pop(), 1)
        XCTAssertEqual(priorityQueue.pop(), 2)
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testTwoInReverseOrder() {
        let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
        priorityQueue.insert(element: 2, value: 2)
        priorityQueue.insert(element: 1, value: 1)
        XCTAssertEqual(priorityQueue.pop(), 1)
        XCTAssertEqual(priorityQueue.pop(), 2)
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testManyInOrder() {
        let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
        priorityQueue.insert(element: 1, value: 1)
        priorityQueue.insert(element: 2, value: 2)
        priorityQueue.insert(element: 3, value: 3)
        priorityQueue.insert(element: 4, value: 4)
        priorityQueue.insert(element: 5, value: 5)
        XCTAssertEqual(priorityQueue.pop(), 1)
        XCTAssertEqual(priorityQueue.pop(), 2)
        XCTAssertEqual(priorityQueue.pop(), 3)
        XCTAssertEqual(priorityQueue.pop(), 4)
        XCTAssertEqual(priorityQueue.pop(), 5)
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testManyInReverseOrder() {
        let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
        priorityQueue.insert(element: 5, value: 5)
        priorityQueue.insert(element: 4, value: 4)
        priorityQueue.insert(element: 3, value: 3)
        priorityQueue.insert(element: 2, value: 2)
        priorityQueue.insert(element: 1, value: 1)
        XCTAssertEqual(priorityQueue.pop(), 1)
        XCTAssertEqual(priorityQueue.pop(), 2)
        XCTAssertEqual(priorityQueue.pop(), 3)
        XCTAssertEqual(priorityQueue.pop(), 4)
        XCTAssertEqual(priorityQueue.pop(), 5)
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testManyOutOfOrder() {
        let inOrderElements = [1, 2, 3, 4, 5]
        self.testPermutations(elements: inOrderElements, callback: { elements in
            let priorityQueue = PriorityQueue<Int, Int>(comparator: <)
            for element in elements {
                priorityQueue.insert(element: element, value: element)
            }
            var output:[Int] = []
            while let head = priorityQueue.pop() {
                output.append(head)
            }
            XCTAssertEqual(output, inOrderElements)
        })
    }

    func testUpdateOne() {
        let priorityQueue = PriorityQueue<String, Int>(comparator: <)
        priorityQueue.insert(element: "A", value: 1)
        priorityQueue.update(element: "A", value: 2)
        XCTAssertEqual(priorityQueue.peek(), "A")
        XCTAssertEqual(priorityQueue.pop(), "A")
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testUpdateFirstTwo() {
        let priorityQueue = PriorityQueue<String, Int>(comparator: <)
        priorityQueue.insert(element: "A", value: 1)
        priorityQueue.insert(element: "B", value: 2)
        priorityQueue.update(element: "A", value: 3)
        XCTAssertEqual(priorityQueue.pop(), "B")
        XCTAssertEqual(priorityQueue.pop(), "A")
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testUpdateLastTwo() {
        let priorityQueue = PriorityQueue<String, Int>(comparator: <)
        priorityQueue.insert(element: "A", value: 1)
        priorityQueue.insert(element: "B", value: 2)
        priorityQueue.update(element: "B", value: 3)
        XCTAssertEqual(priorityQueue.pop(), "A")
        XCTAssertEqual(priorityQueue.pop(), "B")
        XCTAssertEqual(priorityQueue.pop(), nil)
    }

    func testUpdateManyOutOfOrder() {
        let inOrderElements = ["A", "B", "C", "D", "E"]
        self.testPermutations(elements: inOrderElements, callback: { elements in
            for element in elements {
                for newValue in [-100, 100] {
                    var values = ["A": 1, "B": 2, "C": 3, "D": 4, "E": 5]
                    let priorityQueue = PriorityQueue<String, Int>(comparator: <)
                    for element in elements {
                        priorityQueue.insert(element: element, value: values[element]!)
                    }
                    values[element] = newValue
                    priorityQueue.update(element: element, value: newValue)
                    var output:[String] = []
                    while let head = priorityQueue.pop() {
                        output.append(head)
                    }
                    let expected = values.sorted() { $0.1 < $1.1 } .map() { $0.0 }
                    XCTAssertEqual(output, expected)
                }
            }
        })
    }

    private func testPermutations<T>(elements:[T], callback:([T]) -> Void) {
        var elements = elements
        self.generatePermutations(elements: &elements, count: elements.count, callback: callback)
    }

    private func generatePermutations<T>(elements:inout [T], count:Int, callback:([T]) -> Void) {
        if count == 1 {
            callback(elements)
            return
        }
        self.generatePermutations(elements: &elements, count: count - 1, callback: callback)
        for i in 0..<count-1 {
            let swapIndex = i % 2 == 0 ? i : 0
            elements.swapAt(swapIndex, count - 1)
            self.generatePermutations(elements: &elements, count: count - 1, callback: callback)
        }
    }


    static var allTests = [
        ("testEmpty", testEmpty),
        ("testOne", testOne),
        ("testTwoInOrder", testTwoInOrder),
        ("testTwoInReverseOrder", testTwoInReverseOrder),
        ("testManyInOrder", testManyInOrder),
        ("testManyInReverseOrder", testManyInReverseOrder),
        ("testManyOutOfOrder", testManyOutOfOrder),
    ]
}
