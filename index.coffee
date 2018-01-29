fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
util = require 'util'
exec = util.promisify require('child_process').exec

module.exports =
  backup: (backupList, host) ->
    Promise.map backupList, (element) ->
      # fsExtra.copy element.src, path.join __dirname, element.dest
      command = "scp -r -oStrictHostKeyChecking=no root@#{host}:#{element.src} #{element.dest}"
      { stdout, stderr } = await exec command
      if stderr != ''
        throw stderr
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