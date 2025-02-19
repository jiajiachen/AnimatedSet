//
//  SetGameModel.swift
//  SoloSetGame
//
//  Created by Jia Chen on 2024/11/16.
//

import Foundation
import SwiftUI

struct SetGameModel {

    private(set) var cards: Array<Card>
   // private(set) var dealtCards: Array<Card>
    private(set) var score = 0
   // private var selectedCardCount = 0
  //  private var isMatched = false
  //  private var selectedCardIndex: Array<Int> = []
    
    init() {
        var id = 0
        cards = []
       // dealtCards = []
        for number in CardNumber.allCases {
            for color in CardColor.allCases {
                for shape in CardShape.allCases {
                    for shading in CardShading.allCases {
                        cards.append(Card(id: String(id), number: number, shape: shape, shading: shading, color: color))
                        id += 1
                    }
                }
            }
        }
        shuffle()
        for index in 0..<12 {
            setCardDeal(cards[index])
          //  dealtCards.append(cards[index])
        }
      
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id} ) {
           //print("card", chosenIndex, cards[chosenIndex].isSelected)
            
            let selectedCards = cards.filter { $0.isSelected}
            
            if selectedCards.count == 3 {
                
                if selectedCards[0].isMatched {
                    cards[chosenIndex].isSelected = true
                    let cardsInDeck = cards.filter { $0.isInDeck }
                
                    for index in selectedCards.indices {
                        if let cardIndex = cards.firstIndex(where: { $0.id ==  selectedCards[index].id}) {
                            cards[cardIndex].isSelected = false
                            cards[cardIndex].show = false
                            
                            if cardsInDeck.count > 0 {
                                let tempCard = cards[cardIndex]
                                if let cardInDeckIndex = cards.firstIndex(where: { $0.id ==  cardsInDeck[index].id }) {
                                    cards[cardInDeckIndex].isInDeck = false
                                    cards[cardIndex] = cards[cardInDeckIndex]
                                    
                                    cards[cardInDeckIndex] = tempCard
                                }
                            }
                          
                        }
                    }
                   
                   // dealCards()
                    
                } else if selectedCards[0].isThreeCardsUnMatched {
                    for index in cards.indices {
                        if (cards[index].isSelected) {
                            cards[index].isSelected = false
                            cards[index].isThreeCardsUnMatched = false
                        }
                    }
                
                    cards[chosenIndex].isSelected = true
                    
                }
                
               
            } else {
                cards[chosenIndex].isSelected = !cards[chosenIndex].isSelected
                let selectedCards = cards.filter { $0.isSelected}
                if selectedCards.count == 3 {
                    let isMatched = isValidSet(selectedCards)
                    
                    if (isMatched) {
                        for index in cards.indices {
                            if (cards[index].isSelected) {
                                cards[index].isMatched = true
                            }
                        }
                        score += 1
                    } else {
                        for index in cards.indices {
                            if (cards[index].isSelected) {
                                cards[index].isThreeCardsUnMatched = true
                            }
                        }
                    }
                }
            }
            

        }
    }
    
    mutating func isCardsMatched() {
        
    }
    
    func isValidSet(_ cards: [Card]) -> Bool {
        guard cards.count == 3 else { return false }
        
        // 检查每个特征是否符合 SET 规则：要么全部相同，要么全部不同
        return isValidFeature(cards.map { $0.shape }) &&
               isValidFeature(cards.map { $0.color }) &&
               isValidFeature(cards.map { $0.shading }) &&
               isValidFeature(cards.map { $0.number })
        

    }
    
    // 检查单个特征是否符合规则
    func isValidFeature<T: Hashable>(_ features: [T]) -> Bool {
         let uniqueFeatures = Set(features)
        // 要么全部相同（集合大小为1），要么全部不同（集合大小为3）
        return uniqueFeatures.count == 1 || uniqueFeatures.count == 3
    }
    
    mutating func dealCards() {
        
        let selectedCards = cards.filter { $0.isSelected}
        let cardsInDeck = cards.filter { $0.isInDeck }
        if selectedCards.count == 3 && selectedCards[0].isMatched {
           
                for index in selectedCards.indices {
                    if let cardIndex = cards.firstIndex(where: { $0.id ==  selectedCards[index].id}) {
                        cards[cardIndex].isSelected = false
                        cards[cardIndex].show = false
                        let tempCard = cards[cardIndex]
                        if let cardInDeckIndex = cards.firstIndex(where: { $0.id ==  cardsInDeck[index].id }) {
                            cards[cardInDeckIndex].isInDeck = false
                            cards[cardIndex] = cards[cardInDeckIndex]
                            
                            cards[cardInDeckIndex] = tempCard
                        }
                    }
                }
              
            
        } else {
            if cardsInDeck.count > 0 {
                for index in 0..<3 {
                    setCardDeal(cardsInDeck[index])
                   // dealtCards.append(cards[index])
                }
            }
        }
    }
    
    mutating func setCardDeal(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id} ) {
            cards[chosenIndex].isInDeck = false
        }
       
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func resumeScore() {
        score = 0
    }
    
    
    struct Card: Identifiable, Equatable, Hashable {
        var id: String
        var number: CardNumber
        var shape: CardShape
        var shading: CardShading
        var color: CardColor
        var isSelected: Bool = false
        var isMatched: Bool = false
        var isThreeCardsUnMatched: Bool = false
        var fillColor: Color = .orange
        var isInDeck: Bool = true
        var show: Bool = true
    }


}

enum CardNumber:Int, CaseIterable, Hashable {
    case one = 1
    case two = 2
    case three = 3
}
enum CardColor: CaseIterable,Equatable, Hashable {
    case green
    case purple
    case red
    func toColor() -> Color {
          switch self {
          case .green: return .green
          case .purple: return .purple
          case .red: return .red
          }
      }
    
}
enum CardShape: CaseIterable,Equatable, Hashable {
    case diamond
    case squiggle
    case oval
}
enum CardShading: CaseIterable,Equatable, Hashable {
    case solid
    case striped
    case open
}
