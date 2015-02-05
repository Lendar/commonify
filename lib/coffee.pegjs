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

AMDProgram = type:AMDKeyword __ modules:(Modules __ ',')? __ args:(Arguments __)? module_fn:CoffeeFunction {
  return {
    type: 'amd',
    requires: modules ? modules[0].elements : null,
    vars: args ? args[0] : null,
    body: module_fn.body,
    return_statement: module_fn.return_statement //body.join('')
  };
}

CJSProgram = Raw {
  return {type: 'cjs'};
}

Modules = __ e:ArrayLiteral {
  return e;
}

AMDKeyword = 'require' / 'define'

CoffeeFunction = Arrow lines:TopWhiteSpaceBody {
  var _ = require('lodash');
  var return_line = _(lines)
    .xor()
    .reverse()
    .filter('code')
    .min('indent')
    .line;
  var parts = _(lines)
    .partition(function(x) {return x.line < return_line})
    .value();
  var body = _(parts[0])
    .map('indented_code')
    .value()
    .join('\n');
  var return_statement = _(parts[1])
    .map('indented_code')
    .value()
    .join('\n');
  return {
    body: body,
    return_statement: return_statement
  };
}

Arrow = '->' / '=>'

TopWhiteSpaceBody =
  _? '\n' body:CoffeeLine+ {
    return body;
  }

CoffeeLine = indent:Zs* code:[^\n]* '\n' {
  return {
    line: line(),
    indent: indent.length,
    code: code.join(''),
    indented_code: indent.join('') + code.join('')
  };
}

Raw = .*
