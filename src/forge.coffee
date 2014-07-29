###################################################################################
# util

module.exports.uppercaseFirstLetter = (string) ->
  string.charAt(0).toUpperCase() + string.slice(1)

module.exports.lowercaseFirstLetter = (string) ->
  string.charAt(0).toLowerCase() + string.slice(1)

# splitCamelcase 'oneTwoThree' => ['one', 'two', 'three']
module.exports.splitCamelcase = (string) ->
  string.match(/([A-Z]?[^A-Z]*)/g).slice(0,-1).map (x) ->
    x.toLowerCase()

# joinCamelcase ['One', 'two', 'three'] => 'oneTwoThree'
module.exports.joinCamelcase = (array) ->
  capitalize = (string) ->
    module.exports.uppercaseFirstLetter string.toLowerCase()
  module.exports.lowercaseFirstLetter array.map(capitalize).join('')

# find the index of the first array element for which predicate returns true
# otherwise returns -1
module.exports.findIndex = (array, predicate) ->
  i = 0
  length = array.length
  while i < length
    if predicate array[i]
        return i
    i++
  return -1

module.exports.splitArray = (array, value) ->
  partitions = []
  currentPartition = []
  i = 0
  length = array.length
  while i < length
    if array[i] is value
      partitions.push currentPartition
      currentPartition = []
    else
      currentPartition.push array[i]
    i++
  partitions.push currentPartition
  partitions

# split array into two parts:
# the first part contains all elements up to (but not including)
# the first element for which predicate returned true.
# the second part contains all elements from (and including)
# the first element for which preducate returned true.
module.exports.splitWith = (array, predicate) ->
  index = module.exports.findIndex array, predicate
  if index is -1
    return [array, []]
  [array.slice(0, index), array.slice(index)]

###################################################################################
# env

module.exports.parseEnvSpec = (name) ->
  words = module.exports.splitCamelcase name

  unless words[0] is 'env'
    return

  maybe = words[1] is 'maybe'

  type = words[if maybe then 2 else 1]

  unless type in ['string', 'bool', 'int', 'float']
    return

  varWords = words.slice if maybe then 3 else 2

  if varWords.length is 0
    return

  varName = module.exports.joinCamelcase varWords
  envVarName = varWords.map((x) -> x.toUpperCase()).join('_')

  {
    maybe: maybe
    type: type
    name: varName
    envVarName: envVarName
  }

module.exports.newEnvFactoryResolver = ->
  (container, name, inner) ->
    spec = module.exports.parseEnvSpec name
    unless spec?
      return inner()

    (env) ->
      value = env[spec.envVarName]
      if not value? or value is''
        if spec.maybe
          return null
        else
          throw new Error "env var #{spec.envVarName} must not be blank"

      switch spec.type
        when 'string'
          value
        when 'bool'
          unless value in ['true', 'false']
            throw new Error "env var #{spec.envVarName} must be 'true' or 'false'"
          value is 'true'
        when 'int'
          result = parseInt value, 10
          if isNaN result
            throw new Error "env var #{spec.envVarName} must be an integer"
          result
        when 'float'
          result = parseFloat value
          if isNaN result
            throw new Error "env var #{spec.envVarName} must be a float"
          result

###################################################################################
# table

module.exports.newTableFactoryResolver = (name) ->
  (container, name, inner) ->
    words = module.exports.splitCamelcase name

    unless words[words.length - 1] is 'table'
      return

    unless words.length > 2
      return

    tableName = module.exports.joinCamelcase words.slice(0, words.length - 1)

    (table) ->
      table[tableName]

###################################################################################
# data accessor

module.exports.parseDataAccessorSpec = (name) ->
  words = module.exports.splitCamelcase name

  rest = words.slice(1)

  partition = module.exports.splitArray rest, 'where'

  switch words[0]
    when 'first'
      {
        type: 'first'
        name: partition[0]
        where: partition.slice(1)
      }
    when 'update'
      # dont allow mass update without condition for security reasons
      if partition.slice(1).length is 0
        return
      {
        type: 'update'
        name: partition[0]
        where: partition.slice(1)
      }
    when 'delete'
      # dont allow mass delete without condition for security reasons
      if partition.slice(1).length is 0
        return
      {
        type: 'delete'
        name: partition[0]
        where: partition.slice(1)
      }
    when 'insert'
      {
        type: 'insert'
        name: rest
      }
    else
      return

module.exports.extractWhereClauses = (words) ->
  if words[0] isnt 'where'
    return []

  [conditionWords, remainder] = module.exports.splitWith words.slice(1), (x) -> x is 'where'

  if conditionWords.length is 0
    return []

  remainingClauses = module.exports.extractWhereClauses remainder

  [conditionWords].concat(remainingClauses)

module.exports.firstDataAccessorSpec = (words) ->

module.exports.newDataAccessorResolver = (modelNameToDependencyName) ->
  (container, name) ->
    dataAccessorSpec = module.exports.nameToDataAccessorSpec name
    if not dataAccessorSpec?
      return

    dependencyName = modelNameToDependencyName

    factory = () ->
      () ->

    factory.$inject = []

    return factory
