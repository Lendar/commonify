{{javascript}}

// --- CoffeeScript grammar overrides JavaScript ------------------------------

ElementList
  = first:(
      elision:(Elision __)? element:AssignmentExpression {
        return optionalList(extractOptional(elision, 0)).concat(element);
      }
    )
    rest:(
      __ ","? __ elision:(Elision __)? element:AssignmentExpression {
        return optionalList(extractOptional(elision, 0)).concat(element);
      }
    )*
    { return Array.prototype.concat.apply(first, rest); }

ArrayLiteral = "[" __ elision:(Elision __)? "]" {
      return {
        type:     "ArrayExpression",
        elements: optionalList(extractOptional(elision, 0))
      };
    }
  / "[" __ elements:ElementList __ "]" {
      return {
        type:     "ArrayExpression",
        elements: elements
      };
    }
  / "[" __ elements:ElementList __ ","? __ elision:(Elision __)? "]" {
      return {
        type:     "ArrayExpression",
        elements: elements.concat(optionalList(extractOptional(elision, 0)))
      };
    }

SingleLineComment
  = "#" (!LineTerminator SourceCharacter)*

ArgumentList
  = first:AssignmentExpression rest:(__ ","? __ AssignmentExpression)* {
      return buildList(first, rest, 3);
    }

// ----------------------------------------------------------------------------



Program = AMDProgram / CJSProgram

AMDProgram = type:AMDKeyword __ modules:(Modules __ ',')? __ args:(Arguments __)? Arrow body:Raw {
  return {
    type: 'amd',
    requires: modules ? modules[0].elements : null,
    vars: args ? args[0] : null,
    body: body.join('')
  };
}

CJSProgram = Raw {
  return {type: 'cjs'};
}

Modules = __ e:ArrayLiteral {
  return e;
}

Arrow = '->' / '=>'
AMDKeyword = 'require' / 'define'
Raw = .*
