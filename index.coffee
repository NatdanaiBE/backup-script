fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
util = require 'util'
exec = util.promisify require('child_process').exec
tar = require 'tar'
fs = require 'fs'

module.exports =
  backup: (backupList, host) ->
    Promise.map backupList, (element) ->
      # fsExtra.copy element.src, path.join __dirname, element.dest
      command = "scp -r -oStrictHostKeyChecking=no root@#{host}:#{element.src} #{element.dest}"
      try
        { stdout, stderr } = await exec command
      catch e
      stderr == ''

  tarCreate: (host) ->
    tar.create
      file: "#{host}.tgz"
    , ["#{host}"]

  restore: (backupList, host, callback) ->
    jsonString =  JSON.stringify backupList
    fs.writeFile 'fileList.json', jsonString, () ->
    fileList = "#{host}.tgz restore.coffee fileList.json"
    existList = []
    command = "scp -r -oStrictHostKeyChecking=no #{fileList} root@#{host}:/tmp"
    await exec command, (err, out) ->
      console.log err if err
      command = "ssh -oStrictHostKeyChecking=no root@#{host} 'coffee /tmp/restore.coffee'"
      exec command, (err, out) ->
        console.log err if err
        # console.log out
        stdoutList = out.split '\n'
        _.each stdoutList, (e) ->
          if e == 'true' or e == 'false'
            existList.push e == 'true'
        console.log existList
        command = "ssh -oStrictHostKeyChecking=no root@#{host} 'cd /tmp && rm #{fileList}'"
        exec command, (err, out) -> ##rm
          console.log err if err
          callback existList

