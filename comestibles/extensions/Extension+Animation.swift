//
//  Extension+Animation.swift
//  tageweise
//
//  Created by Daniel Kagemann on 29.12.23.
//

import SwiftUI

enum AnimationDirection {
   case horizontal
   case vertical
}

struct Slide: ViewModifier {
   @State var animate: Bool = false
   var direction: AnimationDirection
   var value: Double
   
   func body(content: Content) -> some View {
      content
         .offset(x: direction == .horizontal ? (animate ? 0 : value) : 0,
                 y: direction == .vertical ? (animate ? 0 : value) : 0)
         .opacity(animate ? 1 : 0)
         .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
               animate.toggle()
            }
         }
   }
}

enum ViewAlign {
   case left
   case right
}

struct Align: ViewModifier {
   
   var align: ViewAlign
   
   func body(content: Content) -> some View {
      if align == .left {
         HStack {
            content
            Spacer()
         }
      } else {
         HStack {
            Spacer()
            content
         }
      }
   }
}

extension View {   
   func slideUp(value: Double = 30) -> some View {
      modifier(Slide(direction: .vertical, value:  value))
   }
   
   func slideDown(value: Double = 30) -> some View {
      modifier(Slide(direction: .vertical, value: -value))
   }

   func slideLeft(value: Double = 30) -> some View {
      modifier(Slide(direction: .horizontal, value:  value))
   }
   
   func slideRight(value: Double = 30) -> some View {
      modifier(Slide(direction: .horizontal, value: -value))
   }
   
   func fadeIn() -> some View {
      modifier(Slide(direction: .horizontal, value: 0))
   }
   
   func alignLeft() -> some View {
      modifier(Align(align: .left))
   }
   
   func alignRight() -> some View {
      modifier(Align(align: .right))
   }
}
