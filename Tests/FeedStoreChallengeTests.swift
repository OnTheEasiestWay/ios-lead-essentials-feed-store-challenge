//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
    //  ***********************
    //
    //  Follow the TDD process:
    //
    //  1. Uncomment and run one test at a time (run tests with CMD+U).
    //  2. Do the minimum to make the test pass and commit.
    //  3. Refactor if needed and commit again.
    //
    //  Repeat this process until all tests are passing.
    //
    //  ***********************

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(coreDataOperation: FeedStoreCoreDataCacheOperation = CoreDataOperation()) -> FeedStore {
		// Set file url with path: `/dev/null` to use in-memory SQLite for test cases
		let url = URL(fileURLWithPath: "/dev/null")
		let bundle = Bundle.init(for: CoreDataFeedStore.self)
		let sut = try! CoreDataFeedStore(model: "FeedStore", in: bundle, storeAt: url, coreDataOperation: coreDataOperation)

		return sut
	}
	
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
	func test_retrieve_deliversFailureOnRetrievalError() {
		let sut = makeSUT(coreDataOperation: FailableRetrieveStub())

		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnFailure() {
		let sut = makeSUT(coreDataOperation: FailableRetrieveStub())

		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
	}

}

extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {

	func test_insert_deliversErrorOnInsertionError() {
		let sut = makeSUT(coreDataOperation: FailableInsertStub())

		assertThatInsertDeliversErrorOnInsertionError(on: sut)
	}

	func test_insert_hasNoSideEffectsOnInsertionError() {
		let sut = makeSUT(coreDataOperation: FailableInsertStub())

		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
	}

}

extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {

	func test_delete_deliversErrorOnDeletionError() {
//		let sut = makeSUT()
//
//		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
	}

	func test_delete_hasNoSideEffectsOnDeletionError() {
//		let sut = makeSUT()
//
//		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
	}

	// MARK: - Helpers
	class FailableRetrieveStub: FeedStoreCoreDataCacheOperation {
		let defaultOperation = CoreDataOperation();

		func retrieve(in context: NSManagedObjectContext) throws -> ManagedCache? {
			throw NSError(domain: "CoreData Fetch Error", code: -1)
		}

		func delete(in context: NSManagedObjectContext) throws {
			try defaultOperation.delete(in: context)
		}

		func insert(in context: NSManagedObjectContext) throws -> ManagedCache {
			try defaultOperation.insert(in: context)
		}
	}

	class FailableInsertStub: FeedStoreCoreDataCacheOperation {
		let defaultOperation = CoreDataOperation();

		func retrieve(in context: NSManagedObjectContext) throws -> ManagedCache? {
			try defaultOperation.retrieve(in: context)
		}

		func delete(in context: NSManagedObjectContext) throws {
			try defaultOperation.delete(in: context)
		}

		func insert(in context: NSManagedObjectContext) throws -> ManagedCache {
			throw NSError(domain: "CoreData Insert Error", code: -1)
		}
	}
}
