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

DestructingIdentifier = Identifier / '{' ident:Identifier '}' {
  return {name: '{' + ident.name + '}'};
}

FormalParameterList
  = first:DestructingIdentifier rest:(__ ","? __ DestructingIdentifier)* {
      return buildList(first, rest, 3);
    }

// ----------------------------------------------------------------------------



Program = AMDProgram / CJSProgram

AMDProgram = type:AMDKeyword __ modules:(Modules __ ',')? __ module_fn:CoffeeFunction {
  return {
    type: 'amd',
    requires: modules ? modules[0] : null,
    vars: module_fn.args ? module_fn.args[0] : null,
    body: module_fn.body,
    return_type: module_fn.return_type,
    return_statement: module_fn.return_statement
  };
}

CJSProgram = Raw {
  return {type: 'cjs'};
}

Modules = __ modules:ArrayLiteral {
  return modules.elements.map(function (item) {
    return item.value;
  });
}

AMDKeyword = 'require' / 'define'

CoffeeFunction = args:CoffeeFunctionArgs? __ Arrow lines:TopWhiteSpaceBody {
  var _ = require('lodash');
  var min_indent = _(lines)
    .filter('code')
    .min('indent')
    .indent;
  var return_type;
  var top_lines;
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
  if (!guess_return_statement) {
    top_lines = _(lines)
      .filter('code')
      .filter(function (x) {return x.indent === min_indent});
    if (top_lines.last().type === 'bracket_right') {
      guess_return_statement = top_lines.findLast({type: 'bracket_left'});
    }
    return_type = 'implicit_array';
  };
  if (!guess_return_statement) {
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
  var return_line = guess_return_statement.line;
  var parts = _(lines)
    .partition(function(x) {return x.line < return_line})
    .value();
  var body = _(parts[0])
    .map('indented_code')
    .value()
    .join('\n');
  var return_statement = _(parts[1])
    .first()
    .indented_code_without_return;
  return_statement += '\n' + _(parts[1])
    .rest()
    .map('indented_code')
    .value()
    .join('\n');
  return {
    args: args,
    body: body,
    return_type: return_type,
    return_statement: return_statement
  };
}

CoffeeFunctionArgs =
  "(" __ args:(FormalParameterList __)? ")" { return args; }

Arrow = '->' / '=>'

TopWhiteSpaceBody =
  _? multiline:'\n'? body:(CoffeeLine '\n')* last:CoffeeLine '\n'? {
    return body.map(function (x) {
      return x[0];
    }).concat(last);
  }

CoffeeLine = indent:Zs* expression:CoffeeLineExpression {
  var without_return;
  if (expression.type === 'explicit_return') {
    without_return = expression.code_without_return;
  } else {
    without_return = expression.code;
  }
  return {
    line: line(),
    indent: indent.length,
    type: expression.type,
    code: expression.code,
    indented_code_without_return: indent.join('') + without_return,
    indented_code: indent.join('') + expression.code
  };
}

CoffeeLineExpression = CoffeeReturnStatement / CoffeeLineBracket / CoffeeLineObject / CoffeeLineComment / CoffeeLineText

CoffeeLineBracket = bracket:('[' / ']') text:CoffeeLineText {
  var type;
  if (bracket === '[') {
    type = 'bracket_left';
  } else if (bracket === ']') {
    type = 'bracket_right';
  }

  return {
    type: type,
    code: bracket + text.code
  };
}

CoffeeReturnStatement = 'return ' text:CoffeeLineText {
  return {
    type: 'explicit_return',
    code_without_return: text.code,
    code: 'return ' + text.code
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
