# Lesson 7: Real-time Features with FaunaDB

## Overview

In this lesson, we will explore the real-time capabilities of FaunaDB and how to implement them in your Next.js application. Real-time features are essential for modern applications that require instant updates and user interactions, such as chat applications, collaborative tools, and live dashboards. We will cover how to implement subscriptions in your GraphQL API, handle real-time updates in the frontend, and discuss use cases for real-time applications. By the end of this lesson, you will have a solid understanding of how to leverage FaunaDB's real-time features to enhance your applications.

## 1. Understanding Real-time Capabilities

FaunaDB provides robust real-time capabilities through its event streaming feature. This allows applications to receive updates as soon as changes occur in the database, eliminating the need for polling and ensuring that users see the most current data.

### Key Features of FaunaDB's Real-time Capabilities:

- **Event Streaming**: FaunaDB supports push-based event streaming, where clients can subscribe to changes in documents or collections. This means that when a document is updated, the client is immediately notified, allowing for instant UI updates.
- **Document and Collection Events**: Developers can subscribe to changes at both the document level (individual records) and the collection level (groups of records), providing flexibility in how data updates are handled.
- **Reduced Latency**: By using event streaming, applications can achieve lower latency in data updates, providing a smoother user experience.

## 2. Implementing Subscriptions in Your GraphQL API

To enable real-time updates in your application, we will implement GraphQL subscriptions using Apollo Server.

### Step 1: Setting Up Apollo Server for Subscriptions

1. **Install Additional Dependencies**: You will need to install the `subscriptions-transport-ws` package to handle WebSocket connections for subscriptions:

   ```bash
   npm install subscriptions-transport-ws
   ```

2. **Update Your Apollo Server Configuration**: Modify your `graphql.js` file to support subscriptions:

```javascript
// pages/api/graphql.js
import { ApolloServer, gql } from 'apollo-server-micro';
import { createServer } from 'http';
import { SubscriptionServer } from 'subscriptions-transport-ws';
import { execute, subscribe } from 'graphql';
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

  type Subscription {
    userCreated: User!
  }
`;

// Define resolvers
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
    createUser: async (_, { name, email }, { pubsub }) => {
      const user = await client.query(
        q.Create(q.Collection('users'), { data: { name, email } })
      );
      pubsub.publish('USER_CREATED', { userCreated: { id: user.ref.id, ...user.data } });
      return { id: user.ref.id, ...user.data };
    },
  },
  Subscription: {
    userCreated: {
      subscribe: (_, __, { pubsub }) => pubsub.asyncIterator('USER_CREATED'),
    },
  },
};

// Create an instance of ApolloServer
const server = new ApolloServer({
  typeDefs,
  resolvers,
});

// Create an HTTP server
const httpServer = createServer(server);

// Set up the subscription server
SubscriptionServer.create(
  {
    execute,
    subscribe,
    schema: server.schema,
  },
  {
    server: httpServer,
    path: server.graphqlPath,
  }
);

// Export the server
export const config = {
  api: {
    bodyParser: false,
  },
};

export default server.createHandler();
```

### Explanation

- **Subscription Type**: We define a `Subscription` type with a `userCreated` field that clients can subscribe to.
- **PubSub Mechanism**: We use a PubSub mechanism to publish events when a user is created. The `createUser` mutation publishes a `USER_CREATED` event with the new user data.
- **Subscription Resolver**: The `userCreated` subscription resolver allows clients to subscribe to the `USER_CREATED` event.

### Step 2: Testing Subscriptions

To test the subscriptions, you can use a GraphQL client like Apollo Client or a tool like GraphQL Playground.

1. **Create a Subscription Query**:

```graphql
subscription {
  userCreated {
    id
    name
    email
  }
}
```

2. **Create a User**: In another tab, execute the `createUser` mutation to create a new user. You should see the subscription update in real-time.

## 3. Handling Real-time Updates in the Frontend

Now that we have set up subscriptions in our GraphQL API, we will handle real-time updates in the frontend of our Next.js application.

### Step 1: Installing Apollo Client

If you haven't already installed Apollo Client, do so by running:

```bash
npm install @apollo/client graphql
```

### Step 2: Setting Up Apollo Client

1. **Create an Apollo Client Instance**: In your project, create a new file called `apolloClient.js` in the `lib` directory:

```javascript
// lib/apolloClient.js
import { ApolloClient, InMemoryCache, ApolloProvider } from '@apollo/client';
import { WebSocketLink } from '@apollo/client/link/ws';
import { split } from '@apollo/client';
import { getMainDefinition } from '@apollo/client/utilities';
import { HttpLink } from '@apollo/client';

const httpLink = new HttpLink({
  uri: 'http://localhost:3000/api/graphql',
});

const wsLink = new WebSocketLink({
  uri: `ws://localhost:3000/api/graphql`,
  options: {
    reconnect: true,
  },
});

// Using split to send data to each link
const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  wsLink,
  httpLink
);

const client = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache(),
});

export default client;
```

### Step 3: Wrapping Your Application with ApolloProvider

In your `_app.js` file, wrap your application with the `ApolloProvider` to provide the Apollo Client instance to your components:

```javascript
// pages/_app.js
import { ApolloProvider } from '@apollo/client';
import client from '../lib/apolloClient';

function MyApp({ Component, pageProps }) {
  return (
    <ApolloProvider client={client}>
      <Component {...pageProps} />
    </ApolloProvider>
  );
}

export default MyApp;
```

### Step 4: Subscribing to Real-time Updates

Now, you can subscribe to the `userCreated` event in any component. For example, create a `UserList` component that listens for new users:

```javascript
// components/UserList.js
import { useQuery, useSubscription } from '@apollo/client';
import gql from 'graphql-tag';

const GET_USERS = gql`
  query {
    getUsers {
      id
      name
      email
    }
  }
`;

const USER_CREATED_SUBSCRIPTION = gql`
  subscription {
    userCreated {
      id
      name
      email
    }
  }
`;

const UserList = () => {
  const { data, loading, error } = useQuery(GET_USERS);
  
  useSubscription(USER_CREATED_SUBSCRIPTION, {
    onSubscriptionData: ({ subscriptionData }) => {
      // Handle the new user data
      console.log('New user created:', subscriptionData.data.userCreated);
    },
  });

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;

  return (
    <ul>
      {data.getUsers.map(user => (
        <li key={user.id}>
          {user.name} - {user.email}
        </li>
      ))}
    </ul>
  );
};

export default UserList;
```

### Explanation

- **GET_USERS Query**: This query fetches the existing users from the database.
- **USER_CREATED_SUBSCRIPTION**: This subscription listens for new users being created and logs the new user data when received.
- **Updating the UI**: You can further enhance the UI to display the new user in the list when the subscription data is received.

## 4. Use Cases for Real-time Applications

Real-time features can significantly enhance the user experience in various applications. Here are some common use cases:

### 1. Collaborative Applications

Applications like Google Docs or Trello benefit from real-time updates, allowing multiple users to collaborate seamlessly. Changes made by one user are instantly reflected for all other users.

### 2. Chat Applications

Real-time messaging applications require instant updates to display new messages as they are sent. Users expect to see messages in real-time without refreshing the page.

### 3. Live Dashboards

Business intelligence dashboards that display real-time data (e.g., sales metrics, user analytics) can provide valuable insights and allow users to make informed decisions quickly.

### 4. Gaming

Real-time features are crucial in multiplayer games, where players need to see updates on game state changes, player actions, and scores instantly.

### 5. Notifications

Applications that send notifications (e.g., social media updates, alerts) can use real-time capabilities to inform users immediately when relevant events occur.

## Conclusion

In this lesson, you learned how to implement real-time features in your Next.js application using FaunaDB. We covered understanding real-time capabilities, implementing subscriptions in your GraphQL API, handling real-time updates in the frontend, and exploring use cases for real-time applications. These features will greatly enhance the interactivity and responsiveness of your applications.

### Next Steps

In the next lesson, we will explore advanced querying techniques with FaunaDB, allowing you to leverage the full power of FaunaDB's query language to retrieve and manipulate data effectively.

[Next Lesson](./08_performance_optimization.md)