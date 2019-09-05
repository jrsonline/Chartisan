//
//  RotatableLabel.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 15-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

extension CGSize {
    func rotate() -> CGSize {
        return CGSize(width:self.height, height: self.width)
    }
}



/// A set of labels which knows its size, its container size, and if it's too large, can shrink and rotate itself.
struct RotatableLabelSet: View, FrameReportingView {
    let labels: [String]
    let modifier: (Text) -> Text
    let normalContainerSize: CGSize
    let rotatedContainerSize: CGSize
    let normalContainerCentre: (Int) -> CGPoint
    let rotatedContainerCentre: (Int) -> CGPoint
    let alignWithSteps: StepAlignment
    let alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference
    
    var calculatedPositions : ((Int) -> CGPoint)! = nil
    var calculatedRotated : Bool! = nil
    var calculatedTextSize : CGFloat! = nil
    var calculatedAlignment : Alignment! = nil
    var calculatedFrame : CGSize! = nil
    
    enum RotatableAlignment {
        case top
        case right
        case centre
        case none
        
        func getTextPositioning() -> Alignment {
            switch self {
                case .top: return .center
                case .right: return .trailing
                default: return .center
            }
        }
    }
    
    enum StepAlignment {
        case unaligned
        case xAligned(stepWidth: CGFloat)
        case yAligned(stepWidth: CGFloat)
        
        func adjust(position pos:CGPoint) -> CGPoint {
            switch self {
                case .unaligned : return pos
                case .xAligned(let stepWidth): return CGPoint(x:pos.x + 0.5*stepWidth, y:pos.y)
                case .yAligned(let stepWidth): return CGPoint(x:pos.x, y:pos.y + 0.5*stepWidth)
            }
        }
        
        static func xAlign(with align: Bool, stepWidth: CGFloat? = nil) -> StepAlignment {
            if align {
                return .xAligned(stepWidth: stepWidth!)
            } else {
                return .unaligned
            }
        }
        
        static func yAlign(with align: Bool, stepWidth: CGFloat? = nil) -> StepAlignment {
            if align {
                return .yAligned(stepWidth: stepWidth!)
            } else {
                return .unaligned
            }
        }
    }
    
    struct RotatableAlignmentPreference {
        let normal: RotatableAlignment
        let rotated: RotatableAlignment
        
        func alignment(forRotation isRotated: Bool) -> RotatableAlignment {
            return isRotated ? self.rotated : self.normal
        }
    }
    
    let sFont: Font = Font.body
    
    init(labels: [String],
         modifier: @escaping (Text) -> Text = {$0},
         containerSize: CGSize,
         rotatedContainerSize: CGSize? = nil,
         containerCentre: @escaping (Int) -> CGPoint,
         rotatedContainerCentre: ((Int) -> CGPoint)? = nil,
         alignWithSteps: StepAlignment,
         alignmentPreference: RotatableAlignmentPreference) {
        self.labels = labels
        self.modifier = modifier
        self.normalContainerSize = containerSize
        self.rotatedContainerSize = rotatedContainerSize ?? containerSize.rotate()
        self.normalContainerCentre = containerCentre
        self.rotatedContainerCentre = rotatedContainerCentre ?? containerCentre
        self.alignWithSteps = alignWithSteps
        self.alignmentPreference = alignmentPreference
        
        // Do the calculation
        (calculatedPositions, calculatedRotated, calculatedTextSize, calculatedAlignment, calculatedFrame) = self.getBestTextSizePositionAndOrientation()
    }
    
    var frames: [String:CGRect] { get {
        Dictionary(uniqueKeysWithValues: self.labels.enumerated().map { nx in
            let (n,_) = nx
            return ("\(n)",CGRect(origin: self.calculatedPositions(n), size: self.calculatedFrame) )
        })
        }
    }
    
    var body: some View {
        
        return ZStack {
            ForEach(IndexedItem.box(self.labels)) { label in
                self.modifier(Text(label.dt)
                .font(.system(size: self.calculatedTextSize)))
                .allowsTightening(true)
                .lineLimit(2)
                .frame(width:self.calculatedFrame.width, height:self.calculatedFrame.height, alignment: self.calculatedAlignment)
//                .border(Color.red)
                .rotationEffect(Angle(degrees:self.calculatedRotated ? 270.0 : 0.0))
                .position(self.calculatedPositions(label.id))
            }
        }
    }
    
    public func with<OtherView: View>(@ViewBuilder builder:(CGRect) -> OtherView) -> AnyView {
        let (position, rotated, _, _, frame) = self.getBestTextSizePositionAndOrientation()
        let coveringFrame = self.labels.enumerated().reduce(CGRect.null) { f,nx in
            return f.union(CGRect.centred(at: position(nx.0), size: frame.transpose(ifRotated: rotated)))
        }
        return ZStack {
            self.body
            builder(coveringFrame)
        }.asAnyView
    }
    
    private func getBestTextSizeAndOrientation() -> (textSize: CGFloat, rotated: Bool, newSize:CGSize) {
        let uFont = self.sFont.getUIFont()
        
        // first find  the largest bounding box for a reasonable font size
        let maxStringSize = getMaxTextSize(for: labels, withFont: uFont)

        let ratio = self.normalContainerSize.width / maxStringSize.width
        let rotatedRatio = self.rotatedContainerSize.height / maxStringSize.width
        let (textSize, rotated) : (CGFloat, Bool) = {
         switch (ratio, rotatedRatio) {
             case (0..<0.75, 1.0...) : return (floor(uFont.pointSize), true)
             case (0..<0.75, 0.3..<1.0) : return (floor(uFont.pointSize * rotatedRatio), true)
             case (0.75..<1.0,_): return (floor(uFont.pointSize * ratio), false)
             default : return (uFont.pointSize, false)
         }
        }()
        return (textSize: textSize, rotated: rotated, newSize: getMaxTextSize(for:labels, withFont: uFont, ofSize: textSize))
     }
    
    private func getBestTextSizePositionAndOrientation() -> (position: (Int) -> CGPoint, rotated: Bool, textSize: CGFloat, alignment: Alignment, frame: CGSize) {
        let (textSize, rotated, newSize) = getBestTextSizeAndOrientation()

        let containerCentre = rotated ? rotatedContainerCentre : normalContainerCentre
        let containerSize = newSize
        let rotatedContainerSize = containerSize
        
        let doAlignWithSteps : (CGPoint) -> CGPoint = { (pos : CGPoint) in
            return self.alignWithSteps.adjust(position: pos)
        }
        
        let doAlignToPreference: (CGPoint) -> CGPoint = { (pos : CGPoint) in
            switch self.alignmentPreference.alignment(forRotation: rotated) {
            case .top:
                return CGPoint(x:pos.x, y: pos.y + 0.5 * (containerSize.height + Cartesian.TEXT_LABEL_OFFSET))
            case .right:
                return CGPoint(x: pos.x - containerSize.width/2.0 - Cartesian.TEXT_LABEL_OFFSET,
                               y: pos.y)
            default:
                return pos
            }
        }
        
       return ( {i in (doAlignToPreference • doAlignWithSteps • containerCentre)(i) },
                rotated,
                textSize,
                self.alignmentPreference.alignment(forRotation: rotated).getTextPositioning(),
                rotatedContainerSize)
    }
     
     private func getMaxTextSize(for ts:[String], withFont font: UIFont) -> CGSize {
         return ts.map( { $0.sizeOfString(usingFont: font) }).max()  ?? CGSize.zero
     }

    private func getMaxTextSize(for ts:[String], withFont font: UIFont, ofSize size:CGFloat) -> CGSize {
        return getMaxTextSize(for: ts, withFont: font.withSize(size))
    }
}

/// A list of labels which know their maximum size and will shrink and rotate themselves all together
struct RotatableLabel : View {
    let labelSet: RotatableLabelSet
                
    init(label: String,
         modifier: @escaping (Text) -> Text = {$0},
         containerSize: CGSize,
         rotatedContainerSize: CGSize? = nil,
         containerCentre: CGPoint,
         rotatedContainerCentre: CGPoint? = nil,
         alignWithSteps: RotatableLabelSet.StepAlignment,
         alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference) {
        
        self.labelSet = RotatableLabelSet(
            labels: [label],
            modifier: modifier,
            containerSize: containerSize,
            rotatedContainerSize: rotatedContainerSize,
            containerCentre: { _ in containerCentre },
            rotatedContainerCentre: rotatedContainerCentre == nil ? { _ in containerCentre } : { _ in rotatedContainerCentre! },
            alignWithSteps: alignWithSteps,
            alignmentPreference: alignmentPreference
        )
    }
    
    var body: some View {
        self.labelSet.body
    }
}


