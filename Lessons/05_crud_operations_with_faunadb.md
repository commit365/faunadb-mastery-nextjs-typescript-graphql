# Lesson 5: CRUD Operations with FaunaDB

## Overview

In this lesson, we will explore how to perform Create, Read, Update, and Delete (CRUD) operations using FaunaDB in a Next.js application. Understanding these operations is fundamental for managing data effectively in your applications. We will cover creating records (mutations), reading records (queries), updating records, deleting records, and implementing pagination and filtering. By the end of this lesson, you will be able to interact with your FaunaDB database to manage data dynamically.

## 1. Creating Records (Mutations)

### Setting Up the Mutation

To create records in FaunaDB, we will use the `Create` function from the FaunaDB query language (FQL). In our example, we will create a user record in the `users` collection.

#### API Route for Creating Users

1. **Create or Update the API Route**: If you haven't already, create an API route for handling user creation. In the `pages/api/users.js` file, add the following code:

```javascript
// pages/api/users.js
import client from '../../lib/faunaClient';
import { query as q } from 'faunadb';

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const { name, email } = req.body;

    // Input validation
    if (!name || !email) {
      return res.status(400).json({ error: 'Name and email are required.' });
    }

    try {
      const user = await client.query(
        q.Create(q.Collection('users'), { data: { name, email } })
      );
      res.status(201).json({ id: user.ref.id, ...user.data });
    } catch (error) {
      res.status(500).json({ error: 'Failed to create user: ' + error.message });
    }
  } else {
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}
```

### Explanation

- **Input Validation**: Before creating a user, we validate the input to ensure that both `name` and `email` are provided.
- **Creating a User**: The `Create` function is called with the `users` collection and the user data. If successful, the new user is returned with its ID.

## 2. Reading Records (Queries)

Reading records from FaunaDB involves querying the database to retrieve existing data. We will implement a query to fetch all users from the `users` collection.

### API Route for Fetching Users

1. **Update the API Route**: Modify the existing `pages/api/users.js` file to include a GET method for fetching users:

```javascript
if (req.method === 'GET') {
  try {
    const users = await client.query(
      q.Map(
        q.Paginate(q.Documents(q.Collection('users'))),
        q.Lambda('userRef', q.Get(q.Var('userRef')))
      )
    );

    const formattedUsers = users.data.map(user => ({
      id: user.ref.id,
      ...user.data,
    }));

    res.status(200).json(formattedUsers);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users: ' + error.message });
  }
}
```

### Explanation

- **Fetching Users**: The `Paginate` function retrieves all documents from the `users` collection, and `Map` applies the `Get` function to each document reference to return the complete user data.
- **Formatting the Response**: The response is formatted to include the user ID along with the user data.

## 3. Updating Records

To update existing records, we will use the `Update` function in FaunaDB. We will implement an API route to update a user’s information based on their ID.

### API Route for Updating Users

1. **Add Update Logic**: In the `pages/api/users.js` file, add the following code to handle PUT requests for updating users:

```javascript
if (req.method === 'PUT') {
  const { id, name, email } = req.body;

  if (!id || (!name && !email)) {
    return res.status(400).json({ error: 'ID is required and at least one field (name or email) must be provided.' });
  }

  try {
    const updatedUser = await client.query(
      q.Update(q.Ref(q.Collection('users'), id), {
        data: { name, email },
      })
    );
    res.status(200).json({ id: updatedUser.ref.id, ...updatedUser.data });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update user: ' + error.message });
  }
}
```

### Explanation

- **Input Validation**: We check that the `id` is provided and at least one of the fields (`name` or `email`) is specified for the update.
- **Updating a User**: The `Update` function is used to modify the user’s data in the `users` collection. The updated user is returned in the response.

## 4. Deleting Records

To delete records, we will use the `Delete` function. We will implement an API route to remove a user based on their ID.

### API Route for Deleting Users

1. **Add Delete Logic**: In the `pages/api/users.js` file, add the following code to handle DELETE requests:

```javascript
if (req.method === 'DELETE') {
  const { id } = req.body;

  if (!id) {
    return res.status(400).json({ error: 'ID is required.' });
  }

  try {
    await client.query(q.Delete(q.Ref(q.Collection('users'), id)));
    res.status(204).end(); // No content
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete user: ' + error.message });
  }
}
```

### Explanation

- **Input Validation**: We ensure that the `id` is provided for the user to be deleted.
- **Deleting a User**: The `Delete` function is called with the user’s reference, and a 204 No Content response is returned upon successful deletion.

## 5. Implementing Pagination and Filtering

To enhance the user experience, we will implement pagination and filtering for the `getUsers` query.

### Pagination

To paginate results, modify the GET method in `pages/api/users.js`:

```javascript
if (req.method === 'GET') {
  const { page = 1, size = 10 } = req.query; // Default to page 1 and size 10
  const from = (page - 1) * size;

  try {
    const users = await client.query(
      q.Map(
        q.Paginate(q.Documents(q.Collection('users')), { size: parseInt(size), after: from }),
        q.Lambda('userRef', q.Get(q.Var('userRef')))
      )
    );

    const formattedUsers = users.data.map(user => ({
      id: user.ref.id,
      ...user.data,
    }));

    res.status(200).json(formattedUsers);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users: ' + error.message });
  }
}
```

### Filtering

To filter users by name, you can modify the query to accept a `name` parameter:

```javascript
if (req.method === 'GET') {
  const { page = 1, size = 10, name } = req.query;
  const from = (page - 1) * size;

  try {
    const users = await client.query(
      q.Map(
        q.Paginate(
          name 
            ? q.Filter(q.Documents(q.Collection('users')), q.Lambda('userRef', q.Equals(q.Select(['data', 'name'], q.Get(q.Var('userRef'))), name)))
            : q.Documents(q.Collection('users')),
          { size: parseInt(size), after: from }
        ),
        q.Lambda('userRef', q.Get(q.Var('userRef')))
      )
    );

    const formattedUsers = users.data.map(user => ({
      id: user.ref.id,
      ...user.data,
    }));

    res.status(200).json(formattedUsers);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users: ' + error.message });
  }
}
```

### Explanation

- **Pagination**: The `Paginate` function is modified to accept `page` and `size` parameters, allowing clients to specify how many results to return and which page to fetch.
- **Filtering**: The `Filter` function is used to retrieve users based on a specified name, enhancing the API's usability.

## Conclusion

In this lesson, you learned how to perform CRUD operations with FaunaDB in a Next.js application. We covered creating, reading, updating, and deleting records, as well as implementing pagination and filtering. These operations are essential for managing data effectively in your applications.

### Next Steps

In the next lesson, we will explore how to implement authentication and authorization in your application, ensuring that only authorized users can access and manipulate data in your FaunaDB database.

[Next Lesson](./06_authentication_and_authorization.md)