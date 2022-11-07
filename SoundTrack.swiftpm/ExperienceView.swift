//
//  File.swift
//  SoundTrack
//
//  Created by 唐烁 on 2022/4/25.
//

import SwiftUI

struct ExperienceView: View{
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
    var title : String
    var image : String
    var detail : String
    @State private var text = ""
    
    
    @StateObject var messageManager = MessagesManager()
    @State private var melody:[[[(String,Double)]]] = []
    @State private var wait = false
    
    func sendText(text:String){
        messageManager.sendMessage(tempMessage: Message(id: messageManager.lastMessageId + 1, text: text, received: false, haveImage: false, image: ""))
        if(text == "play" || text == "Play"){
            let guitar = GuitarModule()
            wait.toggle()
            guitar.play(melody: melody)
            wait.toggle()
            guitar.enableSpeaker()
            melody.removeAll()
        }
        else if (text == "Play Castle in the Sky" || text == "play Castle in the Sky"){
            let guitar = GuitarModule()
            wait.toggle()
            guitar.play(melody: castleInTheSky)
            wait.toggle()
            guitar.enableSpeaker()
        }
        else{
            let info = text.split(separator: "|")
            var record : [(String,Double)] = []
            for i in info {
                let temp = i.split(separator: ",")
                let prefix = String(temp[0].dropFirst(2).dropLast(1))
                let suffix = Double(temp[1].dropLast(1))
                let re : (String,Double) = (prefix,suffix!)
                record.append(re)
            }
            var section:[[(String,Double)]] = []
            section.append(record)
            print(section)
            melody.append(section)
        }
    }
    
    
    var body: some View{
        ZStack(alignment: .center){
                VStack{
                    IntroductionViewTitle(settingPagePresented: $settingPagePresented, title: title, image: image, detail: detail)
                    
                    ScrollViewReader { proxy in
                        ScrollView{
                            
                            MessageBubble(message: Message(id: messageManager.lastMessageId + 1, text: "Welcome to the last part, where you can enter \"play Castle in the Sky\" to play the changed music, or you can customize your music and enter \"play\" to play music", received: true, haveImage: false, image: ""))
                            
                            MessageBubble(message: Message(id: messageManager.lastMessageId + 1, text: "The custom coding rules of music are as follows. Use (\"12\", 4) to represent one string, two grades and full notes of guitar, separated by \"|\". 4, 1 and 0.25 represent full note, quarter note and sixteenth note respectively. Each input will be used as all the notes that the guitar string should dial in the current section. You can use the first section of the city of the sky as an example:(\"13\",1.5)|(\"12\", 0.5)|(\"13\", 1)|(\"13\", 0.5)|(\"17\", 0.5)", received: true, haveImage: false, image: ""))
                            
                            ForEach(messageManager.messages){ message in
                                MessageBubble(message: message)
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
                    
                    HStack{
                        ZStack(alignment: .leading){
                            if text.isEmpty {
                                Text("Enter your message here").opacity(0.5).foregroundColor(.black)
                            }
                            TextField("", text: $text){
                                sendText(text: text)
                                text = ""
                            }
                            .foregroundColor(.black)
                        }
                        Button{
                            sendText(text: text)
                            text = ""
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.orange)
                                .cornerRadius(50)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("gray"))
                    .cornerRadius(50)
                    .padding()
                    
                }
            }
    }
}

