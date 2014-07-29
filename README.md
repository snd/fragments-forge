# blaze-forge

#### ~~ BLAZE-FORGE IS A WORK IN PROGRESS ~~

blaze-forge is a collection of factory-resolvers for hinoki containers.

blaze-forge is a resolver for hinoki containers that can autogenerate
common data accessor functions, loaders, etc.
according to some conventions
and greatly reduce the amount of code needed.

it allows you to ask for things that don't yet exist.

convention

opinionated

- serverside
  - [`envIntPort`](#env-resolver)
  - [`userTable`](#table-resolver)
  - [`getUserWhereId`, `deleteUserWhereId`](#data-accessor-resolver)
  - [REST](#)
- clientside
  - [`getUserWhereId`](#)
- shared
  - [alias -> name](#alias-resolver)

### env resolver

`forge.envFactoryResolver`

`env[Maybe]{String|Bool|Int|Float}{name}`

examples: 

returned factories depend on `env`

### table resolver

mesa tables have circular dependencies

returned factories depend on `table`

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
