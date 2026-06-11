extension Array {
    func unwrapped<Wrapped>() -> [Wrapped]? where Element == Wrapped? {
        var result: [Wrapped] = []
        result.reserveCapacity(count)

        for element in self {
            guard let element else {
                return nil
            }
            result.append(element)
        }

        return result
    }
}
