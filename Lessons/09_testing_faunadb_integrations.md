# Lesson 9: Testing FaunaDB Integrations

## Overview

Testing is a critical aspect of software development that ensures your application behaves as expected. In this lesson, we will focus on testing the integrations between your Next.js application and FaunaDB. We will cover writing unit tests for GraphQL resolvers, performing integration testing with FaunaDB, using tools like Jest and Supertest, and mocking FaunaDB for testing purposes. By the end of this lesson, you will have a comprehensive understanding of how to effectively test your FaunaDB integrations.

## 1. Writing Unit Tests for GraphQL Resolvers

Unit tests are designed to test individual components of your application in isolation. For GraphQL resolvers, this means testing the logic that handles fetching and manipulating data.

### a. Setting Up Jest for Testing

First, ensure that you have Jest installed in your project. If you haven't done so, install Jest and its dependencies:

```bash
npm install --save-dev jest @testing-library/react @testing-library/jest-dom
```

### b. Creating a Test File

Create a new directory called `__tests__` in your project root or alongside your API routes. Inside this directory, create a file called `users.test.js` (or `users.test.ts` if using TypeScript).

### c. Writing Unit Tests for Resolvers

In `users.test.js`, write tests for your GraphQL resolvers. Here's an example of how to test the `createUser` resolver:

```javascript
// __tests__/users.test.js
import { ApolloServer, gql } from 'apollo-server-micro';
import client from '../lib/faunaClient';
import { query as q } from 'faunadb';

// Define your GraphQL schema and resolvers
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
  }

  type Mutation {
    createUser(name: String!, email: String!): User!
  }
`;

const resolvers = {
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
const server = new ApolloServer({ typeDefs, resolvers });

describe('GraphQL Resolvers', () => {
  it('creates a new user', async () => {
    const CREATE_USER = gql`
      mutation {
        createUser(name: "John Doe", email: "john.doe@example.com") {
          id
          name
          email
        }
      }
    `;

    const result = await server.executeOperation({ query: CREATE_USER });
    expect(result.errors).toBeUndefined();
    expect(result.data.createUser).toHaveProperty('id');
    expect(result.data.createUser.name).toBe('John Doe');
    expect(result.data.createUser.email).toBe('john.doe@example.com');
  });
});
```

### Explanation

- **Apollo Server Instance**: We create an instance of Apollo Server using the same schema and resolvers as in your application.
- **Test Case**: The test case sends a mutation to create a new user and checks the response for errors and expected data.

## 2. Integration Testing with FaunaDB

Integration tests verify that different parts of your application work together as expected. For our purposes, this means testing the interaction between your application and FaunaDB.

### a. Setting Up Integration Tests

1. **Create a New Test File**: In the `__tests__` directory, create a file called `integration.test.js`.

2. **Writing Integration Tests**: In this file, you can write tests that interact with the FaunaDB database directly. Here’s an example of how to test fetching users:

```javascript
// __tests__/integration.test.js
import { ApolloServer, gql } from 'apollo-server-micro';
import client from '../lib/faunaClient';
import { query as q } from 'faunadb';

// Define your GraphQL schema and resolvers
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
  }

  type Query {
    getUsers: [User!]!
  }
`;

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
};

// Create an instance of ApolloServer
const server = new ApolloServer({ typeDefs, resolvers });

describe('Integration Tests', () => {
  beforeAll(async () => {
    // Setup any necessary data in FaunaDB before tests
    await client.query(
      q.Create(q.Collection('users'), { data: { name: 'Alice', email: 'alice@example.com' } })
    );
  });

  afterAll(async () => {
    // Clean up any data after tests
    const users = await client.query(q.Paginate(q.Documents(q.Collection('users'))));
    await Promise.all(users.data.map(user => client.query(q.Delete(user))));
  });

  it('fetches users', async () => {
    const GET_USERS = gql`
      query {
        getUsers {
          id
          name
          email
        }
      }
    `;

    const result = await server.executeOperation({ query: GET_USERS });
    expect(result.errors).toBeUndefined();
    expect(result.data.getUsers).toHaveLength(1);
    expect(result.data.getUsers[0].name).toBe('Alice');
  });
});
```

### Explanation

- **Setup and Teardown**: The `beforeAll` and `afterAll` hooks are used to set up initial data and clean up after tests.
- **Integration Test**: The test case fetches users and checks that the expected data is returned.

## 3. Using Tools Like Jest and Supertest

### a. Jest

Jest is a powerful testing framework that provides a rich set of features for writing unit and integration tests. It includes built-in assertions, mocking capabilities, and a user-friendly interface.

#### Key Features of Jest:

- **Snapshot Testing**: Capture the rendered output of components and compare it to a reference snapshot.
- **Mocking**: Easily mock functions and modules to isolate the code being tested.
- **Coverage Reports**: Generate code coverage reports to identify untested parts of your codebase.

### b. Supertest

Supertest is a popular library for testing HTTP servers. It allows you to send requests to your API and assert the responses.

#### Example of Using Supertest

To test your API routes, you can use Supertest in conjunction with Jest:

1. **Install Supertest**:

```bash
npm install --save-dev supertest
```

2. **Write Tests for API Routes**:

```javascript
// __tests__/api.test.js
import request from 'supertest';
import { createServer } from 'http';
import { ApolloServer } from 'apollo-server-micro';
import { typeDefs, resolvers } from '../pages/api/graphql'; // Adjust the path as necessary

const server = new ApolloServer({ typeDefs, resolvers });
const httpServer = createServer(server);

describe('API Tests', () => {
  it('creates a user', async () => {
    const response = await request(httpServer)
      .post('/api/graphql')
      .send({
        query: `
          mutation {
            createUser(name: "Bob", email: "bob@example.com") {
              id
              name
              email
            }
          }
        `,
      });
    expect(response.status).toBe(201);
    expect(response.body.data.createUser.name).toBe('Bob');
  });

  it('fetches users', async () => {
    const response = await request(httpServer)
      .post('/api/graphql')
      .send({
        query: `
          query {
            getUsers {
              id
              name
              email
            }
          }
        `,
      });
    expect(response.status).toBe(200);
    expect(response.body.data.getUsers).toBeDefined();
  });
});
```

### Explanation

- **Supertest Requests**: Supertest is used to send requests to your GraphQL API and assert the responses.
- **Testing API Endpoints**: You can test both mutations and queries to ensure your API behaves as expected.

## 4. Mocking FaunaDB for Testing

When writing tests, especially unit tests, it is often beneficial to mock external dependencies like FaunaDB. This allows you to isolate your tests and avoid making actual database calls.

### a. Using Jest Mocks

You can use Jest to create mocks for FaunaDB client methods. For example, to mock the `client.query` method:

```javascript
// __tests__/users.test.js
import client from '../lib/faunaClient';

jest.mock('../lib/faunaClient');

describe('GraphQL Resolvers', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('creates a new user', async () => {
    client.query.mockResolvedValueOnce({
      ref: { id: '123' },
      data: { name: 'John Doe', email: 'john.doe@example.com' },
    });

    const result = await server.executeOperation({ query: CREATE_USER });
    expect(result.errors).toBeUndefined();
    expect(result.data.createUser).toHaveProperty('id');
    expect(result.data.createUser.name).toBe('John Doe');
  });
});
```

### Explanation

- **Mocking Client Methods**: The `client.query` method is mocked to return a predefined response, allowing you to test your resolvers without hitting the actual database.
- **Isolation of Tests**: This approach ensures that your tests are fast and reliable, as they do not depend on the state of the database.

## Conclusion

In this lesson, you have learned how to effectively test your FaunaDB integrations in a Next.js application. We covered writing unit tests for GraphQL resolvers, performing integration testing with FaunaDB, using tools like Jest and Supertest, and mocking FaunaDB for testing purposes. Implementing a robust testing strategy is essential for maintaining the quality and reliability of your application.

### Next Steps

In the next lesson, we will explore advanced querying techniques with FaunaDB, allowing you to leverage the full power of FaunaDB's query language to retrieve and manipulate data effectively.

[Next Steps](./10_deploying_application.md)