var fs = require('fs');
var path = require('path');
var PEG = require('pegjs');
var js_grammar = fs.readFileSync(path.join(__dirname, 'javascript.pegjs'), 'utf8');
var coffee_grammar = fs.readFileSync(path.join(__dirname, 'coffee.pegjs'), 'utf8');
coffee_grammar = coffee_grammar.replace('{{javascript}}', js_grammar);
var parser = PEG.buildParser(coffee_grammar);

module.exports = parser;
