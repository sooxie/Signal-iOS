//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalServiceKit
import SignalMessaging

class DebugUICalling: DebugUIPage {

    // MARK: Dependencies

    var messageSender: MessageSender {
        return Environment.current().messageSender
    }

    // MARK: Overrides 

    override func name() -> String {
        return "Calling"
    }

    override func section(thread aThread: TSThread?) -> OWSTableSection? {
        guard let thread = aThread as? TSContactThread else {
            owsFail("Calling is only valid for contact thread, got thread: \(String(describing: aThread))")
            return nil
        }

        let sectionItems = [
            OWSTableItem(title: "Send 'hangup' for old call") { [weak self] in
                guard let strongSelf = self else { return }

                let kFakeCallId = UInt64(12345)
                var hangupMessage: SSKProtoCallMessageHangup
                do {
                    let hangupBuilder = SSKProtoCallMessageHangup.SSKProtoCallMessageHangupBuilder()
                    hangupBuilder.setId(kFakeCallId)
                    hangupMessage = try hangupBuilder.build()
                } catch {
                    owsFail("\(strongSelf.logTag) could not build proto")
                    return
                }
                let callMessage = OWSOutgoingCallMessage(thread: thread, hangupMessage: hangupMessage)

                strongSelf.messageSender.sendPromise(message: callMessage).then {
                    Logger.debug("\(strongSelf.logTag) Successfully sent hangup call message to \(thread.contactIdentifier())")
                }.catch { error in
                    Logger.error("\(strongSelf.logTag) failed to send hangup call message to \(thread.contactIdentifier()) with error: \(error)")
                }
            },
            OWSTableItem(title: "Send 'busy' for old call") { [weak self] in
                guard let strongSelf = self else { return }

                let kFakeCallId = UInt64(12345)
                var busyMessage: SSKProtoCallMessageBusy
                do {
                    let busyBuilder = SSKProtoCallMessageBusy.SSKProtoCallMessageBusyBuilder()
                    busyBuilder.setId(kFakeCallId)
                    busyMessage = try busyBuilder.build()
                } catch {
                    owsFail("Couldn't build proto in \(#function)")
                    return
                }

                let callMessage = OWSOutgoingCallMessage(thread: thread, busyMessage: busyMessage)

                strongSelf.messageSender.sendPromise(message: callMessage).then {
                    Logger.debug("\(strongSelf.logTag) Successfully sent busy call message to \(thread.contactIdentifier())")
                }.catch { error in
                    Logger.error("\(strongSelf.logTag) failed to send busy call message to \(thread.contactIdentifier()) with error: \(error)")
                }
            }
        ]

        return OWSTableSection(title: "Call Debug", items: sectionItems)
    }
}
