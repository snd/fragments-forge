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

# joinUnderscore ['one', 'two', 'three'] => 'one_two_three'
module.exports.joinUnderscore = (array) ->
  array.join('_')

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

module.exports.reverseIndex = (index) ->
  reverseIndex = {}
  Object.keys(index).forEach (key) ->
    value = index[key]
    unless 'string' is typeof value
      throw Error 'all keys in index must map to a string'
    reverseIndex[value] ?= []
    reverseIndex[value].push key
  return reverseIndex

###################################################################################
# env

module.exports.parseEnvSpec = (name, flagPrefix = 'env') ->
  words = module.exports.splitCamelcase name

  unless words[0] is flagPrefix
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

module.exports.newEnvResolver = (flagPrefix) ->
  (query, inner) ->
    result = inner query
    # we dont need to do anything
    if result?
      return result

    spec = module.exports.parseEnvSpec query.name, flagPrefix
    # we cant do anything
    unless spec?
      return

    factory = (env) ->
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

    factory.$source = 'autogenerated by blaze-forge.newEnvFactoryResolver'
    factory.$match = spec

    return {
      name: query.name
      factory: factory
      container: query.container
    }

###################################################################################
# table

module.exports.newTableResolver = ->
  (query, inner) ->
    result = inner query
    if result?
      return result

    words = module.exports.splitCamelcase query.name

    unless words[words.length - 1] is 'table'
      return

    unless words.length > 1
      return

    tableName = module.exports.joinCamelcase words.slice(0, words.length - 1)

    factory = (table) ->
      table[tableName]

    factory.$inject = ['table']
    factory.$source = 'autogenerated by blaze-forge.newTableFactoryResolver'

    return {
      factory: factory
      name: query.name
      container: query.container
    }

###################################################################################
# alias

module.exports.newAliasResolver = (aliasMap = {}) ->
  (query, inner) ->
    result = inner query
    if result?
      return result

    alias = aliasMap[query.name]

    unless alias?
      return

    inner
      name: alias
      container: query.container

###################################################################################
# data first

module.exports.parseDataFirst = (name) ->
  words = module.exports.splitCamelcase name

  unless 'first' is words[0]
    return

  rest = words.slice(1)

  partition = module.exports.splitArray rest, 'where'

  {
    name: module.exports.joinCamelcase partition[0]
    where: partition.slice(1).map (x) -> module.exports.joinUnderscore x
  }

module.exports.newDataFirstFactoryResolver = (options = {}) ->
  options.matcher ?= module.exports.parseDataFirst
  options.nameToTable ?= (name) ->
    name + 'Table'

  (query, inner) ->
    result = inner query
    if result?
      return result

    match = options.matcher query.name
    unless match?
      return

    factory = (table) ->
      (args...) ->
        q = table
        match.where.forEach (x, index) ->
          condition = {}
          condition[x] = args[index]
          q = q.where condition
        q.first()

    factory.$inject = [
      options.nameToTable(match.name)
    ]
    factory.$source = 'autogenerated by blaze-forge.newDataFirstFactoryResolver'
    factory.$match = match

    return {
      factory: factory
      name: query.name
      container: query.container
    }

###################################################################################
# data select

module.exports.parseDataSelect = (name) ->
  words = module.exports.splitCamelcase name

  unless 'select' is words[0]
    return

  rest = words.slice(1)

  partition = module.exports.splitArray rest, 'where'

  {
    name: module.exports.joinCamelcase partition[0]
    where: partition.slice(1).map (x) -> module.exports.joinUnderscore x
  }

module.exports.newDataSelectFactoryResolver = (options = {}) ->
  options.matcher ?= module.exports.parseDataSelect
  options.nameToTable ?= (name) ->
    name + 'Table'

  (query, inner) ->
    result = inner query
    # we dont need to do anything
    if result?
      return result

    match = options.matcher query.name
    # we cant do anything
    unless match?
      return

    factory = (table) ->
      (args...) ->
        q = table
        match.where.forEach (x, index) ->
          condition = {}
          condition[x] = args[index]
          q = q.where condition
        q.find()

    factory.$inject = [
      options.nameToTable(match.name)
    ]
    factory.$source = 'autogenerated by blaze-forge.newDataSelectFactoryResolver'
    factory.$match = match

    return {
      factory: factory
      container: query.container
      name: query.name
    }

###################################################################################
# data insert

module.exports.parseDataInsert = (name) ->
  words = module.exports.splitCamelcase name

  unless 'insert' is words[0]
    return

  {
    name: module.exports.joinCamelcase(words.slice(1))
  }

module.exports.newDataInsertFactoryResolver = (options = {}) ->
  options.matcher ?= module.exports.parseDataInsert
  options.nameToTable ?= (name) ->
    name + 'Table'
  # options.nameToAllowedColumns ?= (name) ->
  #   name + 'Columns'

  (query, inner) ->
    result = inner query
    if result?
      return result

    match = options.matcher name
    unless match?
      return

    factory = (table, allowedColumns) ->
      (data) ->
        table
          # .allowedColumns(allowedColumns)
          .insert(data)

    factory.$inject = [
      options.nameToTable(match.name)
      # options.nameToAllowedColumns(match.name)
    ]
    factory.$source = 'autogenerated by blaze-forge.newDataInsertFactoryResolver'
    factory.$match = match

    return {
      factory: factory
      name: query.name
      container: query.container
    }

###################################################################################
# data update

module.exports.parseDataUpdate = (name) ->
  words = module.exports.splitCamelcase name

  unless 'update' is words[0]
    return

  rest = words.slice(1)

  partition = module.exports.splitArray rest, 'where'

  # dont allow mass update without condition for security reasons
  if partition.length is 1
    return

  {
    name: module.exports.joinCamelcase partition[0]
    where: partition.slice(1).map (x) -> module.exports.joinUnderscore x
  }

module.exports.newDataUpdateFactoryResolver = (options = {}) ->
  options.matcher ?= module.exports.parseDataUpdate
  options.nameToTable ?= (name) ->
    name + 'Table'
  # options.nameToAllowedColumns ?= (name) ->
  #   name + 'Columns'

  (query, inner) ->
    result = inner query
    if result?
      return result

    match = options.matcher name
    unless match?
      return

    factory = (table, allowedColumns) ->
      (data, args...) ->
        query = table
        match.where.forEach (x, index) ->
          condition = {}
          condition[x] = args[index]
          query = query.where condition
        query
          # .allowedColumns(allowedColumns)
          .update(data)

    factory.$inject = [
      options.nameToTable(match.name)
      # options.nameToAllowedColumns(match.name)
    ]
    factory.$source = 'autogenerated by blaze-forge.newDataUpdateFactoryResolver'
    factory.$match = match

    return {
      factory: factory
      name: name
      container: container
    }

###################################################################################
# data delete

module.exports.parseDataDelete = (name) ->
  words = module.exports.splitCamelcase name

  unless 'delete' is words[0]
    return

  rest = words.slice(1)

  partition = module.exports.splitArray rest, 'where'

  # dont allow mass delete without condition for security reasons
  if partition.length is 1
    return

  {
    name: module.exports.joinCamelcase partition[0]
    where: partition.slice(1).map (x) -> module.exports.joinUnderscore x
  }

module.exports.newDataDeleteFactoryResolver = (options = {}) ->
  options.matcher ?= module.exports.parseDataDelete
  options.nameToTable ?= (name) ->
    name + 'Table'

  (query, inner) ->
    result = inner query
    if result?
      return result

    match = options.matcher name
    unless match?
      return

    factory = (table) ->
      (args...) ->
        query = table
        match.where.forEach (x, index) ->
          condition = {}
          condition[x] = args[index]
          query = query.where condition
        query.delete()

    factory.$inject = [
      options.nameToTable(match.name)
    ]
    factory.$source = 'autogenerated by blaze-forge.newDataDeleteFactoryResolver'
    factory.$match = match

    return {
      factory: factory
      container: query.container
      name: query.name
    }

module.exports.newNamespaceResolver = (aliasToNamespaces = {}) ->
  (query, inner) ->
    # if the name is directly resolvable return it
    value = inner query
    if value?
      return value

    # otherwise try out namespace mappings

    parts = query.name.split '_'
    if parts.length is 1
      # common case (no namespace part)
      aliasPart = ''
      namePart = parts[0]
    else
      aliasPart = parts.slice(0, -1).join('_')
      namePart = parts[parts.length - 1]

    possibleNamespaces = aliasToNamespaces[aliasPart]

    # console.log 'aliasPart', aliasPart
    # console.log 'namePart', namePart
    # console.log 'aliasToNamespaces', aliasToNamespaces
    # console.log 'possibleNamespaces', possibleNamespaces

    unless possibleNamespaces?
      # common case (no mapping for namespace part)
      return

    unless Array.isArray possibleNamespaces
      throw new Error 'values in aliasToNamespaces must be arrays'

    results = []

    for namespace in possibleNamespaces
      do (namespace) ->
        # call inner multiple times with different ids
        mappedName = if namespace is ''
            namePart
          else
            [namespace, namePart].join('_')
        resolved = inner
          container: query.container
          name: mappedName
        if resolved?
          results.push
            namespace: namespace
            mappedName: mappedName
            resolved: resolved

    return switch results.length
      when 0 then undefined
      when 1 then results[0].resolved
      else
        lines = [
          "ambiguity in namespace resolver."
          "\"name\" maps to multiple resolvable names:"
        ]
        results.forEach (result) ->
          lines.push "#{result.mappedName} (#{alias} -> #{result.namespace})"
        throw new Error lines.join('\n')
