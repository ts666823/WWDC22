//
//  File.swift
//  SoundTrack
//
//  Created by 唐烁 on 2022/4/24.
//

import SwiftUI

struct Message: Identifiable,Codable{
    var id:Int
    var text:String
    var received: Bool
    var haveImage: Bool
    var image:String
}

struct MessageBubble: View{
    var message : Message
    var body: some View{
        VStack(alignment: message.received ? .leading : .trailing){
            HStack{
                if message.haveImage {
                    Image(message.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical)
                        .frame(width: 280)
                }
                else{
                    Text(message.text)
                        .foregroundColor(.black)
                        .padding()
                        .background(message.received ? Color("gray") : Color.orange)
                        .frame(alignment: message.received ? .leading : .trailing)
                        .cornerRadius(30)
                }
            }
            .frame(maxWidth: 300,  alignment: message.received ? .leading : .trailing)
        }
        .frame(maxWidth: .infinity, alignment: message.received ? .leading : .trailing)
        .padding(message.received ? .leading : .trailing)
        .padding(.horizontal)
    }
}



