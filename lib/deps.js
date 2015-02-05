var path = require('path');
var findup = require('findup-sync');

module.exports = {
  BASE: '{,*}/',
  EXT: '.{js,coffee}',

  template: function (name) {
    return '**/' + name + '.{js,coffee}';
  },
  node_modules: function () {
  },
  addMissingDot: function (path) {
    if (/^\.\.\//.test(path)) {
      return path;
    } else {
      return './' + path;
    }
  },
  relativeWithoutExt: function (from, to) {
    return this.addMissingDot(path.relative(path.dirname(from), to))
      .replace(new RegExp(path.extname(to) + '$'), '');
  },
  nodeGuess: function (to, from) {
    var cwd = path.dirname(from);
    var guess = findup('node_modules/' + to, {cwd: cwd});
    if (guess) {
      return path.basename(guess);
    } else {
      return null;
    }
  },
  fileGuess: function (to, from) {
    var cwd = path.dirname(from);
    var guess = findup(this.BASE + to + this.EXT, {cwd: cwd});
    if (guess) {
      return this.relativeWithoutExt(from, guess);
    } else {
      return null;
    }
  },
  fix: function (to, from) {
    var node_guess = this.nodeGuess(to, from);
    var file_guess = this.fileGuess(to, from);
    var guesses = [];
    if (file_guess) {
      guesses.push({
        to: file_guess,
        type: 'file'
      });
    }
    if (node_guess) {
      guesses.push({
        to: node_guess,
        type: 'node'
      });
    }
    return guesses;
  }
};
