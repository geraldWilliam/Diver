//
//  LoginView.swift
//  Diver
//
//  Created by Gerald Burke on 8/1/24.
//

import SwiftUI

@MainActor struct LoginView: View {
    @Environment(Session.self) var session
    @Environment(Instances.self) var instances
    
    // TODO: Move instance list to separate view.
    @State private var instanceName: String = ""
    @FocusState private var addingInstance: Bool

    var body: some View {
        @Bindable var session = session
        ZStack {
            ForEach(0..<4) { index in
                BubbleView(
                    isHidden: $session.isLoggedIn,
                    startAfter: TimeInterval(index)
                )
            }
            VStack {
                Group {
                    Text("Welcome to Diver")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("A Fediverse Client")
                        .font(.headline)
                }
                .foregroundColor(Color.primary)
                .fontDesign(.rounded)

                Button(action: { session.logIn() }) {
                    Text("Sign In")
                        .fontWeight(.medium)
                        .padding(.horizontal)
                }
                .primaryButtonStyle()
                .padding(.top)
                
                CardView {
                    ScrollView {
                        VStack {
                            Spacer()
                                .frame(height: 50)
                            
                            Group {
                                Button(action: { addingInstance = true }) {
                                    Label {
                                        Text("Add an Instance")
                                    } icon: {
                                        Image(systemName: "plus")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                /// Button press should...
                                /// - Add an item with empty text
                                /// - Activate keyboard
                                /// - On return, call instances.add(newInstance)
//                                if addingInstance {
                                    TextField("Instance Name", text: $instanceName)
                                        .focused($addingInstance)
                                        .onSubmit {
                                            // TODO: Validate URL
                                            if instanceName.isEmpty == false {
                                                instances.add(instanceName)
                                            }
                                            instanceName = ""
                                            addingInstance = false
                                        }
//                                }
                                ForEach(instances.available) { instance in
                                    Button(action: { }) {
                                        Text(instance.domainName)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                }
                .padding(12)
                .frame(maxHeight: 300)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Color.blue.opacity(0.35))
        .alert(isPresented: $session.showingError, error: session.failure) {
            Button(action: { session.failure = nil }) {
                Text("OK")
            }
        }
    }
}

#Preview {
    let session = Session(repo: MockSessionRepository())
    return LoginView()
        .environment(session)

}
