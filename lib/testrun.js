var assert = require('assert');

var file = require('./file');
var commonify = require('./commonify');

function cleanConsole() {
  console.log('\033[2J');
}

function main() {
  var amdfile, result;
  cleanConsole();
  amdfile = process.env.npm_config_files;
  assert(amdfile,
    'Please provide files. Example: $ npm --files=../file.coffee start');
  result = commonify(file.load(amdfile), {path: amdfile});
  console.log(result.code);
}

main();
