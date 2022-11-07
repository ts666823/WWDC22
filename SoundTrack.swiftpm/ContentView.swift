import SwiftUI

struct Session : Identifiable{
    var id : Int
    var image : String
    var offset : CGFloat
    var title : String
    var headerNote : String
    var detail : String
}

struct ContentView: View {
    @State var settingPagePresented: Bool = false
    @State var index = 0
    @State var sessions = [
        Session(id: 0, image:"p0", offset: 0, title: "Learn About Sound", headerNote: "First Part of Sound Track", detail: "In this section, you will learn the basic physics of sound and understand the representation of sound from the perspective of computer."),
        Session(id: 1, image:"p1", offset: 0, title: "Single Frequency Sound by Swift", headerNote: "Second Part of Sound Track", detail: "In this section, you will learn how to use swift to make a single frequency sound"),
        Session(id: 2, image:"p2", offset: 0, title: "Add Guitar Effect", headerNote: "Third Part of Sound Track", detail: "In this section, you will learn the sound characteristics of guitar and learn how to simulate this sound"),
        Session(id: 3, image:"p3", offset: 0, title: "Play Guitar by Swift", headerNote: "First Part of Sound Track", detail: "In this section, you will use swift to play the guitar in combination with the previous knowledge")
    ]
    @State var scrolled = 0
    
    var body: some View {
        VStack {
            HStack{
                Text("Sound Track")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                Spacer(minLength: 0)
                Button(action:{}){
                    Image(systemName: "questionmark.circle")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
            }
            .padding([.top, .leading, .trailing])
            SessionsView(sessions: $sessions, scrolled: $scrolled)
            Button(action:{
                settingPagePresented = true
            }){
                Text("Learn More")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal,25)
                    .background(Color("Color1"))
                    .clipShape(Capsule())
                    .fullScreenCover(isPresented: $settingPagePresented, content: {scrolled != 3 ? AnyView(IntroductionView(settingPagePresented: $settingPagePresented, scrolled: $scrolled, title: sessions[scrolled].title, image: sessions[scrolled].image, detail: sessions[scrolled].headerNote)) : AnyView(ExperienceView(settingPagePresented: $settingPagePresented, title: sessions[scrolled].title, image: sessions[scrolled].image, detail: sessions[scrolled].headerNote))})
            }
            .padding(.top, 100.0)
            Spacer()
        }
        .background(
            LinearGradient(gradient: .init(colors:[Color("top"),Color("bottom")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        
    }
}

struct SessionsView: View {
    @Binding var sessions : [Session]
    @Binding var scrolled : Int
    func calculateWidth() -> CGFloat{
        let screen = UIScreen.main.bounds.width - 60
        let width = screen - (2 * 30)
        return width
    }
    
    var body: some View {
        ZStack{
            ForEach(sessions.reversed()){session in
                HStack{
                    CardView(session: session,scrolled: $scrolled)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
                .offset(x:session.offset)
                .gesture(DragGesture().onChanged({ (value) in
                    withAnimation {
                        if value.translation.width < 0 && session.id != sessions.last!.id{
                            sessions[session.id].offset = value.translation.width
                        }
                        else{
                            if session.id > 0{
                                sessions[session.id - 1].offset = -(calculateWidth() + 60) + value.translation.width
                            }
                        }
                        
                        
                    }
                }).onEnded({ (value) in
                    withAnimation {
                        if value.translation.width < 0{
                            if -value.translation.width > 180 && session.id != sessions.last!.id{
                                sessions[session.id].offset = -(calculateWidth() + 60)
                                scrolled += 1
                            }
                            else{
                                sessions[session.id].offset = 0
                            }
                        }
                        else{
                            if session.id > 0{
                                if value.translation.width > 180{
                                    sessions[session.id -  1].offset = 0
                                    scrolled -= 1
                                }
                                else{
                                    sessions[session.id - 1].offset = -(calculateWidth() + 60)
                                }
                                
                            }
                        }
                        
                    }
                }))
            }
            
        }
        .frame(height: UIScreen.main.bounds.height / 1.8)
        .padding(.horizontal)
    }
}

struct CardView: View {
    var session:Session
    @Binding var scrolled : Int
    
    func calculateWidth() -> CGFloat{
        let screen = UIScreen.main.bounds.width - 60
        let width = screen - (2 * 30)
        return width
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)){
            Image(session.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: calculateWidth(), height: (UIScreen.main.bounds.height / 1.8) - CGFloat(session.id - scrolled) * 50)
                .cornerRadius(15)
            VStack(alignment: .leading,spacing: 18){
                Text(session.headerNote)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                HStack{
                    Text(session.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                Text(session.detail)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical)
                
                
            }
            .frame(width:calculateWidth() - 40)
            .padding(.leading, 20)
            .padding(.bottom, 20 )
        }
        .offset(x:session.id - scrolled <= 2 ? CGFloat(session.id - scrolled)  * 30 : 60)
    }
}
