import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // Star background
            ForEach(0..<60, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.6)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...900)
                    )
            }
            
            VStack(spacing: 32) {
                Spacer()
                Text("✦")
                    .font(.system(size: 60))
                Text("AstralVeil")
                    .font(.system(size: 42, weight: .thin))
                    .foregroundColor(.white)
                    .tracking(8)
                Text("When were you born?")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .colorScheme(.dark)
                    .labelsHidden()
                
                Button(action: { profile.birthDate = selectedDate }) {
                    Text("REVEAL MY PATH")
                        .tracking(4)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding()
        }
    }
}//
//  OnboardingView.swift
//  AstralVeil
//
//  Created by Tania on 04.03.2026.
//

