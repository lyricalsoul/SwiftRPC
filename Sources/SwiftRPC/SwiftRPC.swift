import Foundation
import OSLog
import Socket

public final class SwiftRPC: @unchecked Sendable {
    // MARK: App Info
    public let appId: String
    public var handlerInterval: Int
    public let autoRegister: Bool
    public let steamId: String?
    
    // MARK: Technical stuff
    let pid: Int32
    var socket: Socket? = nil
    let worker: DispatchQueue
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    var presence: RichPresence? = nil
    
    // MARK: Event Handlers
    public weak var delegate: SwiftRPCDelegate? = nil
    var connectHandler:      ((_ rpc: SwiftRPC) -> ())? = nil
    var disconnectHandler:   ((_ rpc: SwiftRPC, _ code: Int?, _ msg: String?) -> ())? = nil
    var errorHandler:        ((_ rpc: SwiftRPC, _ code: Int, _ msg: String) -> ())? = nil
    var joinGameHandler:     ((_ rpc: SwiftRPC, _ secret: String) -> ())? = nil
    var spectateGameHandler: ((_ rpc: SwiftRPC, _ secret: String) -> ())? = nil
    var joinRequestHandler:  ((_ rpc: SwiftRPC, _ request: JoinRequest, _ secret: String) -> ())? = nil
    
    public init(appId: String, handlerInterval: Int = 1000, autoRegister: Bool = true, steamId: String? = nil) {
        self.appId = appId
        self.handlerInterval = handlerInterval
        self.autoRegister = autoRegister
        self.steamId = steamId
        
        pid = ProcessInfo.processInfo.processIdentifier
        worker = DispatchQueue(label: "me.azoy.swiftrpc.\(pid)", qos: .userInitiated)
        encoder.dateEncodingStrategy = .secondsSince1970
        
        createSocket()
        registerUrl()
    }
    
    public func connect() {
        guard let socket else {
            logError("[SwiftRPC] Unable to connect")
            return
        }
        
        let tmp = NSTemporaryDirectory()
        
        for i in 0..<10 {
            try? socket.connect(to: "\(tmp)/discord-ipc-\(i)")
            
            guard !socket.isConnected else {
                handshake()
                receive()
                
                subscribe("ACTIVITY_JOIN")
                subscribe("ACTIVITY_SPECTATE")
                subscribe("ACTIVITY_JOIN_REQUEST")
                
                return
            }
        }
        
        logError("[SwiftRPC] Discord not detected")
    }
    
    public func setPresence(_ presence: RichPresence, immediate: Bool = false) {
        self.presence = presence

        guard immediate else { return }

        try? sendActivity(presence)
    }
    
    public func reply(to request: JoinRequest, with reply: JoinReply) {
        let json = """
        {
          "cmd": "\(
            reply == .yes ? "SEND_ACTIVITY_JOIN_INVITE" : "CLOSE_ACTIVITY_JOIN_REQUEST"
          )",
          "args": {
            "user_id": "\(request.userId)"
          }
        }
        """
        
        try? send(json, .frame)
    }
    
    func logError(_ message: String) {
        if #available(macOS 11, iOS 14, tvOS 14, watchOS 7, *) {
            Logger().error("\(message)")
        }
    }
}
