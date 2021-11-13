//
//  UserView.swift
//  SwiftZoomin8
//
//  Created by KAWASHIMA Yoshiyuki on 2021/11/13.
//

import SwiftUI

@MainActor struct UserView: View {
    
    @StateObject private var state: UserViewState
    
    init(id: User.ID) {
        self._state = StateObject(wrappedValue: UserViewState(id: id))
    }
    
    var body: some View {
        VStack {
            Group {
                if let iconImage = state.iconImage {
                    Image(uiImage: iconImage)
                    .resizable()
                } else {
                    Color.clear
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(uiColor: .systemGray3), lineWidth: 4))
            
            if let name = state.user?.name {
                Text(name)
            }
            
            Spacer()
        }
        .padding(16)
        .task {
            await state.loadUser()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(id: 1)
    }
}
