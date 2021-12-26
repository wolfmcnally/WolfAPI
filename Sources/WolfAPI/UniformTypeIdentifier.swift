//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/25/21.
//

import WolfBase

// See also: https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_intro/understand_utis_intro.html#//apple_ref/doc/uid/TP40001319-CH201-SW1
public struct UniformTypeIdentifier: Enumeration, Codable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }
}

// See also: https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
extension UniformTypeIdentifier {
    // There is no UTI for JSON
    public static let jpg = UniformTypeIdentifier("public.jpeg")
    public static let png = UniformTypeIdentifier("public.png")
    public static let gif = UniformTypeIdentifier("com.compuserve.gif")
    public static let html = UniformTypeIdentifier("public.html")
    public static let txt = UniformTypeIdentifier("public.plain-text")
    public static let pdf = UniformTypeIdentifier("com.adobe.pdf")
    public static let mp4 = UniformTypeIdentifier("public.mpeg-4")
    public static let vcard = UniformTypeIdentifier("public.vcard")
}
