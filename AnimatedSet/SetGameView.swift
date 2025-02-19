//
//  ContentView.swift
//  SoloSetGame
//
//  Created by Jia Chen on 2024/11/16.
//

import SwiftUI

struct SetGameView: View {
    typealias Card = SetGameModel.Card
    @ObservedObject var viewModel: SetGameViewModel
    
    private let aspectRatio: CGFloat = 2/3
    private let spacing: CGFloat = 4
    private let dealAnimation: Animation = .easeInOut(duration: 1)
    private let dealInterval: TimeInterval = 0.15
    private let deckWidth: CGFloat = 50
    
    
    let count = 0
    
    var body: some View {
        VStack {
            Text("Set").font(.largeTitle)
            Text("Score: \(String(viewModel.score))")
                .font(.title)
        }
        cards
        Spacer()
        HStack() {
            matchedDeck
            Spacer()
      
//            Button {
//                dealCards()
//            } label: {
//                Text("Deal")
//            }.disabled(viewModel.cardsCountIndeck == 0)
            undealtDeck
            Spacer()
            shuffle
            Spacer()
            Button {
                withAnimation {
                    startNewGame()
                }
            } label: {
                Text("New Game")
            }
        }
        .padding()
    }
    
    private var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                viewModel.shuffle()
            }
        }
    }
    
    var cards: some View {
        GeometryReader { geometry in
            let gridItemSize = gridItemWidthThatFits(
                count: viewModel.cards.count,
                size: geometry.size,
                atAspectRatio: 2/3)
            
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: gridItemSize), spacing: 0)], spacing: 0) {
                ForEach(viewModel.cards) { card in
                        CardView(card, gridItemSize)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .transition(.asymmetric(insertion: .identity, removal: .identity))
                        .padding(4)
                        .aspectRatio(2/3, contentMode: .fit)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 1)) {
                                viewModel.choose(card)
                            }
                            
                        }
                    
                  
                
                }
            }
        }
   
    }
    

    
 
    @Namespace private var dealingNamespace
    
    var undealtDeck: some View {
        ZStack {
            ForEach(viewModel.undealtCards) { card in
                
                CardView(card, deckWidth / aspectRatio)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
            .frame(width: deckWidth, height: deckWidth / aspectRatio)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 1)) {
                    dealCards()
                }
            }
        }
    }
    
    var matchedDeck: some View {
        ZStack {
            ForEach(viewModel.matchedCards) { card in
                CardView(card,  deckWidth / aspectRatio)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            
            }
            .frame(width: deckWidth, height: deckWidth / aspectRatio)
           
        }
    }
    
    func startNewGame() {
        viewModel.startNewGame()
    }
    
    func dealCards() {
       viewModel.dealCards()
    }
    

    

    
    func gridItemWidthThatFits(
        count: Int,
        size: CGSize,
        atAspectRatio aspectRatio: CGFloat
    ) -> CGFloat {
        let count = CGFloat(count)
        var columnCount = 1.0
        // print(count)
        repeat {
            let width = size.width / columnCount
            let height = width / aspectRatio
            
            let rowCount = (count / columnCount).rounded(.up)
            if rowCount * height < size.height {
                return (size.width / columnCount).rounded(.down)
            }
            columnCount += 1
        } while columnCount < count
        return min(size.width / count, size.height * aspectRatio).rounded(.down)
        
    }
    


}

struct CardView: View {
//    let content: String
//    @State var isFaceUp: Bool = false
//    let fillColor: Color?
    
    let card: SetGameModel.Card
    
    let gridItemSize: CGFloat
    
    init(_ card: SetGameModel.Card, _ gridItemSize: CGFloat) {
        self.card = card
        self.gridItemSize = gridItemSize
    }
    func getCardBackgroundColor() -> Color {
       
        if card.isMatched {
            return .red
            
        } else if card.isThreeCardsUnMatched {
            return .yellow
        } else {
            return .white
        }
    }
    
    var isFaceUp: Bool {
        return !card.isInDeck && card.show
    }
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 8)
                
            Group {
                
                base.foregroundStyle(card.isMatched && !card.show ? .white : getCardBackgroundColor())
               base.strokeBorder(lineWidth: 2)
             //  base.overlay {

                 VStack {
//                     ForEach(0..<card.number.rawValue) { _ in
//                         HStack {
//                             applyShading(to:getShape(card, gridItemSize))
//                         }
//                     }
                     ForEach(Array(0..<card.number.rawValue), id: \.self) { _ in
                         HStack {
                             
                              applyShading(to:getShape(card, gridItemSize))
                           
                          }
                     }
                  }.padding(6)
                  
             
               // }
                base.fill(.orange).opacity(card.isInDeck ? 1 : 0)
             
               
            }
     
        }
        .foregroundStyle(card.isSelected ? Color.orange : Color.cyan) // dealtCards cards
        

    }
    
    @ViewBuilder
    func applyShading(to shape: some Shape) -> some View {
//        var content = getShape(card)
        let color = card.color.toColor()
        switch card.shading {
        case .solid:
            shape.fill(color)
        case .striped:
            shape.stroke(color)
                .overlay(
                    shape
                        .fill(color)
                        .mask(StripedPattern(use: color))
                )
        case .open:
            shape.stroke(color, lineWidth: 2)
        }
    }
    
    func getShape(_ card: SetGameModel.Card, _ gridItemSize: CGFloat) -> some Shape {
        let height = gridItemSize / 3
        let width = gridItemSize / 3 * 2
        switch card.shape {
        case CardShape.diamond:
            return Diamond().path(in: CGRect(x: 0, y: 0, width: width, height: height))
        case CardShape.squiggle:
            return Rectangle().path(in: CGRect(x: 0, y: 0, width: width, height: height))
        case CardShape.oval:
            return Capsule().path(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}

struct StripedPattern: View {
    var color: Color
    init(use color: Color) {
        self.color = color
    }
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                stride(from: 0, to: geometry.size.width, by: 4).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
            }
            .stroke(color, lineWidth: 1)
        }
    }
}




struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: center.y ))
        path.addLine(to: CGPoint(x: center.x, y: rect.maxY  ))
        path.addLine(to: CGPoint(x: rect.minX, y: center.y  ))
        path.addLine(to: CGPoint(x: center.x, y: rect.minY))
        path.closeSubpath()
        return path
    }
}



#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
