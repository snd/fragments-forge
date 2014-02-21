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

    'dataAccessorSpec':

        'first': (test) ->
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
            test.deepEqual forge.dataAccessorSpec('firstOrderReportWhereIdWhereCreatedAt'),
                type: 'first'
                name: ['order', 'report']
                where: [['id'], ['created', 'at']]

            test.done()

        'delete': (test) ->
            test.ok not forge.dataAccessorSpec('deleteOrderReport')?
            test.deepEqual forge.dataAccessorSpec('deleteOrderReportWhereId'),
                type: 'delete'
                name: ['order', 'report']
                where: [['id']]

            test.done()

        'delete': (test) ->
            test.ok not forge.dataAccessorSpec('updateOrderReport')?
            test.deepEqual forge.dataAccessorSpec('updateOrderReportWhereRegistrationNumber'),
                type: 'update'
                name: ['order', 'report']
                where: [['registration', 'number']]

            test.done()

        'insert': (test) ->
            test.deepEqual forge.dataAccessorSpec('insertOrderReport'),
                type: 'insert'
                name: ['order', 'report']
            test.deepEqual forge.dataAccessorSpec('insertUserWhere'),
                type: 'insert'
                name: ['user', 'where']

            test.done()
