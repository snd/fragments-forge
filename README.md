# blaze-forge

#### ~~ BLAZE-FORGE IS A WORK IN PROGRESS ~~

> scrap your boilerplate! by auto-generating boilerplate dependencies based on naming conventions

blaze-forge is a collection of factory-resolvers for hinoki containers.


its like rubys method missing.

blaze-forge is a resolver for hinoki containers that can autogenerate
common data accessor functions, loaders, etc.
according to some conventions
and greatly reduce the amount of code needed.

- greatly reduces the amount of code needed

it allows you to ask for things that don't yet exist.

convention

```javascript
var forge = require('blaze-forge');
```

opinionated

- serverside
  - [`envIntPort`, `envMaybeStringMandrillApiKey`, ...](#envmaybestringboolintfloatname)
  - [`userTable`, `orderReportTable`, ...](#tablenametable)
  - [`getUserWhereId`, `deleteUserWhereId`](#data-accessor-resolver)
  - [REST](#)
  - [`$$firstUserWhereIdIsParamsId`]
- clientside
  - [`getUserWhereId`](#)
- shared
  - [alias -> name](#alias-resolver)

### `env[Maybe](String|Bool|Int|Float){name}`

> makes depending on parsed and checked environment variables dead-simple!

- `envIntPort` parses int from envvar `PORT`. throws if not present or not parseable.
- `envBoolEnableEtags` parses bool from envvar `ENABLE_ETAGS`. throws if not present or not parseable.
- `envStringDatabaseUrl` reads string from envvar `DATABASE_URL`. throws if not present or blank.
- `envFloatCommisionPercentage` parses float from envvar `COMMISSION_PERCENTAGE`. throws if not present or not parseable.
- `envMaybeStringMandrillApikey` reads string from envvar `MANDRILL_APIKEY`. returns null if not present or blank.
- `envMaybeIntPoolSize` parses int from envvar `POOL_SIZE`. returns null if not present. throws if present and not parseable.
- ...

#### internals

returned factories depend on `env`. `env` is provided by [blaze-fragments](https://github.com/snd/blaze-fragments)

```javascript
var container = {
  // ...
  factoryResolvers: [
    // ...
    forge.newEnvFactoryResolver('env')
    // ...
  ]
};
```

### `{tableName}Table`

mesa tables often need circular dependencies for associations.
hinoki doesn't support circular dependencies.
this resolver removes this mismatch.

just have a `table` factory that returns an object containing
all the tables.

then require the tables with this naming convention `{tableName}Table`

- `userTable` auto resolves to `table.user`
- `orderReportTable` auto resolves to `table.orderReport`
- ...

#### internals

returned factories depend on `table`

```javascript
var container = {
  // ...
  factoryResolvers: [
    // ...
    forge.newTableFactoryResolver('table')
    // ...
  ]
};
```

### serverside data accessor resolver

**definition: data accessor:** a function used to get or manipulate
data in the database

**definition: data specification:** an object with properties
`table`, `updateableColumns`, `insertableColumns`

? for blaze-rest also `errors`, `accessControl`

the data accessor resolver needs a way to look up data specs by name:

you can overwrite everything auto generated if you want
because the factory resolver is called before the generator resolver

### alias resolver

### data accessor patterns

#### select first

`first` followed by the model name followed by zero-or-more
[conditions](#condition-pattern-fragment):

- firstUserWhereId(id)
- firstAdmin()
- firstOrderReport()
- firstOrderWhereIsPendingWhereIsActive(isPending, isActive)

#### select all

`select` followed by the model name followed by zero-or-more
[conditions](#condition-pattern-fragment) followed by an optional [order](#order-pattern-fragment):

- selectUserProfile()
- selectUserProfileWhereIsActiveOrderByCreatedAtDesc(isActive)

#### browse (for backoffice table views)

`browse` followed by the model name followed by an optional [order](#order-pattern-fragment)
(which overwrites/disables `orderBy` and `orderAsc`):

- browseUser(options)
- browseUserProfile(options)
- browseUserProfileOrderByCreatedAtDesc(options)

generated function takes a single options object as its argument.
options object can contain `limit: limit` and `offset: offset`,
`orderBy: column` and `orderAsc: true | false` (default true) which work as expected.
options object can also contain a `criterion: criterion` which
can be any valid [criterion](https://github.com/snd/criterion) for filtering.

#### insert

`insert` followed by the model name:

- insertUser(user)
- insertUserProfile(userProfile)

generated function returns inserted record.

#### insertMany

`insertMany` followed by the model name:

- insertManyUser(users)
- insertManyUserProfile(userProfiles)

generated function returns inserted records.

#### update

`update` followed by the model name followed by **one**-or-more
[conditions](#condition-pattern-fragment):

- updateUserWhereId(updates, id)
- updateUserWhereIdWhereIsActive(updates, id, isActive)

generated function returns first updated record.

#### updateMany

`updateMany` followed by the model name followed by **one**-or-more
[conditions](#condition-pattern-fragment):

- updateManyUserWhereIsActive(updates, id)
- updateManyWhereIsActiveWhereIsAdmin(updates, id, isActive, isAdmin)

generated function returns updated records.

#### delete

`delete` followed by the model name followed by **one**-or-more
[conditions](#condition-pattern-fragment):

- deleteWhereId(id)
- deleteWhereIsActive(isActive)
- deleteWhereIdWhereIsActive(id, isActive)

#### condition (pattern fragment)

`Where` followed by a camelcased column name:

- WhereId
- WhereCreatedAt
- WhereReferenceNumber

#### order (pattern fragment)

`OrderBy` followed by a camelcased column name followed by either `Asc` or `Desc`:

- OrderByCreatedAtAsc
- OrderByViewCountDesc

### data loader patterns

$$firstPageWhereIdIsParamsId

$$pageWhereIsActive

$$pageOrderByCreatedAtDesc

$$pageByQuery

## alpha thoughts

you can not give arguments to the factories
but through resolvers you can give some sort of arguments
through the dependency names

? scrap url boilerplate

this is heavy on conventions!!!

? make the conventions changeable
