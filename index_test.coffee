backupList = require './backup_list'
{ backup, restore } = require './index'
{ expect } = require 'chai'
_ = require 'lodash'
fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
util = require 'util'
exec = util.promisify require('child_process').exec

HOME = '/home/tiramizu/'
HOST = '192.168.56.78'

sshRemoveAll = () ->
  _.each backupList, (e) ->
    preCommand = "ssh -oStrictHostKeyChecking=no root@#{HOST} 'rm -rf #{e.src}'"
    { stdout, stderr } = await exec preCommand
    if stderr != ''
      throw stderr

describe "BACKUP AND RESTORE File", ->
  before ->
    console.log 'AWAKENING!'
    await fsExtra.remove 'tmp'
    fsExtra.mkdirs 'tmp'
    sshRemoveAll()

  it 'should Backup', ->
    await backup backupList, '127.0.0.1'

    exists = await Promise.map backupList, (e) ->
      fsExtra.pathExists path.join __dirname, e.dest
    existTrueLength = (_.filter exists, (e) -> _.isBoolean(e) and e).length
    expect(existTrueLength).to.eq backupList.length

  it 'should Restore', (done) ->
    this.timeout 4000
    wrapper = ->
      await restore backupList, HOST
      
      exists = await Promise.map backupList, (e) ->
        innerCommand = "[ -e #{e.src} ] && echo 1 || echo 0"
        command = "ssh -oStrictHostKeyChecking=no root@#{HOST} '#{innerCommand}'"
        { stdout, stderr } = await exec command
        if stderr != ''
          throw stderr
        stdout

      existTrueLength = (_.filter exists, (e) -> _.isString(e) and _.includes e, '1').length
      expect(existTrueLength).to.eq backupList.length
      done()
    console.log wrapper()
