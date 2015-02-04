var fs = require('fs');

module.exports = {
  load: function (filename) {
    return fs.readFileSync(filename, 'utf8');
  },
  save: function (filename, contents) {
    fs.writeFileSync(filename, contents, 'utf8');
  }
};
