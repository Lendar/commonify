var peg = require('./peg');
var template = require('./template');

module.exports = function (code) {
  var parsed = peg.parse(code);
  if (parsed.type === 'amd') {
    var cjs = template.render(parsed);
    return {
      code: cjs,
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
