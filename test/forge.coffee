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
# env

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

  'newEnvFactoryResolver':

    'passthrough': (test) ->
      test.expect 2

      resolver = forge.newEnvResolver()
      factory = {}
      query =
        path: ['envIntPort']
        container: {}
      test.equals factory, resolver query, (arg) ->
        test.equals query, arg
        return factory

      test.done()

    'envStringBaseUrl': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envStringBaseUrl']
        container: {}
      result = resolver query, (arg) ->
        test.equals query, arg
        null

      test.equals result.path, query.path
      test.equals result.container, query.container

      test.equals '/test', result.factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.throws(
        ->
          factory {
            BASE_URL: ''
            PORT: '9000'
          }
        Error
        'env var BASE_URL must not be blank'
      )

      test.throws(
        ->
          result.factory {
            PORT: '9000'
          }
        Error
        'env var BASE_URL must not be blank'
      )

      test.done()

    'envBoolIsActive': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envBoolIsActive']
        container: {}
      result = resolver query, ->

      test.equals true, result.factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'true'
        PORT: '9000'
      }

      test.equals false, result.factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'false'
        PORT: '9000'
      }

      test.throws(
        ->
          result.factory {
            PORT: 'dflkdjfl'
            IS_ACTIVE: 'foo'
          }
        Error
        "env var IS_ACTIVE must be 'true' or 'false'"
      )

      test.done()

    'envIntPort': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envIntPort']
        container: {}
      result = resolver query, ->

      test.equals 9000, result.factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.throws(
        ->
          result.factory {
            PORT: 'dflkdjfl'
          }
        Error
        'env var PORT must be an integer'
      )

      test.done()

    'envFloatPi': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envFloatPi']
        container: {}
      result = resolver query, ->

      test.equals 3.141, result.factory {
        BASE_URL: '/test'
        PI: '3.141'
      }

      test.throws(
        ->
          result.factory {
            PI: 'dflkdjfl'
          }
        Error
        'env var PI must be a float'
      )

      test.done()

    'envMaybeStringBaseUrl': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envMaybeStringBaseUrl']
        container: {}
      result = resolver query, ->

      test.equals '/test', result.factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.equals null, result.factory {
        BASE_URL: ''
        PORT: '9000'
      }

      test.equals null, result.factory {
        PORT: '9000'
      }

      test.done()

    'envMaybeBoolIsActive': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envMaybeBoolIsActive']
        container: {}
      result = resolver query, ->

      test.equals true, result.factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'true'
        PORT: '9000'
      }

      test.equals false, result.factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'false'
        PORT: '9000'
      }

      test.equals null, result.factory {
        BASE_URL: '/test'
        IS_ACTIVE: ''
        PORT: '9000'
      }

      test.equals null, result.factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.throws(
        ->
          result.factory {
            PORT: 'dflkdjfl'
            IS_ACTIVE: 'foo'
          }
        Error
        "env var IS_ACTIVE must be 'true' or 'false'"
      )

      test.done()

    'envMaybeIntPort': (test) ->
      resolver = forge.newEnvResolver()
      query =
        path: ['envMaybeIntPort']
        container: {}
      result = resolver query, ->

      test.equals 9000, result.factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'true'
        PORT: '9000'
      }

      test.equals null, result.factory {
        BASE_URL: '/test'
        PORT: ''
      }

      test.equals null, result.factory {
        BASE_URL: '/test'
      }

      test.throws(
        ->
          result.factory {
            PORT: 'dflkdjfl'
            IS_ACTIVE: 'foo'
          }
        Error
        "env var PORT must be an integer"
      )

      test.done()

###################################################################################
# table

  'newTableFactoryResolver':

    'no match': (test) ->
      resolver = forge.newTableResolver()
      query =
        path: ['Table']
        container: {}
      test.equals null, resolver query, (arg) ->
        test.equals arg, query
        return null

      test.done()

    'if inner returns truthy then return that': (test) ->
      resolver = forge.newTableResolver()
      factoryResult = {}
      query =
        path: ['userTable']
        container: {}
      test.equals factoryResult, resolver query, (arg) ->
        test.equals query, arg
        return factoryResult

      test.done()

    'userTable': (test) ->
      resolver = forge.newTableResolver()
      factoryResult = {}
      query =
        path: ['userTable']
        container: {}
      result = resolver query, (arg) ->
        test.equals query, arg
        return null

      test.ok result?

      table =
        user: {}
        projectMessage: {}

      test.equals table.user, result.factory table

      test.done()

    'projectMessageTable': (test) ->
      resolver = forge.newTableResolver()
      factoryResult = {}
      query =
        path: ['projectMessageTable']
        container: {}
      result = resolver query, (arg) ->
        test.equals query, arg
        return null

      test.ok result?

      table =
        user: {}
        projectMessage: {}

      test.equals table.projectMessage, result.factory table

      test.done()

###################################################################################
# alias

  'newAliasResolver':

    'passthrough': (test) ->
      x = {}

      resolver = forge.newAliasResolver()
      query =
        path: ['thing']
        container: {}
      test.equals x, resolver query, (arg) ->
        test.equals query, arg
        return x

      test.done()

    'no alias': (test) ->
      x = {}

      resolver = forge.newAliasResolver()
      query =
        path: ['thing']
        container: {}
      test.equals null, resolver query, (arg) ->
        test.equals query, arg
        return null

      test.done()

    'alias': (test) ->
      x = {}

      resolver = forge.newAliasResolver
        alias: 'name'

      query =
        path: ['alias']
        container: {}

      calls = []
      test.equals x, resolver query, (arg) ->
        calls.push arg
        if calls.length is 1
          null
        else
          x

      test.deepEqual calls, [
        {path: ['alias'], container: query.container}
        {path: ['name'], container: query.container}
      ]

      test.done()

###################################################################################
# data accessor

  'parseDataFirst': (test) ->
    test.deepEqual forge.parseDataFirst('firstUser'),
      name: 'user'
      where: []
    test.deepEqual forge.parseDataFirst('firstUserCreatedAt'),
      name: 'userCreatedAt'
      where: []
    test.deepEqual forge.parseDataFirst('firstUserWhereCreatedAt'),
      name: 'user'
      where: ['created_at']
    test.deepEqual forge.parseDataFirst('firstOrderReportWhereIdWhereCreatedAt'),
      name: 'orderReport'
      where: ['id', 'created_at']

    test.done()

  'parseDataSelect': (test) ->
    test.deepEqual forge.parseDataSelect('selectUser'),
      name: 'user'
      where: []
    test.deepEqual forge.parseDataSelect('selectUserCreatedAt'),
      name: 'userCreatedAt'
      where: []
    test.deepEqual forge.parseDataSelect('selectUserWhereCreatedAt'),
      name: 'user'
      where: ['created_at']
    test.deepEqual forge.parseDataSelect('selectOrderReportWhereIdWhereCreatedAt'),
      name: 'orderReport'
      where: ['id', 'created_at']

    test.done()

  'parseDataInsert': (test) ->
    test.deepEqual forge.parseDataInsert('insertOrderReport'),
      name: 'orderReport'
    test.deepEqual forge.parseDataInsert('insertUserWhere'),
      name: 'userWhere'

    test.done()

  'parseDataUpdate': (test) ->
    test.ok not forge.parseDataUpdate('updateOrderReport')?
    test.deepEqual forge.parseDataUpdate('updateOrderReportWhereRegistrationNumber'),
      name: 'orderReport'
      where: ['registration_number']

    test.done()

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
