import Foundation

public struct RichPresence: Encodable {
    public var assets = Assets()
    public var buttons: [Button]? = nil
    public var details = ""
    public var instance = true
    public var party = Party()
    public var secrets = Secrets()
    public var state = ""
    public var statusDisplayType: StatusDisplayType? = nil
    public var timestamps = Timestamps()
    public var type = ActivityType.playing

    enum CodingKeys: String, CodingKey {
        case assets, buttons, details, instance, party, secrets, state
        case statusDisplayType = "status_display_type"
        case timestamps, type
    }

    public init() {}

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(assets, forKey: .assets)
        try container.encodeIfPresent(buttons, forKey: .buttons)
        try container.encode(details, forKey: .details)
        try container.encode(instance, forKey: .instance)
        try container.encode(party, forKey: .party)

        if !secrets.isEmpty {
            guard buttons == nil else {
                throw EncodingError.invalidValue(secrets, .init(
                    codingPath: container.codingPath + [CodingKeys.secrets],
                    debugDescription: "Discord does not allow an activity to have both buttons and secrets set"
                ))
            }

            try container.encode(secrets, forKey: .secrets)
        }

        try container.encode(state, forKey: .state)
        try container.encodeIfPresent(statusDisplayType, forKey: .statusDisplayType)
        try container.encode(timestamps, forKey: .timestamps)
        try container.encode(type, forKey: .type)
    }
}

extension RichPresence {
    public enum ActivityType: Int, Encodable {
        case playing = 0
        case streaming = 1
        case listening = 2
        case watching = 3
        case custom = 4
        case competing = 5
    }

    public enum StatusDisplayType: Int, Encodable {
        case name = 0
        case state = 1
        case details = 2
    }

    public struct Button: Encodable {
        public var label: String
        public var url: String

        public init(label: String, url: String) {
            self.label = label
            self.url = url
        }
    }

    public struct Timestamps: Encodable {
        public var end: Date? = nil
        public var start: Date? = nil

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(start.map { Int($0.timeIntervalSince1970) }, forKey: .start)
            try container.encodeIfPresent(end.map { Int($0.timeIntervalSince1970) }, forKey: .end)
        }

        enum CodingKeys: String, CodingKey {
            case end, start
        }
    }
    
    public struct Assets: Encodable {
        public var largeImage: String? = nil
        public var largeText: String? = nil
        public var smallImage: String? = nil
        public var smallText: String? = nil
        
        enum CodingKeys: String, CodingKey {
            case largeImage = "large_image",
                 largeText = "large_text",
                 smallImage = "small_image",
                 smallText = "small_text"
        }
    }
    
    public struct Party: Encodable {
        public var id: String? = nil
        public var max: Int? = nil
        public var size: Int? = nil
        
        enum CodingKeys: String, CodingKey {
            case id
            case size
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(id, forKey: .id)
            
            guard let max, let size else { return }
            
            try container.encode([size, max], forKey: .size)
        }
    }
    
    public struct Secrets: Encodable {
        public var join: String? = nil
        public var match: String? = nil
        public var spectate: String? = nil

        var isEmpty: Bool {
            join == nil && match == nil && spectate == nil
        }
    }
}
