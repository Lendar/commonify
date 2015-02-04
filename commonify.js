var peg = require('./peg');

module.exports = function (contents) {
  return peg.parse(contents);
};
