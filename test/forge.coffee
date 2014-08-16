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
      test.equals '', forge.joinCamelcase []
      test.equals 'a', forge.joinCamelcase ['a']
      test.equals 'first', forge.joinCamelcase ['first']
      test.equals 'firstWhereId', forge.joinCamelcase ['first', 'where', 'id']

      test.done()

    'joinUnderscore': (test) ->
      test.equals '', forge.joinUnderscore []
      test.equals 'first', forge.joinUnderscore ['first']
      test.equals 'first_where_id', forge.joinUnderscore ['first', 'where', 'id']

      test.done()

    'findIndex': (test) ->
      test.equals -1, forge.findIndex [], -> true
      test.equals 0, forge.findIndex [1], (x) -> x is 1
      test.equals -1, forge.findIndex [1], (x) -> x is 2
      test.equals 1, forge.findIndex [1, 2, 3], (x) -> x > 1
      test.equals -1, forge.findIndex [1, 2, 3], (x) -> x > 3

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
        test.equals actual, expected
        test.done()

    'envStringBaseUrl':

      'strict':

        'success': (test) ->
          container =
            values:
              env:
                BASE_URL: '/test'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envStringBaseUrl')
            .then (result) ->
              test.equals result, '/test'
              test.done()

        'must be present': (test) ->
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envStringBaseUrl')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var BASE_URL must not be blank'
              test.done()

        'must not be blank': (test) ->
          container =
            values:
              env:
                BASE_URL: ''
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envStringBaseUrl')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var BASE_URL must not be blank'
              test.done()

      'maybe':

        'null': (test) ->
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeStringBaseUrl')
            .then (result) ->
              test.equals result, null
              test.done()
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

        'null (blank)': (test) ->
          container =
            values:
              env:
                BASE_URL: ''
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeStringBaseUrl')
            .then (result) ->
              test.equals result, null
              test.done()


        'success': (test) ->
          container =
            values:
              env:
                BASE_URL: '/test'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeStringBaseUrl')
            .then (result) ->
              test.equals result, '/test'
              test.done()

    'envBoolIsActive':

      'strict':

        'true': (test) ->
          container =
            values:
              env:
                IS_ACTIVE: 'true'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envBoolIsActive')
            .then (result) ->
              test.equals true, result
              test.done()

        'false': (test) ->
          container =
            values:
              env:
                IS_ACTIVE: 'false'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envBoolIsActive')
            .then (result) ->
              test.equals false, result
              test.done()

        'must be true or false': (test) ->
          container =
            values:
              env:
                IS_ACTIVE: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envBoolIsActive')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var IS_ACTIVE must be \'true\' or \'false\''
              test.done()

      'maybe':

        'null': (test) ->
          container =
            values:
              env:
                {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .then (result) ->
              test.equals result, null
              test.done()

        'true': (test) ->
          container =
            values:
              env:
                IS_ACTIVE: 'true'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .then (result) ->
              test.equals true, result
              test.done()

        'false': (test) ->
          container =
            values:
              env:
                IS_ACTIVE: 'false'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .then (result) ->
              test.equals false, result
              test.done()

        'must be true or false': (test) ->
          container =
            values:
              env:
                IS_ACTIVE: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeBoolIsActive')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var IS_ACTIVE must be \'true\' or \'false\''
              test.done()

    'envIntPort':

      'strict':

        'success': (test) ->
          container =
            values:
              env:
                PORT: '9000'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envIntPort')
            .then (result) ->
              test.equals 9000, result
              test.done()

        'must be an integer': (test) ->
          container =
            values:
              env:
                PORT: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envIntPort')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var PORT must be an integer'
              test.done()

      'maybe':

        'null': (test) ->
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeIntPort')
            .then (result) ->
              test.equals null, result
              test.done()

        'success': (test) ->
          container =
            values:
              env:
                PORT: '9000'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeIntPort')
            .then (result) ->
              test.equals 9000, result
              test.done()

        'must be an integer': (test) ->
          container =
            values:
              env:
                PORT: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeIntPort')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var PORT must be an integer'
              test.done()

    'envFloatPi':

      'strict':

        'success': (test) ->
          container =
            values:
              env:
                PI: '3.141'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envFloatPi')
            .then (result) ->
              test.equals 3.141, result
              test.done()

        'must be a float': (test) ->
          container =
            values:
              env:
                PI: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envFloatPi')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var PI must be a float'
              test.done()

      'maybe':

        'null': (test) ->
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeFloatPi')
            .then (result) ->
              test.equals null, result
              test.done()

        'success': (test) ->
          container =
            values:
              env:
                PI: '3.141'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeFloatPi')
            .then (result) ->
              test.equals 3.141, result
              test.done()

        'must be a float': (test) ->
          container =
            values:
              env:
                PI: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeFloatPi')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var PI must be a float'
              test.done()

    'envJsonConfig':

      'strict':

        'success': (test) ->
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
          container =
            values:
              env:
                CONFIG: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envJsonConfig')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var CONFIG must be json. syntax error: Unexpected token o'
              test.done()

      'maybe':

        'null': (test) ->
          container =
            values:
              env: {}
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envMaybeJsonConfig')
            .then (result) ->
              test.equals null, result
              test.done()

        'success': (test) ->
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
          container =
            values:
              env:
                CONFIG: 'foo'
            resolvers: [forge.newEnvResolver()]

          hinoki.get(container, 'envJsonConfig')
            .catch hinoki.ExceptionInFactoryError, (error) ->
              test.equals error.exception.message, 'env var CONFIG must be json. syntax error: Unexpected token o'
              test.done()

###################################################################################
# table

  'newTableResolver':

    'no match': (test) ->
      container =
        resolvers: [forge.newTableResolver()]

      hinoki.get(container, 'Table')
        .catch hinoki.UnresolvableFactoryError, (error) ->
          test.deepEqual error.path, ['Table']
          test.done()

    'if inner returns truthy then return that': (test) ->
      container =
        values:
          userTable: {}
        resolvers: [forge.newTableResolver()]

      hinoki.get(container, 'userTable')
        .then (result) ->
          test.equals result, container.values.userTable
          test.done()

    'userTable': (test) ->
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
      container =
        values:
          thing: {}
        resolvers: [forge.newAliasResolver()]

      hinoki.get(container, 'thing').then (result) ->
        test.equal result, container.values.thing
        test.done()

    'no alias': (test) ->
      container =
        resolvers: [forge.newAliasResolver()]

      hinoki.get(container, 'thing')
        .catch hinoki.UnresolvableFactoryError, (error) ->
        test.done()

    'value': (test) ->
      container =
        values:
          thing: {}
        resolvers: [forge.newAliasResolver({alias: 'thing'})]

      hinoki.get(container, 'alias').then (result) ->
        test.equal result, container.values.thing
        test.done()

    'factory': (test) ->
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
# first

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
          direction: 'desc'
        }
      ]
      where: ['order_id', 'created_at']
    test.deepEqual forge.parseDataSelect('selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAsc'),
      type: 'select'
      name: 'orderReport'
      order: [
        {
          column: 'created_at'
          direction: 'asc'
        }
        {
          column: 'id'
          direction: 'desc'
        }
        {
          column: 'report_number'
          direction: 'asc'
        }
      ]
      where: ['order_id', 'created_at']

    test.done()

###################################################################################
# select

###################################################################################
# insert

  'parseDataInsert': (test) ->
    test.deepEqual forge.parseDataInsert('insertOrderReport'),
      name: 'orderReport'
    test.deepEqual forge.parseDataInsert('insertUserWhere'),
      name: 'userWhere'

    test.done()

###################################################################################
# update

  'parseDataUpdate': (test) ->
    test.ok not forge.parseDataUpdate('updateOrderReport')?
    test.deepEqual forge.parseDataUpdate('updateOrderReportWhereRegistrationNumber'),
      name: 'orderReport'
      where: ['registration_number']

    test.done()

###################################################################################
# delete

  'parseDataDelete': (test) ->
    test.ok not forge.parseDataDelete('deleteOrderReport')?
    test.deepEqual forge.parseDataDelete('deleteOrderReportWhereOrderId'),
      name: 'orderReport'
      where: ['order_id']

    test.done()

###################################################################################
# namespace

  'newNamespaceResolver':

    'global to namespace with match with result': (test) ->
      x = {}
      calls = []
      returns = [undefined, x].reverse()

      resolver = forge.newNamespaceResolver
        '': ['acrobat']
      query =
        path: ['opinion']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['opinion']}
        {container: query.container, path: ['acrobat_opinion']}
      ]

      test.done()

    'namespace to global with match with result': (test) ->
      x = {}
      calls = []
      returns = [undefined, x].reverse()

      resolver = forge.newNamespaceResolver
        'acrobat': ['']
      query =
        path: ['acrobat_opinion']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['acrobat_opinion']}
        {container: query.container, path: ['opinion']}
      ]

      test.done()

    'namespace to namespace without match': (test) ->
      calls = []
      returns = [undefined, undefined].reverse()

      resolver = forge.newNamespaceResolver
        'tourist': ['artist']
      query =
        path: ['opinion']
        container: {}
      test.ok 'undefined' is typeof resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['opinion']}
      ]

      test.done()

    'namespace to namespace with match with result': (test) ->
      x = {}
      calls = []
      returns = [undefined, x].reverse()

      resolver = forge.newNamespaceResolver
        'tourist': ['acrobat']
      query =
        path: ['tourist_opinion']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['tourist_opinion']}
        {container: query.container, path: ['acrobat_opinion']}
      ]

      test.done()

    'namespace to namespace with match with null result': (test) ->
      calls = []
      returns = [undefined, null].reverse()

      resolver = forge.newNamespaceResolver
        'tourist': ['acrobat']
      query =
        path: ['tourist_opinion']
        container: {}
      test.equals null, resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['tourist_opinion']}
        {container: query.container, path: ['acrobat_opinion']}
      ]

      test.done()

    'namespace to namespace with match without result': (test) ->
      x = {}
      calls = []
      returns = [undefined, undefined].reverse()

      resolver = forge.newNamespaceResolver
        'tourist': ['acrobat']
      query =
        path: ['tourist_opinion']
        container: {}
      test.ok 'undefined' is typeof resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['tourist_opinion']}
        {container: query.container, path: ['acrobat_opinion']}
      ]

      test.done()

    'namespace to multi-namespace with match with result': (test) ->
      x = {}
      calls = []
      returns = [undefined, x].reverse()

      resolver = forge.newNamespaceResolver
        'tourist': ['acrobat_echo']
      query =
        path: ['tourist_opinion']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['tourist_opinion']}
        {container: query.container, path: ['acrobat_echo_opinion']}
      ]

      test.done()

    'multi-namespace to namespace with match with result': (test) ->
      x = {}
      calls = []
      returns = [undefined, x].reverse()

      resolver = forge.newNamespaceResolver
        'tourist_bravo': ['acrobat']
      query =
        path: ['tourist_bravo_opinion']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()

      test.deepEqual calls, [
        {container: query.container, path: ['tourist_bravo_opinion']}
        {container: query.container, path: ['acrobat_opinion']}
      ]

      test.done()

    'ambiguity error': (test) ->
      x = {}
      y = {}
      z = {}
      calls = []
      returns = [undefined, x, y, z].reverse()

      resolver = forge.newNamespaceResolver
        'delta': ['alpha_echo', 'tourist', 'bravo']
      query =
        path: ['delta_charlie']
        container: {}
      error = [
        "ambiguity in namespace resolver."
        "\"delta_charlie\" maps to multiple resolvable names:"
        "alpha_echo_charlie (alpha_echo -> delta)"
        "tourist_charlie (tourist -> delta)"
        "bravo_charlie (bravo -> delta)"
      ].join '\n'
      test.throws(
        ->
          resolver query, (arg) ->
            calls.push arg
            return returns.pop()
        Error
        error
      )

      test.deepEqual calls, [
        {container: query.container, path: ['delta_charlie']}
        {container: query.container, path: ['alpha_echo_charlie']}
        {container: query.container, path: ['tourist_charlie']}
        {container: query.container, path: ['bravo_charlie']}
      ]

      test.done()

    'complex run': (test) ->
      resolver = forge.newNamespaceResolver
        '': ['blaze', 'dragon']
        'u': ['util', 'delta']
        'urlApi': ['url_api']
        'blaze_port': ['']
      container = {}

      x = {}
      calls = []
      returns = [undefined, undefined, x].reverse()
      query =
        path: ['userAgent']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()
      test.deepEqual calls, [
        {container: query.container, path: ['userAgent']}
        {container: query.container, path: ['blaze_userAgent']}
        {container: query.container, path: ['dragon_userAgent']}
      ]

      x = {}
      calls = []
      returns = [undefined, x].reverse()
      query =
        path: ['urlApi_passwordForgot']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()
      test.deepEqual calls, [
        {container: query.container, path: ['urlApi_passwordForgot']}
        {container: query.container, path: ['url_api_passwordForgot']}
      ]

      x = {}
      calls = []
      returns = [undefined, undefined, undefined].reverse()
      query =
        path: ['urlApi']
        container: {}
      test.ok 'undefined' is typeof resolver query, (arg) ->
        calls.push arg
        return returns.pop()
      test.deepEqual calls, [
        {container: query.container, path: ['urlApi']}
        {container: query.container, path: ['blaze_urlApi']}
        {container: query.container, path: ['dragon_urlApi']}
      ]

      x = {}
      calls = []
      returns = [x].reverse()
      query =
        path: ['_']
        container: {}
      test.equals x, resolver query, (arg) ->
        calls.push arg
        return returns.pop()
      test.deepEqual calls, [
        {container: query.container, path: ['_']}
      ]

      test.done()
