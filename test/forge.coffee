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

    'extractWhereClauses': (test) ->
      test.deepEqual [], forge.extractWhereClauses []
      test.deepEqual [], forge.extractWhereClauses ['where']
      test.deepEqual [], forge.extractWhereClauses ['id']
      test.deepEqual [['id']], forge.extractWhereClauses ['where', 'id']
      test.deepEqual [['created', 'at']],
          forge.extractWhereClauses ['where', 'created', 'at']
      test.deepEqual [['created', 'at'], ['id']],
          forge.extractWhereClauses ['where', 'created', 'at', 'where', 'id']
      test.deepEqual [['created', 'at'], ['id']],
          forge.extractWhereClauses ['where', 'created', 'at', 'where', 'id', 'where']
      test.deepEqual [],
          forge.extractWhereClauses ['id', 'where', 'created', 'at']

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
        test.fail()

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
        test.fail()

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
        test.fail()

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
        test.fail()

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
        test.fail()

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
        test.fail()

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
        test.fail()

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
# table

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

  'parseDataAccessorSpec':

    'first': (test) ->
      test.deepEqual forge.parseDataAccessorSpec('firstUser'),
        type: 'first'
        name: ['user']
        where: []
      test.deepEqual forge.parseDataAccessorSpec('firstUserCreatedAt'),
        type: 'first'
        name: ['user', 'created', 'at']
        where: []
      test.deepEqual forge.parseDataAccessorSpec('firstUserWhereCreatedAt'),
        type: 'first'
        name: ['user']
        where: [['created', 'at']]
      test.deepEqual forge.parseDataAccessorSpec('firstOrderReportWhereIdWhereCreatedAt'),
        type: 'first'
        name: ['order', 'report']
        where: [['id'], ['created', 'at']]

      test.done()

    'delete': (test) ->
      test.ok not forge.parseDataAccessorSpec('deleteOrderReport')?
      test.deepEqual forge.parseDataAccessorSpec('deleteOrderReportWhereId'),
        type: 'delete'
        name: ['order', 'report']
        where: [['id']]

      test.done()

    'delete': (test) ->
      test.ok not forge.parseDataAccessorSpec('updateOrderReport')?
      test.deepEqual forge.parseDataAccessorSpec('updateOrderReportWhereRegistrationNumber'),
        type: 'update'
        name: ['order', 'report']
        where: [['registration', 'number']]

      test.done()

    'insert': (test) ->
      test.deepEqual forge.parseDataAccessorSpec('insertOrderReport'),
        type: 'insert'
        name: ['order', 'report']
      test.deepEqual forge.parseDataAccessorSpec('insertUserWhere'),
        type: 'insert'
        name: ['user', 'where']

      test.done()
