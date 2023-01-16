//
//  HTTPHeaders.swift
//
//  Created by Waqar Malik on 1/14/23.
//  Copyright © 2020 Waqar Malik All rights reserved.
//

import Foundation

public struct HTTPHeaders {
	private(set) var headers: [HTTPHeader] = []

	public init() {}

	public init(_ headers: [HTTPHeader]) {
		headers.forEach { update($0) }
	}

	public init(_ dictionary: [String: String]) {
		dictionary.forEach { (key: String, value: String) in
			update(name: key, value: value)
		}
	}

	@inlinable
	public mutating func update(name: String, value: String) {
		update(HTTPHeader(name: name, value: value))
	}

	public mutating func update(_ header: HTTPHeader) {
		guard let index = headers.firstIndex(of: header.name) else {
			headers.append(header)
			return
		}

		headers.replaceSubrange(index ... index, with: [header])
	}

	@discardableResult
	public func add(name: String, value: String) -> Self {
		var headers = self
		headers.update(HTTPHeader(name: name, value: value))
		return headers
	}

	@discardableResult
	public func add(_ header: HTTPHeader) -> Self {
		var headers = self
		headers.update(header)
		return headers
	}

	@discardableResult
	public mutating func remove(name: String) -> HTTPHeader? {
		guard let index = headers.firstIndex(of: name) else {
			return nil
		}

		return headers.remove(at: index)
	}

	public mutating func sort() {
		headers.sort { $0.name.lowercased() < $1.name.lowercased() }
	}

	public func sorted() -> Self {
		var headers = self
		headers.sort()
		return headers
	}

	public func value(for name: String) -> String? {
		guard let index = headers.firstIndex(of: name) else {
			return nil
		}

		return headers[index].value
	}

	public subscript(_ name: String) -> String? {
		get {
			value(for: name)
		}

		set {
			if let newValue {
				update(name: name, value: newValue)
			} else {
				remove(name: name)
			}
		}
	}

	public var dictionary: [String: String] {
		headers.reduce([:]) { partialResult, header in
			var result = partialResult
			result[header.name] = header.value
			return result
		}
	}
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: (String, String)...) {
		self.headers = elements.map { name, value in
			HTTPHeader(name: name, value: value)
		}
	}
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: HTTPHeader...) {
		self.init(elements)
	}
}

extension HTTPHeaders: Sequence {
	public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
		headers.makeIterator()
	}
}

extension HTTPHeaders: Collection {
	public var startIndex: Int {
		headers.startIndex
	}

	public var endIndex: Int {
		headers.endIndex
	}

	public subscript(position: Int) -> HTTPHeader {
		headers[position]
	}

	public func index(after i: Int) -> Int {
		headers.index(after: i)
	}
}

extension Array where Element == HTTPHeader {
	func firstIndex(of name: String) -> Int? {
		let lowercasedName = name.lowercased()
		return firstIndex {
			$0.name.lowercased() == lowercasedName
		}
	}
}
