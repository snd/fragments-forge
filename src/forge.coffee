util = require '../src/util'

module.exports = forge = {}

module.exports.dataAccessorSpec = (name) ->
    words = util.splitCamelcase name

    switch words[0]
        when 'first'
            forge.firstDataAccessorSpec words.slice 1
        else
            return

# module.exports.extractWhereClauses = (words) ->
#     if words[0] isnt 'where'
#         return []
# 
#     [conditionWords, remainder] = util.splitWith words.slice(1), (x) -> x is 'where'
# 
#     if conditionWords.length is 0
#         return []
# 
#     remainingClauses = forge.extractWhereClauses remainder
# 
#     [conditionWords].concat(remainingClauses)

module.exports.firstDataAccessorSpec = (words) ->
    partition = util.splitArray words, 'where'

    {
        type: 'first'
        name: partition[0]
        where: partition.slice(1)
    }

module.exports.newDataAccessorResolver = (modelNameToDependencyName) ->
    (container, name) ->
        dataAccessorSpec = forge.nameToDataAccessorSpec name
        if not dataAccessorSpec?
            return

        dependencyName = modelNameToDependencyName

        factory = () ->
            () ->

        factory.$inject = []

        return factory
