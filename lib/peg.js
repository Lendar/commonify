var fs = require('fs');
var path = require('path');
var PEG = require('pegjs');
var grammar = fs.readFileSync(path.join(__dirname, 'coffee.pegjs'), 'utf8');
var parser = PEG.buildParser(grammar);

module.exports = parser;
