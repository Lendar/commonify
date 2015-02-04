#!/usr/bin/env node

var minimist = require('minimist');
var file = require('../lib/file');
var commonify = require('../lib/commonify');


function main(argv) {
  argv._.map(function (amdfile) {
    console.log('--- Converting', amdfile);
    var result = commonify(file.load(amdfile));
    if (argv.dry || !result.code) {
      console.log('--- Result:', result.message);
      if (argv.dry && result.code) {
        console.log(result.code);
      }
      console.log('');
    } else {
      file.save(amdfile, result.code);
    }
  });
}

var argv = minimist(process.argv.slice(2), {
  dry: false
});
main(argv);
