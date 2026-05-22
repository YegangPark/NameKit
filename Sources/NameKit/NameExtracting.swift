//
//  NameExtracting.swift
//  NameKit
//
//  Created by Ye Park on 5/6/26.
//


// MARK: - Protocol
// 💡 프로토콜은 격리를 강제하지 않습니다.
// MainActor가 필요한 구현체(NameExtractor)만 개별적으로 격리합니다.
public protocol NameExtracting: Sendable {
    @MainActor func extract() -> String?
}

// MARK: - Mock
public final class MockNameExtractor: NameExtracting, @unchecked Sendable {
    public var stubbedName: String?
    
    public init(stubbedName: String?) {
        self.stubbedName = stubbedName
    }
    
    @MainActor
    public func extract() -> String? {
        return stubbedName
    }
}
