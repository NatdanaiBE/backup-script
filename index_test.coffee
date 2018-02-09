{ backup, tarCreate, restore } = require './index'
{ expect } = require 'chai'
_ = require 'lodash'
fsExtra = require 'fs-extra'
path = require 'path'
Promise = require 'bluebird'
util = require 'util'
exec = util.promisify require('child_process').exec
moment = require 'moment'

HOME = '/root/'
HOST = '192.168.56.22'
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

  # it 'should Backup', ->
  #   this.timeout 0
  #   sourceExists = await backup backupList, HOST

  #   backupExists = await Promise.map backupList, (e) ->
  #     fsExtra.pathExists path.join __dirname, e.dest
  #   expect(backupExists).to.deep.eq sourceExists

  #   await tarCreate HOST
  #   tarExist = await fsExtra.pathExists path.join __dirname, "#{HOST}.tgz"
  #   expect(tarExist).to.be.true

  #   await fsExtra.remove "#{HOST}"
  #   folderExist = await fsExtra.pathExists path.join __dirname, "#{HOST}"
  #   expect(folderExist).to.be.false

  it 'should Restore', ->
    this.timeout 0
    restore backupList, HOST, (existList) ->
      console.log existList
      console.log 'asdf'

      exists = await Promise.map backupList, (e) ->
        innerCommand = "stat #{e.src}"
        command = "ssh -oStrictHostKeyChecking=no root@#{HOST} '#{innerCommand}'"
        try
          { stdout, stderr } = await exec command
        catch e 
        if stdout
          dateString = stdout.split('\n')[6].split(' ')[1]
          moment(dateString).format('YY-MM-DD') == moment().format('YY-MM-DD')
        else
          false
        
      
      console.log exists
      console.log 'ghjk'

      # existTrueLength = (_.filter exists, (e) -> _.isString(e) and _.includes e, '1').length
      # expect(existTrueLength).to.eq backupList.length
