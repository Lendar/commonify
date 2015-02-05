Converts AMD/RequireJS modules to CommonJS. Supports CoffeeScript.

Commonify
================

As you know, AMD handles [path differently](http://urequire.org/flexible-path-conventions) than CommonJS. Commonify automatically finds correct path using fuzzy search.

## Example

##### Before convertation

```
define ['underscore', 'models/user'], (_, User) ->
  initialize: (app) ->
```

##### After convertation

```coffee
_ = require('underscore')
User = require('./models/user')

module.exports =
  initialize: (app) ->
```

## Usage

##### Install and run

```sh
$ npm install -g commonify
$ commonify app/*.coffee
```

```sh
$ commonify [--dry] files
```

## Contributing (doesn't work? How to fix)

While this project lacks unit tests (yet), it has workflow focused on fixing bugs in the wild.

So, if you encounter the bug, please:

1. [Clone the repo](https://help.github.com/articles/fork-a-repo/), install deps in `npm install`.
2. Run Commonify in development mode (see below).
3. You will likely want to fix grammar file [coffee.pegjs](lib/coffee.pegjs). Use [PEG.js docs](http://pegjs.org/documentation#grammar-syntax-and-semantics) for that. When you change any source file, Commonify re-runs the convertation.
4. Do few quickly iterations.
5. When you're done with the file, re-run Commonify on the whole project and review diffs.

##### Development Mode

```sh
$ git clone https://github.com/Lendar/commonify; cd commonify
$ npm start --files=../existing-project/file.coffee
```

Inspired by [Bret Victor - Inventing on Principle talk](http://vimeo.com/36579366)

## Licence

Copyright (c) 2015 Denis Elistratov

MIT (http://www.opensource.org/licenses/mit-license.php)
