module.exports = util = {}

module.exports.splitCamelcase = (string) ->
    string.match(/([A-Z]?[^A-Z]*)/g).slice(0,-1).map (x) ->
        x.toLowerCase()

# module.exports.uppercaseFirstLetter = (string) ->
#     string.charAt(0).toUpperCase() + string.slice(1)
# 
# module.exports.lowercaseFirstLetter = (string) ->
#     string.charAt(0).toLowerCase() + string.slice(1)
# 
# module.exports.joinCamelcase = (array) ->
#     capitalize = (string) ->
#         util.uppercaseFirstLetter string.toLowerCase()
#     util.lowercaseFirstLetter array.map(capitalize).join('')

# module.exports.findIndex = (array, predicate) ->
#     i = 0
#     length = array.length
#     while i < length
#         if predicate array[i]
#             return i
#         i++
#     return -1

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

# module.exports.splitWith = (array, predicate) ->
#     index = util.findIndex array, predicate
#     if index is -1
#         return [array, []]
#     [array.slice(0, index), array.slice(index)]
