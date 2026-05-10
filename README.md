# SwiftRPC - Discord Rich Presence Library written in Swift

Swift library for Discord Rich Presence

## Requirements
1. macOS, Linux
2. Swift 6+

> [!WARNING]
> RPC will not work in sandboxed apps

## Example

Check out the [demo project](https://github.com/TopScrech/SwiftRPC-Sandbox)

### Callbacks
```swift
import SwiftRPC

/// Additional arguments:
/// handlerInterval: Int = 1000 (decides how fast to check discord for updates, 1000ms = 1s)
/// autoRegister: Bool = true (automatically registers your application to discord's url scheme (discord-appid://))
/// steamId: String? = nil (this is for steam games on these platforms)
let rpc = SwiftRPC(appId: "123")

rpc.onConnect { rpc in
  var presence = RichPresence()
  presence.details = "Ranked | Mode: \(mode)"
  presence.state = "In a Group"
  presence.timestamps.start = Date()
  presence.timestamps.end = Date() + 600 // 600s = 10m
  presence.assets.largeImage = "map1"
  presence.assets.largeText = "Map 1"
  presence.assets.smallImage = "character1"
  presence.assets.smallText = "Character 1"
  presence.party.max = 5
  presence.party.size = 3
  presence.party.id = "partyId"
  presence.secrets.match = "matchSecret"
  presence.secrets.join = "joinSecret"
  presence.secrets.joinRequest = "joinRequestSecret"

  rpc.setPresence(presence)
}

rpc.onDisconnect { rpc, code, msg in
  print("It appears we have disconnected from Discord")
}

rpc.onError { rpc, code, msg in
  print("It appears we have discovered an error!")
}

rpc.onJoinGame { rpc, secret in
  print("We have found us a join game secret!")
}

rpc.onSpectateGame { rpc, secret in
  print("Our user wants to spectate!")
}

rpc.onJoinRequest { rpc, request, secret in
  print("Some user wants to play with us!")
  print(request.username)
  print(request.avatar)
  print(request.discriminator)
  print(request.userId)

  rpc.reply(to: request, with: .yes) // or .no or .ignore
}

rpc.connect()
```

### Delegation
```swift
import SwiftRPC

class ViewController {
  override func viewDidLoad() {
    let rpc = SwiftRPC(appId: "123")
    rpc.delegate = self
    rpc.connect()
  }
}

extension ViewController: SwiftRPCDelegate {
  func swiftRPCDidConnect(
    _ rpc: SwiftRPC
  ) {}

  func swiftRPCDidDisconnect(
    _ rpc: SwiftRPC,
    code: Int?,
    message msg: String?
  ) {}

  func swiftRPCDidReceiveError(
    _ rpc: SwiftRPC,
    code: Int,
    message msg: String
  ) {}

  func swiftRPCDidJoinGame(
    _ rpc: SwiftRPC,
    secret: String
  ) {}

  func swiftRPCDidSpectateGame(
    _ rpc: SwiftRPC,
    secret: String
  ) {}

  func swiftRPCDidReceiveJoinRequest(
    _ rpc: SwiftRPC,
    request: JoinRequest,
    secret: String
  ) {}
}
```

## Links
Join the [API Channel](https://discord.gg/99a3xNk) to ask questions!
