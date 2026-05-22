//
//  NameExtractorTests.swift
//  NameKitTests
//
//  Created by Ye Park on 5/6/26.
//

import Testing
@testable import NameKit

// MARK: - NameExtractor.parse() Tests
// parse()는 nonisolated이므로 MainActor 없이 직접 테스트 가능

@Suite("NameExtractor Tests")
struct NameExtractorTests {

    let sut = NameExtractor()

    // MARK: - 1. Generic Device Names → nil

    @Suite("Generic device names should return nil")
    struct GenericDeviceNames {
        let sut = NameExtractor()

        @Test("Exact generic names", arguments: [
            "iPhone", "iPad", "Mac", "Apple Watch", "AirPods", "Apple TV"
        ])
        func exactGenericName(name: String) {
            #expect(sut.parse(name) == nil)
        }

        @Test("Generic name with model suffix", arguments: [
            "iPhone 15 Pro Max", "iPhone 16", "iPad Pro 12.9",
            "iPad mini", "Mac Studio", "Apple Watch Ultra 2",
            "AirPods Pro", "Apple TV 4K"
        ])
        func genericNameWithModelSuffix(name: String) {
            #expect(sut.parse(name) == nil)
        }
    }

    // MARK: - 2. Korean Suffix (의 ~)

    @Suite("Korean suffix patterns")
    struct KoreanSuffixPatterns {
        let sut = NameExtractor()

        @Test("의 iPhone suffix")
        func koreanIPhoneSuffix() {
            #expect(sut.parse("예강의 iPhone") == "예강")
        }

        @Test("의 아이폰 suffix")
        func koreanIPhoneKoreanSuffix() {
            #expect(sut.parse("예강의 아이폰") == "예강")
        }

        @Test("의 iPad suffix")
        func koreanIPadSuffix() {
            #expect(sut.parse("민수의 iPad") == "민수")
        }

        @Test("의 아이패드 suffix")
        func koreanIPadKoreanSuffix() {
            #expect(sut.parse("민수의 아이패드") == "민수")
        }

        @Test("의 MacBook suffix")
        func koreanMacBookSuffix() {
            #expect(sut.parse("지현의 MacBook") == "지현")
        }

        @Test("의 Mac suffix")
        func koreanMacSuffix() {
            #expect(sut.parse("수진의 Mac") == "수진")
        }

        @Test("Full Korean name with suffix")
        func fullKoreanName() {
            #expect(sut.parse("박예강의 iPhone") == "박예강")
        }

        @Test("Long Korean name within 15 char limit")
        func longKoreanName() {
            // "김수한무거북이"는 7글자, 15자 이하
            #expect(sut.parse("김수한무거북이의 iPhone") == "김수한무거북이")
        }

        @Test("Korean name exceeding 15 char limit returns nil")
        func koreanNameExceeding15Chars() {
            // 16글자 이름 생성
            let longName = String(repeating: "가", count: 16)
            let result = sut.parse("\(longName)의 iPhone")
            #expect(result == nil)
        }
    }

    // MARK: - 3. English Possessive Suffix ('s ~)

    @Suite("English possessive suffix patterns")
    struct EnglishSuffixPatterns {
        let sut = NameExtractor()

        @Test("'s iPhone suffix")
        func englishIPhoneSuffix() {
            #expect(sut.parse("John's iPhone") == "John")
        }

        @Test("'s iPad suffix")
        func englishIPadSuffix() {
            #expect(sut.parse("Sarah's iPad") == "Sarah")
        }

        @Test("'s MacBook suffix")
        func englishMacBookSuffix() {
            #expect(sut.parse("David's MacBook") == "David")
        }

        @Test("'s Mac suffix")
        func englishMacSuffix() {
            #expect(sut.parse("Emily's Mac") == "Emily")
        }

        @Test("'s Phone suffix")
        func englishPhoneSuffix() {
            #expect(sut.parse("Alex's Phone") == "Alex")
        }

        @Test("Full English name with suffix")
        func fullEnglishName() {
            #expect(sut.parse("Ye Gang Park's iPhone") == "Ye Gang Park")
        }

        @Test("Case insensitive suffix matching")
        func caseInsensitiveSuffix() {
            #expect(sut.parse("john's iphone") == "john")
        }
    }

    // MARK: - 4. NLP Path (no suffix match, > 4 chars)
    // 💡 NLTagger는 문맥 없는 짧은 문자열에서 이름 인식률이 극히 낮습니다.
    // suffix 매칭도 안 되고, ≤4자 fallback에도 해당하지 않으면 NLP에 의존하는데,
    // NLP 결과는 OS 버전·언어 설정에 따라 비결정적이므로 "크래시 없음"만 검증합니다.

    @Suite("NLP path — no suffix, > 4 chars")
    struct NLPPath {
        let sut = NameExtractor()

        @Test("English name without suffix — NLP dependent, no crash")
        func englishNameNoSuffix() {
            // NLP가 인식할 수도, 못 할 수도 있음 → 크래시만 안 나면 OK
            let result = sut.parse("Michael Johnson")
            _ = result
        }

        @Test("Full name without device suffix — NLP dependent, no crash")
        func fullNameWithoutSuffix() {
            let result = sut.parse("James Smith")
            _ = result
        }

        @Test("Non-name string falls through to nil")
        func nonNameString() {
            // "hello world"는 이름이 아니므로 NLP도 인식 못 함 → nil
            let result = sut.parse("hello world")
            #expect(result == nil)
        }
    }

    // MARK: - 5. Short String Fallback (≤4 chars, no NLP match)

    @Suite("Short string fallback (≤4 chars)")
    struct ShortStringFallback {
        let sut = NameExtractor()

        @Test("Single Korean character")
        func singleKoreanChar() {
            #expect(sut.parse("강") == "강")
        }

        @Test("Two Korean characters")
        func twoKoreanChars() {
            #expect(sut.parse("예강") == "예강")
        }

        @Test("Three Korean characters")
        func threeKoreanChars() {
            #expect(sut.parse("박예강") == "박예강")
        }

        @Test("Four character string")
        func fourCharString() {
            #expect(sut.parse("Park") == "Park")
        }

        @Test("Single Latin character")
        func singleLatinChar() {
            #expect(sut.parse("A") == "A")
        }
    }

    // MARK: - 6. Empty & Whitespace

    @Suite("Empty and whitespace inputs")
    struct EmptyAndWhitespace {
        let sut = NameExtractor()

        @Test("Empty string returns nil")
        func emptyString() {
            #expect(sut.parse("") == nil)
        }
    }

    // MARK: - 7. Edge Cases

    @Suite("Edge cases and boundary conditions")
    struct EdgeCases {
        let sut = NameExtractor()

        @Test("Name containing apostrophe but not possessive")
        func nameWithApostropheNotPossessive() {
            // "O'Brien" 처럼 이름 자체에 아포스트로피가 있는 경우
            let result = sut.parse("O'Brien's iPhone")
            #expect(result == "O'Brien")
        }

        @Test("Suffix matching is case insensitive")
        func caseInsensitiveSuffixMatching() {
            let result = sut.parse("Tom's IPHONE")
            #expect(result == "Tom")
        }

        @Test("Name exactly 15 characters with suffix")
        func nameExactly15CharsWithSuffix() {
            let name15 = String(repeating: "a", count: 15)
            let result = sut.parse("\(name15)의 iPhone")
            #expect(result == name15)
        }

        @Test("Name 16 characters with suffix returns nil")
        func name16CharsWithSuffix() {
            let name16 = String(repeating: "a", count: 16)
            let result = sut.parse("\(name16)의 iPhone")
            #expect(result == nil)
        }

        @Test("5-char string without suffix goes to NLP path")
        func fiveCharStringNoSuffix() {
            // 5글자는 short fallback(≤4) 범위 밖 → NLP 경로
            let result = sut.parse("abcde")
            // NLP가 이름으로 인식하지 않으면 nil
            #expect(result == nil)
        }

        @Test("Numeric device name")
        func numericDeviceName() {
            let result = sut.parse("12345")
            #expect(result == nil)
        }

        @Test("Mixed alphanumeric string")
        func mixedAlphanumericString() {
            let result = sut.parse("User123's iPhone")
            #expect(result == "User123")
        }

        @Test("Emoji in device name with suffix")
        func emojiWithSuffix() {
            let result = sut.parse("🐱의 iPhone")
            #expect(result == "🐱")
        }

        @Test("Only whitespace after suffix removal")
        func whitespaceAfterSuffixRemoval() {
            // " 의 iPhone" → 접미사 제거 후 빈 문자열
            let result = sut.parse(" 의 iPhone")
            #expect(result == nil)
        }

        @Test("Multiple potential suffixes - last match wins")
        func multipleSuffixes() {
            // "Mac의 MacBook" → "의 MacBook" 제거 → "Mac"
            // "Mac의 MacBook" != "Mac" 이고 "Mac " prefix 아님 → suffix 경로로 감
            let result = sut.parse("Mac의 MacBook")
            #expect(result == "Mac")
        }

        @Test("Smart quotes in possessive")
        func smartQuotes() {
            // iOS가 스마트 따옴표(\u{2019})를 사용하는 경우
            // 코드는 일반 아포스트로피만 처리하므로 매칭 안 됨 → NLP 의존
            let result = sut.parse("John\u{2019}s iPhone")
            _ = result // 크래시만 안 나면 OK
        }

        @Test("Japanese name with Korean suffix")
        func japaneseNameWithKoreanSuffix() {
            let result = sut.parse("太郎의 iPhone")
            #expect(result == "太郎")
        }

        @Test("Chinese name with English suffix")
        func chineseNameWithEnglishSuffix() {
            let result = sut.parse("小明's iPhone")
            #expect(result == "小明")
        }

        @Test("Very long name without suffix")
        func veryLongNameWithoutSuffix() {
            let longString = String(repeating: "abcdef", count: 50)
            let result = sut.parse(longString)
            // 300자, suffix 없음, NLP 경로 → 크래시 없이 동작해야 함
            _ = result
        }

        @Test("Device name with extra spaces around suffix")
        func extraSpacesAroundSuffix() {
            let result = sut.parse("Tom  's iPhone")
            // "Tom " 이 남고 trim → "Tom"
            #expect(result == "Tom")
        }

        @Test("Generic name substring should not be filtered")
        func genericNameSubstring() {
            // "iPho"는 genericNames와 정확히 일치하지 않으므로 필터링 안 됨
            let result = sut.parse("iPho")
            #expect(result == "iPho") // 4자 이하 → short fallback
        }

        @Test("'iPhone' prefix but not space-separated")
        func iPhonePrefixNoSpace() {
            // "iPhoneCase"는 "iPhone "으로 시작하지 않으므로 generic이 아님
            let result = sut.parse("iPhoneCase")
            // NLP 경로 → NLP 의존적
            _ = result
        }
    }

    // MARK: - 8. Real-World Device Names

    @Suite("Real-world device name scenarios")
    struct RealWorldScenarios {
        let sut = NameExtractor()

        @Test("Korean possessive with iPhone", arguments: [
            ("예강의 iPhone", "예강"),
            ("민지의 아이폰", "민지"),
            ("수현의 iPad", "수현"),
            ("지훈의 아이패드", "지훈"),
            ("태현의 MacBook", "태현"),
        ])
        func koreanRealWorld(input: String, expected: String) {
            #expect(sut.parse(input) == expected)
        }

        @Test("English possessive real names", arguments: [
            ("John's iPhone", "John"),
            ("Sarah's iPad", "Sarah"),
            ("Mike's MacBook", "Mike"),
            ("Emma's Phone", "Emma"),
        ])
        func englishRealWorld(input: String, expected: String) {
            #expect(sut.parse(input) == expected)
        }

        @Test("Generic device defaults return nil", arguments: [
            "iPhone", "iPad", "iPhone 16 Pro", "iPad Air",
            "Mac", "Apple Watch", "AirPods", "Apple TV",
        ])
        func genericDefaults(name: String) {
            #expect(sut.parse(name) == nil)
        }
    }
}
