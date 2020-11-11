//
//  ManagedCache.swift
//  FeedStoreChallenge
//
//  Created by liuzhijin on 2020/11/10.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
	static func fetchCache(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let fetchRequest = ManagedCache.fetchRequest()
		return try context.fetch(fetchRequest).first as? ManagedCache
	}

	static func deleteCache(in context: NSManagedObjectContext) throws {
		if let cache = try ManagedCache.fetchCache(in: context) {
			context.delete(cache)
		}
	}

	static func replaceCache(in context: NSManagedObjectContext) throws -> ManagedCache {
		try ManagedCache.deleteCache(in: context)

		return ManagedCache(context: context)
	}
}
