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
    return_type: module_fn.return_type,
    return_statement: module_fn.return_statement
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
  var min_indent = _(lines)
    .filter('code')
    .min('indent')
    .indent;
  var return_type;
  var guess_return_statement = _(lines)
    .filter('code')
    .filter(function (x) {return x.indent === min_indent})
    .takeRightWhile(function (x) {
      return x.type === 'implicit_object' || x.type === 'comment';
    })
    .first();
  if (guess_return_statement) {
    return_type = 'implicit_object'
  }
  else {
    guess_return_statement = _(lines)
      .filter('code')
      .filter(function (x) {return x.indent === min_indent})
      .last();
    if (!guess_return_statement) {
      error('Could not find return statement');
    }
    if (guess_return_statement.type === 'explicit_return') {
      return_type = 'explicit_return';
    } else {
      return_type = 'implicit_value';
    }
  }
  return_line = guess_return_statement.line;
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
    return_type: return_type,
    return_statement: return_statement
  };
}

Arrow = '->' / '=>'

TopWhiteSpaceBody =
  _? '\n' body:CoffeeLine+ {
    return body;
  }

CoffeeLine = indent:Zs* expression:CoffeeLineExpression '\n' {
  return {
    line: line(),
    indent: indent.length,
    type: expression.type,
    code: expression.code,
    indented_code: indent.join('') + expression.code
  };
}

CoffeeLineExpression = CoffeeReturnStatement / CoffeeLineObject / CoffeeLineComment / CoffeeLineText

CoffeeReturnStatement = 'return ' text:CoffeeLineText {
  return {
    type: 'explicit_return',
    code: text.code
  };
}

CoffeeLineObject = key:PropertyName s1:_ ':' s2:_ value:CoffeeLineText {
  var keyname = key.name ? key.name : ("'" + key.value + "'");
  return {
    type: 'implicit_object',
    code: keyname + s1.join('') + ':' + s2.join('') + value.code,
    key: key,
    value: value
  };
}

CoffeeLineComment = '#' ' '? comment:CoffeeLineText {
  return {
    type: 'comment',
    code: '# ' + comment.code
  };
}

CoffeeLineText = text:[^\n]* {
  return {
    type: 'text',
    code: text.join(''),
  }
}

Raw = .*
