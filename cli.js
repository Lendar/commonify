#!/usr/bin/env node

var minimist = require('minimist');
var file = require('./file');
var commonify = require('./commonify');


function main(argv) {
  argv._.map(function (amdfile) {
    console.log('--- Converting', amdfile);
    var content = commonify(file.load(amdfile));
    if (content.type === 'amd') {
      console.log('requires =', content.requires);
      console.log('vars =', content.vars);
    }
    else if (content.type === 'cjs') {
      console.log('skipping CommonJS file');
    }
    else {
      throw new Error('Unknown type: ' + content.type);
    }
  });
}

var argv = minimist(process.argv.slice(2));
main(argv);
