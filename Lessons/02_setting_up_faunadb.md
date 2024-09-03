# Lesson 2: Setting Up Your FaunaDB Environment

## Overview

In this lesson, we will guide you through the process of setting up your FaunaDB environment. This includes creating a FaunaDB account, setting up a new database and collections, configuring access keys and security settings, and exploring the FaunaDB dashboard and query editor. By the end of this lesson, you will have a fully functional FaunaDB instance ready for use in your applications.

## 1. Creating a FaunaDB Account

To get started with FaunaDB, you first need to create an account. Follow these steps:

1. **Visit the FaunaDB Website**: Go to [FaunaDB's official website](https://fauna.com).
2. **Sign Up**: Click on the "Sign Up" button. You can register using your email address or sign in with GitHub.
3. **Verify Your Email**: After signing up, check your email for a verification link from FaunaDB. Click the link to verify your account.
4. **Log In**: Once your email is verified, log in to your FaunaDB dashboard.

## 2. Setting Up a New Database and Collections

After logging in, you will set up your first database and collections.

### Creating a Database

1. **Access the Dashboard**: Once logged in, you will be directed to the FaunaDB dashboard.
2. **Create a New Database**:
   - Click on the "Databases" tab in the left sidebar.
   - Click the "New Database" button.
   - Enter a name for your database (e.g., `my_first_database`).
   - Click "Create Database."

### Creating Collections

Collections in FaunaDB are similar to tables in traditional databases. To create collections:

1. **Navigate to the Database**: Click on your newly created database from the dashboard.
2. **Create Collections**:
   - Click on the "Collections" tab.
   - Click the "New Collection" button.
   - Enter a name for your collection (e.g., `users`).
   - Click "Create Collection."
   - Repeat the process to create additional collections as needed (e.g., `posts`, `comments`).

## 3. Configuring Access Keys and Security Settings

Access keys are essential for authenticating requests to your FaunaDB instance. Here’s how to create and configure them:

### Creating an Access Key

1. **Go to Security Settings**: In your database view, click on the "Security" tab.
2. **Create a New Key**:
   - Click the "New Key" button.
   - Enter a name for your key (e.g., `server_key`).
   - Select the role for the key. For server-side applications, select the "Server" role to grant full access.
   - Click "Save" to create the key.

### Storing the Access Key

Once the key is created, you will see a secret key displayed. **Make sure to copy this key** as it will not be shown again.

- **Environment Variables**: For security, it’s best practice to store your access key in an environment variable. You can create a `.env` file in your project directory and add the following line:
  ```plaintext
  FAUNADB_SECRET=your_secret_key_here
  ```

## 4. Exploring the FaunaDB Dashboard and Query Editor

FaunaDB provides a user-friendly dashboard that allows you to manage your databases, collections, and data easily.

### Dashboard Overview

- **Databases**: View and manage all your databases.
- **Collections**: Access and manage collections within your selected database.
- **Security**: Manage access keys and roles.
- **Indexes**: Create and manage indexes to optimize query performance.
- **Query Editor**: Execute queries directly against your database.

### Using the Query Editor

1. **Access the Query Editor**:
   - In your database view, click on the "Query" tab.
2. **Run Queries**:
   - You can write Fauna Query Language (FQL) queries or GraphQL queries directly in the editor.
   - For example, to create a new document in the `users` collection, you can run:
     ```javascript
     Create(Collection("users"), { data: { name: "John Doe", email: "john.doe@example.com" } })
     ```
3. **Execute the Query**: Click the "Run" button to execute your query. You should see the result in the output pane.

## Conclusion

In this lesson, you have successfully set up your FaunaDB environment by creating an account, setting up a new database and collections, configuring access keys, and exploring the FaunaDB dashboard and query editor. This foundational setup is crucial for the subsequent lessons, where you will learn how to interact with your FaunaDB instance programmatically.

### Next Steps

In the next lesson, we will dive into integrating FaunaDB with Next.js, where you will learn how to create a FaunaDB client and connect it to your Next.js application. This integration will allow you to leverage the power of FaunaDB in your web applications.

[Next Lesson](./03_integrating_faunadb_with_nextjs.md)