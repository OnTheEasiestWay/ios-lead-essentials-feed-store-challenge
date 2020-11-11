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
	let backgroundContext: NSManagedObjectContext

	public init(model name: String, in bundle: Bundle, storeAt url: URL) throws {
		persistentContainer = try NSPersistentContainer.load(model: name, in: bundle, storeAt: url)
		backgroundContext = persistentContainer.newBackgroundContext()
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		try! ManagedCache.deleteCache(in: backgroundContext)

		try! backgroundContext.save()

		completion(nil)
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let cache = try! ManagedCache.replaceCache(in: backgroundContext)
		cache.timestamp = timestamp
		cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage(from: $0, in: backgroundContext) })

		try! backgroundContext.save()

		completion(nil)
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func retrieve(completion: @escaping RetrievalCompletion) {
		if let cache = try! ManagedCache.fetchCache(in: backgroundContext) {
			completion(.found(feed: cache.local, timestamp: cache.timestamp))
		} else {
			completion(.empty)
		}
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
