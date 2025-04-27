import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    var onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            TextField("검색해주세요.", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(8)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    isFocused = false
                    onSearch()
                }

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = false
                    onClear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
