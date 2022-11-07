//
//  File.swift
//  SoundTrack
//
//  Created by 唐烁 on 2022/4/24.
//

import SwiftUI

struct ImageMessage: Identifiable,Codable{
    var id:Int
    var image:String
    var received: Bool
}

struct MessageImageBubble: View{
    var message : ImageMessage
    var body: some View{
        VStack(alignment: message.received ? .leading : .trailing){
            HStack{
                Image(message.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                    
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.5,  alignment: .center)
            .background(message.received ? Color("gray") : Color.orange)
            .cornerRadius(15)
            
        }
        .frame(maxWidth: .infinity, alignment: message.received ? .leading : .trailing)
        .padding(message.received ? .leading : .trailing)
        .padding(.horizontal)
    }
}


struct Introduction1View_Previews: PreviewProvider{
    static var previews: some View{
        MessageImageBubble(message: ImageMessage(id: 0, image: "p1", received: true))
    }
}
