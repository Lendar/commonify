var assert = require('assert');
var _ = require('lodash');
var stripIndent = require('strip-indent');

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
  render: function (data) {
    var head, return_statement, body;
    data.requires = data.requires || [];
    data.vars = data.vars || [];
    return_statement = data.return_statement;
    body = stripIndent(data.body);
    head = this.requires(data) + '\n\n';
    if (data.return_type === 'implicit_object') {
      exports = 'module.exports =\n' + data.return_statement;
    } else {
      exports = 'module.exports =' + data.return_statement;
    }
    if (data.vars.length) {
      return head + body + exports;
    }
    else {
      return body + exports;
    }
  }
};
