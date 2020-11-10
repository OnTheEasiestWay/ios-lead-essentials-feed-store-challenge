//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by liuzhijin on 2020/11/10.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
	public init() {
		
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
