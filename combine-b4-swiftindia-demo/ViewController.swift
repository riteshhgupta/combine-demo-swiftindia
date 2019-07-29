//
//  ViewController.swift
//  combine-b4-swiftindia-demo
//
//  Created by Ritesh Gupta on 27/07/19.
//  Copyright © 2019 Ritesh Gupta. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet var decrementButton: UIButton!
    @IBOutlet var incrementButton: UIButton!
    @IBOutlet var label: UILabel!

    lazy var decrementButtonPublisher = decrementButton
        .publisher(for: [.touchUpInside])
        .map { _ in () }

    lazy var incrementButtonPublisher = incrementButton
        .publisher(for: [.touchUpInside])
        .map { _ in () }

    var cancellables: [AnyCancellable] = []

    var currentValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        demoFilter()
    }

    func demoMap() {
        decrementButtonPublisher
            .print()
            .map { self.decrementedValue() }
            .map { "\($0)" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)

        incrementButtonPublisher
            .map { self.incrementedValue() }
            .map { "\($0)" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)
    }

    func demoFilter() {
        decrementButtonPublisher
            .filter { self.currentValue > 0 }
            .map { "\(self.decrementedValue())" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)

        incrementButtonPublisher
            .filter { self.currentValue < 10 }
            .map { "\(self.incrementedValue())" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)
    }
    
    func demoFlatMap() {
        decrementButtonPublisher
            .map { "\(self.decrementedValue())" }
            .flatMap(Just.init)
            .assign(to: \.text, on: label)
            .store(in: &cancellables)

        incrementButtonPublisher
            .map { "\(self.incrementedValue())" }
            .flatMap(Just.init)
            .assign(to: \.text, on: label)
            .store(in: &cancellables)
    }

    func demoDebounce() {
        decrementButtonPublisher
            .debounce(for: 2, scheduler: DispatchQueue.main)
            .map { "\(self.decrementedValue())" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)

        incrementButtonPublisher
            .debounce(for: 2, scheduler: DispatchQueue.main)
            .map { "\(self.incrementedValue())" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)
    }

    func demoDelay() {
        decrementButtonPublisher
            .delay(for: 2, scheduler: DispatchQueue.main)
            .map { "\(self.decrementedValue())" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)

        incrementButtonPublisher
            .delay(for: 2, scheduler: DispatchQueue.main)
            .map { "\(self.incrementedValue())" }
            .assign(to: \.text, on: label)
            .store(in: &cancellables)
    }

    func demoMerge() {
        let p1 = decrementButtonPublisher
            .map { "\(self.decrementedValue())" }
            .eraseToAnyPublisher()

        let p2 = incrementButtonPublisher
            .map { "\(self.incrementedValue())" }
            .eraseToAnyPublisher()

        Publishers
            .MergeMany([p1, p2])
            .map(Optional.init)
            .assign(to: \.text, on: label)
            .store(in: &cancellables)
    }

    func demoAssign() {
        let p1 = decrementButtonPublisher
            .map { "\(self.decrementedValue())" }
            .eraseToAnyPublisher()

        let p2 = incrementButtonPublisher
            .map { "\(self.incrementedValue())" }
            .eraseToAnyPublisher()

        let sub = label.assign(\.text)

        Publishers
            .MergeMany([p1, p2])
            .map(Optional.init)
            .assertNoFailure()
            .subscribe(sub)
    }

    func demoOperator() {
        let p1 = decrementButtonPublisher
            .map { "\(self.decrementedValue())" }
            .eraseToAnyPublisher()

        let p2 = incrementButtonPublisher
            .map { "\(self.incrementedValue())" }
            .eraseToAnyPublisher()

        label.assign(\.text) <~ Publishers.MergeMany([p1, p2]).map(Optional.init)
    }

    func demoThreading() {
        let p1 = decrementButtonPublisher
            .map { "\(self.decrementedValue())" }
            .eraseToAnyPublisher()

        let p2 = incrementButtonPublisher
            .map { "\(self.incrementedValue())" }
            .eraseToAnyPublisher()

        let sub = label.assign(\.text)

        Publishers
            .MergeMany([p1, p2])
            .map(Optional.init)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .subscribe(sub)
    }

    func decrementedValue() -> Int {
        currentValue -= 1
        return currentValue
    }

    func incrementedValue() -> Int {
        currentValue += 1
        return currentValue
    }
}
