var assert = require('assert');

var file = require('./file');
var commonify = require('./commonify');

function cleanConsole() {
  console.log('\033[2J');
}

function main() {
  var amdfiles, content;
  cleanConsole();
  amdfiles = process.env.npm_config_files;
  assert.ok(amdfiles,
    'Please provide files. Example: $ npm --files=../file.coffee start');
  result = commonify(file.load(amdfiles));
  console.log(result.code);
}

main();
