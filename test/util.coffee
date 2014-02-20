util = require '../src/util'

module.exports =

    'splitCamelcase': (test) ->
        test.deepEqual [],
            util.splitCamelcase ''
        test.deepEqual ['a'],
            util.splitCamelcase 'a'
        test.deepEqual ['first'],
            util.splitCamelcase 'first'
        test.deepEqual ['first', 'where', 'id'],
            util.splitCamelcase 'firstWhereId'
        test.deepEqual ['a', 'one', 'a', 'two', 'a', 'three'],
            util.splitCamelcase 'aOneATwoAThree'
        test.deepEqual ['config_url', 'prefix'],
            util.splitCamelcase 'config_urlPrefix'
        test.deepEqual ['pages', 'order', 'by', 'created', 'at', 'desc'],
            util.splitCamelcase 'pagesOrderByCreatedAtDesc'

        test.done()

    # 'joinCamelcase': (test) ->
    #     test.equals '', util.joinCamelcase []
    #     test.equals 'a', util.joinCamelcase ['a']
    #     test.equals 'first', util.joinCamelcase ['first']
    #     test.equals 'firstWhereId', util.joinCamelcase ['first', 'where', 'id']

    #     test.done()

    # 'findIndex': (test) ->
    #     test.equals -1, util.findIndex [], -> true
    #     test.equals 0, util.findIndex [1], (x) -> x is 1
    #     test.equals -1, util.findIndex [1], (x) -> x is 2
    #     test.equals 1, util.findIndex [1, 2, 3], (x) -> x > 1
    #     test.equals -1, util.findIndex [1, 2, 3], (x) -> x > 3

    #     test.done()

    # 'splitWith': (test) ->
    #     test.deepEqual [[], []],
    #         util.splitWith [], -> true
    #     test.deepEqual [[], [1, 2, 3]],
    #         util.splitWith [1, 2, 3], -> true
    #     test.deepEqual [[1, 2, 3], []],
    #         util.splitWith [1, 2, 3], -> false
    #     test.deepEqual [[1], [2, 3]],
    #         util.splitWith [1, 2, 3], (x) -> x is 2

    #     test.done()

    'splitArray': (test) ->
        test.deepEqual [[]],
            util.splitArray [], 'where'
        test.deepEqual [[], []],
            util.splitArray ['where'], 'where'
        test.deepEqual [['first']],
            util.splitArray ['first'], 'where'
        test.deepEqual [['first', 'order', 'report']],
            util.splitArray ['first', 'order', 'report'], 'where'
        test.deepEqual [['first', 'order', 'report'], []],
            util.splitArray ['first', 'order', 'report', 'where'], 'where'
        test.deepEqual [['first', 'order', 'report'], ['created', 'at']],
            util.splitArray ['first', 'order', 'report', 'where', 'created', 'at'], 'where'
        test.deepEqual [['first', 'order', 'report'], ['created', 'at'], []],
            util.splitArray ['first', 'order', 'report', 'where', 'created', 'at', 'where'], 'where'
        test.deepEqual [['first', 'order', 'report'], ['created', 'at'], ['id']],
            util.splitArray ['first', 'order', 'report', 'where', 'created', 'at', 'where', 'id'], 'where'

        test.done()

