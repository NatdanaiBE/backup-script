{ backup, restore } = require './index'
{ expect } = require 'chai'
_ = require 'lodash'
fsExtra = require 'fs-extra'
path = require 'path'
HOME = '/home/tiramizu/'
Promise = require 'bluebird'
util = require 'util'
exec = util.promisify require('child_process').exec
backupList = [
		src: path.join HOME, '.bashrc'
		dest: 'tmp/.bashrc'
	,
		src: path.join HOME, '.docker'
		dest: 'tmp/.docker'
	,
		src: '/etc/docker'
		dest: 'tmp/docker'
	,
		src: '/etc/hosts'
		dest: 'tmp/hosts'
	,
		src: '/etc/openvpn'
		dest: 'tmp/openvpn'
]
host = '192.168.56.78'

describe "Copy File", ->
  before ->
    console.log 'AWAKENING!'
    await fsExtra.remove 'tmp'
    fsExtra.mkdirs 'tmp'

    _.each backupList, (e) ->
      preCommand = "ssh -oStrictHostKeyChecking=no root@#{host} 'rm -rf #{e.src}'"
      { stdout, stderr } = await exec preCommand
      if stderr != ''
        throw stderr

  it 'should backup', ->
    await backup backupList, '127.0.0.1'

    exists = await Promise.map backupList, (e) ->
      fsExtra.pathExists path.join __dirname, e.dest
    existTrueLength = (_.filter exists, (e) -> _.isBoolean(e) and e).length
    expect(existTrueLength).to.eq backupList.length

  it 'should restore', (done) ->
    this.timeout 4000
    wrapper = ->
      await restore backupList, host
      exists = await Promise.map backupList, (e) ->
        innerCommand = "[ -e #{e.src} ] && echo 1 || echo 0"
        command = "ssh -oStrictHostKeyChecking=no root@#{host} '#{innerCommand}'"
        { stdout, stderr } = await exec command
        if stderr != ''
          throw stderr
        stdout

      existTrueLength = (_.filter exists, (e) -> _.isString(e) and _.includes e, '1').length
      expect(existTrueLength).to.eq backupList.length
      done()
    console.log wrapper()
