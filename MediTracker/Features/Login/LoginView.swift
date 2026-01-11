import SwiftUI

struct LoginView: View {
    @Binding var isPresented: Bool

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol, isPresented: Binding<Bool>){
        self.authService = authService
        _isPresented = isPresented
    }
    
    private var viewModel: LoginViewModel {
        return LoginViewModel(authService: authService)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Please sign in")
                    .font(.title2)

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("Log in") {
                    Task {
                         do {
                            try await viewModel.login(username: username, password: password)
                            isPresented = false
                        } catch {
                            errorMessage = "Invalid credentials"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .interactiveDismissDisabled(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authService: AuthenticationServicePreview(), isPresented: .constant(true))
    }
}
