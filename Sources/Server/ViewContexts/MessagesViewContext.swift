import Foundation

/*
 View context for `messages.stencil`.
 */
struct MessagesViewContext: ViewContext {
    
    let base: [String: Any]
    var contents: [String: Any] = [:]
    
    init(base: [String: Any], messages: [Message]) throws {
        self.base = base
        contents = [
            "messages": try messages.map(messageMapper)
        ]
    }
    
    private func messageMapper(_ message: Message) throws -> [String: Any] {
        var output: [String: Any] = [
            "creationDate": formatted(message.creationDate, dateStyle: .long, timeStyle: .none),
            "category": message.category.description
        ]
        switch message.category {
        case .requestReceived(let request):
            guard let gameID = request.game.id else {
                try logAndThrow(ServerError.invalidState)
            }
            output["link"] = "/web/game/\(gameID)"
            output["sender"] = [
                "name": request.player.name,
                "picture": request.player.picture?.absoluteString ?? Settings.defaultProfilePicture
            ]
            output["game"] = [
                "name": request.game.data.name,
                "date": formatted(request.game.date, dateStyle: .long, timeStyle: .none)
            ]
        case .requestApproved(let request):
            guard let gameID = request.game.id else {
                try logAndThrow(ServerError.invalidState)
            }
            output["link"] = "/web/game/\(gameID)"
            output["sender"] = [
                "name": request.game.host.name,
                "picture": request.game.host.picture?.absoluteString ?? Settings.defaultProfilePicture
            ]
            output["game"] = [
                "name": request.game.data.name,
                "date": formatted(request.game.date, dateStyle: .long, timeStyle: .none)
            ]
        }
        return output
    }
}