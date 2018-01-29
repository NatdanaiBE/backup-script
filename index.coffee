fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'

module.exports =
  copy: (backupList) ->
    Promise.map backupList, (element) ->
      fsExtra.copy element.src, path.join __dirname, element.dest