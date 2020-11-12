//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by liuzhijin on 2020/11/10.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var url: URL
	@NSManaged var location: String?
	@NSManaged var imageDescription: String?
	@NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
	convenience init(from local: LocalFeedImage, in context: NSManagedObjectContext) {
		self.init(context: context)

		self.id = local.id
		self.url = local.url
		self.location = local.location
		self.imageDescription = local.description
	}
}
