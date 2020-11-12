//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by liuzhijin on 2020/11/10.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public protocol FeedStoreCoreDataCacheOperation {
	func retrieve(in context: NSManagedObjectContext) throws -> ManagedCache?

	func delete(in context: NSManagedObjectContext) throws

	func insert(in context: NSManagedObjectContext) throws -> ManagedCache
}

public class CoreDataOperation: FeedStoreCoreDataCacheOperation {
	public init() { }

	public func retrieve(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let fetchRequest = ManagedCache.fetchRequest()
		return try context.fetch(fetchRequest).first as? ManagedCache
	}

	public func delete(in context: NSManagedObjectContext) throws {
		if let cache = try retrieve(in: context) {
			context.delete(cache)
		}
	}

	public func insert(in context: NSManagedObjectContext) throws -> ManagedCache {
		return ManagedCache(context: context)
	}
}

public class CoreDataFeedStore: FeedStore {
	let persistentContainer: NSPersistentContainer
	let backgroundContext: NSManagedObjectContext
	let coreDataOperation: FeedStoreCoreDataCacheOperation

	public init(model name: String, in bundle: Bundle, storeAt url: URL, coreDataOperation: FeedStoreCoreDataCacheOperation = CoreDataOperation()) throws {
		persistentContainer = try NSPersistentContainer.load(model: name, in: bundle, storeAt: url)
		backgroundContext = persistentContainer.newBackgroundContext()
		self.coreDataOperation = coreDataOperation
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context, operation in
			do {
				try operation.delete(in: context)

				try context.save()

				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context, operation in
			do {
				try operation.delete(in: context)
				let cache = try operation.insert(in: context)
				cache.timestamp = timestamp
				cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage(from: $0, in: context) })

				try context.save()

				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate threads, if needed.
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context, operation in
			do {
				if let cache = try operation.retrieve(in: context) {
					completion(.found(feed: cache.local, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	private func perform(action: @escaping (NSManagedObjectContext, FeedStoreCoreDataCacheOperation) -> Void) {
		let context = backgroundContext
		let operation = coreDataOperation
		context.perform {
			action(context, operation)
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
