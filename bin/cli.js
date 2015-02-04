#!/usr/bin/env node

var minimist = require('minimist');
var file = require('../lib/file');
var commonify = require('../lib/commonify');


function main(argv) {
  argv._.map(function (amdfile) {
    console.log('--- Converting', amdfile);
    var result = commonify(file.load(amdfile));
    console.log('--- Result:', result.message);
    console.log('');
  });
}

var argv = minimist(process.argv.slice(2));
main(argv);
