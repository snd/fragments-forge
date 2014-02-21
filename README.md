# blaze-forge

**THOUGHT IN PROGRESS!**

blaze-forge is a resolver for hinoki containers that can autogenerate
common data accessor functions, loaders, etc.
according to some conventions
and greatly reduce the amount of code needed.

**definition: data accessor:** a function used to get or manipulate
data in the database

**definition: data specification:** an object with properties
`table`, `updateableColumns`, `insertableColumns`

? for blaze-rest also `errors`, `accessControl`

the data accessor resolver needs a way to look up data specs by name:

you can overwrite everything auto generated if you want
because the factory resolver is called before the generator resolver

### use

```coffeescript
hinoki.defaultResolver = (container, name) ->
    container.factories?[name]

newDataMethodResolver = (modelNameToDependencyName) ->

container =
    instances: {}
    factories: ...
    resolvers: [
        hinoki.defaultResolver
        blazeForge.newDataAccessorResolver (modelName) ->
        blazeForge.newDataLoaderResolver()
    ]
```

### data accessor patterns

#### condition (pattern fragment)

`Where` followed by a camelcased column name

##### examples

- whereId
- whereCreatedAt
- whereReferenceNumber

#### first

##### pattern

`first` followed by the model name followed by zero-or-more
[conditions](#condition)

##### examples

- firstUserWhereId (id)
- firstAdmin ()
- firstOrderReport ()
- firstOrderWhereIsPendingAndIsActive (isPending, isActive)

#### select

#### browse

#### insert

#### insertMany


#### update


#### updateMany

like [update](#update)

auto generate the most common dao methods according to a naming convention:
firstUserWhereId
firstAdminWhereCreatedAt
browseAdmins (filtering and pagination)
deleteAdminWhereId

#### delete

`first` followed by the model name followed by zero-or-more
[conditions](#condition)

### data loader patterns

##### first where params

##### where params

$$pageWhereIdIsParamsId

##### 

$$pagesOrderByCreatedAtDesc

##### browse

load 

- pagesByQuery

---

you can not give arguments to the factories
but through resolvers you can give some sort of arguments
through the dependency names

? scrap url boilerplate

this is heavy on conventions!!!

? make the conventions changeable
