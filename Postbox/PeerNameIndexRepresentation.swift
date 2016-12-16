import Foundation

public enum PeerIndexNameRepresentation: Equatable {
    case title(title: String, addressName: String?)
    case personName(first: String, last: String, addressName: String?)
    
    public static func ==(lhs: PeerIndexNameRepresentation, rhs: PeerIndexNameRepresentation) -> Bool {
        switch lhs {
            case let .title(lhsTitle, lhsAddressName):
                if case let .title(rhsTitle, rhsAddressName) = rhs, lhsTitle == rhsTitle, lhsAddressName == rhsAddressName {
                    return true
                } else {
                    return false
                }
            case let .personName(lhsFirst, lhsLast, lhsAddressName):
                if case let .personName(rhsFirst, rhsLast, rhsAddressName) = rhs, lhsFirst == rhsFirst, lhsLast == rhsLast, lhsAddressName == rhsAddressName {
                    return true
                } else {
                    return false
                }
        }
    }
}

public enum PeerNameIndex {
    case firstNameFirst
    case lastNameFirst
}

extension PeerIndexNameRepresentation {
    public func indexName(_ index: PeerNameIndex) -> String {
        switch self {
            case let .title(title, _):
                return title
            case let .personName(first, last, _):
                switch index {
                    case .firstNameFirst:
                        return first + last
                    case .lastNameFirst:
                        return last + first
                }
        }
    }
    
    public func matchesByTokens(_ other: String) -> Bool {
        var foundAtLeastOne = false
        for searchToken in stringIndexTokens(other, transliteration: .none) {
            var found = false
            for token in self.indexTokens {
                if searchToken.isPrefix(to: token) {
                    found = true
                    break
                }
            }
            if !found {
                return false
            }
            foundAtLeastOne = true
        }
        return foundAtLeastOne
    }
    
    var indexTokens: [ValueBoxKey] {
        switch self {
            case let .title(title, addressName):
                var tokens: [ValueBoxKey] = stringIndexTokens(title, transliteration: .combined)
                if let addressName = addressName {
                    tokens.append(contentsOf: stringIndexTokens(addressName, transliteration: .none))
                }
                return tokens
            case let .personName(first, last, addressName):
                var tokens: [ValueBoxKey] = stringIndexTokens(first, transliteration: .combined)
                tokens.append(contentsOf: stringIndexTokens(last, transliteration: .combined))
                if let addressName = addressName {
                    tokens.append(contentsOf: stringIndexTokens(addressName, transliteration: .none))
                }
                return tokens
        }
    }
}