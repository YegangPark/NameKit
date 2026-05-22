//
//  NameExtractor.swift
//  NameKit
//
//  Created by Ye Park on 5/6/26.
//


import NaturalLanguage
import UIKit

// MARK: - Implementation
public final class NameExtractor: NameExtracting {
    
    public init() {}
    
    // 💡 UIDevice.current.name 접근만 MainActor가 필요하므로 메서드 레벨에서 격리합니다.
    @MainActor
    public func extract() -> String? {
        let rawDeviceName = UIDevice.current.name
        return parse(rawDeviceName)
    }
    
    // 💡 순수 연산 함수: MainActor 격리 불필요, 어디서든 호출 가능
    func parse(_ deviceName: String) -> String? {
        let genericNames = ["iPhone", "iPad", "Mac", "Apple Watch", "AirPods", "Apple TV"]
        if genericNames.contains(where: { deviceName == $0 || deviceName.hasPrefix("\($0) ") }) {
            return nil
        }

        var cleanString = deviceName
        let suffixes = [
            "의 iPhone", "의 아이폰", "의 iPad", "의 아이패드", "의 MacBook", "의 Mac",
            "'s iPhone", "'s iPad", "'s MacBook", "'s Mac", "'s Phone"
        ]

        var suffixMatched = false
        for suffix in suffixes {
            if let range = cleanString.range(of: suffix, options: [.caseInsensitive, .backwards]) {
                cleanString = String(cleanString[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                suffixMatched = true
                break
            }
        }

        // 💡 접미사가 매칭된 경우, 사용자 이름일 확률이 매우 높으므로 길이를 15자까지 허용합니다.
        if suffixMatched && !cleanString.isEmpty && cleanString.count <= 15 {
            return cleanString
        }

        // 접미사 매칭은 안 되었지만 짧은 문자열인 경우 이름일 수 있으므로 NLP 시도
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = cleanString

        var extractedName: String?
        let range = cleanString.startIndex..<cleanString.endIndex

        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: [.omitWhitespace, .omitPunctuation, .joinNames]) { tag, tokenRange in
            if tag == .personalName {
                extractedName = String(cleanString[tokenRange])
                return false
            }
            return true
        }

        // NLP 결과도 없는데 문자열이 매우 짧다면(예: "강", "Park") 이름으로 간주
        if extractedName == nil && cleanString.count > 0 && cleanString.count <= 4 {
            return cleanString
        }

        return extractedName
    }
}
