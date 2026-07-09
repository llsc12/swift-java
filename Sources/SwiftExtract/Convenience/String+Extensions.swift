//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift.org project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift.org project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SwiftParser

extension String {

  package var firstCharacterUppercased: String {
    guard let f = first else {
      return self
    }

    return "\(f.uppercased())\(String(dropFirst()))"
  }

  package var firstCharacterLowercased: String {
    guard let f = first else {
      return self
    }

    return "\(f.lowercased())\(String(dropFirst()))"
  }

  /// If the string ends with `.swift`, return it without that suffix;
  /// otherwise return self unchanged
  package func dropSwiftFileSuffix() -> String {
    if hasSuffix(".swift") {
      return String(dropLast(".swift".count))
    }
    return self
  }

  /// Unescapes the name if it is surrounded by backticks.
  package var unescapedSwiftName: String {
    if count >= 2 && hasPrefix("`") && hasSuffix("`") {
      return String(dropFirst().dropLast())
    }
    return self
  }

  /// Backtick-escape this name if needed to use it as a new local binding
  /// (`let`/`var`, or a capture in a `case let .foo(name)` pattern).
  ///
  /// Many Swift declarations use a reserved keyword as a parameter label
  /// (`else:`, `for:`, `in:`, ...) - Swift allows that for labels, so such
  /// names show up unremarkably as `param.name` when jextract walks a
  /// function's parameters. But reusing that same bare string as a *new
  /// binding name* is a different context that keywords aren't valid in
  /// without backticks; printing it unescaped produces a parse error (or
  /// silently-wrong parse, since e.g. a bare `else` reads as the start of an
  /// `if`/`else`) in the generated file.
  package var escapedAsSwiftBindingName: String {
    isValidSwiftIdentifier(for: .variableName) ? self : "`\(self)`"
  }

  /// Same escaping as `escapedAsSwiftBindingName`, but only applied when this
  /// string is itself a bare identifier token. Some call sites reuse a
  /// parameter's raw name both to build derived names (e.g. `"\(name)Bits$"`)
  /// and to reference the parameter's own value as an expression (e.g.
  /// `"fromJNI: \(name)"`); by the time the latter is rendered, `name` may
  /// already have been substituted with a compound expression (a property
  /// access chain, a call, ...) rather than a plain identifier. Backtick-
  /// escaping a compound expression corrupts it, so leave anything that isn't
  /// a simple identifier untouched.
  package var escapedAsSwiftReference: String {
    guard !isEmpty, allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" || $0 == "$" }) else {
      return self
    }
    return escapedAsSwiftBindingName
  }
}
