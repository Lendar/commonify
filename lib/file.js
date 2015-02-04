var fs = require('fs');

module.exports = {
  load: function (amd) {
    return fs.readFileSync(amd, 'utf8');
  }
};
