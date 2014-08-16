hinoki = require 'hinoki'

forge = require '../src/forge'

module.exports =

###################################################################################
# util

  'util':

    'splitCamelcase': (test) ->
      test.deepEqual [],
        forge.splitCamelcase ''
      test.deepEqual ['a'],
        forge.splitCamelcase 'a'
      test.deepEqual ['first'],
        forge.splitCamelcase 'first'
      test.deepEqual ['first', 'where', 'id'],
        forge.splitCamelcase 'firstWhereId'
      test.deepEqual ['a', 'one', 'a', 'two', 'a', 'three'],
        forge.splitCamelcase 'aOneATwoAThree'
      test.deepEqual ['config_url', 'prefix'],
        forge.splitCamelcase 'config_urlPrefix'
      test.deepEqual ['pages', 'order', 'by', 'created', 'at', 'desc'],
        forge.splitCamelcase 'pagesOrderByCreatedAtDesc'

      test.done()

    'joinCamelcase': (test) ->
      test.equal '', forge.joinCamelcase []
      test.equal 'a', forge.joinCamelcase ['a']
      test.equal 'first', forge.joinCamelcase ['first']
      test.equal 'firstWhereId', forge.joinCamelcase ['first', 'where', 'id']

      test.done()

    'joinUnderscore': (test) ->
      test.equal '', forge.joinUnderscore []
      test.equal 'first', forge.joinUnderscore ['first']
      test.equal 'first_where_id', forge.joinUnderscore ['first', 'where', 'id']

      test.done()

    'findIndex': (test) ->
      test.equal -1, forge.findIndex [], -> true
      test.equal 0, forge.findIndex [1], (x) -> x is 1
      test.equal -1, forge.findIndex [1], (x) -> x is 2
      test.equal 1, forge.findIndex [1, 2, 3], (x) -> x > 1
      test.equal -1, forge.findIndex [1, 2, 3], (x) -> x > 3

      test.done()

    'splitWith': (test) ->
      test.deepEqual [[], []],
        forge.splitWith [], -> true
      test.deepEqual [[], [1, 2, 3]],
        forge.splitWith [1, 2, 3], -> true
      test.deepEqual [[1, 2, 3], []],
        forge.splitWith [1, 2, 3], -> false
      test.deepEqual [[1], [2, 3]],
        forge.splitWith [1, 2, 3], (x) -> x is 2

      test.done()

    'splitArray': (test) ->
      test.deepEqual [[]],
        forge.splitArray [], 'where'
      test.deepEqual [[], []],
        forge.splitArray ['where'], 'where'
      test.deepEqual [['first']],
        forge.splitArray ['first'], 'where'
      test.deepEqual [['first', 'order', 'report']],
        forge.splitArray ['first', 'order', 'report'], 'where'
      test.deepEqual [['first', 'order', 'report'], []],
        forge.splitArray ['first', 'order', 'report', 'where'], 'where'
      test.deepEqual [['first', 'order', 'report'], ['created', 'at']],
        forge.splitArray ['first', 'order', 'report', 'where', 'created', 'at'], 'where'
      test.deepEqual [['first', 'order', 'report'], ['created', 'at'], []],
        forge.splitArray ['first', 'order', 'report', 'where', 'created', 'at', 'where'], 'where'
      test.deepEqual [['first', 'order', 'report'], ['created', 'at'], ['id']],
        forge.splitArray ['first', 'order', 'report', 'where', 'created', 'at', 'where', 'id'], 'where'

      test.deepEqual [[]],
        forge.splitArray [], []
      test.deepEqual [[]],
        forge.splitArray [], ['where']
      test.deepEqual [[], []],
        forge.splitArray ['where'], ['where']
      test.deepEqual [['first']],
        forge.splitArray ['first'], ['where']
      test.deepEqual [['first', 'order', 'report']],
        forge.splitArray ['first', 'order', 'report'], ['where']
      test.deepEqual [['first', 'order', 'report'], []],
        forge.splitArray ['first', 'order', 'report', 'where'], ['where']
      test.deepEqual [['first', 'order', 'report'], ['created', 'at']],
        forge.splitArray ['first', 'order', 'report', 'where', 'created', 'at'], ['where']
      test.deepEqual [['first', 'order', 'report'], ['created', 'at'], []],
        forge.splitArray ['first', 'order', 'report', 'where', 'created', 'at', 'where'], ['where']
      test.deepEqual [['first', 'order', 'report'], ['created', 'at'], ['id']],
        forge.splitArray ['first', 'order', 'report', 'where', 'created', 'at', 'where', 'id'], ['where']

      test.deepEqual [[]],
        forge.splitArray [], []
      test.deepEqual [[]],
        forge.splitArray [], ['order', 'by']
      test.deepEqual [[], []],
        forge.splitArray ['order', 'by'], ['order', 'by']
      test.deepEqual [['first']],
        forge.splitArray ['first'], ['order', 'by']
      test.deepEqual [['first', 'order', 'report']],
        forge.splitArray ['first', 'order', 'report'], ['order', 'by']
      test.deepEqual [['first', 'order', 'report', 'where', 'order', 'id']],
        forge.splitArray ['first', 'order', 'report', 'where', 'order', 'id'], ['order', 'by']
      test.deepEqual [['first', 'order', 'report', 'where', 'order', 'id'], []],
        forge.splitArray ['first', 'order', 'report', 'where', 'order', 'id', 'order', 'by'], ['order', 'by']
      test.deepEqual [['first', 'order', 'report', 'where', 'order', 'id'], ['created', 'at', 'desc']],
        forge.splitArray ['first', 'order', 'report', 'where', 'order', 'id', 'order', 'by', 'created', 'at', 'desc'], ['order', 'by']
      test.deepEqual [['first', 'order', 'report', 'where', 'order', 'id'], ['created', 'at', 'desc'], ['count', 'asc']],
        forge.splitArray ['first', 'order', 'report', 'where', 'order', 'id', 'order', 'by', 'created', 'at', 'desc', 'order', 'by', 'count', 'asc'], ['order', 'by']
      test.deepEqual [['first', 'order', 'report', 'where', 'order', 'id'], ['created', 'at', 'desc'], ['order']],
        forge.splitArray ['first', 'order', 'report', 'where', 'order', 'id', 'order', 'by', 'created', 'at', 'desc', 'order', 'by', 'order'], ['order', 'by']

      test.done()

    'reverseIndex': (test) ->
      test.deepEqual {},
        forge.reverseIndex {}
      test.throws ->
        forge.reverseIndex {a: null}
      test.deepEqual {b: ['a']},
        forge.reverseIndex {a: 'b'}
      test.deepEqual {b: ['a', 'c']},
        forge.reverseIndex {a: 'b', c: 'b'}
      test.deepEqual {b: ['a', 'c', 'f'], e: ['d', 'i'], h: ['g']},
        forge.reverseIndex {a: 'b', c: 'b', d: 'e', f: 'b', g: 'h', i: 'e'}

      test.done()

###################################################################################
# env parse

  'parseEnvSpec':

    'no match': (test) ->
      test.ok not forge.parseEnvSpec('env')?
      test.ok not forge.parseEnvSpec('envPort')?
      test.ok not forge.parseEnvSpec('envObjectPort')?
      test.ok not forge.parseEnvSpec('envString')?
      test.ok not forge.parseEnvSpec('envBool')?
      test.ok not forge.parseEnvSpec('envMaybeString')?

      test.done()

    'match': (test) ->
      test.deepEqual forge.parseEnvSpec('envStringBaseUrl'),
        maybe: false
        type: 'string'
        name: 'baseUrl'
        envVarName: 'BASE_URL'
      test.deepEqual forge.parseEnvSpec('envBoolIsActive'),
        maybe: false
        type: 'bool'
        name: 'isActive'
        envVarName: 'IS_ACTIVE'
      test.deepEqual forge.parseEnvSpec('envIntPort'),
        maybe: false
        type: 'int'
        name: 'port'
        envVarName: 'PORT'

      test.done()

    'maybe': (test) ->
      test.deepEqual forge.parseEnvSpec('envMaybeStringBaseUrl'),
        maybe: true
        type: 'string'
        name: 'baseUrl'
        envVarName: 'BASE_URL'
      test.deepEqual forge.parseEnvSpec('envMaybeBoolIsActive'),
        maybe: true
        type: 'bool'
        name: 'isActive'
        envVarName: 'IS_ACTIVE'
      test.deepEqual forge.parseEnvSpec('envMaybeIntPort'),
        maybe: true
        type: 'int'
        name: 'port'
        envVarName: 'PORT'

      test.done()

###################################################################################
# env resolver

  'newEnvResolver':

    'inner result is passed on unchanged': (test) ->
      expected = {}

      container =
        factories:
          envIntPort: -> expected
        resolvers: [forge.newEnvResolver()]

      hinoki.get(container, 'envIntPort').then (actual) ->
        test.equal actual, expected
        test.done()

    'envStringBaseUrl':

      'strict':

        'success': (test) ->
          test.expect 1
          container =
            values:
              env:
                BASE_URL: '/test'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envStringBaseUrl')
            .then (result) ->
              test.equal result, '/test'
              test.done()

        'must be present': (test) ->
          test.expect 1
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envStringBaseUrl')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var BASE_URL must not be blank'
              test.done()

        'must not be blank': (test) ->
          test.expect 1
          container =
            values:
              env:
                BASE_URL: ''
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envStringBaseUrl')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var BASE_URL must not be blank'
              test.done()

      'maybe':

        'null': (test) ->
          test.expect 1
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeStringBaseUrl')
            .then (result) ->
              test.equal result, null
              test.done()
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

        'null (blank)': (test) ->
          test.expect 1
          container =
            values:
              env:
                BASE_URL: ''
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeStringBaseUrl')
            .then (result) ->
              test.equal result, null
              test.done()


        'success': (test) ->
          test.expect 1
          container =
            values:
              env:
                BASE_URL: '/test'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeStringBaseUrl')
            .then (result) ->
              test.equal result, '/test'
              test.done()

    'envBoolIsActive':

      'strict':

        'true': (test) ->
          test.expect 1
          container =
            values:
              env:
                IS_ACTIVE: 'true'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envBoolIsActive')
            .then (result) ->
              test.equal true, result
              test.done()

        'false': (test) ->
          test.expect 1
          container =
            values:
              env:
                IS_ACTIVE: 'false'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envBoolIsActive')
            .then (result) ->
              test.equal false, result
              test.done()

        'must be true or false': (test) ->
          test.expect 1
          container =
            values:
              env:
                IS_ACTIVE: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envBoolIsActive')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var IS_ACTIVE must be \'true\' or \'false\''
              test.done()

      'maybe':

        'null': (test) ->
          test.expect 1
          container =
            values:
              env:
                {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .then (result) ->
              test.equal result, null
              test.done()

        'true': (test) ->
          test.expect 1
          container =
            values:
              env:
                IS_ACTIVE: 'true'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .then (result) ->
              test.equal true, result
              test.done()

        'false': (test) ->
          test.expect 1
          container =
            values:
              env:
                IS_ACTIVE: 'false'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .then (result) ->
              test.equal false, result
              test.done()

        'must be true or false': (test) ->
          test.expect 1
          container =
            values:
              env:
                IS_ACTIVE: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var IS_ACTIVE must be \'true\' or \'false\''
              test.done()

    'envIntPort':

      'strict':

        'success': (test) ->
          test.expect 1
          container =
            values:
              env:
                PORT: '9000'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envIntPort')
            .then (result) ->
              test.equal 9000, result
              test.done()

        'must be an integer': (test) ->
          test.expect 1
          container =
            values:
              env:
                PORT: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envIntPort')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var PORT must be an integer'
              test.done()

      'maybe':

        'null': (test) ->
          test.expect 1
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeIntPort')
            .then (result) ->
              test.equal null, result
              test.done()

        'success': (test) ->
          test.expect 1
          container =
            values:
              env:
                PORT: '9000'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeIntPort')
            .then (result) ->
              test.equal 9000, result
              test.done()

        'must be an integer': (test) ->
          test.expect 1
          container =
            values:
              env:
                PORT: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeIntPort')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var PORT must be an integer'
              test.done()

    'envFloatPi':

      'strict':

        'success': (test) ->
          test.expect 1
          container =
            values:
              env:
                PI: '3.141'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envFloatPi')
            .then (result) ->
              test.equal 3.141, result
              test.done()

        'must be a float': (test) ->
          test.expect 1
          container =
            values:
              env:
                PI: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envFloatPi')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var PI must be a float'
              test.done()

      'maybe':

        'null': (test) ->
          test.expect 1
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeFloatPi')
            .then (result) ->
              test.equal null, result
              test.done()

        'success': (test) ->
          test.expect 1
          container =
            values:
              env:
                PI: '3.141'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeFloatPi')
            .then (result) ->
              test.equal 3.141, result
              test.done()

        'must be a float': (test) ->
          test.expect 1
          container =
            values:
              env:
                PI: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeFloatPi')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var PI must be a float'
              test.done()

    'envJsonConfig':

      'strict':

        'success': (test) ->
          test.expect 1
          data =
            alpha: 1
            bravo: true
            charlie: "delta"

          container =
            values:
              env:
                CONFIG: JSON.stringify(data)
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envJsonConfig')
            .then (result) ->
              test.deepEqual data, result
              test.done()

        'must be json': (test) ->
          test.expect 1
          container =
            values:
              env:
                CONFIG: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envJsonConfig')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var CONFIG must be json. syntax error: Unexpected token o'
              test.done()

      'maybe':

        'null': (test) ->
          test.expect 1
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeJsonConfig')
            .then (result) ->
              test.equal null, result
              test.done()

        'success': (test) ->
          test.expect 1
          data =
            alpha: 1
            bravo: true
            charlie: "delta"

          container =
            values:
              env:
                CONFIG: JSON.stringify(data)
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeJsonConfig')
            .then (result) ->
              test.deepEqual data, result
              test.done()

        'must be json': (test) ->
          test.expect 1
          container =
            values:
              env:
                CONFIG: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envJsonConfig')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equal error.exception.message, 'env var CONFIG must be json. syntax error: Unexpected token o'
              test.done()

###################################################################################
# table

  'newTableResolver':

    'no match': (test) ->
      test.expect 1
      container =
        resolvers: [forge.newTableResolver()]

      hinoki.get(container, 'Table')
        .catch hinoki.UnresolvableFactoryError, (error) ->
          test.deepEqual error.path, ['Table']
          test.done()

    'if inner returns truthy then return that': (test) ->
      test.expect 1
      container =
        values:
          userTable: {}
        resolvers: [forge.newTableResolver()]

      hinoki.get(container, 'userTable')
        .then (result) ->
          test.equal result, container.values.userTable
          test.done()

    'userTable': (test) ->
      test.expect 1
      container =
        values:
          table:
            user: {}
        resolvers: [forge.newTableResolver()]

      hinoki.get(container, 'userTable')
        .then (result) ->
          test.equal result, container.values.table.user
          test.done()

    'projectMessageTable': (test) ->
      test.expect 1
      container =
        values:
          table:
            projectMessage: {}
        resolvers: [forge.newTableResolver()]

      hinoki.get(container, 'projectMessageTable')
        .then (result) ->
          test.equal result, container.values.table.projectMessage
          test.done()

###################################################################################
# alias

  'newAliasResolver':

    'passthrough': (test) ->
      test.expect 1
      container =
        values:
          thing: {}
        resolvers: [forge.newAliasResolver()]

      hinoki.get(container, 'thing').then (result) ->
        test.equal result, container.values.thing
        test.done()

    'no alias': (test) ->
      test.expect 0
      container =
        resolvers: [forge.newAliasResolver()]

      hinoki.get(container, 'thing')
        .catch hinoki.UnresolvableFactoryError, (error) ->
        test.done()

    'value': (test) ->
      test.expect 1
      container =
        values:
          thing: {}
        resolvers: [forge.newAliasResolver({alias: 'thing'})]

      hinoki.get(container, 'alias').then (result) ->
        test.equal result, container.values.thing
        test.done()

    'factory': (test) ->
      test.expect 2
      value = {}
      container =
        factories:
          thing: -> value
        resolvers: [forge.newAliasResolver({alias: 'thing'})]

      hinoki.get(container, 'alias').then (result) ->
        test.equal value, result
        test.equal value, container.values.thing
        test.done()

###################################################################################
# parse select

  'parseDataSelect': (test) ->
    test.deepEqual forge.parseDataSelect('firstUser'),
      type: 'first'
      name: 'user'
      order: []
      where: []
    test.deepEqual forge.parseDataSelect('selectUserCreatedAt'),
      type: 'select'
      name: 'userCreatedAt'
      order: []
      where: []
    test.deepEqual forge.parseDataSelect('firstUserWhereCreatedAt'),
      type: 'first'
      name: 'user'
      order: []
      where: ['created_at']
    test.deepEqual forge.parseDataSelect('selectOrderReportWhereOrderIdWhereCreatedAt'),
      type: 'select'
      name: 'orderReport'
      order: []
      where: ['order_id', 'created_at']
    test.deepEqual forge.parseDataSelect('firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDesc'),
      type: 'first'
      name: 'orderReport'
      order: [
        {
          column: 'created_at'
          direction: 'DESC'
        }
      ]
      where: ['order_id', 'created_at']
    test.deepEqual forge.parseDataSelect('selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAsc'),
      type: 'select'
      name: 'orderReport'
      order: [
        {
          column: 'created_at'
          direction: 'ASC'
        }
        {
          column: 'id'
          direction: 'DESC'
        }
        {
          column: 'report_number'
          direction: 'ASC'
        }
      ]
      where: ['order_id', 'created_at']

    test.done()

###################################################################################
# first

  'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrder': (test) ->
      test.expect 3
      calls =
        where: []
        order: []
      table = {}
      result = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.order = (arg) ->
        calls.order.push arg
        table
      table.first = ->
        result

      container =
        values:
          userTable: table
        resolvers: [forge.newDataFirstResolver()]

      hinoki.get(container, 'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrder')
        .then (accessor) ->
          test.equal result, accessor 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.deepEqual calls.order, ['updated_at DESC, order ASC']
          test.done()

###################################################################################
# select

  'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrder': (test) ->
      test.expect 3
      calls =
        where: []
        order: []
      table = {}
      result = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.order = (arg) ->
        calls.order.push arg
        table
      table.find = ->
        result

      container =
        values:
          userTable: table
        resolvers: [forge.newDataSelectResolver()]

      hinoki.get(container, 'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrder')
        .then (accessor) ->
          test.equal result, accessor 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.deepEqual calls.order, ['updated_at DESC, order ASC']
          test.done()

###################################################################################
# insert

  'parseDataInsert': (test) ->
    test.deepEqual forge.parseDataInsert('insertOrderReport'),
      name: 'orderReport'
    test.deepEqual forge.parseDataInsert('insertUserWhere'),
      name: 'userWhere'

    test.done()

  'insertUser': (test) ->
      test.expect 2
      result = {}
      data = {}
      table =
        insert: (arg) ->
          test.equal arg, data
          result

      container =
        values:
          userTable: table
        resolvers: [forge.newDataInsertResolver()]

      hinoki.get(container, 'insertUser')
        .then (accessor) ->
          test.equal result, accessor data
          test.done()

###################################################################################
# update

  'parseDataUpdate': (test) ->
    test.ok not forge.parseDataUpdate('updateOrderReport')?
    test.deepEqual forge.parseDataUpdate('updateOrderReportWhereRegistrationNumber'),
      name: 'orderReport'
      where: ['registration_number']

    test.done()

  'updateUserWhereIdWhereCreatedAt': (test) ->
      test.expect 3
      calls =
        where: []
      table = {}
      result = {}
      data = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.update = (arg) ->
        test.equal arg, data
        result

      container =
        values:
          userTable: table
        resolvers: [forge.newDataUpdateResolver()]

      hinoki.get(container, 'updateUserWhereIdWhereCreatedAt')
        .then (accessor) ->
          test.equal result, accessor data, 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.done()

###################################################################################
# delete

  'parseDataDelete': (test) ->
    test.ok not forge.parseDataDelete('deleteOrderReport')?
    test.deepEqual forge.parseDataDelete('deleteOrderReportWhereOrderId'),
      name: 'orderReport'
      where: ['order_id']

    test.done()

  'deleteUserWhereIdWhereCreatedAt': (test) ->
      test.expect 2
      calls =
        where: []
      table = {}
      result = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.delete = ->
        result

      container =
        values:
          userTable: table
        resolvers: [forge.newDataDeleteResolver()]

      hinoki.get(container, 'deleteUserWhereIdWhereCreatedAt')
        .then (accessor) ->
          test.equal result, accessor 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.done()

###################################################################################
# namespace

  'newNamespaceResolver':

    'if inner can resolve return that': (test) ->
      test.expect 4
      acrobat_opinion = {}
      opinion = {}

      container =
        factories:
          acrobat_opinion: -> acrobat_opinion
          opinion: -> opinion
        resolvers: [forge.newNamespaceResolver('': ['acrobat'])]

      hinoki.get(container, 'opinion').then (result) ->
        test.equal result, container.values.opinion
        test.ok not container.values.acrobat_opinion?
        test.equal result, opinion
        test.notEqual result, acrobat_opinion
        test.done()

    'global to namespace with match with result': (test) ->
      test.expect 2
      value = {}

      container =
        factories:
          acrobat_opinion: -> value
        resolvers: [forge.newNamespaceResolver('': ['acrobat'])]

      hinoki.get(container, 'opinion').then (result) ->
        test.equal result, container.values.acrobat_opinion
        test.equal result, value
        test.done()

    'namespace to global with match with result': (test) ->
      test.expect 2
      value = {}

      container =
        factories:
          opinion: -> value
        resolvers: [forge.newNamespaceResolver('acrobat': [''])]

      hinoki.get(container, 'acrobat_opinion').then (result) ->
        test.equal result, container.values.opinion
        test.equal result, value
        test.done()

    'namespace to namespace without match': (test) ->
      test.expect 0
      value = {}

      container =
        resolvers: [forge.newNamespaceResolver('tourist': ['artist'])]

      hinoki.get(container, 'opinion')
        .catch hinoki.UnresolvableFactoryError, (error) ->
          test.done()

    'namespace to namespace with match':

      'with result': (test) ->
        test.expect 2
        value = {}

        container =
          factories:
            acrobat_opinion: -> value
          resolvers: [forge.newNamespaceResolver('tourist': ['acrobat'])]

        hinoki.get(container, 'tourist_opinion').then (result) ->
          test.equal result, container.values.acrobat_opinion
          test.equal result, value
          test.done()

      'with null result': (test) ->
        test.expect 2
        container =
          factories:
            acrobat_opinion: -> null
          resolvers: [forge.newNamespaceResolver('tourist': ['acrobat'])]

        hinoki.get(container, 'tourist_opinion').then (result) ->
          test.equal null, container.values.acrobat_opinion
          test.equal null, result
          test.done()

      'without result': (test) ->
        test.expect 0
        container =
          resolvers: [forge.newNamespaceResolver('tourist': ['acrobat'])]

        hinoki.get(container, 'tourist_opinion')
          .catch hinoki.UnresolvableFactoryError, (error) ->
            test.done()

    'namespace to multi-namespace with match with result': (test) ->
      test.expect 2
      value = {}
      container =
        factories:
          acrobat_echo_opinion: -> value
        resolvers: [forge.newNamespaceResolver('tourist': ['acrobat_echo'])]

      hinoki.get(container, 'tourist_opinion').then (result) ->
        test.equal value, container.values.acrobat_echo_opinion
        test.equal value, result
        test.done()

    'multi-namespace to namespace with match with result': (test) ->
      test.expect 2
      value = {}
      container =
        factories:
          acrobat_opinion: -> value
        resolvers: [forge.newNamespaceResolver('tourist_bravo': ['acrobat'])]

      hinoki.get(container, 'tourist_bravo_opinion').then (result) ->
        test.equal value, container.values.acrobat_opinion
        test.equal value, result
        test.done()


    'ambiguity error': (test) ->
      test.expect 1
      resolver = forge.newNamespaceResolver
        'delta': ['alpha_echo', 'tourist', 'bravo']

      container =
        values:
          alpha_echo_charlie: {}
          tourist_charlie: {}
          bravo_charlie: {}
        resolvers: [resolver]

      message = [
        "ambiguity in namespace resolver."
        "\"delta_charlie\" maps to multiple resolvable names:"
        "alpha_echo_charlie (delta -> alpha_echo)"
        "tourist_charlie (delta -> tourist)"
        "bravo_charlie (delta -> bravo)"
      ].join '\n'

      hinoki.get(container, 'delta_charlie')
        .catch (error) ->
          test.equal error.message, message
          test.done()

    'single underscore works': (test) ->
      test.expect 1
      container =
        values:
          _: {}
        resolvers: [forge.newNamespaceResolver('tourist_bravo': ['acrobat'])]

      hinoki.get(container, '_').then (result) ->
        test.equal result, container.values._
        test.done()

    'multiple namespace mappings at once':

      'userAgent': (test) ->
        test.expect 2
        resolver = forge.newNamespaceResolver
          '': ['blaze', 'dragon']
          'u': ['util', 'delta']
          'urlApi': ['url_api']
          'blaze_port': ['']

        value = {}
        container =
          factories:
            dragon_userAgent: -> value
          resolvers: [resolver]

        hinoki.get(container, 'userAgent').then (result) ->
          test.equal result, value
          test.equal container.values.dragon_userAgent, value
          test.done()

      'urlApi_passwordForgot': (test) ->
        test.expect 1
        resolver = forge.newNamespaceResolver
          '': ['blaze', 'dragon']
          'u': ['util', 'delta']
          'urlApi': ['url_api']
          'blaze_port': ['']

        value = {}
        container =
          values:
            url_api_passwordForgot: value
          resolvers: [resolver]

        hinoki.get(container, 'urlApi_passwordForgot').then (result) ->
          test.equal result, value
          test.done()

###################################################################################
# surgical

  'newSurgicalResolver':

    'passthrough': (test) ->
      test.expect 2
      predicate = (path) ->
        test.deepEqual path, ['x']
        {value: {}}
      container =
        values:
          'x': {}
        resolvers: [forge.newSurgicalResolver(predicate)]

      hinoki.get(container, 'x').then (result) ->
        test.equal result, container.values.x
        test.done()

    'override': (test) ->
      test.expect 2
      value = {}
      predicate = (path) ->
        test.deepEqual path, ['x']
        {
          value: value
          override: true
        }
      container =
        values:
          'x': {}
        resolvers: [forge.newSurgicalResolver(predicate)]

      hinoki.get(container, 'x').then (result) ->
        test.equal result, value
        test.done()

    'as null resolver':

      'predicate match': (test) ->
        test.expect 2
        predicate = (path) ->
          test.deepEqual path, ['x']
          if path[0] is 'x'
            {value: null}
        container =
          resolvers: [forge.newSurgicalResolver(predicate)]

        hinoki.get(container, 'x').then (result) ->
          test.equal null, result
          test.done()

      'no predicate match': (test) ->
        test.expect 1
        predicate = (path) ->
          test.deepEqual path, ['y']
          if path[0] is 'x'
            return {value: null}
        container =
          resolvers: [forge.newSurgicalResolver(predicate)]

        hinoki.get(container, 'y')
          .catch hinoki.UnresolvableFactoryError, ->
            test.done()
