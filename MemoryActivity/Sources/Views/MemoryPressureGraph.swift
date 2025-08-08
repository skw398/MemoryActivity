import SwiftUI

struct MemoryPressureGraph: View {
    typealias Data = MemoryData.MemoryPressure.Data

    let memoryPressure: MemoryData.MemoryPressure

    var body: some View {
        Canvas { context, size in
            let data = memoryPressure.data
            let maxDataCount = memoryPressure.capacity
            let dataPointWidth = 1.0
            let lineWidth = 0.75

            var anchor: (point: CGPoint, data: Data)?
            for (i, target) in data.reversed().enumerated() {
                let point = CGPoint(
                    x: size.width - CGFloat(i) * dataPointWidth * size.width / CGFloat(maxDataCount - 1),
                    y: size.height * (1 - CGFloat(target.value) / 100)
                )

                if let anchor {
                    let start = anchor.point
                    let endXOffset = (anchor.data.level == target.level || i == data.count - 1) ? 0 : dataPointWidth / 2
                    let end = CGPoint(x: point.x + endXOffset, y: point.y)
                    let color = Color(anchor.data.level.colorResource)

                    var area = Path()
                    area.move(to: start)
                    area.addLine(to: end)
                    area.addLine(to: CGPoint(x: end.x, y: size.height))
                    area.addLine(to: CGPoint(x: start.x, y: size.height))
                    area.closeSubpath()
                    let shading = GraphicsContext.Shading.linearGradient(
                        Gradient(colors: [color.opacity(0.4), color.opacity(0.35)]),
                        startPoint: CGPoint(x: start.x, y: start.y),
                        endPoint: CGPoint(x: start.x, y: size.height)
                    )
                    context.fill(area, with: shading)

                    var top = Path()
                    top.move(to: start)
                    top.addLine(to: end)
                    context.stroke(top, with: .color(color), lineWidth: lineWidth)

                    if i == data.count - 1 {
                        var left = Path()
                        left.move(to: CGPoint(x: end.x, y: size.height))
                        left.addLine(to: CGPoint(x: end.x, y: point.y))
                        context.stroke(
                            left, with: .color(color), lineWidth: lineWidth * (data.count == maxDataCount ? 2 : 1)
                        )
                    }

                    var bottom = Path()
                    bottom.move(to: CGPoint(x: start.x, y: size.height))
                    bottom.addLine(to: CGPoint(x: end.x, y: size.height))
                    context.stroke(bottom, with: .color(color), lineWidth: lineWidth * 2)

                    if i == 1 {
                        var right = Path()
                        right.move(to: CGPoint(x: start.x, y: size.height))
                        right.addLine(to: CGPoint(x: start.x, y: point.y))
                        context.stroke(right, with: .color(color), lineWidth: lineWidth * 2)
                    }
                }

                anchor = (point: point, data: target)
            }
        }
    }
}

#Preview {
    VStack {
        Group {
            MemoryPressureGraph(memoryPressure: MemoryData.sample.memoryPressure)
            MemoryPressureGraph(
                memoryPressure: MemoryData.MemoryPressure(
                    data: MemoryData.sample.memoryPressure.data.suffix(50),
                    capacity: MemoryData.sample.memoryPressure.data.capacity
                )
            )
        }
        .frame(width: 198, height: 58)
        .border(.separator)
    }
    .padding()
}
