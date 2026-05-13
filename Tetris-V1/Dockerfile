# Use the official Node.js 16 image as the base image
FROM node:20

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) to the container
COPY package*.json ./

# Install project dependencies
RUN npm ci

# Copy the rest of the application code to the container
COPY . .

# Build the React app
RUN npm run build

# Expose the port that the app will run on (usually 3000 by default)
EXPOSE 3000

# Create pod.js at container runtime, then start React app
CMD sh -c "echo \"REACT_APP_POD_NAME=$POD_NAME\" > .env && echo \"REACT_APP_NODE_NAME=$NODE_NAME\" >> .env && npm start"