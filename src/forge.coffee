util = require '../src/util'

module.exports = forge = {}

module.exports.dataAccessorSpec = (name) ->
    words = util.splitCamelcase name

    rest = words.slice(1)

    partition = util.splitArray rest, 'where'

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
