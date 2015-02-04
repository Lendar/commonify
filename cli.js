#!/usr/bin/env node

var minimist = require('minimist');
var file = require('./file');
var commonify = require('./commonify');


function main(argv) {
  argv._.map(function (amdfile) {
    console.log('--- Converting', amdfile);
    var content = commonify(file.load(amdfile));
    console.log(content.vars);
  });
}

var argv = minimist(process.argv.slice(2));
main(argv);
