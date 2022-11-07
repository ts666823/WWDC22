//
//  File.swift
//  SoundTrack
//
//  Created by 唐烁 on 2022/4/24.
//

import SwiftUI

struct IntroductionView: View{

    
    var castleInTheSky = [
        [
            [("10",0.5),("12",0.5)]
        ],
        [ // 第2节
            [("13",1.5),("12",0.5),("13",1),("13",0.5),("17",0.5)], // 1弦
            [("0",1),("20",3)], // 2弦
            [("0",0.5),("30",2),("30",1.5)], // 3弦
            [("60",2),("60",2)] // 6弦
        ],
        [ // 第3节
            [("12",4)], // 1弦
            [("0",1),("23",2),("20",1)], // 2弦
            [("0",0.5),("32",1),("32",2.5)], // 3弦
            [("40",2),("40",2)] // 4弦
        ],
        [ // 第4节
            [("10",2),("10",1),("13",1)], // 1弦
            [("21",1.5),("23",2.5)], // 2弦
            [("0",1),("30",1.5),("30",1),("30",0.5)], // 3弦
            [("0",0.5),("42",3.5)], // 4弦
            [("53",4)] // 5弦
        ],
        [ // 第5节
            [("23",3),("20",1)], // 2弦
            [("0",1),("30",1),("30",2)], // 3弦
            [("0",0.5),("40",1),("40",2.5)], // 4弦
            [("52",4)] // 5弦
        ],
        [ // 第6节
            [("0",2.5),("13",1.5)], // 1弦
            [("21",1.5),("20",0.5),("21",2)], // 2弦
            [("0",1),("30",2.5),("30",0.5)], // 3弦
            [("0",0.5),("42",2.5),("42",1)], // 4弦
            [("50",2),("50",2)] // 5弦
        ],
        [ // 第7节
            [("0",3),("13",0.5),("13",0.5)], // 1弦
            [("20",2),("20",2)], // 2弦
            [("0",1),("30",3)], // 3弦
            [("0",0.5),("42",1),("42",2.5)], // 4弦
            [("60",4)] // 6弦
        ],
        [ // 第8节
            [("12",3),("12",0.5),("10",0.5)], // 1弦
            [("0",1.5),("22",0.5),("22",2)], // 2弦
            [("0",1),("33",1.5),("33",1.5)], // 3弦
            [("0",0.5),("44",3.5)], // 4弦
            [("62",2),("62",2)] // 6弦
        ],
        [ // 第9节
            [("12",2),("12",2)], // 1弦
            [("0",1.5),("24",0.5),("24",2)], // 2弦
            [("0",1),("34",1),("34",2)], // 3弦
            [("0",0.5),("44",1.5),("44",2)], // 4弦
            [("51",4)] // 5弦
        ]
    ]
    
    
    
    @Binding var settingPagePresented: Bool
    @Binding var scrolled : Int
    
    var title : String
    var image : String
    var detail : String
    
    @StateObject var messageManager = MessagesManager()
    
    
    var body: some View{
        VStack{
            IntroductionViewTitle(settingPagePresented: $settingPagePresented, title: title, image: image, detail: detail)
            
            ScrollViewReader { proxy in
                ScrollView{
                    ForEach(messageManager.messages){ message in
                        MessageBubble(message: message)
                            .onTapGesture {
                                if(message.id == 15){
                                    let myUnit = OutputToneModule()
                                    myUnit.setFrequency(freq: 329.6)
                                    myUnit.setToneVolume(vol: 0.5)
                                    myUnit.enableSpeaker()
                                    myUnit.setToneTime(t: 3)
                                }
                                if(message.id == 29){
                                    let guitar = GuitarModule()
                                    guitar.play(melody: castleInTheSky)
                                    guitar.enableSpeaker()
                                }
                            }
                    }
                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(30)
                .onChange(of: messageManager.lastMessageId) { id in
                    withAnimation {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
            MessageEditor( scroll: $scrolled)
                .environmentObject(messageManager)
        }
    }
}


struct IntroductionViewTitle: View{
    
    @Binding var settingPagePresented: Bool
    var title : String
    var image : String
    var detail : String
    
    var body: some View{
        VStack {
            HStack{
                Button {
                    settingPagePresented = false
                } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                }
                .padding(.leading)
                Spacer()
                   
            }
            HStack(spacing: 20){
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
                VStack(alignment: .leading){
                    Text(title)
                        .font(.title)
                        .bold()
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(50)
            }
            .padding()
        }
    }
}
