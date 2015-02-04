var assert = require('assert');
var stripIndent = require('strip-indent');
var _ = require('lodash');

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
    return this.requires(data) + '\n' + stripIndent(data.body);
  }
};
