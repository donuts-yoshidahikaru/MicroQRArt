//
//  QRCodeImageGenerator.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/05.
//

import UIKit

// MARK: - QR Code Image Generator
final class QRCodeImageGenerator {
    
    // MARK: - Configuration
    struct PlaceholderConfig {
        let size: CGSize
        let backgroundColor: UIColor
        let foregroundColor: UIColor
        let patternSize: CGFloat
        
        static let `default` = PlaceholderConfig(
            size: CGSize(width: 56, height: 56),
            backgroundColor: .systemGray5,
            foregroundColor: .label,
            patternSize: 4
        )
    }
    
    // MARK: - Public Methods
    static func createPlaceholder(config: PlaceholderConfig = .default) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Background
        config.backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: config.size))
        
        // QR pattern simulation
        config.foregroundColor.setFill()
        
        let rows = Int(config.size.height / config.patternSize)
        let cols = Int(config.size.width / config.patternSize)
        
        for row in 0..<rows {
            for col in 0..<cols {
                if shouldFillPattern(row: row, col: col) {
                    let rect = CGRect(
                        x: CGFloat(col) * config.patternSize,
                        y: CGFloat(row) * config.patternSize,
                        width: config.patternSize,
                        height: config.patternSize
                    )
                    UIRectFill(rect)
                }
            }
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - Private Methods
    private static func shouldFillPattern(row: Int, col: Int) -> Bool {
        // Create a more QR-like pattern instead of simple checkerboard
        let size = 14 // Assuming 14x14 grid for 56x56 with 4px pattern
        
        // Corner detection squares (simplified)
        if isCornerDetectionSquare(row: row, col: col, gridSize: size) {
            return true
        }
        
        // Random-like pattern for data area
        return (row + col) % 2 == 0 && (row * 3 + col * 7) % 5 != 0
    }
    
    private static func isCornerDetectionSquare(row: Int, col: Int, gridSize: Int) -> Bool {
        let cornerSize = 3
        
        // Top-left corner
        if row < cornerSize && col < cornerSize {
            return row == 0 || col == 0 || (row == cornerSize - 1 && col < cornerSize) || (col == cornerSize - 1 && row < cornerSize)
        }
        
        // Top-right corner
        if row < cornerSize && col >= gridSize - cornerSize {
            return row == 0 || col == gridSize - 1 || (row == cornerSize - 1) || (col == gridSize - cornerSize)
        }
        
        // Bottom-left corner
        if row >= gridSize - cornerSize && col < cornerSize {
            return col == 0 || row == gridSize - 1 || (row == gridSize - cornerSize) || (col == cornerSize - 1)
        }
        
        return false
    }
}