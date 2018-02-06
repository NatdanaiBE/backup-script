tar = require 'tar'
fsExtra = require 'fs-extra'
Promise = require 'bluebird'
fs = Promise.promisifyAll require 'fs'
path = require 'path'
_ = require 'lodash'
async = require 'async'

moveAndExtract = () ->
  jsonString = await fs.readFileAsync '/tmp/fileList.json'
  jsonData = JSON.parse jsonString.toString()
  hostName = path.dirname jsonData[0].dest
  await tar.extract
    file: "#{hostName}.tgz"
  , ["#{hostName}"]
  
  async.each jsonData, (elem, callback) ->
    fileName = path.basename elem.dest
    if await fsExtra.pathExists path.join __dirname, hostName, fileName
      console.log fileName + ' exist'
      if fileName == '.bashrc'
        sourceFile = await fs.readFileAsync(elem.src)
        destFile = await fs.readFileAsync(path.join(__dirname, hostName, '.bashrc'))
        newFile = mergeFile sourceFile.toString(), destFile.toString()
        # console.log newFile
        fs.writeFile elem.src, newFile
      else
        await fsExtra.copy path.join(__dirname, hostName, fileName), elem.src
    callback()
  , () -> fsExtra.remove path.join __dirname, hostName

moveAndExtract()

mergeFile = (sourceFile, destFile) ->
  destLines = destFile.split '\n' #key
  sourceLines = sourceFile.split '\n'
  aliasListSource = {}
  _.each sourceLines, (elem, index) ->
    if elem.startsWith 'alias'
      aliasListSource[elem.substring(6).split('=')[0]] = index

  _.each destLines, (elem, index) ->
    if elem.startsWith 'alias'
      alias = elem.substring(6).split('=')[0]
      if _.has aliasListSource, alias
        sourceAliasIndex = aliasListSource[alias]
        sourceLines[sourceAliasIndex] = undefined
        aliasListSource[alias] = sourceLines.length
      sourceLines.push elem
  
  sourceLines = _.filter sourceLines, (e) -> e
  
  _.reduce sourceLines, (result, value, index) ->
    result += value + '\n'
    result