var fs = require('fs');
var PEG = require('pegjs');
var parser = PEG.buildParser(fs.readFileSync('coffee.pegjs', 'utf8'));

module.exports = parser;
