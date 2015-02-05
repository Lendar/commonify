var assert = require('assert');
var _ = require('lodash');
var stripIndent = require('strip-indent');
var indentString = require('indent-string');

var INDENT_STYLE = ' ';
var INDENT_SIZE = 2;

module.exports = {
  requires: function (data) {
    assert(data.requires, 'missing data.requires');
    assert(data.vars, 'missing data.vars');
    return _.zip(data.vars, data.requires).map(function (pair) {
      var moduleName = pair[0] ? pair[0].name : null;
      var modulePath = pair[1].value;
      if (moduleName) {
        return moduleName + ' = ' + "require('" + modulePath  + "')";
      } else {
        return "require('" + modulePath  + "')";
      }
    }).join('\n');
  },
  deindentFirstLine: function (str) {
    var lines = str.split('\n');
    var rest = lines.slice(1).join('\n');
    var reindentedRest = indentString(stripIndent(rest), INDENT_STYLE, INDENT_SIZE);
    return stripIndent(lines[0]) + '\n' + reindentedRest;
  },
  render: function (data) {
    var head, return_statement, body;
    data.requires = data.requires || [];
    data.vars = data.vars || [];
    return_statement = data.return_statement;
    body = stripIndent(data.body);
    head = this.requires(data) + '\n\n';
    if (data.return_type === 'implicit_object') {
      exports = 'module.exports =\n' + return_statement;
    } else {
      exports = 'module.exports = ' + this.deindentFirstLine(return_statement);
    }
    if (data.vars.length) {
      return head + body + '\n' + exports + '\n';
    }
    else {
      return body + '\n' + exports + '\n';
    }
  }
};
