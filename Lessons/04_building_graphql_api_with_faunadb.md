# Lesson 4: Building a GraphQL API with FaunaDB

## Overview

In this lesson, we will build a GraphQL API using FaunaDB as the backend database. We will set up Apollo Server to handle GraphQL requests, define the GraphQL schema (including types, queries, and mutations), implement resolvers to interact with FaunaDB, and incorporate error handling and validation. By the end of this lesson, you will have a fully functional GraphQL API that can be integrated into your Next.js application.

## 1. Setting Up Apollo Server with FaunaDB

### Installing Apollo Server

To get started, you need to install Apollo Server and the necessary dependencies. Run the following command in your Next.js project directory:

```bash
npm install apollo-server-micro graphql
```

### Creating the Apollo Server

1. **Create a New Directory for Your API**: Inside the `pages` directory, create a new folder called `api` if it doesn't already exist.

2. **Create a New File for Apollo Server**: Inside the `api` directory, create a file called `graphql.js` (or `graphql.ts` if using TypeScript).

3. **Set Up Apollo Server**: Add the following code to `graphql.js`:

```javascript
// pages/api/graphql.js
import { ApolloServer, gql } from 'apollo-server-micro';
import client from '../../lib/faunaClient';
import { query as q } from 'faunadb';

// Define your GraphQL schema
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
  }

  type Query {
    getUsers: [User!]!
  }

  type Mutation {
    createUser(name: String!, email: String!): User!
  }
`;

// Define your resolvers
const resolvers = {
  Query: {
    getUsers: async () => {
      const users = await client.query(
        q.Map(
          q.Paginate(q.Documents(q.Collection('users'))),
          q.Lambda('userRef', q.Get(q.Var('userRef')))
        )
      );
      return users.data.map(user => ({
        id: user.ref.id,
        ...user.data,
      }));
    },
  },
  Mutation: {
    createUser: async (_, { name, email }) => {
      const user = await client.query(
        q.Create(q.Collection('users'), { data: { name, email } })
      );
      return { id: user.ref.id, ...user.data };
    },
  },
};

// Create an instance of ApolloServer
const server = new ApolloServer({
  typeDefs,
  resolvers,
});

// Export the server as a microservice
export const config = {
  api: {
    bodyParser: false, // Disable body parsing for Apollo Server
  },
};

export default server.createHandler();
```

### Explanation of the Code

- **Type Definitions**: The `typeDefs` variable defines the GraphQL schema, including the `User` type, queries, and mutations.
- **Resolvers**: The `resolvers` object contains functions that implement the logic for each query and mutation. The `getUsers` query retrieves users from FaunaDB, while the `createUser` mutation adds a new user.
- **Apollo Server Instance**: The `ApolloServer` instance is created with the defined schema and resolvers, and it is exported as a microservice.

## 2. Defining the GraphQL Schema

The GraphQL schema is a crucial part of your API, defining the structure of your data and how clients can interact with it.

### Types

In our example, we defined a `User` type with the following fields:

- `id`: The unique identifier for the user.
- `name`: The name of the user.
- `email`: The email address of the user.

### Queries

We defined a single query, `getUsers`, which returns a list of users.

### Mutations

We defined a mutation, `createUser`, which allows clients to create a new user by providing a name and email.

## 3. Implementing Resolvers to Interact with FaunaDB

Resolvers are functions that handle the logic for fetching and manipulating data. In our example, we implemented resolvers for both the `getUsers` query and the `createUser` mutation.

### Fetching Users

The `getUsers` resolver uses the FaunaDB client to query the `users` collection and return the list of users. The results are mapped to include the user ID along with the user data.

### Creating Users

The `createUser` resolver accepts the user's name and email as arguments, creates a new document in the `users` collection, and returns the created user.

## 4. Error Handling and Validation in GraphQL

Error handling and validation are essential for building robust APIs. In this section, we will discuss how to implement error handling and validation in our GraphQL API.

### Error Handling

You can handle errors in your resolvers by using try-catch blocks. For example, you can modify the `createUser` resolver as follows:

```javascript
createUser: async (_, { name, email }) => {
  try {
    const user = await client.query(
      q.Create(q.Collection('users'), { data: { name, email } })
    );
    return { id: user.ref.id, ...user.data };
  } catch (error) {
    throw new Error('Failed to create user: ' + error.message);
  }
},
```

### Input Validation

You can also validate input data before processing it. For example, you can check if the `name` and `email` fields are provided:

```javascript
createUser: async (_, { name, email }) => {
  if (!name || !email) {
    throw new Error('Name and email are required.');
  }
  // Proceed with user creation...
},
```

### Returning Errors

When an error occurs, you can throw an error with a descriptive message. The client will receive the error in the response, allowing it to handle it appropriately.

## Conclusion

In this lesson, you have learned how to build a GraphQL API using FaunaDB. We covered setting up Apollo Server, defining the GraphQL schema, implementing resolvers to interact with FaunaDB, and incorporating error handling and validation. This foundation will enable you to create robust and scalable applications that leverage the power of GraphQL and FaunaDB.

### Next Steps

In the next lesson, we will explore how to connect your Next.js frontend to the GraphQL API you just built, allowing you to fetch and display data in your application.

[Next Lesson](./05_crud_operations_with_faunadb.md)