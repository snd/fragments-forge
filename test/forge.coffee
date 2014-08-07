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

    'no match': (test) ->
      test.expect 2

      resolver = forge.newEnvFactoryResolver()
      factory = {}
      test.equals factory, resolver {}, 'configPort', ->
        test.ok true
        return factory

      test.done()

    'envStringBaseUrl': (test) ->
      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envStringBaseUrl', ->
        null

      test.equals '/test', factory {
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
          factory {
            PORT: '9000'
          }
        Error
        'env var BASE_URL must not be blank'
      )

      test.done()

    'envBoolIsActive': (test) ->

      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envBoolIsActive', ->
        null

      test.equals true, factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'true'
        PORT: '9000'
      }

      test.equals false, factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'false'
        PORT: '9000'
      }

      test.throws(
        ->
          factory {
            PORT: 'dflkdjfl'
            IS_ACTIVE: 'foo'
          }
        Error
        "env var IS_ACTIVE must be 'true' or 'false'"
      )

      test.done()

    'envIntPort': (test) ->

      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envIntPort', ->
        null

      test.equals 9000, factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.throws(
        ->
          factory {
            PORT: 'dflkdjfl'
          }
        Error
        'env var PORT must be an integer'
      )

      test.done()

    'envFloatPi': (test) ->

      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envFloatPi', ->
        null

      test.equals 3.141, factory {
        BASE_URL: '/test'
        PI: '3.141'
      }

      test.throws(
        ->
          factory {
            PI: 'dflkdjfl'
          }
        Error
        'env var PI must be a float'
      )

      test.done()

    'envMaybeStringBaseUrl': (test) ->
      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envMaybeStringBaseUrl', ->
        null

      test.equals '/test', factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.equals null, factory {
        BASE_URL: ''
        PORT: '9000'
      }

      test.equals null, factory {
        PORT: '9000'
      }

      test.done()

    'envMaybeBoolIsActive': (test) ->

      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envMaybeBoolIsActive', ->
        null

      test.equals true, factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'true'
        PORT: '9000'
      }

      test.equals false, factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'false'
        PORT: '9000'
      }

      test.equals null, factory {
        BASE_URL: '/test'
        IS_ACTIVE: ''
        PORT: '9000'
      }

      test.equals null, factory {
        BASE_URL: '/test'
        PORT: '9000'
      }

      test.throws(
        ->
          factory {
            PORT: 'dflkdjfl'
            IS_ACTIVE: 'foo'
          }
        Error
        "env var IS_ACTIVE must be 'true' or 'false'"
      )

      test.done()

    'envMaybeIntPort': (test) ->

      resolver = forge.newEnvFactoryResolver()
      factory = resolver {}, 'envMaybeIntPort', ->
        null

      test.equals 9000, factory {
        BASE_URL: '/test'
        IS_ACTIVE: 'true'
        PORT: '9000'
      }

      test.equals null, factory {
        BASE_URL: '/test'
        PORT: ''
      }

      test.equals null, factory {
        BASE_URL: '/test'
      }

      test.throws(
        ->
          factory {
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
      test.expect 2

      resolver = forge.newTableFactoryResolver()
      test.equals null, resolver {}, 'Table', ->
        test.ok true
        return null

      test.done()

    'if inner returns truthy then return that': (test) ->
      test.expect 2

      resolver = forge.newTableFactoryResolver()
      factory = {}
      test.equals factory, resolver {}, 'userTable', ->
        test.ok true
        return factory

      test.done()

    'userTable': (test) ->
      test.expect 3

      resolver = forge.newTableFactoryResolver()
      factory = resolver {}, 'userTable', ->
        test.ok true
        return null

      test.ok factory?

      table =
        user: {}
        projectMessage: {}

      test.equals table.user, factory table

      test.done()

    'projectMessageTable': (test) ->
      test.expect 3

      resolver = forge.newTableFactoryResolver()
      factory = resolver {}, 'projectMessageTable', ->
        test.ok true
        return null
      test.ok factory?

      table =
        user: {}
        projectMessage: {}

      test.equals table.projectMessage, factory table

      test.done()

###################################################################################
# alias

  'newAliasResolver':

    'inner is passed through': (test) ->
      test.expect 2

      x = {}

      resolver = forge.newAliasResolver()
      test.equals x, resolver {}, 'thing', ->
        test.ok true
        return x

      test.done()

    'no alias': (test) ->
      test.expect 2

      x = {}

      resolver = forge.newAliasResolver()
      test.equals null, resolver {}, 'thing', ->
        test.ok true
        return null

      test.done()

    'alias': (test) ->
      test.expect 2

      c = {}
      x = {}

      resolver = forge.newAliasResolver
        alias: 'name'

      callsToInner = []
      test.equals x, resolver c, 'alias', (args...) ->
        callsToInner.push args
        if callsToInner.length is 1
          null
        else
          x

      test.deepEqual callsToInner, [
        []
        [c, 'name']
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

    'namespace to global with match with result': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        'acrobat': ''
      container = {}
      calls = []
      test.equals x, resolver container, 'opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then x

      test.deepEqual calls, [
        [container, 'acrobat_opinion']
      ]

      test.done()

    'namespace to namespace without match': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        'acrobat': 'tourist'
      container = {}
      calls = []
      test.equals x, resolver container, 'opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then x

      test.deepEqual calls, [
        []
      ]

      test.done()

    'namespace to namespace with match with result': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        'acrobat': 'tourist'
      container = {}
      calls = []
      test.equals x, resolver container, 'tourist_opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then x

      test.deepEqual calls, [
        [container, 'acrobat_opinion']
      ]

      test.done()

    'namespace to namespace with match with null result': (test) ->
      test.expect 2

      resolver = forge.newNamespaceResolver
        'acrobat': 'tourist'
      container = {}
      calls = []
      test.equals null, resolver container, 'tourist_opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then null

      test.deepEqual calls, [
        [container, 'acrobat_opinion']
      ]

      test.done()

    'namespace to namespace with match without result': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        'acrobat': 'tourist'
      calls = []
      container = {}
      test.equals x, resolver container, 'tourist_opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then undefined
          when 2 then x

      test.deepEqual calls, [
        [container, 'acrobat_opinion']
        []
      ]

      test.done()

    'multi-namespace to namespace with match with result': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        'acrobat_echo': 'tourist'
      calls = []
      container = {}
      test.equals x, resolver container, 'tourist_opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then x

      test.deepEqual calls, [
        [container, 'acrobat_echo_opinion']
      ]

      test.done()

    'namespace to multi-namespace with match with result': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        'acrobat': 'tourist_bravo'
      calls = []
      container = {}
      test.equals x, resolver container, 'tourist_bravo_opinion', (args...) ->
        calls.push args
        switch calls.length
          when 1 then x

      test.deepEqual calls, [
        [container, 'acrobat_opinion']
      ]

      test.done()

    'global to multi-namespace with match with result': (test) ->
      test.expect 2

      x = {}
      resolver = forge.newNamespaceResolver
        '': 'tourist_alpha_echo'
      calls = []
      container = {}
      test.equals x, resolver container, 'tourist_alpha_echo_bravo', (args...) ->
        calls.push args
        switch calls.length
          when 1 then x

      test.deepEqual calls, [
        [container, 'bravo']
      ]

      test.done()

    'ambiguity error': (test) ->
      test.expect 2

      x = {}
      y = {}
      z = {}
      resolver = forge.newNamespaceResolver
        'alpha_echo': 'delta'
        'tourist': 'delta'
        'bravo': 'delta'
      calls = []
      container = {}
      error = [
        "ambiguity in namespace resolver."
        "\"delta_charlie\" maps to multiple resolvable names:"
        "alpha_echo_charlie (alpha_echo -> delta)"
        "tourist_charlie (tourist -> delta)"
        "bravo_charlie (bravo -> delta)"
      ].join '\n'
      test.throws(
        ->
          resolver container, 'delta_charlie', (args...) ->
            calls.push args
            switch calls.length
              when 1 then x
              when 2 then y
              when 2 then z
        Error
        error
      )

      test.deepEqual calls, [
        [container, 'alpha_echo_charlie']
        [container, 'tourist_charlie']
        [container, 'bravo_charlie']
      ]

      test.done()

      # test multiple mappings and resultions
