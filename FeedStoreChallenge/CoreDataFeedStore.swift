//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by liuzhijin on 2020/11/10.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataOperation {
	public init() { }

	open func retrieve(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let fetchRequest = ManagedCache.fetchRequest()
		return try context.fetch(fetchRequest).first as? ManagedCache
	}

	open func delete(in context: NSManagedObjectContext) throws {
		if let cache = try retrieve(in: context) {
			context.delete(cache)
		}
	}

	open func insert(in context: NSManagedObjectContext) throws -> ManagedCache {
		return ManagedCache(context: context)
	}
}

public class CoreDataFeedStore: FeedStore {
	private enum Error: Swift.Error {
		case modelFailure
		case persistentContainerFailure(Swift.Error)
	}

	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel.model(with: modelName, in: Bundle.init(for: CoreDataFeedStore.self))

	private let persistentContainer: NSPersistentContainer
	private let backgroundContext: NSManagedObjectContext
	private let coreDataOperation: CoreDataOperation

	public init(storeAt url: URL, with coreDataOperation: CoreDataOperation = CoreDataOperation()) throws {
		guard let model = CoreDataFeedStore.model else {
			throw Error.modelFailure
		}

		do {
			persistentContainer = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, storeAt: url)
			backgroundContext = persistentContainer.newBackgroundContext()
			self.coreDataOperation = coreDataOperation
		} catch {
			throw Error.persistentContainerFailure(error)
		}
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

	private func perform(action: @escaping (NSManagedObjectContext, CoreDataOperation) -> Void) {
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
	static func load(name: String, model: NSManagedObjectModel, storeAt url: URL) throws -> NSPersistentContainer {
		let description = NSPersistentStoreDescription(url: url)
		description.shouldAddStoreAsynchronously = false

		let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)
		persistentContainer.persistentStoreDescriptions = [description]

		var capturedError: Swift.Error?
		persistentContainer.loadPersistentStores { capturedError = $1 }
		try capturedError.map { throw $0 }

		return persistentContainer
	}
}
