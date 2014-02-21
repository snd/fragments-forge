# blaze-forge

**WORK IN PROGRESS**

blaze-forge is a resolver for hinoki containers that can autogenerate
common data accessor functions, loaders, etc.
according to some conventions
and greatly reduce the amount of code needed.

**definition: data accessor:** a function used to get or manipulate
data in the database

**definition: data specification:** an object with properties
`table`, `updateableColumns`, `insertableColumns`

for blaze-rest also `errors`, `accessControl` (?)

the data accessor resolver needs a way to look up data specs by name:

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

you can overwrite everything auto generated if you want
because the factory resolver is called before the generator resolver


this is heavy on conventions!!!

? make the conventions changeable

auto generate the most common dao methods according to a naming convention:
firstUserWhereId
firstAdminWhereCreatedAt
browseAdmins (filtering and pagination)
deleteAdminWhereId

Start with: First{}whereid
Insert{}
Update{}where{}...
Delete{}where{}...
First{}where{}...
Select{}where{}...Orderby{}asc|desc
Browse{} which Takes options that allow ordering, filtering, pagination and sorting

updateMany signalizes to return all
insertMany signalizes to return all

$$pageWhereIdIsParamsId

$$pagesOrderByCreatedAtDesc

$$pages

you can not give arguments to the factories
but through resolvers you can give some sort of arguments
through the dependency names

scrap url boilerplate
