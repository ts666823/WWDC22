//
//  File.swift
//  SoundTrack
//
//  Created by 唐烁 on 2022/4/24.
//

import Foundation

class MessagesManager: ObservableObject{
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = 0
    
    func sendMessage(tempMessages:[Message]){
        messages.append(contentsOf: tempMessages)
        if let id = self.messages.last?.id{
            self.lastMessageId = id
        }
    }
    
    func sendMessage(tempMessage:Message){
        messages.append(tempMessage)
        if let id = self.messages.last?.id{
            self.lastMessageId = id
        }
    }
}
