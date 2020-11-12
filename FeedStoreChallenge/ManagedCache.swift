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
public class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
	var local: [LocalFeedImage] {
		return feed
			.compactMap { $0 as? ManagedFeedImage }
			.map { LocalFeedImage(id: $0.id,
								  description: $0.imageDescription,
								  location: $0.location,
								  url: $0.url)}
	}
}
