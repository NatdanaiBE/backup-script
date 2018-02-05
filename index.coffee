fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
util = require 'util'
exec = util.promisify require('child_process').exec
tar = require 'tar'

module.exports =
  backup: (backupList, host) ->
    Promise.map backupList, (element) ->
      # fsExtra.copy element.src, path.join __dirname, element.dest
      command = "scp -r -oStrictHostKeyChecking=no root@#{host}:#{element.src} #{element.dest}"
      try
        { stdout, stderr } = await exec command
      catch e
      # if stderr != ''
      #   throw stderr
      stderr == ''

  tarCreate: (host) ->
    tar.create
      file: "#{host}.tgz"
    , ["#{host}"]

  restore: (backupList, host) ->
    Promise.map backupList, (element) ->
      prePath = element.src.substring 0, element.src.lastIndexOf '/'
      preCommand = "ssh -oStrictHostKeyChecking=no root@#{host} 'mkdir -p #{prePath}'"
      { stdout, stderr } = await exec preCommand
      if stderr != ''
        throw stderr

      command = "scp -r -oStrictHostKeyChecking=no #{element.dest} root@#{host}:#{element.src}"
      { stdout, stderr } = await exec command
      if stderr != ''
        throw stderr
mergeFile = (sourceFile, destFile) ->
  destLines = destFile.split '\n'
  sourceLines = sourceFile.split '\n'
  _.each destLines, (v) ->
    if v.startsWith 'alias' and not sourceLines.includes v
      sourceFile += v
  sourceFile
