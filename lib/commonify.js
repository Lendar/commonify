var peg = require('./peg');
var template = require('./template');
var deps = require('./deps');

module.exports = function (code, options) {
  var parsed, cjs, oldRequires, misses;
  options = options || {};
  parsed = peg.parse(code);
  misses = [];
  if (parsed.type === 'amd') {
    oldRequires = parsed.requires;
    if (options.path && oldRequires) {
      parsed.requires = oldRequires.map(function (to) {
        var guesses = deps.fix(to, options.path);
        if (guesses.length === 0) {
          misses.push({to: to, msg: 'Missing deps'});
          return 'TODO: fix path: ' + to;
        } else {
          return guesses[0].to;
        }
      });
    }
    cjs = template.render(parsed);
    return {
      code: cjs,
      requires: {
        old: oldRequires,
        fixed: parsed.requires
      },
      message: 'Convert AMD file to CJS'
    };
  }
  else if (parsed.type === 'cjs') {
    return {
      message: 'Skipping CommonJS file'
    };
  }
  else {
    throw new Error('Unknown type: ' + parsed.type);
  }
};
