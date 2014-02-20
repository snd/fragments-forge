forge = require '../src/forge'

module.exports =

    # 'extractWhereClauses': (test) ->
    #     test.deepEqual [], forge.extractWhereClauses []
    #     test.deepEqual [], forge.extractWhereClauses ['where']
    #     test.deepEqual [], forge.extractWhereClauses ['id']
    #     test.deepEqual [['id']], forge.extractWhereClauses ['where', 'id']
    #     test.deepEqual [['created', 'at']],
    #         forge.extractWhereClauses ['where', 'created', 'at']
    #     test.deepEqual [['created', 'at'], ['id']],
    #         forge.extractWhereClauses ['where', 'created', 'at', 'where', 'id']
    #     test.deepEqual [['created', 'at'], ['id']],
    #         forge.extractWhereClauses ['where', 'created', 'at', 'where', 'id', 'where']
    #     test.deepEqual [],
    #         forge.extractWhereClauses ['id', 'where', 'created', 'at']

    #     test.done()

    'dataAccessorSpec': (test) ->
        test.deepEqual forge.dataAccessorSpec('firstUser'),
            type: 'first'
            name: ['user']
            where: []
        test.deepEqual forge.dataAccessorSpec('firstUserCreatedAt'),
            type: 'first'
            name: ['user', 'created', 'at']
            where: []
        test.deepEqual forge.dataAccessorSpec('firstUserWhereCreatedAt'),
            type: 'first'
            name: ['user']
            where: [['created', 'at']]

        test.done()
