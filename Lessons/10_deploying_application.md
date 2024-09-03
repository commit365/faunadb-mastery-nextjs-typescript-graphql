# Lesson 10: Deploying Your Application

## Overview

In this lesson, we will cover the essential steps to deploy your Next.js application that integrates with FaunaDB. Deployment is the process of making your application available to users on the internet. We will discuss preparing your application for production, deploying it to platforms like Vercel, managing environment variables and secrets, and setting up continuous integration and deployment (CI/CD). By the end of this lesson, you will be equipped to deploy your applications effectively and maintain them in a production environment.

## 1. Preparing Your Application for Production

Before deploying your application, it’s crucial to prepare it for a production environment. This involves optimizing performance, ensuring security, and configuring necessary settings.

### a. Optimize Your Application

1. **Remove Unused Dependencies**: Audit your `package.json` file and remove any unused packages to reduce bundle size and improve performance.

2. **Environment Variables**: Ensure that all sensitive information, such as API keys and database secrets, are stored in environment variables. This prevents exposure of sensitive data in your codebase.

3. **Build Your Application**: Run the following command to create an optimized production build of your Next.js application:

   ```bash
   npm run build
   ```

   This command compiles your application and prepares it for deployment.

### b. Testing Your Application

Before deploying, thoroughly test your application to ensure it behaves as expected. Run your tests using Jest or any other testing framework you have set up:

```bash
npm test
```

Make sure all tests pass and that your application functions correctly in a production-like environment.

## 2. Deploying to Vercel or Other Cloud Platforms

Vercel is the recommended platform for deploying Next.js applications due to its seamless integration and optimized performance for Next.js projects. However, you can also deploy to other cloud platforms like AWS, DigitalOcean, or Heroku.

### a. Deploying to Vercel

1. **Sign Up for Vercel**: If you don’t have an account, go to [Vercel](https://vercel.com) and sign up for a free account.

2. **Import Your Project**:
   - Click on the "New Project" button on your Vercel dashboard.
   - Choose your Git provider (e.g., GitHub, GitLab, Bitbucket) and authorize Vercel to access your repositories.
   - Select the repository that contains your Next.js application.

3. **Configure Project Settings**:
   - Vercel will automatically detect that you are using a Next.js application. Review the settings and adjust if necessary.
   - Add any environment variables required for your application. Go to the "Environment Variables" section and input your variables, such as `FAUNADB_SECRET`.

4. **Deploy Your Application**: Click the "Deploy" button. Vercel will build and deploy your application. You will receive a unique URL where your application is hosted.

### b. Deploying to Other Cloud Platforms

If you choose to deploy to other platforms, the process may vary. Here’s a general outline for deploying to a cloud service like AWS or DigitalOcean:

1. **Set Up a Server**: Provision a server instance (e.g., EC2 on AWS, Droplet on DigitalOcean) and configure it to run Node.js applications.

2. **Clone Your Repository**: SSH into your server and clone your application repository:

   ```bash
   git clone https://github.com/yourusername/your-repo.git
   cd your-repo
   ```

3. **Install Dependencies**: Install the necessary dependencies on the server:

   ```bash
   npm install
   ```

4. **Set Environment Variables**: Configure environment variables on your server. This can typically be done in your shell profile or using a tool like `dotenv`.

5. **Run Your Application**: Start your application using a process manager like PM2 or forever to ensure it runs continuously:

   ```bash
   npm run build
   npm start
   ```

## 3. Managing Environment Variables and Secrets

Managing environment variables and secrets is critical for maintaining security in your application. Here are best practices for handling them:

### a. Using `.env` Files

1. **Create a `.env.local` File**: In your Next.js project, create a `.env.local` file to store your environment variables:

   ```plaintext
   FAUNADB_SECRET=your_faunadb_secret_key
   AUTH0_DOMAIN=your_auth0_domain
   AUTH0_CLIENT_ID=your_auth0_client_id
   AUTH0_CLIENT_SECRET=your_auth0_client_secret
   ```

2. **Accessing Environment Variables**: In your application, you can access these variables using `process.env`:

   ```javascript
   const faunaSecret = process.env.FAUNADB_SECRET;
   ```

### b. Using Vercel’s Environment Variable Management

When deploying to Vercel, you can manage environment variables directly from the Vercel dashboard:

1. **Navigate to Your Project**: Go to the project settings in Vercel.

2. **Add Environment Variables**: Under the "Environment Variables" section, add the necessary variables and their values.

3. **Deploy**: When you deploy your application, Vercel will automatically inject these environment variables into your application.

## 4. Setting Up Continuous Integration and Deployment (CI/CD)

Continuous Integration and Deployment (CI/CD) is a set of practices that enable development teams to deliver code changes more frequently and reliably. Here’s how to set up CI/CD for your Next.js application:

### a. Using GitHub Actions

1. **Create a Workflow File**: In your GitHub repository, create a directory called `.github/workflows` and add a file called `ci.yml`.

2. **Define Your Workflow**: Add the following code to `ci.yml` to define your CI/CD pipeline:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test

      - name: Build application
        run: npm run build

      - name: Deploy to Vercel
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
        run: npx vercel --prod --confirm
```

### Explanation

- **Triggers**: The workflow is triggered on every push to the `main` branch.
- **Build Steps**: The workflow checks out the code, sets up Node.js, installs dependencies, runs tests, and builds the application.
- **Deployment**: The application is deployed to Vercel using the Vercel CLI. You need to set up secrets in your GitHub repository for the Vercel token and project details.

### b. Setting Up Secrets in GitHub

1. **Navigate to Your Repository**: Go to the settings of your GitHub repository.

2. **Add Secrets**: Under the "Secrets" section, add the following secrets:
   - `VERCEL_TOKEN`: Your Vercel token for authentication.
   - `VERCEL_PROJECT_ID`: The ID of your Vercel project.
   - `VERCEL_ORG_ID`: Your Vercel organization ID.

## Conclusion

In this lesson, you have learned how to deploy your Next.js application that integrates with FaunaDB. We covered preparing your application for production, deploying it to Vercel and other cloud platforms, managing environment variables and secrets, and setting up continuous integration and deployment (CI/CD). These practices will help ensure that your applications are robust, secure, and maintainable in a production environment.

### Next Steps

In the next lesson, we will explore advanced querying techniques with FaunaDB, allowing you to leverage the full power of FaunaDB's query language to retrieve and manipulate data effectively.

[Next Lesson](./11_case_studies.md)