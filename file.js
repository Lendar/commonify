var path = require('path');
var fs = require('fs');

module.exports = {
  load: function (amd) {
    return fs.readFileSync(path.resolve(__dirname, amd), 'utf8');
  }
};
