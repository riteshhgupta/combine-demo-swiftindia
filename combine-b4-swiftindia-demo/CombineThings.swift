//
//  CombineThings.swift
//  combine-b4-swiftindia-demo
//
//  Created by Ritesh Gupta on 27/07/19.
//  Copyright © 2019 Ritesh Gupta. All rights reserved.
//

import Foundation
import UIKit
import Combine

extension UIControl {
    class Publisher: Combine.Publisher {
        typealias Output = UIControl.Event
        typealias Failure = Never
        let subject = PassthroughSubject<Output, Failure>()

        init(control: UIControl, events: [UIControl.Event]) {
            events.forEach { control.addTarget(self, action: #selector(actionHandler), for: $0) }
        }
        @objc func actionHandler(sender: UIControl, forEvent event: UIControl.Event) {
            subject.send(event)
        }
        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            subject.receive(subscriber: subscriber)
        }
    }
}

extension UIControl {
    func publisher(for events: [UIControl.Event]) -> AnyPublisher<UIControl.Event, Never> {
        return UIControl.Publisher(control: self, events: events)
            .eraseToAnyPublisher()
    }
}

protocol UIKitCombinable {}

extension UIKitCombinable {
    func assign<Input>(_ keyPath: ReferenceWritableKeyPath<Self, Input>) -> AnySubscriber<Input, Never> {
        return AnySubscriber(Subscribers.Assign(object: self, keyPath: keyPath))
    }
}

extension NSObject: UIKitCombinable {}

precedencegroup BindingPrecedence {
    associativity: right
    higherThan: AssignmentPrecedence
}

infix operator <~ : BindingPrecedence

public func <~ <Value, S: Subscriber, P: Publisher>(subscriber: S, publisher: P)
    where S.Input == Value, P.Output == Value, S.Failure == P.Failure {
    publisher.subscribe(subscriber)
}

