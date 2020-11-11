//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by liuzhijin on 2020/11/10.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	let persistentContainer: NSPersistentContainer

	public init(model name: String, in bundle: Bundle, storeAt url: URL) throws {
		persistentContainer = try NSPersistentContainer.load(model: name, in: bundle, storeAt: url)
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}

extension NSManagedObjectModel {
	static func model(with name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
}


extension NSPersistentContainer {
	enum LoadingError: Swift.Error {
		case modelFailure
		case persistentContainerFailure(Swift.Error)
	}

	static func load(model name: String, in bundle: Bundle, storeAt url: URL) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.model(with: name, in: bundle) else {
			throw LoadingError.modelFailure
		}

		let description = NSPersistentStoreDescription(url: url)
		// Make sure `loadPersistentStores`'s completion is called synchronously
		description.shouldAddStoreAsynchronously = false

		let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)
		persistentContainer.persistentStoreDescriptions = [description]

		var capturedError: Swift.Error?
		persistentContainer.loadPersistentStores { capturedError = $1 }
		try capturedError.map { throw LoadingError.persistentContainerFailure($0) }

		return persistentContainer
	}
}