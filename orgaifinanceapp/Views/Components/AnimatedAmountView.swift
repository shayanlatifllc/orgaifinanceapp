import SwiftUI

struct AnimatedAmountView: View {
    let amount: Decimal
    let font: Font
    let color: Color
    
    @State private var showFullAmount = false
    
    var body: some View {
        Text(showFullAmount ? 
            AmountFormatter.formatCurrency(amount) :
            AmountFormatter.formatCompactCurrency(amount))
            .font(font)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .truncationMode(.tail)
            .fixedSize(horizontal: true, vertical: false)
            .contentTransition(.numericText(value: Double(truncating: amount as NSNumber)))
            .transaction { transaction in
                transaction.animation = .spring(response: 0.3, dampingFraction: 0.8)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: amount)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showFullAmount.toggle()
                }
            }
    }
} 