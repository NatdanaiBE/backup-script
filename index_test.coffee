{ backup, tarCreate, restore } = require './index'
{ expect } = require 'chai'
_ = require 'lodash'
fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
util = require 'util'
exec = util.promisify require('child_process').exec

HOME = '/root/'
HOST = '192.168.56.11'
backupList = require('./backup_list') HOME, HOST

sshRemoveAll = () ->
  _.each backupList, (e) ->
    preCommand = "ssh -oStrictHostKeyChecking=no root@#{HOST} 'rm -rf #{e.src}'"
    { stdout, stderr } = await exec preCommand
    if stderr != ''
      throw stderr

describe "BACKUP AND RESTORE File", ->
  before ->
    console.log 'AWAKENING!'
    await fsExtra.remove HOST
    fsExtra.mkdirs HOST
    
  after ->
    # sshRemoveAll()

  it 'should Backup', ->
    this.timeout 0
    sourceExists = await backup backupList, HOST

    backupExists = await Promise.map backupList, (e) ->
      fsExtra.pathExists path.join __dirname, e.dest
    expect(backupExists).to.deep.eq sourceExists

    await tarCreate HOST
    tarExist = await fsExtra.pathExists path.join __dirname, "#{HOST}.tgz"
    expect(tarExist).to.be.true

    await fsExtra.remove "#{HOST}"
    folderExist = await fsExtra.pathExists path.join __dirname, "#{HOST}"
    expect(tarExist).to.be.false

  # it 'should Restore', (done) ->
  #   this.timeout 8000
  #   wrapper = ->
  #     await restore backupList, HOST

  #     exists = await Promise.map backupList, (e) ->
  #       innerCommand = "[ -e #{e.src} ] && echo 1 || echo 0"
  #       command = "ssh -oStrictHostKeyChecking=no root@#{HOST} '#{innerCommand}'"
  #       { stdout, stderr } = await exec command
  #       if stderr != ''
  #         throw stderr
  #       stdout

  #     existTrueLength = (_.filter exists, (e) -> _.isString(e) and _.includes e, '1').length
  #     expect(existTrueLength).to.eq backupList.length
  #     done()
  #   console.log wrapper()
