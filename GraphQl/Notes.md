# 1. What is graphQl?

Query language - layer between DB and quries

Why we should use it?

- do not over fetch data (REST API often return more data than we need, and we have to filter it on client side, which is not efficient. Also, we have to make multiple requests to get all the data we need.)
- do not under fetch data (sometimes need extra requests)

## How it works?

mysite.com/graphql <-to this endpoint request will be sent with special syntax (specify what data we want to get from server). We can nest any data we need.

# 2. Query basics

# 3. Making a GraphQl server with Apollo

Instructions are written here https://www.apollographql.com/docs/apollo-server/getting-started

```ts
const server = new ApolloServer({
  typeDefs, // definitions of types of data
  resolvers, // resolver functions how to get data from the graph
});
```

# 4. Schema & Types

Describes how our graph will look like
Template string"

```ts
export const typeDefs = `#graphql

`;
```

# 5. Resolver functions

Describes how we want to habdle requests (queries for data)

Apollo server runs on http://localhost:4000/

Resolver function will look like:

```js
const resolvers = {
  Query: {
    games() {
      return db.games;
    },
    reviews() {
      return db.reviews;
    },
    authors() {
      return db.authors;
    },
  },
};
```

it is an object that defines function and actions they can do

Example of query is:

```js
query ExampleQuery {
  games {
    title
    platform
  }
}
```

# 6. Query variables

What if we want to just fetch single record/data?
We need to use query variables
