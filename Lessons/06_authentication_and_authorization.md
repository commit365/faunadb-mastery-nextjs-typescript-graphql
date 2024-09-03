# Lesson 6: Implementing Authentication and Authorization

## Overview

In this lesson, we will focus on implementing authentication and authorization in your Next.js application using FaunaDB. Authentication verifies the identity of users, while authorization determines their access levels. We will set up user authentication using JSON Web Tokens (JWT), secure our GraphQL API with middleware, implement role-based access control (RBAC), and manage user sessions and tokens. By the end of this lesson, you will have a robust authentication and authorization system integrated into your application.

## 1. Setting Up User Authentication (Using JWT)

### Introduction to JWT

JSON Web Tokens (JWT) are a compact, URL-safe means of representing claims to be transferred between two parties. The claims in a JWT are encoded as a JSON object that is used as the payload of a JSON Web Signature (JWS) structure or as the plaintext of a JSON Web Encryption (JWE) structure, enabling the claims to be digitally signed or integrity protected with a Message Authentication Code (MAC) and/or encrypted.

### Using Auth0 for Authentication

To implement user authentication, we will use Auth0, a popular authentication and authorization platform.

#### Step 1: Create an Auth0 Account

1. Go to [Auth0](https://auth0.com) and sign up for a free account.
2. After signing up, log in to your Auth0 dashboard.

#### Step 2: Create an Application

1. In the Auth0 dashboard, navigate to the "Applications" section.
2. Click on "Create Application."
3. Choose a name for your application and select "Single Page Web Applications."
4. Click "Create."

#### Step 3: Configure Application Settings

1. In the application settings, set the following:
   - **Allowed Callback URLs**: `http://localhost:3000/api/auth/callback`
   - **Allowed Logout URLs**: `http://localhost:3000`
   - **Allowed Web Origins**: `http://localhost:3000`
2. Save the changes.

#### Step 4: Install Auth0 SDK

In your Next.js application, install the Auth0 SDK:

```bash
npm install @auth0/nextjs-auth0
```

#### Step 5: Configure Auth0 in Your Application

1. Create a new file called `auth0.js` in the `lib` directory and add the following configuration:

```javascript
// lib/auth0.js
import { initAuth0 } from '@auth0/nextjs-auth0';

export const auth0 = initAuth0({
  domain: process.env.AUTH0_DOMAIN,
  clientId: process.env.AUTH0_CLIENT_ID,
  clientSecret: process.env.AUTH0_CLIENT_SECRET,
  scope: 'openid profile',
  redirectUri: 'http://localhost:3000/api/auth/callback',
  postLogoutRedirectUri: 'http://localhost:3000',
  session: {
    cookieSecret: process.env.COOKIE_SECRET,
    cookieLifetime: 60 * 60, // 1 hour
  },
});
```

2. Add the necessary environment variables to your `.env.local` file:

```plaintext
AUTH0_DOMAIN=your-auth0-domain
AUTH0_CLIENT_ID=your-auth0-client-id
AUTH0_CLIENT_SECRET=your-auth0-client-secret
COOKIE_SECRET=your-random-cookie-secret
```

Replace the placeholders with your Auth0 credentials.

### Step 6: Create Auth0 API Routes

1. Create an API route for handling authentication in `pages/api/auth/[...auth0].js`:

```javascript
// pages/api/auth/[...auth0].js
import { auth0 } from '../../../lib/auth0';

export default auth0.handleAuth();
```

### Step 7: Protecting Pages

To protect your Next.js pages, you can use the `withPageAuthRequired` higher-order function provided by Auth0. For example, to protect a page:

```javascript
// pages/profile.js
import { withPageAuthRequired } from '@auth0/nextjs-auth0';

const Profile = ({ user }) => {
  return (
    <div>
      <h1>Welcome, {user.name}</h1>
      <p>Email: {user.email}</p>
    </div>
  );
};

export default withPageAuthRequired(Profile);
```

## 2. Securing Your GraphQL API with Middleware

To secure your GraphQL API, we will implement middleware that checks for valid JWTs in incoming requests.

### Step 1: Create Middleware for Authentication

1. Create a new file called `authMiddleware.js` in the `lib` directory:

```javascript
// lib/authMiddleware.js
import { auth0 } from './auth0';

export const withAuth = (handler) => async (req, res) => {
  try {
    await auth0.handleAuth()(req, res, async () => {
      if (!req.session || !req.session.user) {
        return res.status(401).json({ error: 'Unauthorized' });
      }
      return handler(req, res);
    });
  } catch (error) {
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};
```

### Step 2: Apply Middleware to GraphQL API

1. Update your GraphQL API route to use the authentication middleware:

```javascript
// pages/api/graphql.js
import { ApolloServer, gql } from 'apollo-server-micro';
import { withAuth } from '../../lib/authMiddleware';
import client from '../../lib/faunaClient';
import { query as q } from 'faunadb';

// Define your GraphQL schema and resolvers...

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: ({ req }) => {
    return { user: req.session.user }; // Pass user info to context
  },
});

export const config = {
  api: {
    bodyParser: false,
  },
};

export default withAuth(server.createHandler());
```

## 3. Implementing Role-Based Access Control (RBAC)

Role-Based Access Control (RBAC) allows you to define user roles and permissions within your application.

### Step 1: Define Roles in Auth0

1. In the Auth0 dashboard, navigate to "Roles" and create roles such as "admin" and "user."
2. Assign these roles to users as needed.

### Step 2: Implement Role Checks in Resolvers

1. Update your GraphQL resolvers to check user roles before executing certain operations:

```javascript
const resolvers = {
  Query: {
    getUsers: async (_, __, context) => {
      if (!context.user || !context.user.roles.includes('admin')) {
        throw new Error('Not authorized');
      }
      // Fetch users...
    },
  },
  Mutation: {
    createUser: async (_, { name, email }, context) => {
      if (!context.user || !context.user.roles.includes('admin')) {
        throw new Error('Not authorized');
      }
      // Create user...
    },
  },
};
```

## 4. Managing User Sessions and Tokens

### Step 1: Session Management

Auth0 handles session management for you, but you can customize session settings in your `auth0.js` configuration. Ensure that you set a reasonable cookie lifetime and secret.

### Step 2: Using Tokens

When a user logs in, Auth0 provides an access token. This token can be used to authenticate requests to your GraphQL API. You can extract the token from the session in your API routes:

```javascript
const token = req.session.accessToken; // Access token from session
```

### Step 3: Token Validation

When making requests to your GraphQL API, ensure that the access token is included in the Authorization header:

```javascript
const response = await fetch('/api/graphql', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({ query }),
});
```

## Conclusion

In this lesson, you have learned how to implement authentication and authorization in your Next.js application using FaunaDB and Auth0. We covered setting up user authentication with JWT, securing your GraphQL API with middleware, implementing role-based access control (RBAC), and managing user sessions and tokens. This robust authentication and authorization system is essential for protecting your application's data and ensuring that users have the appropriate access levels.

### Next Steps

In the next lesson, we will explore how to implement real-time features in your application using FaunaDB's capabilities, allowing you to build interactive and dynamic user experiences.

[Next Lesson](./07_real_time_features_with_faunadb.md)